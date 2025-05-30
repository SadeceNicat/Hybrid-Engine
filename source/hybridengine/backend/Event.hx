package hybridengine.backend;

import psychlua.HScript;

enum EventValueTypes {
    STRING;
    NUMBER;
    FLOAT;
    BOOLEAN;
    SLIDER;
    COLOR;
    ARRAY;
    GAME_CHARACTERS;
    DROP_DOWN;
}

class Event {
    public var hscript:Null<HScript> = null;

    public var eventName:String = "Unknown Event";
    public var eventIcon:String = "eventHE";
    public var eventData:Array<Array<Dynamic>> = [];
    public var eventVersion:String = "0.1";
    
    public function new(eventName:String) {
        this.eventName = eventName;

        if(FileSystem.exists(Paths.getSharedPath("scripts/events/"+ eventName +"/Main.hx")) == true) {
            hscript = new HScript(null, Paths.getSharedPath("scripts/events/"+ eventName +"/Main.hx"));
            hscript.set("self", this);
            hscript.set("getValueTypesFromString", getValueTypesFromString);
        }

        eventIcon = INIT_EVENT_PROP("INIT_EVENT_ICON", "eventHE");
        eventData = INIT_EVENT_PROP("INIT_EVENT_DATA", [
            ["EventValue1", EventValueTypes.STRING, ""],
            ["EventValue2", EventValueTypes.STRING, ""]
        ]);
    }

    public function getValueTypesFromString(valueType:String):EventValueTypes {
        switch (valueType) {
            case "string": return EventValueTypes.STRING;
            case "number": return EventValueTypes.NUMBER;
            case "float": return EventValueTypes.FLOAT;
            case "boolean": return EventValueTypes.BOOLEAN;
            case "slider": return EventValueTypes.SLIDER;
            case "color": return EventValueTypes.COLOR;
            case "array": return EventValueTypes.ARRAY;
            case "game_characters": return EventValueTypes.GAME_CHARACTERS;
            case "drop_down": return EventValueTypes.DROP_DOWN;
            default: return EventValueTypes.STRING; // Default to STRING if unknown
        }
    }

    public function INIT_EVENT_PROP(name:String, ?value:Dynamic = ""):Dynamic {
        var returnValue:Dynamic;
        if (hscript != null && hscript.exists(name)) {
            returnValue = hscript.executeFunction(name, []).returnValue;
        } else {
            returnValue = value;
        }

        return returnValue;
    }
}