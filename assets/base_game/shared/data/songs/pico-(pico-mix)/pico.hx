import substates.PauseSubState;

var defDX:Float;
var defDY:Float;
var defBX:Float;
var defBY:Float;

var randomChar:Int = 0;

var isDead:Bool = true;

function onCreate() {
    defDX = game.dad.x;
    defDY = game.dad.y;

    defBX = game.boyfriend.x;
    defBY = game.boyfriend.y;

    randomChar = FlxG.random.int(0,1);

    game.triggerEvent("Change Character","dad","picoDopple");
    game.triggerEvent("Change Character","bf","picoDopple-bf");

    if (FlxG.random.int(0, 30) == 30) {
        isDead = true;
    }


    game.dad.playAnim("gasp");
    game.boyfriend.playAnim("gasp");

    FlxG.sound.play(Paths.sound('pico/cutscene/picoGasp'), 0.6);
    game.triggerEvent("Camera Follow Pos",655,505);

    new FlxTimer().start(3.6, function(tmr:FlxTimer) {
        if (randomChar == 1) {
            game.boyfriend.playAnim("cigara");
            game.triggerEvent("Camera Follow Pos",905,505);
        } else {
            game.dad.playAnim("cigara");
            game.triggerEvent("Camera Follow Pos",605,505);
        }

        if (isDead == true) {
            FlxG.sound.play(Paths.sound('pico/cutscene/picoCigarette2'), 0.6);
        }

        new FlxTimer().start(2.9, function(tmr:FlxTimer) {
            FlxG.sound.play(Paths.sound('pico/cutscene/picoShoot'), 0.6);
            if (randomChar == 1) {
                game.dad.playAnim("fark");
            } else {
                game.boyfriend.playAnim("fark");
            }
            new FlxTimer().start(0.4, function(tmr:FlxTimer) {
                if (randomChar == 1) {
                    game.dad.playAnim("aim");
                } else {
                    game.boyfriend.playAnim("aim");
                }
                new FlxTimer().start(2, function(tmr:FlxTimer) {
                    if (randomChar == 1) {
                        game.dad.playAnim("fire");
                        if (isDead == true) {
                            game.boyfriend.playAnim("die");
                        }
                    } else {
                        game.boyfriend.playAnim("fire");
                        if (isDead == true) {
                            game.dad.playAnim("die");
                        }
                    }

                    new FlxTimer().start(1, function(tmr:FlxTimer) {
                        game.boyfriend.playAnim("backidle");
                        FlxG.sound.play(Paths.sound('pico/cutscene/picoSpin'), 0.6);
                        new FlxTimer().start(2, function(tmr:FlxTimer) {
                            game.triggerEvent("Change Character","bf","pico-playable");
                        });
                    });
                });
            });
        });
    });
}

function onStartCountdown() {
    return Function_Stop;
}

function onUpdate() {
    if (FlxG.keys.justPressed.R) {
        PauseSubState.restartSong(true);
    }
}