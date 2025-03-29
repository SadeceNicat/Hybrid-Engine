package haxeui;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.containers.Box;
import js.Browser;
import js.html.IFrameElement;

/*
    Note, to use this custom component from xml, the following must be in your module.xml:

    <module>
        ...
        <components>
            <component package="custom" />
        </components>
        ...
    </module>
    
*/
class IFrame extends Box {
    private var _iframe:IFrameElement = null;
    
    public function new() {
        super();
        _iframe = Browser.document.createIFrameElement();
        _iframe.frameBorder = "none";
        this.element.append(_iframe);
    }
    
    public var url(get, set):String;
    private function get_url():String {
        return _iframe.src;
    }
    private function set_url(value:String):String {
        _iframe.src = value;
        return value;
    }
    
    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        
        if (width > 0 && height > 0) {
            _iframe.width = HtmlUtils.px(width);
            _iframe.height = HtmlUtils.px(height);
        }
        
        return b;
    }
}