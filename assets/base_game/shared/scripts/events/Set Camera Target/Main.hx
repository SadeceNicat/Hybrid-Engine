import psychlua.LuaUtils;

function INIT_EVENT_ICON() {
    return "FocusCamera";
}

function onHybridEvent(eventName:String, eventData:Array<Dynamic>, engineVersion:String) {
    if (eventName == "Set Camera Target") {
        if (eventData[2] == "classic") {
            game.isCameraOnForcedPos = false;
            game.cameraSpeed = Std.parseFloat(eventData[1]);
            if (eventData[0] == "BOYFRIEND") {
                moveCamera(false);
            } else if (eventData[0] == "GF") {
                    moveCameraToGirlfriend();
            } else {
                moveCamera(true);
            }  
        } else {
            game.isCameraOnForcedPos = true;
            game.cameraSpeed = 100;
            if (eventData[0] == "BOYFRIEND") {
                FlxTween.tween(camFollow, { 
                    x: boyfriend.getMidpoint().x - 100 - (boyfriend.cameraPosition[0] + boyfriendCameraOffset[0]),
                    y: boyfriend.getMidpoint().y - 100 + (boyfriend.cameraPosition[1] - boyfriendCameraOffset[1]),
                }, Std.parseFloat(eventData[1]), {ease: LuaUtils.getTweenEaseByString(eventData[2])});
            } else if (eventData[0] == "GF") {
                FlxTween.tween(camFollow, { 
                    x: gf.getMidpoint().x + (gf.cameraPosition[0] + girlfriendCameraOffset[0]),
                    y: gf.getMidpoint().y + (gf.cameraPosition[1] + girlfriendCameraOffset[1]),
                }, Std.parseFloat(eventData[1]), {ease: LuaUtils.getTweenEaseByString(eventData[2])});
            } else {
                FlxTween.tween(camFollow, { 
                    x: dad.getMidpoint().x + 150 + (dad.cameraPosition[0] + opponentCameraOffset[0]),
                    y: dad.getMidpoint().y - 100 + (dad.cameraPosition[1] + opponentCameraOffset[1]),
                }, Std.parseFloat(eventData[1]), {ease: LuaUtils.getTweenEaseByString(eventData[2])});
            }
        }
    }
}