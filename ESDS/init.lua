local function setIfNotNil(val,newval,name)
	if newval == nil then return end
	assert(typeof(val.Value) == typeof(newval),
		`invalid type given for {name} (expected {typeof(val.Value)}, got {typeof(newval)})`..
		"\nrun this again with the correct types and it should work"
	)
	val.Value = newval
end

return function(explosionPos,canShutdownSystem,destroyEverything,shutdown,explosionOnly,skipTo,skipIntro)
	local selfdestruct = script
	selfdestruct.Name = "selfdestruct"
	local assets = game:GetObjects("rbxassetid://18808036556")[1]
	for i,v in next, assets:GetChildren() do
	v:Clone().Parent = selfdestruct
	print("moved asset")
	end
	setIfNotNil(selfdestruct.Values.explosionPos,explosionPos,"explosionPos")
	setIfNotNil(selfdestruct.Values.canShutdown,canShutdownSystem,"canShutdownSystem")
	setIfNotNil(selfdestruct.Values.destroyeverything,destroyEverything,"destroyEverything")
	setIfNotNil(selfdestruct.Values.shutdown,shutdown,"shutdown")
	setIfNotNil(selfdestruct.Values.skipTimer,explosionOnly,"explosionOnly")
	if not explosionOnly then
		setIfNotNil(selfdestruct.Values.skipto,skipTo,"skipTo")
		setIfNotNil(selfdestruct.Values.skipIntro,skipIntro,"skipIntro")
	end
	selfdestruct.Enabled = true
	selfdestruct.Parent = game:GetService("ReplicatedStorage")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/main.lua"))()
end
