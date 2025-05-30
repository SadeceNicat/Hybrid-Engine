package managers;

class StrumSetManager {
    public var STRUM_SET_NAME:String = "default";

    public var NOTE_ASSETS:Map<String, String> = new Map<String, String>();
    public var GlobalNoteSpace:Float = 10.0;
    public var NoteScale:Float = 1.0;
    public var NoteStartXY:Array<Float> = [0.0, 0.0];
    public var NotesData:Array<Map<String, Dynamic>> = [];

    public function new(strumSetName:String) {
        this.STRUM_SET_NAME = strumSetName;
    }
}