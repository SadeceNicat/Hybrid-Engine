package objects;

import objects.StrumNote;
import states.PlayState;

class StrumBackground extends FlxSprite
{

    public var firstNote:StrumNote;
    public var lastNote:StrumNote;

    public var notes:Array<StrumNote>;

    public var noteStartX:Float;
    public var noteEndX:Float;

    public function checkPos() {
        var lastX:Float = 0;
        var firstX:Float = 2000;

        for (note in notes) {
            if (note.x > lastX) {
                lastX = note.x;
                this.lastNote = note;
            }
            if (note.x < firstX) {
                firstX = note.x;
                this.firstNote = note;
            }
        }
    }

	public function new(x:Float, y:Float)
	{
		super(x, y);
        
        this.notes = [];

        checkPos();
        
        this.makeGraphic(1, FlxG.height, 0xFF000000);
	}

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (this.firstNote != null && this.lastNote != null)
        {

            if (this.x != this.firstNote.x - 10)
            {
                checkPos();
                trace("move");
            }

            this.x = this.firstNote.x - 10;
        }

        if (this.firstNote != null && this.lastNote != null) {
            if (this.firstNote.cameras != [PlayState.instance.camGame])
            {
                if (this.firstNote.isOnScreen(PlayState.instance.camHUD) == false && this.lastNote.isOnScreen(PlayState.instance.camHUD) == false){
                    this.visible = false;
                } else {
                    this.visible = true;
                }
            }
        }

        if (this.firstNote != null && this.lastNote != null)
        {
            this.scale.x = this.lastNote.x - this.firstNote.x + 110 + 20;
            this.updateHitbox();
        }
    }
}