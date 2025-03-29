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