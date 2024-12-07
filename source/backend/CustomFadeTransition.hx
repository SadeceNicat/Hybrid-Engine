package backend;

import flixel.util.FlxGradient;
import haxe.Json;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	var stickers:Array<Dynamic> = [];

	var duration:Float;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	var stickerVariants = [
		"bfSticker1","bfSticker2","bfSticker3",
		"gfSticker1","gfSticker2","gfSticker3",
		"momSticker1","momSticker2","momSticker3",
		"monsterSticker1","monsterSticker2","monsterSticker3",
		"dadSticker1","dadSticker2","dadSticker3",
		"picoSticker1","picoSticker2","picoSticker3"
	];


	override function create()
	{

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001)); 

		if (FlxG.save.data.TransitionType == "Default") {
		transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		add(transBlack);

		if(isTransIn)
			transGradient.y = transBlack.y - transBlack.height;
		else
			transGradient.y = -transGradient.height;

		} else {
			if(isTransIn == false) {
				var timertime = 0.05;
				var exPos:Array<Array<Float>> = [];
				var permPos:Array<Array<Float>> = [];
				for (i in -1...10){
					for (i2 in -1...10){
						var xpos:Float = 125 * i;
						var ypos:Float = 125 * i2;
	
						exPos.push([xpos,ypos]);
						permPos.push([xpos,ypos]);
					}
				}
	
				for (value in permPos){
	
					var randomvalue = Math.floor(Math.random() * (exPos.length - 1));
	
					var xpos = exPos[randomvalue][0];
					var ypos = exPos[randomvalue][1];
	
					var timer = new FlxTimer().start(timertime, function(timer:FlxTimer){
							
						var randomstckr = Math.floor(Math.random() * (stickerVariants.length - 1));
		
						//if (i == 0) xpos = -150;
						
						while ((xpos > FlxG.width) && (xpos < -75)){
							xpos = Math.random() * FlxG.width;
						}
						while ((ypos > FlxG.height) && (ypos < -75)){
							ypos = Math.random() * FlxG.height;
						}
		
						var sticker:FlxSprite = new FlxSprite(xpos,ypos).loadGraphic(Paths.image("stickers/"+stickerVariants[randomstckr]));
						add(sticker);
						sticker.scale.set(0.85, 0.85);
						sticker.angle = FlxG.random.int(-10,10);
						sticker.scrollFactor.set(0,0);
						stickers.push([sticker.x, sticker.y, "stickers/"+stickerVariants[randomstckr],sticker.angle]);
						FlxTween.tween(sticker.scale, {x: 0.95, y: 0.95}, 0.65, {ease: FlxEase.backOut});
						
						var randomsound = Math.ceil(Math.random() * 8);
						if (randomsound <= 0) randomsound = 1;
						if (randomsound >= 9) randomsound = 8;
						FlxG.sound.play(Paths.sound('stickers/keyClick' + randomsound), 0.6);
						
					});
					timertime += 0.005;
	
					exPos.remove(exPos[randomvalue]);
				}
			} else {
				if (FlxG.save.data.stickers != null){
					
					//trace(FlxG.save.data.stickers);
					var savedStickers:Array<Dynamic> = Json.parse(FlxG.save.data.stickers);
					var timertime = 0.1;
						
					for (stckrData in savedStickers){
						var newSticker = new FlxSprite(stckrData[0],stckrData[1]).loadGraphic(Paths.image(stckrData[2]));
						newSticker.angle = stckrData[3];
						newSticker.scale.set(0.95,0.95);
						newSticker.scrollFactor.set(0,0);
						add(newSticker);
						var timer = new FlxTimer().start(timertime, function(timer:FlxTimer){
							var randomsound = Math.ceil(Math.random() * 8);
							if (randomsound <= 0) randomsound = 1;
							if (randomsound >= 9) randomsound = 8;
							FlxG.sound.play(Paths.sound('stickers/keyClick' + randomsound), 0.6);
							newSticker.destroy();
						});
						timertime += 0.005;
					}
					
				} else {
					trace("sticker data is null");
				}
			}
		}

		super.create();
	}

	var naber = false;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.save.data.TransitionType == "Default") {

			final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
			final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
			if(duration > 0)
				transGradient.y += (height + targetPos) * elapsed / duration;
			else
				transGradient.y = (targetPos) * elapsed;

			if(isTransIn)
				transBlack.y = transGradient.y + transGradient.height;
			else
				transBlack.y = transGradient.y - transBlack.height;

			if(transGradient.y >= targetPos)
			{
				close();
			}
		} else {
			if (naber == false && isTransIn == false){
				naber = true;
				var timer = new FlxTimer().start(0.85, function(timer:FlxTimer){
					FlxG.save.data.stickers = Json.stringify(stickers);
					if(finishCallback != null) finishCallback();
					finishCallback = null;
				});
			} else if (naber == false && isTransIn == true) {
				naber = true;
				var timer = new FlxTimer().start(0.85, function(timer:FlxTimer){
					close();
					if(finishCallback != null) finishCallback();
					finishCallback = null;
				});
			}
		}	
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
