function onCreatePost()
    if shadersEnabled == true then
        initLuaShader('adjustColor')
        for i, object in ipairs({'boyfriend', 'dad', 'gf', 'train'}) do
            setSpriteShader(object, 'adjustColor')
            setShaderFloat(object, 'hue', -0)
            setShaderFloat(object, 'saturation', -30)
            setShaderFloat(object, 'contrast', 0)
            setShaderFloat(object, 'brightness', 0)
        end
	end
end