local cutsceneFinished = false
function onCreate()    
    if difficultyName ~= "erect" and difficultyName ~= "nightmare" then return end
    makeFlxAnimateSprite('parentsCutscene')
    loadAnimateAtlas('parentsCutscene', 'christmas/parents_shoot_assets')
    addAnimationBySymbol('parentsCutscene', 'anim', 'parents whole scene')
    setProperty('parentsCutscene.x', -519)
    setProperty('parentsCutscene.y', 503)
    addLuaSprite('parentsCutscene', true)
    setProperty('parentsCutscene.visible', false)
    
    makeFlxAnimateSprite('santaCutscene')
    loadAnimateAtlas('santaCutscene', 'christmas/santa_speaks_assets')
    addAnimationBySymbol('santaCutscene', 'anim', 'santa whole scene')
    setProperty('santaCutscene.x', -460)
    setProperty('santaCutscene.y', 500)
    addLuaSprite('santaCutscene', true)
    setProperty('santaCutscene.visible', false)
end

function onEndSong()
    if difficultyName ~= "erect" and difficultyName ~= "nightmare" then return end
    if cutsceneFinished == false then
        if stringEndsWith(curStage, 'Erect') then
            santaPrefix = ''
            if shadersEnabled == true then
                for i, object in ipairs({'parentsCutscene', 'santaCutscene'}) do
                    setSpriteShader(object, 'adjustColor')
                    setShaderFloat(object, 'hue', 5)
                    setShaderFloat(object, 'saturation', 20)
                    setShaderFloat(object, 'contrast', 0)
                    setShaderFloat(object, 'brightness', 0)
                end
            end
        else
            santaPrefix = 'stages[0].'
        end
        setProperty(santaPrefix..'santa.visible', false)
        setProperty('santaCutscene.visible', true)
        playAnim('santaCutscene', 'anim', true)
        playSound('santa_emotion')
        playCutscene()
        return Function_Stop
    end
    return Function_Continue
end

function playCutscene()
    if difficultyName ~= "erect" and difficultyName ~= "nightmare" then return end
    setProperty('inCutscene', true)
    setProperty('boyfriend.stunned', true)
    setProperty('dad.stunned', true)
    setProperty('gf.stunned', true)
    setProperty('camFollow.x', getProperty('santaCutscene.x') + 300 - screenWidth / 2)
    setProperty('camFollow.y', getProperty('santaCutscene.y') - 110 - screenHeight / 2)
    startTween('moveCamera', 'camGame.scroll', {x = getProperty('camFollow.x'), y = getProperty('camFollow.y')}, 2.8, {ease = 'expoOut'})
    doTweenZoom('zoomOutCamera', 'camGame', 0.73, 2, 'expoOut')
    runTimer('parentsLookSanta', 28 / 24)
    runTimer('moveCam', 2.8)
    runTimer('santaDies', 11.375)
    runTimer('camShake', 12.83)
    runTimer('endCutscene', 15)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if difficultyName ~= "erect" and difficultyName ~= "nightmare" then return end
    if tag == 'parentsLookSanta' then
        setProperty('dad.visible', false)
        setProperty('parentsCutscene.visible', true)
        playAnim('parentsCutscene', 'anim', true, false, 28)
    end
    if tag == 'moveCam' then
        setProperty('camFollow.x', getProperty('santaCutscene.x') + 150 - screenWidth / 2)
        setProperty('camFollow.y', getProperty('santaCutscene.y') - 110 - screenHeight / 2)
        startTween('moveCamera', 'camGame.scroll', {x = getProperty('camFollow.x'), y = getProperty('camFollow.y')}, 9, {ease = 'quartInOut'})
        doTweenZoom('zoomOutCamera', 'camGame', 0.79, 9, 'quadInOut')
    end
    if tag == 'santaDies' then
        playSound('santa_shot_n_falls')
    end
    if tag == 'camShake' then
        cameraShake('camGame', 0.005, 0.2)
        setProperty('camFollow.x', getProperty('santaCutscene.x') + 160 - screenWidth / 2)
        setProperty('camFollow.y', getProperty('santaCutscene.y') - 30 - screenHeight / 2)
        startTween('moveCamera', 'camGame.scroll', {x = getProperty('camFollow.x'), y = getProperty('camFollow.y')}, 5, {ease = 'expoOut'})
    end
    if tag == 'endCutscene' then
        cutsceneFinished = true
        endSong()
    end
end