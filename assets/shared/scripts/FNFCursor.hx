var cursor:FlxSprite;

function onCreate() {
    cursor = new FlxSprite();
    cursor.makeGraphic(15, 15, FlxColor.TRANSPARENT);
    cursor.loadGraphic(Paths.image("cursor/cursor-default"));
    FlxG.mouse.load(cursor.pixels);
}

function onUpdate() {
    if (FlxG.mouse.visible == true) {
    if(FlxG.mouse.justPressed) {
        FlxG.sound.play(Paths.sound('chartingSounds/ClickUp'), 1);
    }

    if (FlxG.mouse.justReleased) {
        FlxG.sound.play(Paths.sound('chartingSounds/ClickDown'), 1);
    }
    }
}