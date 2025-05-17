package backend;

typedef MetadataProp = {
    var album:String;
    var charter:String;
    var artist:String;
    var ratings:Dynamic;
}

class FreeplayProp {
    public var songName:String;
    public var ratings:Map<String, Int>;
    public var ratingsErect:Map<String, Int>;
    public var songMetadata:MetadataProp;
    public var songMetadataErect:MetadataProp;
    public var data:String;
    public var dataErect:String;
    public function new(songName:String) {
        this.songName = songName;

        this.ratings = new Map<String, Int>();
        this.ratingsErect = new Map<String, Int>();

        try {
            data = Paths.getTextFromFile("data/songs/" + songName + "/" + songName + "-metadata.json");
            trace(data);
            if (data != null) {
                this.songMetadata = tjson.TJSON.parse(data);

                for (key in Reflect.fields(this.songMetadata.ratings)) {
                    var value:Dynamic = Reflect.field(this.songMetadata.ratings, key);
                    if (Std.isOfType(value, Int)) {
                        this.ratings.set(key, value);
                    } else {
                        this.ratings.set(key, Std.parseInt(Std.string(value)));
                    }
                }
                trace(this.songMetadata.ratings);
            } else {
                this.songMetadata = {
                    album: "placeholder",
                    charter: "",
                    artist: "",
                    ratings: new Map<String, Int>()
                };
            }
        }

        try {
            dataErect = Paths.getTextFromFile("data/songs/" + songName + "/" + songName + "-metadata-erect.json");
            if (dataErect != null) {
                this.songMetadataErect = tjson.TJSON.parse(dataErect);

                for (key in Reflect.fields(this.songMetadataErect.ratings)) {
                    var value:Dynamic = Reflect.field(this.songMetadataErect.ratings, key);
                    if (Std.isOfType(value, Int)) {
                        this.ratingsErect.set(key, value);
                    } else {
                        this.ratingsErect.set(key, Std.parseInt(Std.string(value)));
                    }
                }
                trace(this.songMetadataErect.ratings);
            } else {
                this.songMetadataErect = {
                    album: "placeholder",
                    charter: "",
                    artist: "",
                    ratings: new Map<String, Int>()
                };
            }
        }
    }
}