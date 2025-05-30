function onCreatePost()
	-- background shit
	makeLuaSprite('limoSunset2', 'stages-erects/week4/limoSunset2', -120, -50);
	setLuaSpriteScrollFactor('limoSunset2', 0.1, 0.1);

	makeAnimatedLuaSprite('limoDrive2', 'stages-erects/week4/aga',-120, 550);
    setLuaSpriteScrollFactor('limoDrive2', 1, 1);
	makeAnimatedLuaSprite('bgLimo2','stages-erects/week4/bgLimo2', -150, 480);
	setLuaSpriteScrollFactor('bgLimo2', 0.4, 0.4);

	

	makeAnimatedLuaSprite('limoDancer2', 'stages-erects/week4/limoDancer2',550, 100);
    setLuaSpriteScrollFactor('limoDancer2', 0.4, 0.4);

	makeAnimatedLuaSprite('limoDancer3', 'stages-erects/week4/limoDancer2',250, 100);
    setLuaSpriteScrollFactor('limoDancer3', 0.4, 0.4);
	
	makeAnimatedLuaSprite('limoDancer4', 'stages-erects/week4/limoDancer2',850, 100);
    setLuaSpriteScrollFactor('limoDancer4', 0.4, 0.4);
	
	makeAnimatedLuaSprite('limoDancer5', 'stages-erects/week4/limoDancer2',1150, 100);
    setLuaSpriteScrollFactor('limoDancer5', 0.4, 0.4);
	
    
	addLuaSprite('limoSunset2', false);
	callOnHScript("addCloud",{})

	addLuaSprite('bgLimo2', false);

	callOnHScript("addBackSPR",{})

	addAnimationByPrefix('bgLimo2', 'idle', 'background limo pink', 20, true); 
	addLuaSprite('limoDancer2', false);
	addAnimationByPrefix('limoDancer2', 'idle', 'bg dancer sketch PINK', 24, false); 
	addLuaSprite('limoDancer3', false);
	addAnimationByPrefix('limoDancer3', 'idle', 'bg dancer sketch PINK', 24, false);
	addLuaSprite('limoDancer4', false);
	addAnimationByPrefix('limoDancer4', 'idle', 'bg dancer sketch PINK', 24, false);
	addLuaSprite('limoDancer5', false);
	addAnimationByPrefix('limoDancer5', 'idle', 'bg dancer sketch PINK', 24, false);

	addAnimationByPrefix('limoDrive2', 'idle', 'Limo stage', 24, true); 

   
	triggerEvent("Set RTX Data","0,0.26737643097092,0.46806992087293,0.13163650331883,0.13416504015164,0.47936865768999,0.73949063693892,0.44020765937809,0.4777527808101,0.57143889093828,0.7388453437604,0.61579654855929,310.45482173735,18.004121759818")


end

function onBeatHit()
	playAnim("limoDancer2","idle",false)
	playAnim("limoDancer3","idle",false)
	playAnim("limoDancer4","idle",false)
	playAnim("limoDancer5","idle",false)
end
