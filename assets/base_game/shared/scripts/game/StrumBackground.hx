// var firstNote:Dynamic;
// var lastNote:Dynamic;

// var strumBackground:FlxSprite;
// function onCreate() {
//     strumBackground = new FlxSprite(500, 0);
//     strumBackground.makeGraphic(1, FlxG.height, 0xFF000000);
//     strumBackground.cameras = [camHUD];
//     strumBackground.alpha = 0.5;
//     add(strumBackground);
// }

// function onSpawnBabyNote(babyArrow,isPlayer) {
//     if (isPlayer == 1 && babyArrow.noteData == 0) {
//         firstNote = babyArrow;
//         new FlxTimer().start(0.1, function(t:FlxTimer) {
//             strumBackground.x = babyArrow.x;
//         });
//     } else if (isPlayer == 1) {
//         lastNote = babyArrow;
//     }
// }

// function onUpdate() {
//     if (firstNote != null && lastNote != null) {
//         strumBackground.scale.x = lastNote.x - firstNote.x + 110;
//         strumBackground.updateHitbox();
//     }

//     if (FlxG.keys.justPressed.SPACE) {
//         lastNote.x += 20;
//     }
// }