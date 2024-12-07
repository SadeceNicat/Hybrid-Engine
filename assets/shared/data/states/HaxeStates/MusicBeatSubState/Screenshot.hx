import flixel.FlxBasic; // Thanks for the script Stryke
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.events.MouseEvent;
import openfl.display.Sprite;
import openfl.display.Bitmap;

import Date;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import Sys;

//ALL RIGHTS TO FUNKIN TEAM!!

enum FileWriteMode
{
  /**
   * Forcibly overwrite the file if it already exists.
   */
  Force;

  /**
   * Ask the user if they want to overwrite the file if it already exists.
   */
  Ask;

  /**
   * Skip the file if it already exists.
   */
  Skip;
}

final SCREENSHOT_FOLDER = 'screenshots';

var _hotkeys:Array<FlxKey>;
var _region:Null<Rectangle>;
var _shouldHideMouse:Bool;
var _flashColor:Null<FlxColor>;
var _fancyPreview:Bool;

function capture():Void
{
    var captureRegion = _region != null ? _region : new Rectangle(0, 0, FlxG.stage.stageWidth, FlxG.stage.stageHeight);
  
    var wasMouseHidden = false;
    var bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));
    _fancyPreview = true;
   
    saveScreenshot(bitmap);
  
    showCaptureFeedback();
    if (_fancyPreview)
    {
        showFancyPreview(bitmap);
    }
}
  
final CAMERA_FLASH_DURATION = 0.25;

function showCaptureFeedback():Void
{
    var flashBitmap = new Bitmap(new BitmapData(Std.int(FlxG.stage.width), Std.int(FlxG.stage.height), false, 0xFFFFFFFF));
    var flashSpr = new Sprite();
    flashSpr.addChild(flashBitmap);
    FlxG.stage.addChild(flashSpr);
    FlxTween.tween(flashSpr, {alpha: 0}, 0.15, {ease: FlxEase.quadOut, onComplete: _ -> FlxG.stage.removeChild(flashSpr)});
    
    // Play a sound (auto-play is true).
    FlxG.sound.play(Paths.sound('screenshot'), 1.0);
}

final PREVIEW_INITIAL_DELAY = 0.25; // How long before the preview starts fading in.
final PREVIEW_FADE_IN_DURATION = 0.3; // How long the preview takes to fade in.
final PREVIEW_FADE_OUT_DELAY = 1.25; // How long the preview stays on screen.
final PREVIEW_FADE_OUT_DURATION = 0.3; // How long the preview takes to fade out.

function showFancyPreview(bitmap:Bitmap):Void
{
    var changingAlpha:Bool = false;
  
    var onHover = function(e:MouseEvent) {
        if (!changingAlpha) e.target.alpha = 0.6;
    };
  
    var onHoverOut = function(e:MouseEvent) {
        if (!changingAlpha) e.target.alpha = 1;
    }

    var scale:Float = 1;
    var w:Int = Std.int(bitmap.bitmapData.width * scale);
    var h:Int = Std.int(bitmap.bitmapData.height * scale);
  
    var preview:BitmapData = new BitmapData(w, h, true);
    var matrix:openfl.geom.Matrix = new openfl.geom.Matrix();
    //matrix.scale(scale, scale);

    preview.draw(bitmap.bitmapData, matrix);
  
    // used for movement + button stuff
    var previewSprite = new Sprite();
  
    previewSprite.buttonMode = true;
    previewSprite.addEventListener('mouseDown', openScreenshotsFolder);
    previewSprite.addEventListener('mouseOver', onHover);
    previewSprite.addEventListener('mouseOut', onHoverOut);
    
    FlxG.stage.addChild(previewSprite);
  
    previewSprite.alpha = 0.0;
    
    var previewBitmap = new Bitmap(preview);
    previewSprite.addChild(previewBitmap);

    FlxTween.tween(previewSprite, {scaleX: .25, scaleY: .25}, .85, {ease: FlxEase.quartOut});
    previewSprite.x += 20;
    previewSprite.y -= 10;
    FlxG.mouse.visible = true;
    new FlxTimer().start(PREVIEW_INITIAL_DELAY, function(_)
    {
        changingAlpha = true;
        FlxTween.tween(previewSprite, {alpha: 1.0, y: 10}, PREVIEW_FADE_IN_DURATION,
        {
            ease: FlxEase.quartOut,
            onComplete: function(_) {
                changingAlpha = false;
                new FlxTimer().start(PREVIEW_FADE_OUT_DELAY, function(_)
                {
                    changingAlpha = true;
                    
                    FlxTween.tween(previewSprite, {alpha: 0.0, x: -50}, PREVIEW_FADE_OUT_DURATION,
                    {
                        ease: FlxEase.quartInOut,
                        onComplete: function(_) 
                        {
  
                            previewSprite.removeEventListener('mouseDown', openScreenshotsFolder);
                            previewSprite.removeEventListener('mouseOver', onHover);
                            previewSprite.removeEventListener('mouseOut', onHoverOut);
  
                            FlxG.stage.removeChild(previewSprite);
                            FlxG.mouse.visible = false;
                        }
                    });
                });
            }
        });
    });
}

function openScreenshotsFolder() {
    openFolder(SCREENSHOT_FOLDER);
}

function generateTimestamp(?date:Date = null):String
{
    if (date == null) date = Date.now();
  
    return 'DATE TAKEN -' +date.getFullYear() + '-' + Std.string(date.getMonth() + 1) + '-' + Std.string(date.getDate()) + '- TIME TAKEN -' + Std.string(date.getHours()) + '-' + Std.string(date.getMinutes()) + '-' + Std.string(date.getSeconds());
}

function getScreenshotPath():String
{
    return SCREENSHOT_FOLDER + '/screenshot-' + generateTimestamp(Date.now()) + '.png';
}
  
function makeScreenshotPath():Void
{
    createDirIfNotExists(SCREENSHOT_FOLDER);
}

function encodePNG(bitmap:Bitmap):ByteArray
{
    return bitmap.bitmapData.encode(bitmap.bitmapData.rect, new PNGEncoderOptions());
}

function saveScreenshot(bitmap:Bitmap)
{
    makeScreenshotPath();
    var targetPath:String = getScreenshotPath();
  
    var pngData = encodePNG(bitmap);
  
    if (pngData == null)
    {
        debugPrint('[WARN] Failed to encode PNG data.');
        return;
    }
    else
    {
        //debugPrint('Saving screenshot to: ' + targetPath);
        writeBytesToPath(targetPath, pngData, FileWriteMode.Force);
    }
}

function createDirIfNotExists(dir:String):Void
{
    if(!doesFileExist(dir))
    {
        FileSystem.createDirectory(dir);
    }
}

function openFolder(pathFolder:String)
{
    Sys.command('explorer', [pathFolder]);
}

function writeBytesToPath(path:String, data:Bytes, mode:FileWriteMode = Skip):Void
{
    createDirIfNotExists(Path.directory(path));
    File.saveBytes(path, data);
}

function doesFileExist(path:String):Void
{
    return FileSystem.exists(path);
}

function onUpdatePost()
{
    if(Std.string(FlxG.keys.firstJustPressed()) == '114') capture();
}