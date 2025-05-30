import flixel.addons.display.FlxBackdrop;
import psychlua.LuaUtils;

function onCreate() {


    var smoke = new FlxBackdrop(Paths.image('stages-erects/week4/mistFront'),1,0,true,false);
    smoke.velocity.set(1531,0);
    smoke.y = -150;
    smoke.blend = LuaUtils.blendModeFromString("add");
    smoke.color = FlxColor.fromRGB(155,50,255);
    smoke.alpha = 0.5;
    add(smoke);

    rchar = new FlxSprite(-120, 550);
    rchar.frames = Paths.getSparrowAtlas("stages-erects/week4/aga");
    rchar.animation.addByPrefix('idle', "Limo stage", 24, true);
    rchar.antialiasing = true;
    rchar.animation.play('idle');
    addBehindDad(rchar);
}
function addBackSPR() {
    var smoke2 = new FlxBackdrop(Paths.image('stages-erects/week4/mistMid'),1,0,true,false);
    smoke2.velocity.set(1531,0);
    smoke2.y = -0;
    smoke2.blend = LuaUtils.blendModeFromString("add");
    smoke2.alpha = 0.5;
    game.addBehindGF(smoke2);
}

function addCloud() {
    var smoke3 = new FlxBackdrop(Paths.image('stages-erects/week4/mistBack'),1,0,true,false);
    smoke3.velocity.set(1531,0);
    smoke3.y = -150;
    smoke3.blend = LuaUtils.blendModeFromString("add");
    smoke3.alpha = 0.5;
    game.addBehindGF(smoke3);
}