package objects;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class StarObject extends FlxSprite {
    var starType:Int = 0;
    var colorArray:Array<Array<FlxColor>> = [
        [0xFFFFFF,0x000000],
        [0xFFFFFF,0x31E0FF],
    ];
    public function new(x:Float,y:Float) {
        super(x,y);

        this.loadGraphic(Paths.image("freeplay/dot"));
    }

    public function setStarType(starType:Int) {
        this.starType = starType;
        switch (starType) {
            case 0:
                this.loadGraphic(Paths.image("freeplay/dot"));
                this.offset.set(0, 0);
            case 1:
                this.loadGraphic(Paths.image("freeplay/star"));
                var newRGB:RGBPalette = new RGBPalette();
                newRGB.g = colorArray[starType-1][0];
                newRGB.b = colorArray[starType-1][1];
                var rgbShader = new RGBShaderReference(this, newRGB);
                rgbShader.enabled = true;
                this.offset.set(23, 23);
            default:
                this.loadGraphic(Paths.image("freeplay/star"));
                var newRGB:RGBPalette = new RGBPalette();
                newRGB.g = colorArray[starType-1][0];
                newRGB.b = colorArray[starType-1][1];
                var rgbShader = new RGBShaderReference(this, newRGB);
                rgbShader.enabled = true;
                this.offset.set(23, 23);
        }
    }
}