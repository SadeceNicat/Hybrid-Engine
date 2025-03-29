package json;

import haxe.Json;

typedef CharacterCreatorJSON = {
    var version:String;
    var name:String;
    var Sprite:String;
    var SpriteType:String;
    var Animations:Dynamic;
    var XY:Array<Float>;
    var Color:Array<Int>;
    var iconXYS:Array<Array<Float>>;
    var Parent:String;
}

class CharacterSelectJson {
    public static var charsJson:Dynamic;

    function reloadChars() {
        charsJson = [];
        var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/playableCharacters/');
        trace(foldersToCheck);
		for (folder in foldersToCheck) {
			for (file in FileSystem.readDirectory(folder)) {
                trace(file);
                if (!Paths.fileExists('data/playableCharacters/'+file+'/disableSelect.txt', TEXT)) {
                    if(!charsJson.contains(file)) {
						charsJson.push(file);
                    }
                }
            }
        }
    }

    public static function getDefaultCharacterJSON():CharacterCreatorJSON {
        var charFile:CharacterCreatorJSON = {
			version: "1.0.0",
            name: "Boyfriend",
            Sprite: "charSelect/characters/bf/BFCharacterSelect",
            SpriteType: "sparrow",
            Animations: [
                ["Idle", "bf cs idle", 0, 0, 24, false],
                ["SlideIn", "bf slide in", 45, -6, 24, false],
                ["Deselect", "bf cs deselect", -2, -8, 24, false],
                ["Confirm", "bf cs confirm", -2, -5, 24, false]
            ],
            XY: [0,0],
            Color: [95,192,255],
            iconXYS: [[0,0,2,2],[100,50,2.5,2.5]],
            Parent: "gf"
		};
        return charFile; 
    }

    public static function getCharacterData(char:String,?charData:String = "charmenu") {
        var file:String = 'data/playableCharacters/' + char + "/" + char + "-"+charData+".json";
        var path = Paths.getPath(file, TEXT);
        return Json.parse(File.getContent(path));
    }

    public static function getCharacterSongs(char:String) {
        var songsJSON:Dynamic = [];
        var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/playableCharacters/'+char+'/songs/');
        trace(foldersToCheck);
		for (folder in foldersToCheck) {
			for (file in FileSystem.readDirectory(folder)) {
                trace(file);
                if(!songsJSON.contains(file)) {
                    songsJSON.push(file);
                }
            }
        }
        return songsJSON;
    }


    public static function getCharIgnoreSongs(char:String) {
        var songsJSON:Dynamic = [];
        var foldersToCheck:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/playableCharacters/'+char+'/ignoreSongs/');
        trace(foldersToCheck);
		for (folder in foldersToCheck) {
			for (file in FileSystem.readDirectory(folder)) {
                trace(file);
                if(!songsJSON.contains(file)) {
                    songsJSON.push(file);
                }
            }
        }
        return songsJSON;
    }
}