package backend;

typedef StrumSetProp = {
    var NoteAssets:Map<String, String>;
    var GlobalNoteSpace:Float;
    var NoteScale:Float;
    var NoteStartXY:Array<Float>;
    var notesData:Array<Map<String, Dynamic>>;
}

class StrumSet {
    public var strumSet:String = "";
    public var strumData:StrumSetProp;
    public var data:String = "";
    public function new(strumSet:String) {
        this.strumSet = strumSet;

        try {
            data = Paths.getTextFromFile("notes/" + strumSet);
            trace(data);
            if (data != null) {
                this.strumData = tjson.TJSON.parse(data);
            }
        } catch (e:Dynamic) {
            trace("Error loading strum set metadata: " + e);
            this.strumData = {
                NoteAssets: new Map<String, String>(),
                GlobalNoteSpace: 0,
                NoteScale: 0,
                NoteStartXY: new Array<Float>(),
                notesData: new Array<Map<String, Dynamic>>()
            };
        }
    }
}