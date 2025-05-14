package states;

import psychlua.HScript;
import crowplexus.iris.Iris;
import backend.Song;
import backend.Highscore;
import options.OptionsState;
import states.modding.ModdingStuff;

class CustomState extends MusicBeatState {

    var currentState = FlxG.save.data.currentState;

    var isScriptFinded:Bool = false;
    
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
		callOnHScript("onUpdate",[elapsed]);

        if (isScriptFinded == false) {
            if (controls.BACK)
            {
                triggerEvent("ChangeState","mainmenu");
            }
        }
		callOnHScript("onUpdatePost",[elapsed]);
    }

    function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1) {
		ModdingStuff.triggerEvent(eventName,eventValue,eventValue2);
		callOnHScript("onEvent",[eventName,eventValue,eventValue2]);
	}
}