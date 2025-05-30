--Create with TieGuo's Lua Stage Editor
function onCreate()
makeLuaSprite('erect/bg', 'erect/bg', -985, -805)
addLuaSprite('erect/bg', false)
scaleObject('erect/bg', 1.1, 1.1)
setScrollFactor('erect/bg', 1, 1)

makeAnimatedLuaSprite('erect/guy', 'erect/guy', 1398, 407)
addLuaSprite('erect/guy', false)
addAnimationByPrefix('erect/guy', 'erect/guy', 'erect/guy', 24, false)
scaleObject('erect/guy', 1.1, 1.1)
setScrollFactor('erect/guy', 1, 1)

makeAnimatedLuaSprite('erect/sniper', 'erect/sniper', -127, 349)
addLuaSprite('erect/sniper', false)
addAnimationByPrefix('erect/sniper', 'erect/sniper', 'erect/sniper', 24, false)
scaleObject('erect/sniper', 1.1, 1.1)
setScrollFactor('erect/sniper', 1, 1)
end

function handleSetGFSpeed(value)
	if value == 'g' then
	  triggerEvent('Camera Follow Pos', '700', '510')
	elseif value == 'b' then
	  triggerEvent('Camera Follow Pos', '', '')
	elseif value == 'dad' then
	  triggerEvent('Camera Follow Pos', '630', '480')
	elseif value == 'bf' then
	  triggerEvent('Camera Follow Pos', '750', '480')
	end
  end

-- function onUpdate()
--     local hueValue = -25;
--     local saturationValue = -40;
--     local contrastValue = -25;
--     local brightnessValue = -20;
--        setSpriteShader('dad', 'adjustColor')
--        setShaderFloat('dad', 'hue', hueValue)
--        setShaderFloat('dad', 'saturation', saturationValue)
--        setShaderFloat('dad', 'contrast', contrastValue)
--        setShaderFloat('dad', 'brightness', brightnessValue)
       
--        setSpriteShader('gf', 'adjustColor')
--        setShaderFloat('gf', 'hue', hueValue)
--        setShaderFloat('gf', 'saturation', saturationValue)
--        setShaderFloat('gf', 'contrast', contrastValue)
--        setShaderFloat('gf', 'brightness', brightnessValue)
       
--        setSpriteShader('boyfriend', 'adjustColor')
--        setShaderFloat('boyfriend', 'hue', hueValue)
--        setShaderFloat('boyfriend', 'saturation', saturationValue)
--        setShaderFloat('boyfriend', 'contrast', contrastValue)
--        setShaderFloat('boyfriend', 'brightness', brightnessValue)
-- end