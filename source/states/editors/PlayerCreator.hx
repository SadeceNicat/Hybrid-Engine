package states.editors;

import objects.CharacterSelectObject;
import json.CharacterSelectJson;

import lime.utils.Assets;

import haxe.Json;
import haxe.Exception;
import haxe.io.Bytes;

import flixel.FlxSubState;
import flixel.util.FlxSave;

import debug.FPSCounter;

import states.editors.content.Prompt;
import states.editors.content.*;

import backend.Song;

class PlayerCreator extends MusicBeatState {

    var curCharacterJson:CharacterCreatorJSON;

    var curPlayer:String = "bf";
    var curParent:String = "gf";

    var playerBack:CharacterSelectObject;
    var player:CharacterSelectObject;
    var parent:CharacterSelectObject;

    var camUI:FlxCamera;

    var charSelectBG:FlxSprite;
    var floor:FlxSprite;
    var curtain:FlxSprite;

    var dipshit:FlxSprite;

    var mainBox:PsychUIBox;
    var upperBox:PsychUIBox;
    var animListBox:PsychUIBox;

    var follow:FlxSprite;

    var speed:Float = 350;

    var playerAnimations:Dynamic;

    var isShift:Bool = false;
    var isCtrl:Bool = false;

    var speedMove:Int = 20;

    var curAnim:Int = 0;

    var characterNameInput:PsychUIInputText;

    var isSaved:Bool = false;

    var fileDialog:FileDialogHandler = new FileDialogHandler();

    var outputTxt:FlxText;

    var characterPath:String = null;

    var animsTxt:FlxText;

    var selectedFormat:FlxTextFormat = new FlxTextFormat(FlxColor.LIME);

    var animationTextList:Array<FlxText> = [];

    var characterGroup:FlxSpriteGroup;
    var frontBackground:FlxSpriteGroup;

    var pixelIcon:FlxSprite;

    function openCharacter() {
        
    }

    override function create() {
        super.create();

        FPSCounter.hideFPS();

        follow = new FlxSprite();
        follow.makeGraphic(32,32,FlxColor.RED);
        follow.screenCenter(XY);
        add(follow);

        curCharacterJson = CharacterSelectJson.getDefaultCharacterJSON();

        createBackgrounds();
        createCameras();
        characterGroup = new FlxSpriteGroup();
        add(characterGroup);
        createPlayer();
        createFrontBackground();
        createEditorStuffs();

        updateText();
                
        dipshit = new FlxSprite();
        dipshit.loadGraphic(Paths.image("charSelect/dipshitIdle"));
        dipshit.antialiasing = ClientPrefs.data.antialiasing;
        add(dipshit);

        outputTxt = new FlxText(25, FlxG.height - 50, FlxG.width - 50, '', 20);
		outputTxt.borderSize = 2;
		outputTxt.borderStyle = OUTLINE_FAST;
		outputTxt.scrollFactor.set();
		outputTxt.cameras = [camUI];
		outputTxt.alpha = 0;
		add(outputTxt);

        animsTxt = new FlxText(10, 32, 400, '');
		animsTxt.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
		animsTxt.scrollFactor.set();
		animsTxt.borderSize = 1;
		animsTxt.cameras = [camUI];
        add(animsTxt);

    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.wheel != 0)
        {
            FlxG.camera.zoom += (FlxG.mouse.wheel / 10);
        }

        if (FlxG.keys.pressed.J) {
            follow.x -= elapsed * speed;
        }
        if (FlxG.keys.pressed.K) {
            follow.y += elapsed * speed;
        }
        if (FlxG.keys.pressed.I) {
            follow.y -= elapsed * speed;
        }
        if (FlxG.keys.pressed.L) {
            follow.x += elapsed * speed;
        }

        if (FlxG.keys.justPressed.R) {
            follow.screenCenter(XY);
            FlxG.camera.zoom = 1;
        }
        
        if (FlxG.keys.justPressed.E) {
            if (curAnim < curCharacterJson.Animations.length - 1) {
                curAnim += 1;
            } else {
                curAnim = 0;
            }
            player.playAnimation(curCharacterJson.Animations[curAnim][0]);
        }

        if (FlxG.keys.justPressed.Q) {
            if (curAnim > 0) {
                curAnim -= 1;
            } else {
                curAnim = 3;
            }
            player.playAnimation(curCharacterJson.Animations[curAnim][0]);
        }

        if (FlxG.keys.justPressed.SPACE) {
            player.playAnimation(curCharacterJson.Animations[curAnim][0]);
        }

        if (FlxG.keys.pressed.SHIFT) {
            isShift = true;
            speedMove = 5;
        } else {
            isShift = false;
            speedMove = 1;
        }

        if (FlxG.keys.pressed.CONTROL) {
            isCtrl = true;
        } else {
            isCtrl = false;
        }

        if (FlxG.keys.justPressed.S) {
            if (isCtrl == true) {
                saveCharacter(true);
            }
        }

        if (FlxG.keys.justPressed.LEFT) {
            player.addOffsetX(curCharacterJson.Animations[curAnim][0],speedMove);
            curCharacterJson.Animations[curAnim][2] = player.getOffset(curCharacterJson.Animations[curAnim][0])[0];
            refreshAnimation();
        }
        if (FlxG.keys.justPressed.RIGHT) {
            player.addOffsetX(curCharacterJson.Animations[curAnim][0],-speedMove);
            curCharacterJson.Animations[curAnim][2] = player.getOffset(curCharacterJson.Animations[curAnim][0])[0];
            refreshAnimation();
        }
        if (FlxG.keys.justPressed.UP) {
            player.addOffsetY(curCharacterJson.Animations[curAnim][0],speedMove);
            curCharacterJson.Animations[curAnim][3] = player.getOffset(curCharacterJson.Animations[curAnim][0])[1];
            refreshAnimation();
        }
        if (FlxG.keys.justPressed.DOWN) {
            player.addOffsetY(curCharacterJson.Animations[curAnim][0],-speedMove);
            curCharacterJson.Animations[curAnim][3] = player.getOffset(curCharacterJson.Animations[curAnim][0])[1];
            refreshAnimation();            
        }

        for (i in 0...animationTextList.length) {
            if (i == curAnim) {
                animationTextList[i].color = FlxColor.GREEN;
            } else {
                animationTextList[i].color = FlxColor.WHITE;
            }
        }
    }

	function updateText()
    {
        var tab_group = animListBox.getTab('List').menu;
        var textY:Float = 8;
        for (i in 0...playerAnimations.length) {
            var txt = new FlxText(10,textY,100,playerAnimations[i][0]);
            textY += 20;

            tab_group.add(txt);
            animationTextList.push(txt);
        }
    }

    function refreshAnimation() {
        if (curCharacterJson.Animations[curAnim][0] == "Idle") {
            playerBack.addOffset(curCharacterJson.Animations[curAnim][0],player.getOffset(curCharacterJson.Animations[curAnim][0])[0],player.getOffset(curCharacterJson.Animations[curAnim][0])[1]);
            playerBack.playAnimation("Idle");
        }
        player.playAnimation(curCharacterJson.Animations[curAnim][0]);
    }

    function createCameras() {
        camUI = new FlxCamera();
        camUI.bgColor.alpha = 0;
        FlxG.cameras.add(camUI,false);
        
        add(camUI);

		FlxG.camera.follow(follow, LOCKON, 1);
    }

    function createEditorStuffs() {
        mainBox = new PsychUIBox(900,50, 300, 280, ["Settings",'Animations', 'Character']);
		mainBox.selectedName = 'Song';
		mainBox.scrollFactor.set();
		mainBox.cameras = [camUI];
		add(mainBox);

        upperBox = new PsychUIBox(0, 0, 300, 600, ['File', 'Edit', "Editors", "Help"],false,26);
		upperBox.scrollFactor.set();
		upperBox.isMinimized = true;
		upperBox.minimizeOnFocusLost = true;
		upperBox.canMove = false;
		upperBox.cameras = [camUI];
		upperBox.bg.visible = false;
		add(upperBox);

        animListBox = new PsychUIBox(10,400, 170, 280, ["List"]);
		animListBox.selectedName = 'Song';
		animListBox.scrollFactor.set();
		animListBox.cameras = [camUI];
		add(animListBox);

        addCharacterTab();
        addAnimationsUI();
        addSettingsTab();

        addFileTab();
    }

    function hideUpperBox() {
        upperBox.isMinimized = true;
        upperBox.bg.visible = false;
    }

    function addFileTab() {
		var tab = upperBox.getTab('File');
		var tab_group = tab.menu;
		var btnX = tab.x - upperBox.x;
		var btnY = 1;
		var btnWid = Std.int(tab.width);

		var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Save', function()
		{
            hideUpperBox();

            
            saveCharacter(true);
		}, btnWid);
		btn.text.alignment = LEFT;
		tab_group.add(btn);

		btnY += 20;
		var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Save as...', function()
		{
			hideUpperBox();

            saveCharacter(false);
		},btnWid);
		btn.text.alignment = LEFT;
		tab_group.add(btn);

        btnY += 20;
        var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Open Character...', function()
        {
            if(!fileDialog.completed) return;
            hideUpperBox();

			fileDialog.open(function()
            {
                try
                {
                    var filePath:String = fileDialog.path.replace('\\', '/');
                    var rP:String = filePath.substr(filePath.lastIndexOf('playableCharacters'));
                    var loadedCharacter:CharacterCreatorJSON = Json.parse(File.getContent(Paths.getPath("data/"+rP, TEXT)));

                    if(loadedCharacter == null)
                    {
                        showOutput('Error: File loaded', true);
                        return;
                    }

                    var func:Void->Void = function()
                    {
                        characterPath = fileDialog.path;
                        showOutput('Opened Character "${characterPath}" successfully!');
                        curCharacterJson = loadedCharacter;
                        curParent = curCharacterJson.Parent;
                        createPlayer();
                    }
                    
                    openSubState(new Prompt('Warning: Any unsaved progress\nwill be lost.', func));
                }
                catch(e:Exception)
                {
                    showOutput('Error: ${e.message}', true);
                    trace(e.stack);
                }
            });

        }, btnWid);
        btn.text.alignment = LEFT;
        tab_group.add(btn);

        btnY += 22;
		var btn:PsychUIButton = new PsychUIButton(btnX, btnY, '  Exit', function()
		{
			MusicBeatState.switchState(new MasterEditorMenu());
		},btnWid);
		btn.text.alignment = LEFT;
		tab_group.add(btn);
    }

    function addSettingsTab() {
        var tab_group = mainBox.getTab('Settings').menu;
    }

    function addCharacterTab() {
        var tab_group = mainBox.getTab('Character').menu;

        characterNameInput = new PsychUIInputText(5, 20, 160, curCharacterJson.Sprite, 8);
		characterNameInput.onChange = function(old:String, cur:String) {
            curCharacterJson.Sprite = cur;
        };

        var reloadCharacter:PsychUIButton = new PsychUIButton(170, 20, "Reload Char", function()
        {
            createPlayer();
        });


        tab_group.add(new FlxText(characterNameInput.x, characterNameInput.y - 15, 80, 'Song Name:'));
        tab_group.add(characterNameInput);
        tab_group.add(reloadCharacter);
    }

    function createPlayer() {
        if (player != null) {
            characterGroup.remove(player);
            characterGroup.remove(playerBack);
            player.destroy();
            playerBack.destroy();
        }

        if (parent != null) {
            characterGroup.remove(parent);
            parent.destroy();
        }

        playerBack = new CharacterSelectObject(810,200,curPlayer,true,curCharacterJson);
        playerBack.playAnimation("Idle");
        playerBack.alpha = 0.4;
        characterGroup.add(playerBack);

        player = new CharacterSelectObject(810,200,curPlayer,true,curCharacterJson);
        player.playAnimation(curCharacterJson.Animations[curAnim][0]);
        characterGroup.add(player);

        parent = new CharacterSelectObject(90,200,curParent);
        parent.playAnimation("Idle");
        characterGroup.add(parent);

        playerAnimations = player.getAnimations();
        trace(playerAnimations);
    }

    function createBackgrounds() {
        charSelectBG = new FlxSprite(0,-130);
        charSelectBG.loadGraphic(Paths.image("charSelect/charSelectBG"));
        charSelectBG.screenCenter(X);
        charSelectBG.antialiasing = ClientPrefs.data.antialiasing;
        add(charSelectBG);

        floor = new FlxSprite(-40, 391);
        floor.frames = Paths.getSparrowAtlas("charSelect/charSelectStage");
        floor.animation.addByPrefix("idle","stage full instance 1",24,true);
        floor.antialiasing = ClientPrefs.data.antialiasing;
        add(floor);
    }

    function createFrontBackground() {
        curtain = new FlxSprite(-50,-10);
        curtain.loadGraphic(Paths.image("charSelect/curtains"));
        curtain.antialiasing = ClientPrefs.data.antialiasing;
        add(curtain);
    }

    var animationDropDown:PsychUIDropDownMenu;
	var animationInputText:PsychUIInputText;
	var animationNameInputText:PsychUIInputText;
	var animationIndicesInputText:PsychUIInputText;
	var animationFramerate:PsychUINumericStepper;
	var animationLoopCheckBox:PsychUICheckBox;
	function addAnimationsUI()
	{
		var tab_group = mainBox.getTab('Animations').menu;

		animationInputText = new PsychUIInputText(15, 85, 80, '', 8);
		animationNameInputText = new PsychUIInputText(animationInputText.x, animationInputText.y + 35, 150, '', 8);
		animationFramerate = new PsychUINumericStepper(animationInputText.x + 170, animationInputText.y, 1, 24, 0, 240, 0);

		animationDropDown = new PsychUIDropDownMenu(15, animationInputText.y - 55, [''], function(selectedAnimation:Int, pressed:String) {
            animationInputText.text = curCharacterJson.Animations[selectedAnimation][0];
            animationNameInputText.text = curCharacterJson.Animations[selectedAnimation][1];
            animationFramerate.value = curCharacterJson.Animations[selectedAnimation][4];
		});

		var updateButton:PsychUIButton = new PsychUIButton(40, animationFramerate.y + 127, "Update", function() {
            curCharacterJson.Animations[curAnim][1] = animationNameInputText.text;
            createPlayer();
            refreshAnimation();
		});

		var removeButton:PsychUIButton = new PsychUIButton(180, animationFramerate.y + 127, "Remove", function() {
			
		});

        reloadAnimationsList();

		animationDropDown.selectedLabel = curCharacterJson.Animations[0] != null ? curCharacterJson.Animations[0][0] : '';

		tab_group.add(new FlxText(animationDropDown.x, animationDropDown.y - 18, 100, 'Animations:'));
		tab_group.add(new FlxText(animationInputText.x, animationInputText.y - 18, 100, 'Animation name:'));
		tab_group.add(new FlxText(animationFramerate.x, animationFramerate.y - 18, 100, 'Framerate:'));
		tab_group.add(new FlxText(animationNameInputText.x, animationNameInputText.y - 18, 150, 'Animation Symbol Name/Tag:'));

		tab_group.add(animationInputText);
		tab_group.add(animationNameInputText);
		tab_group.add(animationFramerate);
		tab_group.add(updateButton);
		tab_group.add(removeButton);
		tab_group.add(animationDropDown);
	}

    function reloadAnimationsList() {
        var animList:Array<String> = [];
        for (anim in 0...curCharacterJson.Animations.length) { animList.push(curCharacterJson.Animations[anim][0]); }
		animationDropDown.list = animList;
    }

    override function openSubState(SubState:FlxSubState) { super.openSubState(SubState); }

    function showOutput(message:String, isError:Bool = false)
    {
        trace(message);
        outputTxt.text = message;
        outputTxt.y = FlxG.height - outputTxt.height - 30; outputTxt.alpha = 1;
        FlxTween.cancelTweensOf(outputTxt); FlxTween.tween(outputTxt, {alpha:0}, 4, {ease: FlxEase.circIn});
        if(isError)
        {
            FlxG.sound.play(Paths.sound('chartingSounds/undo'), 0.6);
            outputTxt.color = FlxColor.RED;
        }
        else
        {
            FlxG.sound.play(Paths.sound('chartingSounds/noteLay'), 0.6);
            outputTxt.color = FlxColor.WHITE;
        }
    }

    function saveCharacter(canQuickSave:Bool = true)
    {   
        var characterData:String = PsychJsonPrinter.print(curCharacterJson, ['Animations', 'XY', 'Color', 'iconXYS']);
        if(canQuickSave && characterPath != null)
        {
            File.saveContent(characterPath, characterData);
            showOutput('Character saved successfully to: ${characterPath}');
        }
        else
        {
            fileDialog.save(curPlayer+".json", characterData,
                function()
                {
                    var newPath:String = fileDialog.path;
                    characterPath = newPath.replace('\\', '/');
                    showOutput('Character saved successfully to: $characterPath');

                }, null, function() showOutput('Error on saving character!', true));
        }
    }
}