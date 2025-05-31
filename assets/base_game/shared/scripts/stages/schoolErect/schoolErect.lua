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

end
