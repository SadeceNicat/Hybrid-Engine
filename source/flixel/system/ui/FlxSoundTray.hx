package flixel.system.ui;

import openfl.display.Sprite;
import flixel.system.FlxAssets;

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 * Modified by ItzJiggzy, so that it looks like how base game is.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;
	var _defaultScale:Float = 0.6;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = "flixel/sounds/beep";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'flixel/sounds/beep';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

	/**This is Were your images are, you can leave imagePath empty if it just in the images folder.**/
    var imagePath = 'soundTray/';
    var volumeImages = [
        'soundTray_0',
        'soundTray_1',
        'soundTray_2',
        'soundTray_3',
        'soundTray_4',
        'soundTray_5',
        'soundTray_6',
        'soundTray_7',
        'soundTray_8',
        'soundTray_9',
        'soundTray_10'
    ];

	/**This is Were your sounds are, you can leave soundPath empty if it just in the sounds folder.**/
    var soundPath = '';
    var volumeSounds = [
        'soundtray/Volup',
        'soundtray/Voldown',
        'soundtray/VolMAX'
    ];

    var defaultStayTime = 1; // How Long you want the SoundTray to stay visible.

    ///// Don't Change any of this below unless you know what you are doing /////
    var makeTray = true;
    public function new()
    {
        super();

        // Image Checker bcs if it fails, it gives Null Object.
        for(i in 0...volumeImages.length)
        {
            if (!Paths.fileExists('images/$imagePath${volumeImages[i]}.png', IMAGE, false)) {
                makeTray = false;
                trace('images/$imagePath${volumeImages[i]}.png was not Found.');
            }
        }
        // Sound Checker.
        for(i in 0...volumeSounds.length)
        {
            if (!Paths.fileExists('sounds/$soundPath${volumeSounds[i]}.ogg', SOUND, false)) {
                trace('sounds/$soundPath${volumeSounds[i]}.ogg was not Found | Using Flixel default sound for this Specific Action.');
            }
        }
        if(makeTray) createTray();
    }

    var fill:Sprite;
    var fillImage = null;

    private function createTray():Void
    {
		fillImage = Paths.image('$imagePath${volumeImages[0]}', false);

		fill = new Sprite();
		addChild(fill);

        scaleX = _defaultScale;
        scaleY = _defaultScale;

		visible = false;
		active = false;
        y = -fillImage.height - 10; // Hides the SoundTray | this.height doesnt fully hide the tray for some reason...
        updateFill(); // Update Fill to Current Volume
    }

    var curVolume = 0;
    private function updateFill():Void
    {   
        curVolume = Math.round(FlxG.sound.volume * 10);
        var number = !silent ? curVolume : 0;

        fillImage = Paths.image('$imagePath${volumeImages[number]}', false);
        // trace('Current Volume: $number');

        fill.graphics.clear();
        fill.graphics.beginBitmapFill(fillImage.bitmap, null, false);
        fill.graphics.drawRect(0, 0, fillImage.width, fillImage.height);
        
        graphics.endFill();

		#if FLX_SAVE
		// Save sound preferences
		if (FlxG.save.isBound)
		{
			FlxG.save.data.muted = silent;
			FlxG.save.data.volume = curVolume / 10;
			FlxG.save.flush();
		}
		#end
    }
    
    var stayTime:Float = 0;
    var lerpYPos:Float = 0;
    var alphaTarget:Float = 0;
    var lowerStayTime:Bool = false;
    private override function __enterFrame(deltaTime:Float):Void
    {
        if(!makeTray) return;

		x = FlxG.stage.window.width / 2 - width/2; // Center X that SoundTray, is in __enterFrame in case people scale the windows.
        y = FlxMath.lerp(y, lerpYPos, 0.1); // Something y related that base game does
        alpha = FlxMath.lerp(alpha, alphaTarget, 0.25); // Something alpha related that base game does
		active = visible = alpha > 0;
        
        if (FlxG.keys.anyJustPressed(FlxG.sound.volumeUpKeys) || FlxG.keys.anyJustPressed(FlxG.sound.volumeDownKeys) || FlxG.keys.anyJustPressed(FlxG.sound.muteKeys)) {
            lowerStayTime = false;
            stayTime = defaultStayTime;
        }

        var sound = null;
        if (FlxG.keys.anyJustPressed(FlxG.sound.volumeUpKeys))
        {
            silent = false;
            if(curVolume == 10 && Paths.fileExists('sounds/$soundPath${volumeSounds[2]}.ogg', SOUND, false))
            {
                sound = Paths.sound('$soundPath${volumeSounds[2]}');
            }
            else
            {
                sound = Paths.fileExists('sounds/$soundPath${volumeSounds[0]}.ogg', SOUND, false) ? Paths.sound('$soundPath${volumeSounds[0]}') : FlxAssets.getSound(volumeUpSound);
            }
        }
        else if (FlxG.keys.anyJustPressed(FlxG.sound.volumeDownKeys))
        {
            silent = false;
            sound = Paths.fileExists('sounds/$soundPath${volumeSounds[1]}.ogg', SOUND, false) ? Paths.sound('$soundPath${volumeSounds[1]}') : FlxAssets.getSound(volumeDownSound);
        }
        else if (FlxG.keys.anyJustPressed(FlxG.sound.muteKeys))
        {
            silent = !silent;
        }
        if (sound != null) FlxG.sound.load(sound).play();

        var elapsed = deltaTime / 1000;
        if (FlxG.keys.anyJustReleased(FlxG.sound.volumeUpKeys) || FlxG.keys.anyJustReleased(FlxG.sound.volumeDownKeys) || FlxG.keys.anyJustReleased(FlxG.sound.muteKeys)) {
            lowerStayTime = true;
            updateFill();
        }

        if(stayTime > 0) { // When you Release Any Volume Key
            if(lowerStayTime) stayTime = Math.max(stayTime - elapsed, 0);
            alphaTarget = 1;
            lerpYPos = 10;
        } else if(y >= -height) {
            alphaTarget = 0;
            lerpYPos = -height - 10;
        }
    }

	// Useless ahh functions that need to be there to let me compile
	public function update(MS:Float):Void {}
	public function show(up:Bool = false):Void {}
	public function screenCenter():Void {}
}