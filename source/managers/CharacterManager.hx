package managers;

enum CharacterType {
    NONE;
    BOYFRIEND;
    GF;
    DAD;
    CUSTOM;
}

class CharacterManager {
    public function getCharacterTypeFromString(type:String):CharacterType {
        switch (type) {
            case "boyfriend":
                return BOYFRIEND;
            case "girlfriend":
                return GF;
            case "dad":
                return DAD;
            case "custom":
                return CUSTOM;
            default:
                return NONE;
        }
    }
}