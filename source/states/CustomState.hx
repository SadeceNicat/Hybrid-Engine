package states;

import psychlua.HScript;
import crowplexus.iris.Iris;
import backend.Song;
import backend.Highscore;
import options.OptionsState;

class CustomState extends MusicBeatState {

    var currentState = FlxG.save.data.currentState;

    var isScriptFinded:Bool = false;
    
	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
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
		try
		{
			newScript = new HScript(null, file);
			newScript.executeFunction('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:Dynamic)
		{
			addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {

	}
	#end

    override function create() {
        super.create();

        if (currentState == null) {
            currentState = "ErrorState";
        }

        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/states/HaxeStates/'+currentState+'/'))
			for (file in FileSystem.readDirectory(folder))
			{

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
                    isScriptFinded = true;
				#end
			}
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (isScriptFinded == false) {
            if (controls.BACK)
            {
                triggerEvent("ChangeState","mainmenu");
            }
        }
    }

    function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1) {
		switch (eventName) {
			case "ChangeState" :
				if (eventValue == "storymode") {
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
                } else if (eventValue == "mainmenu") {
                    MusicBeatState.switchState(new MainMenuState());
				} else {
					FlxG.save.data.currentState = eventValue;
					MusicBeatState.switchState(new CustomState());
				}
			case "LoadSong" :
				var songLowercase:String = Paths.formatToSongPath(eventValue);
				var poop:String = Highscore.formatSong(songLowercase, eventValue2);
	
				try
				{
					Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = eventValue2;
				}

				if (FlxG.save.data.isTransition == false) {
					MusicBeatState.switchState(new PlayState());
				} else {
                    LoadingState.loadAndSwitchState(new PlayState());
				}
			default :
				trace("Null Value");
		}
	}
}