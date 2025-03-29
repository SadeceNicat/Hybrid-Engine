package states;

import hxgamejolt.GameJolt;

import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import api.Gamejolt;

class StatsState extends MusicBeatState {

    var menuBG:FlxSprite;
    var sprite:FlxSprite;

    var upperBox:PsychUIBox;
    var playerBox:PsychUIBox;
    var statsBox:PsychUIBox;
    var modsBox:PsychUIBox;

    var downY:Float = 10;

    override function create() {
        super.create();

		FlxG.mouse.visible = true;

        menuBG = new FlxSprite(0,0);
        menuBG.loadGraphic(Paths.image("menuDesat"));
        add(menuBG);
        
        sprite = new FlxSprite(0,0);

        GameJolt.fetchUser(Gamejolt.getUserName(), [], {
			onSucceed: function(json:Dynamic):Void
			{
				trace(json);

				var loader:Loader = new Loader();
				var url:String = json.users[0].avatar_url;
				var urlPng:String = url.replace(".webp", ".png");

				var request:URLRequest = new URLRequest(urlPng.replace("/60", "/522"));
				
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event:Event) {
					// sprite.loadGraphic(event.target.content);

					var bitmap:Bitmap = event.target.content;
					var bitmapData:BitmapData = bitmap.bitmapData;
					sprite.loadGraphic(bitmapData, true, false);
					sprite.scale.x = 300 / sprite.width;
					sprite.scale.y = 270 / sprite.height;
					sprite.updateHitbox();
					
				});
				trace(loader);
			},
			onFail: function(message:String):Void
			{
				trace("User Not Exist");
				sprite.loadGraphic(Paths.image("login/Placeholder"));
                sprite.scale.x = 300 / sprite.width;
                sprite.scale.y = 270 / sprite.height;
				sprite.updateHitbox();
			}
		});

        upperBox = new PsychUIBox(0, 0, 300, 600, ['File', 'Edit', "Editors", "Help"],false,26);
		upperBox.scrollFactor.set();
		upperBox.isMinimized = true;
		upperBox.minimizeOnFocusLost = true;
		upperBox.canMove = false;
		upperBox.bg.visible = false;
		add(upperBox);

        playerBox = new PsychUIBox(30,27 + downY, 300, 290, ["Unknown"]);
		playerBox.selectedName = 'Unknown';
		playerBox.scrollFactor.set();
		add(playerBox);

        statsBox = new PsychUIBox(30,280 + 50 + downY, 800, 370, ["Stats"]);
		statsBox.selectedName = 'Stats';
		statsBox.scrollFactor.set();
		add(statsBox);

        modsBox = new PsychUIBox(800 + 40,280 + 50 + downY, 410, 370, ["Mods"]);
		modsBox.selectedName = 'Mods';
		modsBox.scrollFactor.set();
		add(modsBox);

        addFileTab();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    function addFileTab() {
		var tab = playerBox.getTab('Unknown');
		var tab_group = tab.menu;

		tab_group.add(sprite);
    }
}