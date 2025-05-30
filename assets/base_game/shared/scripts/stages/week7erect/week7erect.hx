var len = [
    ["boyfriend",boyfriend],
    ["dad",dad],
    ["gf",gf]
];

function onCreatePost() {
    reloadShader();
}

function reloadShader() {
    for (i in 0...len.length) {
        var character = len[i][1];
        var charName = len[i][0];
        var rim = new DropShadowShader();
        rim.setAdjustColor(-46, -38, -25, -20);
        rim.color = 0xFFDFEF3C;
        rim.attachedSprite = character;
        character.shader = rim;

        if (charName == "boyfriend") {
            rim.angle = 90;

            boyfriend.animation.onFrameChange.add(function() {
                if (boyfriend != null)
                {
      			    rim.updateFrameInfo(boyfriend.frame);
                }
    		});
        } else if (charName == "dad") {

            rim.angle = 135;
            rim.threshold = 0.3;

            dad.animation.onFrameChange.add(function() {
      		    rim.updateFrameInfo(dad.frame);
    		});
        } else if (charName == "gf") {

            rim.angle = 90;

            gf.animation.onFrameChange.add(function() {
      		    rim.updateFrameInfo(gf.frame);
    		});
        }
    }
}

function onEvent(eventName:String) {
    if (eventName == "Change Character") {
        reloadShader();
    }
}