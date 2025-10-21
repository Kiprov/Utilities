local assets = game:GetObjects("rbxassetid://18808036556")[1]
local preloadService = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/PreloadService/Source.lua"))().new()
preloadService:SetDirectory("ESDS")
function notify(title,msg,dur)
if getgenv().Silent then return end
game:GetService("StarterGui"):SetCore("SendNotification", {
	    Title = title or "Lorem Ipsum";
	    Duration = dur or 3;
	    Text = msg or "Codice malum!";
})
end
local headers = {"https://github.com/Kiprov/Utilities/blob/main/ESDS/SFX/","?raw=true"}
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
	notify("[ESDS]","Doing a preload sound test.")
-- Test Preload
local test
spawn(function()
test = preloadService:Preload("SFX",headers[1].."trickymazeforlostworld.ogg","beginning_trickymazeforlostworld",nil,".ogg")
end)
for i = 5,1,-1 do
if test ~= nil then break end
wait(1)
end
if test ~= nil then
notify("[ESDS]","Preload successful.")
else
notify("[ESDS]","Preload failed.")
preloadService:SetSpawn(true)
end
notify("[ESDS]","Preloading sounds.")
local snds = assets.selfdestruct.ReplicatedStuff.sndtrack
snds.Parent = game:GetService("SoundService")
wait()
	for i,v in next, snds:GetChildren() do
	if not v.IsLoaded then
	local name = string.split(v.Name,"_")[2]
	preloadService:Preload("SFX",headers[1]..name..".ogg"..headers[2],v.Name,v,".ogg")
	end
	end
	snds.Parent = assets.selfdestruct.ReplicatedStuff
	for i,v in next, assets.selfdestruct:GetChildren() do
	v:Clone().Parent = selfdestruct
	end
	notify("[ESDS]","Preloaded sounds.")
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
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/main.lua"))()
end
