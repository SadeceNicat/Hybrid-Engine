package states;

import psychlua.FunkinLua;
import crowplexus.iris.Iris;
import debug.FPSCounter;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import options.OptionsState;
import psychlua.HScript;
import states.editors.MasterEditorMenu;
import states.modding.ModdingStuff;

class MainMenuState extends MusicBeatState {
    // Configuration
    public static var hybridEngineVersion: String = '0.11';
    public var menuSprites: Map<String, FlxSprite> = new Map<String, FlxSprite>();

    var optionShit: Array<String> = [
        'story_mode', 'freeplay',
        #if MODS_ALLOWED 'mods', #end #if ACHIEVEMENTS_ALLOWED 'achievements', #end
        'credits', 'options'
    ];

    var allowMouse: Bool = true;
    var disableCreateMenu: Bool = false;
    var clearMenu: Bool = false;
    var menuX: Float = 140;
    var lockControls: Bool = false;
	var cancelLoad: Bool = false;
    var disableKeyboard: Bool = false;

    var hybridEngineMenu: Bool = false; var disableLeftRightMenu: Bool = true; // To prevent old mods from crashing

    // HScript
    #if HSCRIPT_ALLOWED
    public var hscriptArray: Array<HScript> = [];
    #end

    // FlxSprites
    var bg: FlxSprite;
    var camFollow: FlxObject;

    // FlxTexts
    var hybridVer: FlxText;
    var fnfVer: FlxText;

	var menuItemsBack: FlxTypedGroup<FlxSprite>;
    var menuItems: FlxTypedGroup<FlxSprite>;

    // Current selected item in menu
    public static var curSelected: Int = 0; public static var oldSelected: Int = 0;
    var option: String;

	#if LUA_ALLOWED 
    public var luaArray:Array<FunkinLua> = [];

    public function callOnLua(funcToCall: String, args: Array<Dynamic> = null) { 
        for (script in luaArray) { if (script != null) { script.call(funcToCall, args); } } 
    }
    
    public function initLua(file: String) {
        try { var newScript: FunkinLua = new FunkinLua(file); trace('Initialized Lua interpreter successfully: $file'); luaArray.push(newScript);
        } catch (e: Dynamic) { trace('ERROR ON LOADING ($file) - $e'); }
    }
    
    #end

    // HScript Methods
    #if HSCRIPT_ALLOWED
    public function callOnHScript(funcToCall: String, args: Array<Dynamic> = null) { 
        for (script in hscriptArray) { if (script != null) { script.executeFunction(funcToCall, args); } } 
    }

    public function initHScript(file: String) {
        try { var newScript: HScript = new HScript(null, file); newScript.executeFunction('onCreate'); trace('Initialized HScript interpreter successfully: $file'); hscriptArray.push(newScript);
        } catch (e: Dynamic) { trace('ERROR ON LOADING ($file) - $e'); var newScript: HScript = cast(Iris.instances.get(file), HScript); if (newScript != null) { newScript.destroy(); } }
    }
    #end

    function loadScripts() {
        for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/states/HaxeStates/MainMenu/'))
            for (file in FileSystem.readDirectory(folder)) {
                #if HSCRIPT_ALLOWED if (file.toLowerCase().endsWith('.hx')) { initHScript(folder + file); } #end 
                #if LUA_ALLOWED if (file.toLowerCase().endsWith('.lua')) { initLua(folder + file); } #end 
            }
    }

	function onLoad(obj:Dynamic,objName:String) { add(obj); variables.set(objName, obj); callOnHScript("onLoad",[objName,obj]); callOnLua("onLoad",[objName]); }
	
    // UI Methods
    override function create() {
        super.create();
        #if MODS_ALLOWED Mods.pushGlobalMods(); #end Mods.loadTopMod();
        #if DISCORD_ALLOWED DiscordClient.changePresence("In the Menus", null); #end FPSCounter.showFPS();

        reloadGroups(); loadScripts();

        camFollow = new FlxObject(0, 0, 1, 1);
        onLoad(camFollow, "camFollow");

		createVisuals(); generateItems(); scrollMenu(0,false,true);

		onLoad(menuItemsBack,"menuItemsBack");
		onLoad(menuItems,"menuItems");
        FlxG.mouse.visible = true;

        callOnHScript("onCreatePost", []);
    }

	function createVisuals() {
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll); bg.setGraphicSize(Std.int(bg.width * 1.175)); bg.updateHitbox(); bg.screenCenter(); bg.antialiasing = ClientPrefs.data.antialiasing; onLoad(bg,"bg");

		var hybridVer = new FlxText(12, FlxG.height - 44, 0, "Hybrid Engine v" + hybridEngineVersion, 12);
		hybridVer.scrollFactor.set(); hybridVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); onLoad(hybridVer,"hybridVer");
		var fnfVer = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set(); fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); onLoad(fnfVer,"fnfVer");
	}

    function reloadGroups() { menuItems = new FlxTypedGroup<FlxSprite>(); menuItemsBack = new FlxTypedGroup<FlxSprite>(); }

    function createMenuItem(name: String, x: Float, y: Float): FlxSprite {
        var menuItem: FlxSprite = new FlxSprite(x, y);
        menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
        menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
        menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
        menuItem.animation.play('idle');
        menuItem.antialiasing = ClientPrefs.data.antialiasing;
        menuItem.updateHitbox();
        menuItems.add(menuItem);
        
        callOnHScript("onCreateMenuItem", [menuItem]); return menuItem;
    }

    function generateItems() {
        for (num => option in optionShit) {
            if (!disableCreateMenu) {
                var scr: Float = (optionShit.length - 4) * 0.135;
                var item: FlxSprite = createMenuItem(option, 0, (num * menuX) + 90);
                item.y += (4 - optionShit.length) * 70; // Offsets for when you have more than 4 items
                item.screenCenter(X);
                if (optionShit.length < 6) scr = 0;
                item.scrollFactor.set(0, scr);

                callOnHScript("onCreateMenuItems", [num, item]);
            } else { callOnHScript("onCreateMenuItems", [num, null]); }
        }
    }

    override function update(elapsed: Float) {
        super.update(elapsed);
        callOnHScript("onUpdate", [elapsed]);

        if (!lockControls) {
            if (controls.UI_UP_P && disableKeyboard == false) { scrollMenu(-1); } else if (controls.UI_DOWN_P && disableKeyboard == false) { scrollMenu(1); }
            if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse)) { onAccept(); }
            if (controls.BACK && disableKeyboard == false) { MusicBeatState.switchState(new TitleState()); }
			if (controls.justPressed('debug_1')) { FlxG.mouse.visible = false; lockControls = true; MusicBeatState.switchState(new MasterEditorMenu()); }

            if (FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0 && allowMouse) {
                for (i in 0...optionShit.length) { var memb:FlxSprite = menuItems.members[i]; if(FlxG.mouse.overlaps(memb)) { scrollMenu(i,true); } }
            }
        }

        if (!clearMenu) FlxG.camera.follow(camFollow, null, 0.15);

        callOnHScript("onUpdatePost", [elapsed]);
    }

	function triggerEvent(eventName:String,eventValue:Dynamic = 1,eventValue2:Dynamic = 1) { ModdingStuff.triggerEvent(eventName,eventValue,eventValue2); }

    function onAccept() {
        var item: FlxSprite = menuItems.members[curSelected];
        lockControls = true;
        FlxG.sound.play(Paths.sound('confirmMenu'));

        // Fade out other menu items
        for (memb in menuItems) {
            if (memb != item) { FlxTween.tween(memb, { alpha: 0 }, 0.4, { ease: FlxEase.quadOut }); } 
        }

        // Flicker selected item and change state
        FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick: FlxFlicker) {
			callOnHScript("onStart",[option]);
			if (!cancelLoad) {
				switch (option) {
					default:
						ModdingStuff.triggerEvent("ChangeState", option);
				}
			} else { }
        });

		callOnHScript("onSelected",[option,item]);
    }

    function scrollMenu(?change: Int = 0,?setValue:Bool = false,?ignoreOldSelected:Bool = false) {
        if (ignoreOldSelected == false) {
        oldSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);
        } else { oldSelected = 105; }
        if (setValue == false) { curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1); } else { curSelected = FlxMath.wrap(change, 0, optionShit.length - 1); }
        if (curSelected != oldSelected) {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        option = optionShit[curSelected];

        // Reset animations and center offsets
        for (item in menuItems) { item.animation.play('idle'); item.centerOffsets(); callOnHScript("onUnHoversMenuItem", [item]); }

        var selectedItem: FlxSprite = menuItems.members[curSelected];
        selectedItem.animation.play('selected'); selectedItem.centerOffsets();
        camFollow.y = selectedItem.getGraphicMidpoint().y;
        callOnHScript("onSelectedMenuItem", [selectedItem]);
        }
    }
}