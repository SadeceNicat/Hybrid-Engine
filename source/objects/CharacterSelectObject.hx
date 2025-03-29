package objects;

import haxe.Json;

import json.CharacterSelectJson;

class CharacterSelectObject extends FlxSprite {
    public var animOffsets:Map<String, Array<Dynamic>>;

    public var curAnimation:String = "idle";

    public var JSON:CharacterCreatorJSON;

    public var curCharacter:String = "bf";

    public function new(x:Float, y:Float, chName:String,?ignoreCharName:Bool = false,?curCharacterJson:CharacterCreatorJSON)
    {
        super(x,y);
        var charName:String = chName;

        curCharacter = charName;

		var file:String = 'data/playableCharacters/' + charName + "/" + charName + "-charmenu.json";

        var path = Paths.getPath(file, TEXT);

        JSON = Json.parse(File.getContent(path));
        if (ignoreCharName == true) {
            JSON = curCharacterJson;
        }
        trace(JSON);
        animOffsets = new Map<String, Array<Dynamic>>();
        trace(JSON.Sprite);

        frames = Paths.getSparrowAtlas(JSON.Sprite);

        antialiasing = ClientPrefs.data.antialiasing;

        this.x += JSON.XY[0];
        this.y += JSON.XY[1];
        
		for (i in 0...JSON.Animations.length)
		{
			var anims:Dynamic = JSON.Animations[i];
			trace(anims);
			animation.addByPrefix(anims[0], anims[1], anims[4], false);
			addOffset(anims[0], anims[2], anims[3]);
		}
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
    {
        animOffsets[name] = [x, y];
    }

    public function addOffsetX(name:String, x:Float = 0)
    {
        animOffsets[name][0] += x;
    }

    public function addOffsetY(name:String, y:Float = 0)
    {
        animOffsets[name][1] += y;
    }

    public function playAnimation(animNAME:String) {
        try {
            animation.play(animNAME,true);
            curAnimation = animNAME;
            var daOffset = animOffsets.get(animation.curAnim.name);
            if (animOffsets.exists(animation.curAnim.name))
            {
                offset.set(daOffset[0], daOffset[1]);
            }

        } catch(e:Dynamic) {
            trace(e);
        }
    }

    public function getAnimations() {
        return JSON.Animations;
    }

    public function getOffset(animationName:String) {
        return animOffsets[animationName];
    }

}