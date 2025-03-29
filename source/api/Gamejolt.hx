package api;

#if GAMEJOLT_ALLOWED
import hxgamejolt.GameJolt;
#end

class Gamejolt {

    public static var gameJoltGameID = "949510";
    public static var privateKey = "a312bb89e09805ebc0fac1069bcc40c4";

    public static var isLogin:Bool = false;
    public static var isGuest:Bool = true;

    public static function getUserToken() {
        trace(ClientPrefs.data.gameJoltToken);
        return ClientPrefs.data.gameJoltToken;
    }

    public static function getUserName() {
        trace(ClientPrefs.data.gameJoltUsername);
        return ClientPrefs.data.gameJoltUsername;
    }
    
    public static function reloadGameJolt() {
        GameJolt.init(gameJoltGameID, privateKey);
    }

    public static function setGameID(ID:String) {
        gameJoltGameID = ID;
    }

    public static function setGameKey(KEY:String) {
        privateKey = KEY;
    }
}