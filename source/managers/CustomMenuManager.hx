package managers;

enum ChangableStates {
    MAINMENU;
    FREEPLAY;
    OPTIONS;
    AWARDS;
    CREDITS;
    CUSTOM_MENU;
}

typedef CustomMenuJson = {
    var STATE_NAME:String;
    var OBJECTS:Array<Dynamic>;
}

class CustomMenuManager {
    public function GET_STATE_NAME():String {
        return "Unknown Menu";
    }
}