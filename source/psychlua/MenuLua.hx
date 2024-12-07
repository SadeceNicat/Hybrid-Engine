#if LUA_ALLOWED
package psychlua;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import openfl.Lib;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxState;


#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

import cutscenes.DialogueBoxPsych;

import objects.StrumNote;
import objects.Note;
import objects.NoteSplash;
import objects.Character;

import states.MainMenuState;
import states.StoryMenuState;
import states.FreeplayState;

import substates.PauseSubState;
import substates.GameOverSubstate;

import psychlua.LuaUtils;
import psychlua.LuaUtils.LuaTweenOptions;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end
import psychlua.DebugLuaText;
import psychlua.ModchartSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import haxe.Json;

class MenuLua {
	public var lua:State = null;
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var modFolder:String = null;
	public var closed:Bool = false;

	#if HSCRIPT_ALLOWED
	public var hscript:HScript = null;
	#end

	public var callbacks:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var customFunctions:Map<String, Dynamic> = new Map<String, Dynamic>();

	public function new(scriptName:String) {
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		//LuaL.dostring(lua, CLENSE);

		this.scriptName = scriptName.trim();
		var game:PlayState = PlayState.instance;
		if(game != null) game.luaArray.push(this);

		var myFolder:Array<String> = this.scriptName.split('/');
		#if MODS_ALLOWED
		if(myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
			this.modFolder = myFolder[1];
		#end

		// Lua shit
		set('Function_StopLua', LuaUtils.Function_StopLua);
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll', LuaUtils.Function_StopAll);
		set('Function_Stop', LuaUtils.Function_Stop);
		set('Function_Continue', LuaUtils.Function_Continue);
		set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);
		set('version', MainMenuState.psychEngineVersion.trim());
		set('modFolder', this.modFolder);

		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);


		// PlayState-only variables

		// Other settings
		set('downscroll', ClientPrefs.data.downScroll);
		set('middlescroll', ClientPrefs.data.middleScroll);
		set('framerate', ClientPrefs.data.framerate);
		set('ghostTapping', ClientPrefs.data.ghostTapping);
		set('hideHud', ClientPrefs.data.hideHud);
		set('timeBarType', ClientPrefs.data.timeBarType);
		set('scoreZoom', ClientPrefs.data.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.data.camZooms);
		set('flashingLights', ClientPrefs.data.flashing);
		set('noteOffset', ClientPrefs.data.noteOffset);
		set('healthBarAlpha', ClientPrefs.data.healthBarAlpha);
		set('noResetButton', ClientPrefs.data.noReset);
		set('lowQuality', ClientPrefs.data.lowQuality);
		set('shadersEnabled', ClientPrefs.data.shaders);
		set('scriptName', scriptName);
		set('currentModDirectory', Mods.currentModDirectory);

		set('noteSkin', ClientPrefs.data.noteSkin);
		set('noteSkinPostfix', Note.getNoteSkinPostfix());
		set('splashSkin', ClientPrefs.data.splashSkin);
		set('splashSkinPostfix', NoteSplash.getSplashSkinPostfix());
		set('splashAlpha', ClientPrefs.data.splashAlpha);

		set('buildTarget', LuaUtils.getBuildTarget());

		ReflectionFunctions.implement(this);
		TextFunctions.implement(this);
		ExtraFunctions.implement(this);

		for (name => func in customFunctions)
		{
			if(func != null)
				Lua_helper.add_callback(lua, name, func);
		}

		try{
			var isString:Bool = !FileSystem.exists(scriptName);
			var result:Dynamic = null;
			if(!isString)
				result = LuaL.dofile(lua, scriptName);
			else
				result = LuaL.dostring(lua, scriptName);

			var resultStr:String = Lua.tostring(lua, result);
			if(resultStr != null && result != 0) {
				trace(resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('$scriptName\n$resultStr', true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
			if(isString) scriptName = 'unknown';
		} catch(e:Dynamic) {
			trace(e);
			return;
		}
		trace('lua file loaded succesfully:' + scriptName);

		call('onCreate', []);
	}

	//main
	public var lastCalledFunction:String = '';
	public static var lastCalledScript:FunkinLua = null;
	public function call(func:String, args:Array<Dynamic>):Dynamic {
		if(closed) return LuaUtils.Function_Continue;

		lastCalledFunction = func;
		lastCalledScript = this;
		try {
			if(lua == null) return LuaUtils.Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.LUA_TFUNCTION) {
				if (type > Lua.LUA_TNIL)
					luaTrace("ERROR (" + func + "): attempt to call a " + LuaUtils.typeToString(type) + " value", false, false, FlxColor.RED);

				Lua.pop(lua, 1);
				return LuaUtils.Function_Continue;
			}

			for (arg in args) Convert.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);

			// Checks if it's not successful, then show a error.
			if (status != Lua.LUA_OK) {
				var error:String = getErrorMessage(status);
				luaTrace("ERROR (" + func + "): " + error, false, false, FlxColor.RED);
				return LuaUtils.Function_Continue;
			}

			// If successful, pass and then return the result.
			var result:Dynamic = cast Convert.fromLua(lua, -1);
			if (result == null) result = LuaUtils.Function_Continue;

			Lua.pop(lua, 1);
			if(closed) stop();
			return result;
		}
		catch (e:Dynamic) {
			trace(e);
		}
		return LuaUtils.Function_Continue;
	}

	public function set(variable:String, data:Dynamic) {
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function stop() {
		closed = true;

		if(lua == null) {
			return;
		}
		Lua.close(lua);
		lua = null;
		#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			hscript.destroy();
			hscript = null;
		}
		#end
	}

	function oldTweenFunction(tag:String, vars:String, tweenValue:Any, duration:Float, ease:String, funcName:String)
	{
		var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
		var variables = MusicBeatState.getVariables();
		if(target != null)
		{
			if(tag != null)
			{
				var originalTag:String = tag;
				tag = LuaUtils.formatVariable('tween_$tag');
				variables.set(tag, FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: function(twn:FlxTween)
					{
						variables.remove(tag);
						if(PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
			return tag;
		}
		else luaTrace('$funcName: Couldnt find object: $vars', false, false, FlxColor.RED);
		return null;
	}

	function noteTweenFunction(tag:String, note:Int, data:Dynamic, duration:Float, ease:String)
	{
		if(PlayState.instance == null) return null;

		var strumNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
		if(strumNote == null) return null;

		if(tag != null)
		{
			var originalTag:String = tag;
			tag = LuaUtils.formatVariable('tween_$tag');
			LuaUtils.cancelTween(tag);

			var variables = MusicBeatState.getVariables();
			variables.set(tag, FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(twn:FlxTween)
				{
					variables.remove(tag);
					if(PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag]);
				}
			}));
			return tag;
		}
		else FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		return null;
	}

	public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE) {
		if(ignoreCheck || getBool('luaDebugMode')) {
			if(deprecated && !getBool('luaDeprecatedWarnings')) {
				return;
			}
			PlayState.instance.addTextToDebug(text, color);
		}
	}

	public static function getBool(variable:String) {
		if(lastCalledScript == null) return false;

		var lua:State = lastCalledScript.lua;
		if(lua == null) return false;

		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if(result == null) {
			return false;
		}
		return (result == 'true');
	}

	function findScript(scriptFile:String, ext:String = '.lua')
	{
		if(!scriptFile.endsWith(ext)) scriptFile += ext;
		var path:String = Paths.getPath(scriptFile, TEXT);
		#if MODS_ALLOWED
		if(FileSystem.exists(path))
		#else
		if(Assets.exists(path, TEXT))
		#end
		{
			return path;
		}
		#if MODS_ALLOWED
		else if(FileSystem.exists(scriptFile))
		#else
		else if(Assets.exists(scriptFile, TEXT))
		#end
		{
			return scriptFile;
		}
		return null;
	}

	public function getErrorMessage(status:Int):String {
		var v:String = Lua.tostring(lua, -1);
		Lua.pop(lua, 1);

		if (v != null) v = v.trim();
		if (v == null || v == "") {
			switch(status) {
				case Lua.LUA_ERRRUN: return "Runtime Error";
				case Lua.LUA_ERRMEM: return "Memory Allocation Error";
				case Lua.LUA_ERRERR: return "Critical Error";
			}
			return "Unknown Error";
		}

		return v;
		return null;
	}

	public function addLocalCallback(name:String, myFunction:Dynamic)
	{
		callbacks.set(name, myFunction);
		Lua_helper.add_callback(lua, name, null); //just so that it gets called
	}

	#if (MODS_ALLOWED && !flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	#end

	public function initLuaShader(name:String)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			var shaderData:Array<String> = runtimeShaders.get(name);
			if(shaderData != null && (shaderData[0] != null || shaderData[1] != null))
			{
				luaTrace('Shader $name was already initialized!');
				return true;
			}
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));

		for(mod in Mods.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if(FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
		#else
		luaTrace('This platform doesn\'t support Runtime Shaders!', false, false, FlxColor.RED);
		#end
		return false;
	}
}
#end
