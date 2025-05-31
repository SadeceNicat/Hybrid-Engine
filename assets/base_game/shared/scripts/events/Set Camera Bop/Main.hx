function INIT_EVENT_ICON() {
    return "defaultEventIcon";

}

function INIT_EVENT_DATA() {
    return [
        ["Step", getValueTypesFromString("float"), 32, [1, 64]],
        ["Camera Zoom", getValueTypesFromString("float"), 0.02, [0.01, 10]],
    ];
}

var hasCameraBop:Bool = false;
var step:Float = 4;
var zoomAmount:Float = 0.02;

function onHybridEvent(eventName:String, eventData:Array<Dynamic>, engineVersion:String) {
    if (eventName == "Set Camera Bop") {
        hasCameraBop = true;
        step = Std.parseFloat(eventData[0]);
        zoomAmount = Std.parseFloat(eventData[1]);
    }
}

function onStepHit() {
    if (hasCameraBop) {
        if (curStep % step == 0) {
            triggerEvent("Add Camera Zoom", Std.string(zoomAmount * 0.3), "0", "0");
        }
    }
}