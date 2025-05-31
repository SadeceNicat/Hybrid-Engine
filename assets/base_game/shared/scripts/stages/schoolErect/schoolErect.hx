import objects.Character;
import psychlua.LuaUtils;
import managers.CharacterManager;

var len = [
    ["boyfriend",boyfriend],
    ["dad",dad],
    ["gf",gf]
];

function onNoteSplash(splash) {
    splash.blend = LuaUtils.blendModeFromString("screen");
}

function onCreatePost() {
    reloadShader();
}

function reloadShader() {
    for (i in 0...len.length) {
        var character = len[i][1];
        var charName = len[i][0];
		var rim = new DropShadowShader();
		rim.setAdjustColor(-66, -10, 24, -23);
		rim.antialiasAmt = 0;
		rim.color = 0xFF52351d;
		rim.attachedSprite = character;
		rim.distance = 5;

        if (charName == "boyfriend") {
            rim.angle = 90;
            character.shader = rim;

            boyfriend.animation.onFrameChange.add(function() {
                if (boyfriend != null)
                {
      			    rim.updateFrameInfo(boyfriend.frame);
                }
    		});
        } else if (charName == "dad") {

            rim.angle = 90;
            character.shader = rim;

            dad.animation.onFrameChange.add(function() {
      		    rim.updateFrameInfo(dad.frame);
    		});
        } else if (charName == "gf") {

            rim.angle = 90;
            character.shader = rim; 

            gf.animation.onFrameChange.add(function() {
      		    rim.updateFrameInfo(gf.frame);
    		});
        }
    }
}