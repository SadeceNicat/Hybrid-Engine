package options;

class SuperSecretSettingsState extends BaseOptionsMenu
{

    public function new()
    {

        title = Language.getPhrase('super_secret_settings', 'Super Secret Settings');
        rpcTitle = 'Super Secret Settings Menu'; //for Discord Rich Presence

        super();
    }
    
    override function create()
    {
        super.create();
        
        // Add your super secret settings options here
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        // Handle any updates for the super secret settings here
    }
}