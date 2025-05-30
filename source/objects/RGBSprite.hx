package objects;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class RGBSprite extends FlxSprite {

    var newRGB:RGBPalette;
    var rgbShader:RGBShaderReference;

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);

        newRGB = new RGBPalette();
        rgbShader = new RGBShaderReference(this, newRGB);
        rgbShader.enabled = true;
    }

    public function setRGBPalette(r:FlxColor,?g:Null<FlxColor> = null,b:Null<FlxColor> = null):Void {
        this.newRGB.r = r;
        if (g != null) {
            this.newRGB.g = g;
        } else {
    
        }
        if (b != null) {
            this.newRGB.b = b;
        } else {

        }
        this.updateHitbox();
    }

    public function getRGBPalette():RGBPalette {
        return this.newRGB;
    }
}