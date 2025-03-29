package backend;

import haxe.Json;

class Config {
    public static function getConfig(configName:String) {
        var returnValue:Dynamic = null;
        if(Paths.fileExists('config/'+configName+'.json', TEXT))
            {
                var confRaw:String = Paths.getTextFromFile('config/'+configName+'.json');
                trace(confRaw);
                if(confRaw != null && confRaw.length > 0)
                {
                    try { 
                        returnValue = tjson.TJSON.parse(confRaw); 
                    }
                    catch(e:haxe.Exception) { trace('[WARN] '+configName+' JSON might broken, ignoring issue...\n${e.details()}'); }
                }
                else { trace('[WARN] No '+configName+' JSON detected, using default values.'); }
            } else { trace("json not exist"); }
        return returnValue;
    }
}