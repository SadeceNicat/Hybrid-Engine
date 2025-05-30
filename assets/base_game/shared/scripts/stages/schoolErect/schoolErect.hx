import psychlua.LuaUtils;

function onNoteSplash(splash) {
    splash.blend = LuaUtils.blendModeFromString("screen");
}