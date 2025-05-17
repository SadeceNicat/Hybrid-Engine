function onCreate()
	makeLuaSprite('black', 'stages-erects/week1/black', -400, -990);
	scaleLuaSprite('black', 0.8, 0.8); 
	addLuaSprite('black', false);
	
	makeAnimatedLuaSprite('crowdanim', 'stages-erects/week1/crowd', 440, -40)
        addAnimationByPrefix('crowdanim', 'idle', 'Symbol 2 instance', 24, true)
        setScrollFactor('crowdanim', 0.33, 0.33)
        setGraphicSize('crowdanim', getProperty('crowdanim.width')*1.2, getProperty('crowdanim.height')*1.2, true)
        updateHitbox('crowdanim')
        addLuaSprite('crowdanim')
        
	function onBeatHit()
    playAnim('crowdanim', 'idle')
    end
    
    makeLuaSprite('stageback', 'stages-erects/week1/bg', -400, -990);
	scaleLuaSprite('stageback', 0.8, 0.8); 
	addLuaSprite('stageback', false);
	
	makeLuaSprite('server', 'stages-erects/week1/server', -400, -990);
	scaleLuaSprite('server', 0.8, 0.8); 
	addLuaSprite('server', false);
	
	makeLuaSprite('lights', 'stages-erects/week1/lights', -400, -900);
	scaleLuaSprite('lights', 0.8, 0.8); 
	addLuaSprite('lights', true);
    setScrollFactor("lights",0.9,0.9)

end

function onCreatePost()
	if shadersEnabled == true then
		initLuaShader('adjustColor')
		setSpriteShader('boyfriend', 'adjustColor')
		setSpriteShader('dad', 'adjustColor')
		setSpriteShader('gf', 'adjustColor')

		setShaderFloat('boyfriend', 'hue', 12)
		setShaderFloat('boyfriend', 'saturation', 0)
		setShaderFloat('boyfriend', 'contrast', 7)
		setShaderFloat('boyfriend', 'brightness', -23)
		
		setShaderFloat('dad', 'hue', -32)
		setShaderFloat('dad', 'saturation', 0)
		setShaderFloat('dad', 'contrast', -23)
		setShaderFloat('dad', 'brightness', -33)

		setShaderFloat('gf', 'hue', -9)
		setShaderFloat('gf', 'saturation', 0)
		setShaderFloat('gf', 'contrast', -4)
		setShaderFloat('gf', 'brightness', -30)
	end
end