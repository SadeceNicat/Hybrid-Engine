package states;

import backend.FreeplayProp;
import objects.StarObject;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import crowplexus.iris.Iris;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import haxe.Json;
import json.CharacterSelectJson;
import objects.HealthIcon;
import objects.MusicPlayer;
import openfl.utils.Assets;
import options.GameplayChangersSubstate;
import psychlua.HScript;
import hybridengine.modding.GameStuffs;
import substates.ResetScoreSubState;

typedef TitleConf = {
	var StartType:String;
	var Where:String;
}

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var characterText:FlxText;
	var characterSelectUP:FlxSprite;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var isLoadedSong:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private var songDataArray:Array<FreeplayProp> = [];

	var bg:FlxSprite;
	var intendedColor:Int;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;
	var isSongLoaded:Bool = false;
	var loadedSong:String;
	
	var ignoreAddSong:Bool = false;

	var orginalSongs:Array<String> = GameStuffs.orginalSongs;

	var camAlphabet:FlxCamera;

	var toggleControls:Bool = false;

	var curChar:String = "bf";
	var charSongs:Array<String> = [];
	var charIgnoreSongs:Array<String> = [];

	var stars:Array<StarObject> = [];
	var flames:Array<FlxSprite> = [];

	var album:FlxSprite;

	var camCur:FlxCamera;
	var camOther:FlxCamera;

	function loadConf()
	{
		if(Paths.fileExists('config/title.json', TEXT))
		{
			var titleRaw:String = Paths.getTextFromFile('config/title.json');
			trace(titleRaw);
			
			if(titleRaw != null && titleRaw.length > 0)
			{
				try
				{
					var titleJSON:TitleConf = tjson.TJSON.parse(titleRaw);
					if (titleJSON.StartType == "Normal") {
						trace("Normal");
						Main.skipModsScreen = true;

						if (FlxG.save.data.menuSong == true) {
							FlxG.save.data.menuSong = false;
							LoadingState.loadAndSwitchState(new TitleState());
						}
					} else if (titleJSON.StartType == "Song") {
						var songLowercase:String = Paths.formatToSongPath(titleJSON.Where);
						var poop:String = Highscore.formatSong(songLowercase, 1);

						Song.loadFromJson(poop, songLowercase);
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = 1;
						LoadingState.prepareToSong();
						FlxG.switchState(new PlayState());
						isSongLoaded = true;
					} else {
						Main.skipModsScreen = true;
						trace("Normal Else");
						if (FlxG.save.data.menuSong == true) {
							FlxG.save.data.menuSong = false;
							LoadingState.loadAndSwitchState(new TitleState());
						}
					}

				}
				catch(e:haxe.Exception)
				{
					trace('[WARN] Title JSON might broken, ignoring issue...\n${e.details()}');
				}
			}
			else trace('[WARN] No Title JSON detected, using default values.');
		} else {
			
		}
	}

	function onLoad(obj:Dynamic,objName:String) {
		add(obj);
		callOnHScript("onLoad",[objName,obj]);
	}

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null) {
		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.executeFunction(funcToCall,args);
			}
		#end
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try { newScript = new HScript(null, file); newScript.executeFunction('onCreate'); hscriptArray.push(newScript); trace('initialized hscript interp successfully: $file'); }
		catch(e:Dynamic) { var newScript:HScript = cast (Iris.instances.get(file), HScript); if(newScript != null) {newScript.destroy();} }
	}

	function generateSong(song:Array<Dynamic>,i:Int) {
		trace(song);
		var colors:Array<Int> = song[2];
		var songAdded:Bool = false;
		if(colors == null || colors.length < 3)
		{
			colors = [146, 113, 253];
		}

		if (song[3] == null) {
			song[3] = 'bf';
		}
		
		if (song[3] == curChar) {
			songAdded = true;
		}

		for (charSong in charIgnoreSongs) {
			if (song[0] == charSong) {
				songAdded = false;
				break;
			}
		}

		if (songAdded == true) {
			var songChar:String = 'bf';
			var ignoreErect:Bool = false;
			if (song[4] != null) {
				ignoreErect = song[4];
			}
			if (song[3] != null) {
				songChar = song[3];
			}
			addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]),ignoreErect,songChar);
		}
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		Mods.loadTopMod();
		loadConf();

		curChar = FlxG.save.data.curChar;

        charSongs = CharacterSelectJson.getCharacterSongs(curChar);
		charIgnoreSongs = CharacterSelectJson.getCharIgnoreSongs(curChar);

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/states/freeplay/'))
			for (file in FileSystem.readDirectory(folder))
			{

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var ignoreLoad:Bool = false;
				if (FlxG.save.data.hideFNFSongs == true) {
					for (ignoreSong in orginalSongs) {
						trace(song[0]+ " = " + ignoreSong);
						if (song[0] == ignoreSong) {
							trace("ignored song : "+ignoreSong);
							ignoreLoad = true;
							break;
						}
					}
				}
				if (ignoreLoad == false) {
				generateSong(song,i);
				}
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();

		if (isSongLoaded == false) {
			onLoad(bg,"bg");

			callOnHScript("onBGLoaded",[bg]);

			album = new FlxSprite(950, 300).loadGraphic(Paths.image('freeplay/albumRoll/placeholder'));
			album.antialiasing = ClientPrefs.data.antialiasing;
			album.scrollFactor.set();
			album.angle = 15;
			onLoad(album,"album");

			for (i in 0...10) {
				var star:StarObject = new StarObject((i * 25) + 1000, (i * 6) + 250);
				star.antialiasing = ClientPrefs.data.antialiasing;
				star.scale.set(0.7,0.7);
				star.scrollFactor.set();
				if (i < 4) {
					star.setStarType(1);
				}
				stars.push(star);
				onLoad(star,"stars");
			}
		
			
			onLoad(grpSongs,"grpSongs");

			callOnHScript("onSongsLoaded",[grpSongs]);
		}

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;

			grpSongs.add(songText);
			songText.scaleX = Math.min(0.85, 950 / songText.width);
			songText.scaleY = songText.scaleX;
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.scale.set(0.85,0.85);

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			if (isSongLoaded == false) {
			onLoad(icon,"icon");
			}

			// şarkının ismindeki boşlukları - ile değiştiriyoruz
			var sMData:FreeplayProp = new FreeplayProp(songs[i].songName.toLowerCase().replace(" ", "-"));
			songDataArray.push(sMData);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.y += 40;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		characterSelectUP = new FlxSprite(0, 0).makeGraphic(FlxG.width, 40, 0xFF000000);
		characterSelectUP.alpha = 0.6;
		if (isSongLoaded == false) {
		onLoad(characterSelectUP,"characterSelectUP");
		}

		var characterText = new FlxText(0, 10, FlxG.width, "Press [ TAB ] to change characters", 20);
		characterText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		characterText.borderSize = 1.25;
		if (isSongLoaded == false) {
		onLoad(characterText,"characterText");
		}

		scoreBG = new FlxSprite(scoreText.x - 6, 40).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		if (isSongLoaded == false) {
		onLoad(scoreBG,"scoreBG");
		}

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		if (isSongLoaded == false) {
		onLoad(diffText,"diffText");
		}

		if (isSongLoaded == false) {
		onLoad(scoreText,"scoreText");
		}


		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		if (isSongLoaded == false) {
		onLoad(missingTextBG,"missingTextBG");
		}
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		if (isSongLoaded == false) {
		onLoad(missingText,"missingText");
		}

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = FlxColor.fromRGB(95,192,255);
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		if (isSongLoaded == false) {
		onLoad(bottomBG,"bottomBG");
		}

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		if (isSongLoaded == false) {
		onLoad(bottomText,"bottomText");
		}
		
		player = new MusicPlayer(this);
		if (isSongLoaded == false) {
		onLoad(player,"player");
		}

		
		changeSelection();
		updateTexts();
		super.create();

		callOnHScript("onCreatePost",[]);
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int,?ignoreErect:Bool = false,?character:String = "bf")
	{
		callOnHScript("onAddedNewSong",[songName, weekNum, songCharacter, color]);

		if (ignoreAddSong == false) {
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, ignoreErect, character));
		}

		callOnHScript("onAddedNewSongPost",[songName, weekNum, songCharacter, color]);
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;

	override function beatHit() {
		super.beatHit();

		bopAlbum();
		
		callOnHScript("onBeatHit",[]);
	}

	override function update(elapsed:Float)
	{
		callOnHScript("onUpdate",[elapsed]);
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (toggleControls == false) {
			if (FlxG.keys.justPressed.TAB) {
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.play(Paths.sound('charSelect/CS_confirm'), 0.5);
				toggleControls = true;

				new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new CharacterSelector());
				});

				FlxTween.tween(FlxG.camera, {alpha:0,y: -720}, 1.5, {ease: FlxEase.circInOut});
			}
		}

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!player.playingMusic)
		{
			scoreText.text = Language.getPhrase('personal_best', 'PERSONAL BEST: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
			positionHighscore();
			
			if (toggleControls == false) {
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}

			if (controls.UI_LEFT_P)
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
			else if (controls.UI_RIGHT_P)
			{
				changeDiff(1);
				_updateSongLastDifficulty();
			}
			}
		}

		if (controls.BACK)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}
		
		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
		stopMusicPlay = true;

		destroyFreeplayVocals();

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected && !player.playingMusic)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound();
					try
					{
						var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
						if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							vocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(vocals);
							vocals.persist = vocals.looped = true;
							vocals.volume = 0.8;
							vocals.play();
							vocals.pause();
						}
						else vocals = FlxDestroyUtil.destroy(vocals);
					}
					catch(e:Dynamic)
					{
						vocals = FlxDestroyUtil.destroy(vocals);
					}
					
					opponentVocals = new FlxSound();
					try
					{
						//trace('please work...');
						var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							opponentVocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(opponentVocals);
							opponentVocals.persist = opponentVocals.looped = true;
							opponentVocals.volume = 0.8;
							opponentVocals.play();
							opponentVocals.pause();
						}
						else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
					catch(e:Dynamic)
					{
						opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				FlxG.sound.music.pause();
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
				player.pauseOrResume(true);
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(!player.playing);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic)
			{
				// MusicBeatState.coolerTransition = true;
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
	
				try
				{
					Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
	
					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				}
				catch(e:haxe.Exception)
				{
					trace('ERROR! ${e.message}');
	
					var errorStr:String = e.message;
					if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
					else errorStr += '\n\n' + e.stack;
	
					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
	
					updateTexts(elapsed);
					super.update(elapsed);
					return;
				}
	
				LoadingState.prepareToSong();
				if (FlxG.save.data.isTransition == false) {
					MusicBeatState.switchState(new PlayState());
				} else {
					LoadingState.loadAndSwitchState(new PlayState());
				}
				#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				stopMusicPlay = true;
	
				destroyFreeplayVocals();
				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			}
		else if(controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);

		callOnHScript("onUpdatePost",[elapsed]);
	}
	
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		if (songs[curSelected].ignoreErect == true) {
			if (lastDifficultyName == "erect" || lastDifficultyName == "nightmare") {
				curDifficulty = 0;
			}
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var displayDiff:String = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + displayDiff.toUpperCase() + ' >';
		else
			diffText.text = displayDiff.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;

		callOnHScript("onChangeDifficulty",[curDifficulty]);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}

		for (num => item in grpSongs.members)
		{
			var icon:HealthIcon = iconArray[num];
			var targetAlpha:Float = curSelected == num ? 1 : 0.7 - Math.abs(num - curSelected) * 0.15;
			var targetScale:Float = curSelected == num ? 0.85 : 0.85 - Math.abs(num - curSelected) * 0.15;
			FlxTween.cancelTweensOf(item);
			FlxTween.cancelTweensOf(icon);
			FlxTween.tween(item, { alpha: targetAlpha }, 0.5, { ease: FlxEase.quadOut }).start(); FlxTween.tween(icon, { alpha: targetAlpha }, 0.4, { ease: FlxEase.quadOut }).start();

			if (item.alpha < 0.3) {
				item.active = false; icon.active = false;
			} else {
				item.active = true; icon.active = true;
			}
			
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();

		callOnHScript("onSongChange",[curSelected]);
	}

	public function changeDifficultyStar(difficultyNumber:Int) {
		if (difficultyNumber > stars.length) {
			for (i in 0...stars.length) {
				if (i <= (difficultyNumber-stars.length)) {
					stars[i].setStarType(2);
				} else {
					stars[i].setStarType(1);
				}
			}
		} else {
			for (i in 0...stars.length) {
				if (i <= (difficultyNumber-1)) {
					stars[i].setStarType(1);
				} else {
					stars[i].setStarType(0);
				}
			}
		}
	}

	public function bopAlbum() {
		FlxTween.cancelTweensOf(album);
		album.scale.set(1.1,1.1);
		FlxTween.tween(album.scale, { x: 1, y: 1 }, 0.3, { ease: FlxEase.circOut });
		bopStars();
	}

	public function bopStars() {
		var iBop:Int = 0;
		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			FlxTween.cancelTweensOf(stars[iBop]);
			stars[iBop].scale.set(1,1);
			FlxTween.tween(stars[iBop].scale, { x: 0.8, y: 0.8 }, 0.3, { ease: FlxEase.circOut });
			iBop++;
		}, stars.length);
	}

	inline private function _updateSongLastDifficulty() {
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

		var songdata:Null<FreeplayProp>;
		songdata = songDataArray[curSelected];
		album.loadGraphic(Paths.image('freeplay/albumRoll/placeholder'));
		changeDifficultyStar(0);

		bopAlbum();

		if (songdata != null) {
			if (lastDifficultyName.toLowerCase() == "erect" || lastDifficultyName.toLowerCase() == "nightmare") {
				var albumName:String = songdata.songMetadataErect.album;

				if (albumName != null) {
					album.loadGraphic(Paths.image('freeplay/albumRoll/' + albumName));
				} else {
					album.loadGraphic(Paths.image('freeplay/albumRoll/placeholder'));
				}
			} else {
				var albumName:String = songdata.songMetadata.album;

				if (albumName != null) {
					album.loadGraphic(Paths.image('freeplay/albumRoll/' + albumName));
				} else {
					album.loadGraphic(Paths.image('freeplay/albumRoll/placeholder'));
				}
			}

			if (lastDifficultyName.toLowerCase() == "erect" || lastDifficultyName.toLowerCase() == "nightmare") {
					if (songdata.ratingsErect[lastDifficultyName.toLowerCase()] != null) {
						changeDifficultyStar(songdata.ratingsErect[lastDifficultyName.toLowerCase()]);
					} else {
						changeDifficultyStar(0);
					}
			} else {
				if (songdata.ratings[lastDifficultyName.toLowerCase()] != null) {
				changeDifficultyStar(songdata.ratings[lastDifficultyName.toLowerCase()]);
				} else {
					changeDifficultyStar(0);
				}
			}
		} else {
			album.loadGraphic(Paths.image('freeplay/albumRoll/placeholder'));
		}
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.05 * item.distancePerItem.y) + item.startPosition.y;
			if (FlxG.save.data.freeplayCenter == true) {
				item.screenCenter(X);
			}

			var icon:HealthIcon = iconArray[i];
			if (FlxG.save.data.freeplayIcon == true) {
			icon.visible = icon.active = true;
			}
			_lastVisibles.push(i);
		}
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;
	public var ignoreErect:Bool = false;
	public var character:String = "bf";

	public function new(song:String, week:Int, songCharacter:String, color:Int,?ignoreErect:Bool = false,?character:String = "bf")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		this.ignoreErect = ignoreErect;
		this.character = character;
		if(this.folder == null) this.folder = '';
	}
}