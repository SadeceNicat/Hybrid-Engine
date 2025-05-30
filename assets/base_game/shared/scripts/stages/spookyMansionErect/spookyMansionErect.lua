local HybridModule = require("HybridModule")

function light(aga)
    setProperty("camGame.zoom",getProperty("camGame.zoom")+0.025);
    doTweenZoom("camGameZ", "camGame", getProperty("defaultCamZoom"), 0.5, "linear");
    if aga == true then
    else
        playSound("thunder_1");
    end
    setProperty("spooky-erect2light.alpha",1)
    setProperty("spooky-erectlight.alpha",1)
    triggerEvent("Set RTX Data","0,0,0.10639353098723,0.7,0,0.08,0.38101788903233,0.55173364838059,0,0.23921009327483,0.3898209110023,1,212.4,50")
    doTweenAlpha("spooky-erectlight", "spooky-erectlight", 0, 1, "circOut")
    doTweenAlpha("spooky-erect2light", "spooky-erect2light", 0, 1, "circOut")
    triggerEvent("Play Animation","scared","boyfriend")
    triggerEvent("Play Animation","scared","gf")
    HybridModule.setTimer(function ()
        triggerEvent("Set RTX Data","0,0,0.07,0.7,0,0.08,0.19,0.65539815035563,0,0.37,0.28,0.67,212.4,37.716068999886")
    end,200,1)
    HybridModule.setTimer(function ()
        triggerEvent("Set RTX Data","0,0,0.07,0.7,0,0.08,0.19,0.76666666666667,0,0.37,0.28,0.61666666666667,212.4,25.801435044587")
    end,500,1)
    HybridModule.setTimer(function ()
        triggerEvent("Set RTX Data","0,0,0.07,0.7,0,0.08,0.19,0.78411499854382,0,0.37,0.28,0.58888888888889,212.4,25.5")
    end,800,1)
    HybridModule.setTimer(function ()
        triggerEvent("Play Animation","idle","boyfriend")
        triggerEvent("Play Animation","danceRight","gf")
        triggerEvent("Set RTX Data","0,0,0.07,0.7,0,0.08,0.19,0.86,0,0.37,0.28,1,212.4,13.588924257223")
    end,1000,1)
end

function onEvent(ename)
    if ename == "Lightbolt" then
        light(true);
    end
end

function onCreate()
    HybridModule.load();
    makeAnimatedLuaSprite('crowdanim', 'stages-erects/week2/bgtrees', -140, -40)
    addAnimationByPrefix('crowdanim', 'idle', 'bgtrees0', 24, true)
    setScrollFactor('crowdanim', 0.33, 0.33)
    setGraphicSize('crowdanim', getProperty('crowdanim.width')*1.5, getProperty('crowdanim.height')*1.5, true)
    updateHitbox('crowdanim')
    addLuaSprite('crowdanim')
        
	function onBeatHit()
    playAnim('crowdanim', 'idle')
    if curBeat % 28 == 0 then
        light();
    end
    end
  
    
	makeLuaSprite('spooky-erect','stages-erects/week2/spooky', -500, -100);
	addLuaSprite('spooky-erect', false);

    makeLuaSprite('spooky-erectlight','stages-erects/week2/erect/bgLight', -500, -100);
	addLuaSprite('spooky-erectlight', false);

    makeLuaSprite('spooky-erect2','stages-erects/week2/stairsDark', -500, -100);
	addLuaSprite('spooky-erect2', true);

    makeLuaSprite('spooky-erect2light','stages-erects/week2/erect/stairsLight', -500, -200);
	addLuaSprite('spooky-erect2light', true);
    setProperty("spooky-erect2light.alpha",0)
    setProperty("spooky-erectlight.alpha",0)
	
end

