local weebSky = "weeb-pico/weebSky"
local weebSchool = "weeb-pico/weebSchool"
local weebStreet = "weeb-pico/weebStreet"
local weebTrees = "weeb-pico/weebTrees"
local weebTreesBack = "weeb-pico/weebTreesBack"
local weebBackTrees = "weeb-pico/weebBackTrees"

function onCreate()
	runHaxeCode('Paths.setCurrentLevel("week6")')
	----bg----
	makeLuaSprite('weebSky', weebSky, 500, 500)
	scaleObject('weebSky', 6, 6)
	setScrollFactor('weebSky', 0.5, 0.7);	
	setProperty('weebSky.antialiasing',false)
	addLuaSprite('weebSky', false)

	makeLuaSprite('weebSchool', weebSchool, 1150, 780)
	scaleObject('weebSchool', 6, 6)
	setScrollFactor('weebSchool', 0.9, 1);	
	setProperty('weebSchool.antialiasing',false)
	addLuaSprite('weebSchool', false)

	makeLuaSprite('weebStreet', weebStreet, 1300, 805)
	scaleObject('weebStreet', 6, 6)	
	setProperty('weebStreet.antialiasing',false)
	addLuaSprite('weebStreet', false)

	makeLuaSprite('weebTreesBack', weebTreesBack, 1270, 780)
	scaleObject('weebTreesBack', 6, 6)	
	setProperty('weebTreesBack.antialiasing',false)
	addLuaSprite('weebTreesBack', false)

	makeLuaSprite('weebTrees', weebTrees, 680, -280)
	scaleObject('weebTrees', 6, 6)	
	setProperty('weebTrees.antialiasing',false)
	addLuaSprite('weebTrees', false)

end

luaDebugMode = true

local path = '../week6/weeb/erect/'

function onCreatePost()
    if shadersEnabled then
        initLuaShader('DropShadow')
        for _, i in pairs({'boyfriend', 'dad', 'gf'}) do
            setSpriteShader(i, 'DropShadow')

            setShaderFloat(i, 'thr', 0.1)
            setShaderFloat(i, 'str', 1)

            setAdjustColor(i, -66, -10, 24, -23)
            setShaderFloat(i, 'AA_STAGES', 2)
            setShaderFloatArray(i, 'dropColor', {83/255, 53/255, 29/255})
            updateFrameInfo(i)
            setShaderFloat(i, 'dist', 5)

            if i == 'boyfriend' then
                setShaderFloat(i, 'ang', 90 * getPropertyFromClass('flixel.math.FlxAngle', 'TO_RAD'))

                setShaderSampler2D(i, 'altMask', path..'masks/picoPixel_mask')
                setShaderFloat(i, 'thr2', 1)
                setShaderBool(i, 'useMask', true)
            elseif i == 'gf' then
                setShaderFloat(i, 'ang', 90 * getPropertyFromClass('flixel.math.FlxAngle', 'TO_RAD'))

                setShaderSampler2D(i, 'altMask', path..'masks/nenePixel_mask')
                setShaderFloat(i, 'thr2', 1)
                setShaderBool(i, 'useMask', true)

                if version >= '1.0' then
                    callOnLuas('addSunsetShader', {''})
                end
            else
                setShaderFloat(i, 'ang', 90 * getPropertyFromClass('flixel.math.FlxAngle', 'TO_RAD'))

                setShaderSampler2D(i, 'altMask', path..'masks/senpai_mask')
                setShaderFloat(i, 'thr2', 1)
                setShaderBool(i, 'useMask', true)
            end
        end
    end
end

function setAdjustColor(spr,b,h,c,s)
    setShaderFloat(spr, 'brightness', b)
    setShaderFloat(spr, 'hue', h)
    setShaderFloat(spr, 'contrast', c)
    setShaderFloat(spr, 'saturation', s)
end

function updateFrameInfo(spr)
    setShaderFloatArray(spr, 'uFrameBounds', {
        getProperty(spr..'.frame.uv.x'), getProperty(spr..'.frame.uv.y'),
        getProperty(spr..'.frame.uv.width'), getProperty(spr..'.frame.uv.height')
    })
    setShaderFloat(spr, 'angOffset', getProperty(spr..'.frame.angle') * getPropertyFromClass('flixel.math.FlxAngle', 'TO_RAD'))
end

function onUpdatePost()
    if shadersEnabled then
        for _, i in pairs({'boyfriend', 'dad', 'gf'}) do
            updateFrameInfo(i)
        end

        if version >= '1.0' then
            updateFrameInfo('abotSpeaker')
        end
    end
end