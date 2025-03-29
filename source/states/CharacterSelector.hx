package states;

import objects.CharacterSelectObject;
import json.CharacterSelectJson;
import openfl.display.BitmapData;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class CharacterSelector extends MusicBeatState {

    var charSelectBG:FlxSprite;

    var charList:Array<Dynamic> = [];
    var charListReal:Array<Dynamic> = [];

    var player:CharacterSelectObject;
    var parent:CharacterSelectObject;

    var floor:FlxSprite;
    var curtain:FlxSprite;

    var speakers:FlxSprite;

    var dipshit:FlxSprite;

    var selectorFollow2:FlxSprite;
    var selectorFollow:FlxSprite;
    var selector:FlxSprite;

    var curSelected:Int = 5;
    var max:Int = 9;

    var pages:Int = 0;
    var maxPages:Int = 0;

    var pagesStuffs:Array<Dynamic> = [];

    var pagesDesign:Array<Int> = [5,4,6,2,1,3,7,8,9];

    var temps:Dynamic = {
        menuTemps : []
    }

    var selecteds:Array<Array<Dynamic>> = [];

    var defX = 520.0;
    var defY = 150.0;
    var x:Float;
    var y:Float;

    var lockControls:Bool = false;

    var isSelect:Bool = false;

    var selectTimer:FlxTimer;

    var colorArray:Array<FlxColor> = [
        0x6AFFAD,
        0x6AFFEB,
        0x6AE1FF,
        0x6AC3FF,
        0x6A9EFF,
        0x6A85FF,
        0x6A80FF,
        0x545DD6,
        0x4644C0
    ];

    var characterGroup:FlxSpriteGroup;

    override function create() {
        super.create();
        clearArrays();

        characterGroup = new FlxSpriteGroup();

        x = defX;
        y = defY;

        FlxG.sound.playMusic(Paths.music('stayFunky'), 1);

        charSelectBG = new FlxSprite(0,-130);
        charSelectBG.loadGraphic(Paths.image("charSelect/charSelectBG"));
        charSelectBG.screenCenter(X);
        charSelectBG.antialiasing = ClientPrefs.data.antialiasing;
        add(charSelectBG);

        floor = new FlxSprite(-40, 391);
        floor.frames = Paths.getSparrowAtlas("charSelect/charSelectStage");
        floor.animation.addByPrefix("idle","stage full instance 1",24,true);
        floor.antialiasing = ClientPrefs.data.antialiasing;
        add(floor);

        reloadCharacters();
        add(characterGroup);

        curtain = new FlxSprite(-50,-10);
        curtain.loadGraphic(Paths.image("charSelect/curtains"));
        curtain.antialiasing = ClientPrefs.data.antialiasing;
        add(curtain);

        speakers = new FlxSprite();
        speakers.loadGraphic(Paths.image("charSelect/speakers"));
        speakers.antialiasing = ClientPrefs.data.antialiasing;
        add(speakers);

        updateCharList();
        updatePage();

        dipshit = new FlxSprite();
        dipshit.loadGraphic(Paths.image("charSelect/dipshitIdle"));
        dipshit.antialiasing = ClientPrefs.data.antialiasing;
        add(dipshit);

        selectorFollow2 = new FlxSprite();
        selectorFollow2.loadGraphic(Paths.image("charSelect/charSelector"));
        selectorFollow2.color = FlxColor.fromRGB(0,188,255);
        selectorFollow2.alpha = 0.5;
        add(selectorFollow2);

        selectorFollow = new FlxSprite();
        selectorFollow.loadGraphic(Paths.image("charSelect/charSelector"));
        selectorFollow.color = FlxColor.fromRGB(0,188,255);
        add(selectorFollow);

        selector = new FlxSprite();
        selector.loadGraphic(Paths.image("charSelect/charSelector"));
        selector.color = FlxColor.fromRGB(255,230,0);
        add(selector);

        updateSelected();
    }

    function clearArrays() {
        charList = [];
        charListReal = [];
    }

    function updatePage() {
        selecteds = [];
        trace(charListReal);
        trace(charList);
        for (i in 1...10) {
            var isFinded:Bool = false;
            var spr = new FlxSprite(x,y);
            spr.frames = Paths.getSparrowAtlas("charSelect/lock/lock");
            spr.animation.addByPrefix("Idle","Static",24,false);
            spr.animation.addByPrefix("Selected","Basic",24,true);
            spr.animation.addByPrefix("Unlock","Unlock",24,true);

            for (index in 0...charListReal.length) {
                if (i == charListReal[index][0]) {
                    spr.frames = Paths.getSparrowAtlas("charSelect/icons/"+charListReal[index][1]+"pixel");
                    spr.animation.addByPrefix("Idle","idle",24,false);
                    spr.animation.addByPrefix("Selected","idle",24,false);
                    spr.animation.addByPrefix("Confirm","confirm",24,false);
                    isFinded = true;
                } else {
                    spr.antialiasing = ClientPrefs.data.antialiasing;
                }
            }
            
            if (isFinded == false) {
                var newRGB:RGBPalette = new RGBPalette();
                newRGB.r = colorArray[i-1];
                newRGB.g = colorArray[i-1];
                newRGB.b = colorArray[i-1];
                var rgbShader = new RGBShaderReference(spr, newRGB);
                rgbShader.enabled = true;
            } else {
                spr.antialiasing = false;
            }

            add(spr);
            x += 85;

            if (i % 3 == 0) {
                x = defX;
                y += 95;
            }
            selecteds.push([spr,isFinded]);
        }
    }

    function getCurSelected() {
        var value:Dynamic = null;
        for (i in 0...charListReal.length) {
            if (charListReal[i][0] == curSelected) {
                value = charListReal[i];
                break;
            }
        }
        return value;
    }

    function updateSelected() {
        for (i in 0...selecteds.length) {
            var cur = selecteds[i][0];
            if (i+1 == curSelected) {
                onSelectedMenu(cur,i);
            } else {
                onUnSelectedMenu(cur,i);
            }
        }
    }

    function onUnSelectedMenu(spr:FlxSprite,id:Int) {
        if (selecteds[id][1] == false) {
        spr.scale.set(1,1);
        } else {
            spr.scale.set(2,2);
        }
        playAnimLock(spr,"Idle");
    }

    function onSelectedMenu(spr:FlxSprite,id:Int) {
        var xx = spr.x - 35;
        var yy = spr.y - 21;

        if (getCurSelected() != null) {
        FlxG.save.data.curChar = getCurSelected()[1];
        }

        if (selecteds[id][1] == false) {
            spr.scale.set(0.8,0.8);
            playAnimLock(spr,"Selected");
        } else {
            spr.scale.set(2.5,2.5);
        }
        FlxG.sound.play(Paths.sound('charSelect/CS_select'),0.5);
        FlxTween.cancelTweensOf(selector);
        FlxTween.cancelTweensOf(selectorFollow);
        FlxTween.cancelTweensOf(selectorFollow2);
        FlxTween.tween(selector, {x:xx,y:yy}, 0.15, {ease: FlxEase.circOut});
        FlxTween.tween(selectorFollow2, {x:xx,y:yy}, 0.65, {ease: FlxEase.circOut});
        FlxTween.tween(selectorFollow, {x:xx,y:yy}, 0.35, {ease: FlxEase.circOut});

        player.destroy();
        parent.destroy();
        reloadCharacters();
        
    }

    function reloadCharacters() {
        var curPlr;
        if (getCurSelected() != null) {
            curPlr = getCurSelected()[1];
        } else {
            curPlr = "bf";
        }
        player = new CharacterSelectObject(810,200,curPlr);
        player.playAnimation("SlideIn");
        characterGroup.add(player);

        player.animation.finishCallback = function(name:String) {
            if (name == "SlideIn") {
                player.playAnimation('Idle');
                lockControls = false;
            }
        }

        parent = new CharacterSelectObject(90,200,player.JSON.Parent);
        parent.playAnimation("Idle");
        characterGroup.add(parent);
    }

    function onConfirm() {
        player.playAnimation('Confirm');
        parent.playAnimation('Confirm');
        var spr = selecteds[curSelected-1][0];
        spr.animation.play("Confirm");
        FlxG.sound.play(Paths.sound('charSelect/CS_confirm'),0.5);

        isSelect = true;
        lockControls = true;    

        FlxTween.tween(FlxG.camera, {alpha:0,y: -720}, 1.5, {ease: FlxEase.circInOut});

        selectTimer = new FlxTimer().start(1.5, function(tmr:FlxTimer)
        {
            if (isSelect == true) {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
            MusicBeatState.switchState(new FreeplayState());
            }
        });
    }

    function onDeselect() {
        player.playAnimation('Deselect');
        parent.playAnimation('Deselect');
    }

    function updateCharList() {
        var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/playableCharacters/');
        trace(foldersToCheck);
		for (folder in foldersToCheck) {
			for (file in FileSystem.readDirectory(folder)) {
                trace(file);
                if (!Paths.fileExists('data/playableCharacters/'+file+'/disableSelect.txt', TEXT)) {
                    if(!charList.contains(file)) {
						charList.push(file);
                    }
                }
            }
        }

        for (i in 0...charList.length) {
            charListReal.push([pagesDesign[i],charList[i]]);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (lockControls == false) {
            if (controls.UI_RIGHT_P) {
                if (curSelected < max) {
                    curSelected += 1;
                    updateSelected();
                }
            } else if (controls.UI_LEFT_P) {
                if (curSelected > 1) {
                    curSelected -= 1;
                    updateSelected();
                }
            } else if (controls.ACCEPT) {
                if (getCurSelected() != null) {
                    onConfirm();
                } else {
                    onFailed();
                }
            }
        }
    }

    function onFailed() {
        FlxG.sound.play(Paths.sound('charSelect/CS_locked'),0.5);
        FlxG.camera.shake(0.01,0.1);
    }

    function playAnimLock(spr:FlxSprite,animName:String) {
        spr.animation.play(animName,true);
        switch (animName) {
            case "Idle" :
                spr.offset.set(0,0);
            case "Selected" :
                spr.offset.set(30,25);
            case "Unlock" :
                spr.offset.set(30,25);
        }
    }
}