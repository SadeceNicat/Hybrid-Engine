package states.modding;
import backend.Song;
import backend.Highscore;
import options.OptionsState;

class HScriptStuffs {

	// #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
    // private var luaDebugGroup: FlxTypedGroup<psychlua.DebugLuaText>;
    // #end

	public static function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1) {
		switch (eventName) {
			case "ChangeState" :
				if (eventValue == "story_mode") {
					MusicBeatState.switchState(new StoryMenuState());
				}
				else if (eventValue == "freeplay") {
					MusicBeatState.switchState(new FreeplayState());
				}
				else if (eventValue == "credits") {
					MusicBeatState.switchState(new CreditsState());
				}
				else if (eventValue == "options") {
					MusicBeatState.switchState(new OptionsState());
				}
				else if (eventValue == "achievement") {
					MusicBeatState.switchState(new AchievementsMenuState());
				}
				else if (eventValue == "mods") {
					MusicBeatState.switchState(new ModsMenuState());
				}
				else if (eventValue == "mainmenu") {
					MusicBeatState.switchState(new MainMenuState()); 
				} else {
					FlxG.save.data.currentState = eventValue;
					MusicBeatState.switchState(new CustomState());
				}
			case "LoadSong" :
				var songLowercase:String = Paths.formatToSongPath(eventValue); var poop:String = Highscore.formatSong(songLowercase, eventValue2);
	
				try
				{
					Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false; PlayState.storyDifficulty = eventValue2;
				}

				if (FlxG.save.data.isTransition == false) { MusicBeatState.switchState(new PlayState()); } 
				else { LoadingState.loadAndSwitchState(new PlayState()); }
			default :
				trace("Null Value");
		}
	}
	
	#if funkin.vis
	public static var audioAnalyzer:funkin.vis.dsp.SpectralAnalyzer;

	public static function initAnalyzer(barCount:Int, maxDelta:Float = 0.01, peakHold:Int = 30) {
		@:privateAccess
		if (FlxG.sound.music == null || FlxG.sound.music._channel == null || FlxG.sound.music._channel.__audioSource == null) return;

		@:privateAccess
		audioAnalyzer = new funkin.vis.dsp.SpectralAnalyzer(FlxG.sound.music._channel.__audioSource, barCount, maxDelta, peakHold);

		#if desktop
		audioAnalyzer.fftN = 256;
		#end
	}

	public static function getAudioLevels() {
		var levels = audioAnalyzer.getLevels();
		return [for (i in levels) i.value];
	}
	#end
	// #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	// public function addTextToDebug(text:String, color:FlxColor) {
	// 	var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
	// 	newText.text = text;
	// 	newText.color = color;
	// 	newText.disableTime = 6;
	// 	newText.alpha = 1;
	// 	newText.setPosition(10, 8 - newText.height);

	// 	luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
	// 		spr.y += newText.height + 2;
	// 	});
	// 	luaDebugGroup.add(newText);

	// 	Sys.println(text);
	// }
	// #end
}