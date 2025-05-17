local lights = {
	"FFFFFF",
	"FF214D",
	"3C77FF",
	"DF3CFF",
	"FFCC3C",
	"47E8A2"
}

function changeColor()
	doTweenColor("light", "light", lights[getRandomInt(1,#lights)], 0.05, "circOut")
end

function onCreatePost()
	changeColor()
end

function onBeatHit()
	if curBeat % 4 == 0 then
		changeColor()
	end
end

function onCreate()
	makeLuaSprite('sky','stages-erects/week3/sky2', -100, 00);
	setLuaSpriteScrollFactor('sky', 0.1, 0.1);
	
	makeLuaSprite('city','stages-erects/week3/city2', -10, 0);
	setLuaSpriteScrollFactor('city', 0.3, 0.3);
	scaleObject('city', 0.85, 0.85);
	makeAnimatedLuaSprite('light', 'stages-erects/week3/light',-10, 0);
	setLuaSpriteScrollFactor('light', 0.3, 0.3);		
	scaleObject('light',0.85, 0.85);
	makeLuaSprite('behindTrain','stages-erects/philly2/behindTrain2', -40, 50);
	makeLuaSprite('street','stages-erects/week3/street2', -40, 50);

	addLuaSprite('sky', false);
	addLuaSprite('city', false);
	addLuaSprite('light', false);
	addLuaSprite('behindTrain', false);
	addLuaSprite('street', false);
end

function onCreatePost()
	if shadersEnabled == true then
        initLuaShader('adjustColor')
        for i, object in ipairs({'boyfriend', 'dad', 'gf', 'train'}) do
            setSpriteShader(object, 'adjustColor')
            setShaderFloat(object, 'hue', -26)
            setShaderFloat(object, 'saturation', -16)
            setShaderFloat(object, 'contrast', 0)
            setShaderFloat(object, 'brightness', -5)
        end
	end
end