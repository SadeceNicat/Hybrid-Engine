import flixel.addons.display.FlxBackdrop;
import psychlua.LuaUtils;

import openfl.filters.ShaderFilter;
import shaders.RainShader;

import flixel.math.FlxMath;

import states.stages.objects.*;

var rainShader:RainShader;
var rainShaderStartIntensity:Float = 0;
var rainShaderEndIntensity:Float = 0;

var blackSpr:FlxSprite;

var canFlash:Bool = true;

var smoothNotes:Bool = false;
var multiSmSpeedpeed:Float = 1.2;
var randomNoteSpeed:Bool = false;

function onCreate() {
    var smoke = new FlxBackdrop(Paths.image('stages-erects/week4/mistFront'),1,0,true,false);
    smoke.velocity.set(131,0);
    smoke.y = 350;

    smoke.blend = LuaUtils.blendModeFromString("add");
    smoke.alpha = 0.5;
    add(smoke);

    blackSpr = new FlxSprite(-250,-250);
    blackSpr.makeGraphic(1800,1120,FlxColor.BLACK);
    blackSpr.scrollFactor.set();
    blackSpr.alpha = 0;
    addBehindGF(blackSpr);

    

    setupRainShader();
}
function addBackSPR() {
    var smoke2 = new FlxBackdrop(Paths.image('stages-erects/week4/mistMid'),1,0,true,false);
    smoke2.velocity.set(1531,0);
    smoke2.y = -0;
    smoke2.blend = LuaUtils.blendModeFromString("add");
    smoke2.alpha = 0.5;
    game.addBehindGF(smoke2);
}

function addCloud() {
    var smoke3 = new FlxBackdrop(Paths.image('stages-erects/week4/mistBack'),1,0,true,false);
    smoke3.velocity.set(1531,0);
    smoke3.y = -150;
    smoke3.blend = LuaUtils.blendModeFromString("add");
    smoke3.alpha = 0.5;
    game.addBehindGF(smoke3);
}

function setupRainShader()
{
    rainShader = new RainShader();
    rainShader.scale = FlxG.height / 200;


    rainShader.intensity = rainShaderStartIntensity;
    FlxG.camera.setFilters([new ShaderFilter(rainShader)]);
}

function onBeatHit() {
    if (curBeat == 63) {
        rainShaderStartIntensity = 0;
        rainShaderEndIntensity = 0.02;
    } else if (curBeat == 96) {
        rainShaderStartIntensity = 0;
        rainShaderEndIntensity = 0.06;
    } else if (curBeat == 160) {
        rainShaderStartIntensity = 0;
        rainShaderEndIntensity = 0.1;
    } else if (curBeat == 288) {
        rainShaderStartIntensity = 0.1;
        rainShaderEndIntensity = 0.2;
    }

    if (songName == "darnell-(bf-mix)") {
        if (curBeat == 304) {
            FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : FlxColor.WHITE, 1);
        }
    } else if (songName == "lit-up-(bf-mix)") {
        if (curBeat == 288) {
            FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : FlxColor.WHITE, 1);
        }
    }
}

function onUpdate(elapsed:Float) {
    if(rainShader != null)
    {    
        var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, (FlxG.sound.music != null ? FlxG.sound.music.length : 0), rainShaderStartIntensity, rainShaderEndIntensity);
        rainShader.intensity = remappedIntensityValue;
        rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
        rainShader.update(elapsed);
    }
}

function onEvent(eventName:String,eventValue1:String) {
    debugPrint(eventName);
    if (eventName == "Philly Glow" ) {
        FlxTween.cancelTweensOf(blackSpr);
        if (eventValue1 == "1") {
            FlxTween.tween(blackSpr, {alpha: 0.4}, 0.6);
        } else {
            FlxTween.tween(blackSpr, {alpha: 0}, 0.6);
        }
    }
}

var easeToUse:(t:Float)->Float = FlxEase.expoIn;
function onSpawnNote(daNote:Note):Void {
    if (songName == "darnell-(bf-mix)") {
        if (curBeat > 280) {
            smoothNotes = true;
        }
    } else if (songName == "lit-up-(bf-mix)") {
        if (curBeat >= 284) {
            smoothNotes = true;
            randomNoteSpeed = true;
        }
    } else if (songName == "darnell" && storyDifficultyText == "nightmare" || storyDifficultyText == "erect") {
        if (curBeat == 192) {
            smoothNotes = true;
        }
        if (curBeat == 256) {
            smoothNotes = false;
        }
    }
  if (smoothNotes == true) {
    if (daNote.mustPress) return;

    var duration:Float = daNote.strumTime - Conductor.songPosition - 250;
    if (game.songSpeed < 1) duration *= game.songSpeed;

    daNote.multSpeed = 0.8;
    if (randomNoteSpeed == true) {
        daNote.multSpeed = 1.2;
        mSpeed = FlxG.random.float(0.5,0.8);
    }
    daNote.extraData['MultSpeedTween'] = FlxTween.tween(daNote, {multSpeed: mSpeed}, duration * .001 / game.playbackRate, {ease: easeToUse});
    return;
  }
}