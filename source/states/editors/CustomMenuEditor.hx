package states.editors;

class CustomMenuEditor extends MusicBeatState implements PsychUIEventHandler.PsychUIEvent
{

    public var STATE_PATH:String = "";
    public var STATE_NAME:String = "";

    public var upperBox:PsychUIBox;

    public var ops:Array<String> = [
        "File",
        "Edit",
        "Tools",
        "View"
    ];

    public var camUI:FlxCamera;
    public var camState:FlxCamera;
    
    public override function create()
    {
        super.create();

        camState = new FlxCamera();
        FlxG.cameras.add(camState);

        camUI = new FlxCamera();
        camUI.bgColor.alpha = 0;
        FlxG.cameras.add(camUI);

        upperBox = new PsychUIBox(0, 0, 300, 600, ops ,false,26);
		upperBox.scrollFactor.set();
		upperBox.isMinimized = true;
		upperBox.minimizeOnFocusLost = true;
		upperBox.canMove = false;
		upperBox.cameras = [camUI];
		upperBox.bg.visible = false;
		add(upperBox);
        
        addFileTab();
    }

    function addFileTab()
	{
		var tab = upperBox.getTab('File');
		var tab_group = tab.menu;
		var btnX = tab.x - upperBox.x; var btnY = 1; var btnWid = Std.int(tab.width);

		var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  New', function()
		{

		}, btnWid);
		btn.text.alignment = LEFT; tab_group.add(btn);

        btnY++; btnY += 20;

        var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Open State...', function()
		{

		}, btnWid);
		btn.text.alignment = LEFT; tab_group.add(btn);

        btnY++; btnY += 20;

        var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Save', function()
		{

		}, btnWid);
		btn.text.alignment = LEFT; tab_group.add(btn);

        btnY++; btnY += 20;

        var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Save as...', function()
		{

		}, btnWid);
		btn.text.alignment = LEFT; tab_group.add(btn);

        btnY++; btnY += 21;

        var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Exit', function()
		{
            MusicBeatState.switchState(new MasterEditorMenu());
		}, btnWid);
		btn.text.alignment = LEFT; tab_group.add(btn);
    }

    public function UIEvent(id:String, sender:Dynamic) {

    }

    public function Save(quickSave:Bool = false):Void {

    }

    public function LoadState(json:String):Void {

    }
}