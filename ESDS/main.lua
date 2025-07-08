--!strict
--[[
	the main self destruct thing
	
	by @jnprge 2023-2025
--]]

local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local twserv = game:GetService("TweenService")
local tags = game:GetService("CollectionService")
local debris = game:GetService("Debris")
local http = game:GetService("HttpService")
local runserv = game:GetService("RunService")
local physics = game:GetService("PhysicsService")
local contentProvider = game:GetService("ContentProvider")

local RANDOM = Random.new(DateTime.now().UnixTimestampMillis)

local char = string.char

-- modules

local mods = script.Modules
mods.Parent = nil

local maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/vendor/Maid.lua"))()

local createWallHole = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/genWallHole.lua"))()
local shatterGlass = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/shatterGlass.lua"))()

local bufferTypes = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/misc/bufferTypes.lua"))()

local getTrisForObj = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/getTrisForObj/main.lua"))()
local mapDefiner = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/mapDefiner/main.lua"))()
local geometry = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/mapDefiner/geometryFinder.lua"))()
local staticize = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/staticize.lua"))()

local util = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/main.lua"))()
local tblUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/tables.lua"))()
local sndUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/sounds.lua"))()
local mathUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/math.lua"))()

local ignoreHandler = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/ignoreHandler.lua"))()

-- SELF DESTRUCT SETTINGS --

local values = script.Values
values.Parent = nil

local shutdownOnEnd = values.shutdown.Value
local destroyMap = values.destroyeverything.Value
local skipto = values.skipto.Value
local onlyExplode = values.skipTimer.Value or skipto <= 0
local skipIntro = skipto ~= 600 or values.skipIntro.Value
local canShutdownSystem = values.canShutdown.Value
local setexplosionpos = values.explosionPos.Value or Vector3.new()
local safenames = values.safeNames.Value

values:Destroy()

local music = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/lists/musicList.lua"))()

-- other important instances

local RE = Instance.new("BindableEvent")
RE.Name = safenames and "BE" or util.genRandomText(50)

local soundassets,modelassets = script.SoundAssets,script.ModelAssets
soundassets.Parent = nil
modelassets.Parent = nil

local mainGlobalValue = Instance.new("StringValue")
mainGlobalValue.Name = safenames and "MainValue" or util.genRandomText(1002)

local repStuff = script.ReplicatedStuff
local tracks = repStuff.sndtrack
local sndgroups = repStuff.sndgroups

if not safenames then
	tracks.Name = util.genRandomText(RANDOM:NextInteger(3,1000))
	sndgroups.Name = util.genRandomText(RANDOM:NextInteger(3,1000))
end

local allMus = {}
for i,v in ipairs(tracks:GetChildren()) do
	allMus[v.Name] = v
end

local gvalsNonEditable = {
	curPlaying = "",
	startTime = -1,
	stage = 0,
	shakeMultiplier = 0,
	pressedShutdownButtons = 0,
	totalShutdownButtons = 0,
	tiltingCamera = false,
	visible = false,
	altVisible = false,
	shiftInfo = false,
	
	musFadeStart = -1,
	musFadeEnd = -1,
	
	buttonsEnabled = false,
	timerFrozen = false,
	setTimerTime = 0,
	
	overheatTimer = false,
	overheatTimerStart = 0,
	overheatTimerEnd = 0
}
local gvalsSort:{{Name: string,Type: bufferTypes.baseBufferType}} = {
	{Name = "curPlaying",Type = bufferTypes.String},
	{Name = "startTime",Type = bufferTypes.Float64},
	{Name = "stage",Type = bufferTypes.UInt8},
	{Name = "shakeMultiplier",Type = bufferTypes.Float32},
	{Name = "pressedShutdownButtons",Type = bufferTypes.UInt8},
	{Name = "totalShutdownButtons",Type = bufferTypes.UInt8},
	{Name = "tiltingCamera",Type = bufferTypes.Boolean},
	{Name = "visible",Type = bufferTypes.Boolean},
	{Name = "altVisible",Type = bufferTypes.Boolean},
	{Name = "shiftInfo",Type = bufferTypes.Boolean},

	{Name = "musFadeStart",Type = bufferTypes.Float64},
	{Name = "musFadeEnd",Type = bufferTypes.Float64},
	
	{Name = "timerFrozen",Type = bufferTypes.Boolean},
	{Name = "setTimerTime",Type = bufferTypes.Float32},
	{Name = "buttonsEnabled",Type = bufferTypes.Boolean},

	{Name = "overheatTimer",Type = bufferTypes.Boolean},
	{Name = "overheatTimerStart",Type = bufferTypes.Float64},
	{Name = "overheatTimerEnd",Type = bufferTypes.Float64},
}

local attributeLookup = {
	TimePlayed = util.genRandomGUID(),
	Rate = util.genRandomGUID(),
	EndTime = util.genRandomGUID(),
	Delay = util.genRandomGUID()
}
local attributeLookupSort = {
	"TimePlayed",
	"Rate",
	"EndTime",
	"Delay",
}

local tagLookup = {
	AlwaysEmit = util.genRandomGUID(),
	SyncPlayback = util.genRandomGUID(),
	IsMusic = util.genRandomGUID(),
}
local tagLookupSort = {
	"AlwaysEmit",
	"SyncPlayback",
	"IsMusic"
}

for _,name in pairs(attributeLookupSort) do
	local uuid = attributeLookup[name]
	local n = `_ATT_{name}`
	table.insert(gvalsSort,{Name = n, Type = bufferTypes.String})
	gvalsNonEditable[n] = uuid
end
for _,name in pairs(tagLookupSort) do
	local uuid = tagLookup[name]
	local n = `_TAG_{name}`
	table.insert(gvalsSort,{Name = n, Type = bufferTypes.String})
	gvalsNonEditable[n] = uuid
end

local function generateGValsBuffer()
	local baseBuffer,offset = buffer.create(0),0
	for ix,info in ipairs(gvalsSort) do
		baseBuffer,offset = info.Type.Write(baseBuffer,offset,gvalsNonEditable[info.Name])
	end
	return baseBuffer
end

local function updateGVal()
	mainGlobalValue.Value = util.tobase64(buffer.tostring(generateGValsBuffer()))
end
updateGVal()

gvalsNonEditable.__index = gvalsNonEditable
gvalsNonEditable.__newindex = function(_,ix,val)
	if gvalsNonEditable[ix] == nil then return end
	gvalsNonEditable[ix] = val
	updateGVal()
end

local gvals = setmetatable({},gvalsNonEditable)

if not safenames then
	for _,mus in pairs(allMus) do
		mus.Name = util.genRandomGUID()
	end
end

local allSoundGroups = {}
for _,g in ipairs(sndgroups:GetChildren()) do
	allSoundGroups[g.Name] = g
	if safenames then continue end
	g.Name = util.genRandomGUID()
	for _,v in ipairs(g:GetDescendants()) do
		v.Name = util.genRandomText(RANDOM:NextInteger(3,1000))
	end
end

tracks:AddTag(tagLookup.IsMusic)
tracks.Parent = rs
sndgroups.Parent = rs
RE.Parent = rs
mainGlobalValue.Parent = rs

local function playtrack(tr:Instance,time:number,del:number?)
	gvals.curPlaying = tr.Name .. "`" .. time + (del or 0)
end
local function syncSoundTime(snd:Sound,del:number?)
	snd:Stop()
	task.delay(del,function()
		snd.Playing = true
	end)
	snd:SetAttribute(attributeLookup.TimePlayed,workspace:GetServerTimeNow()+(del or 0))
	snd:AddTag(tagLookup.SyncPlayback)
end

local allMDHUDs = {}
do
	local addedev

	local sc = script.MeltdownHUD
	sc.MainDisasterLocal.val.Value = mainGlobalValue
	sc.MainDisasterLocal.mus.Value = tracks
	sc.MainDisasterLocal.rem.Value = RE
	sc.Parent = nil
	
	local function add(plr:Player)
		local cl = sc:Clone()
		table.insert(allMDHUDs,cl)
		cl.Parent = plr:FindFirstChildWhichIsA("PlayerGui")
		local clientScript = cl.MainDisasterLocal
		spawn(function()
		--!strict
-- more code!!!! my brain burn

local rand = Random.new()

local twserv = game:GetService("TweenService")
local runserv = game:GetService("RunService")
local http = game:GetService("HttpService")
local tags = game:GetService("CollectionService")
local lighting = game:GetService("Lighting")
local content = game:GetService("ContentProvider")
local guiserv = game:GetService("GuiService")
local sndserv = game:GetService("SoundService")

local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer

local maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/maid.lua"))()

local sharedValue = clientScript.val.Value clientScript.val:Destroy()
local sndtrack = clientScript.mus.Value clientScript.mus:Destroy()
local re:BindableEvent = clientScript.rem.Value clientScript.rem:Destroy()

local byte = string.byte
local getservertime:()->number = function() return workspace:GetServerTimeNow() end

local UI = clientScript.Parent
local info = UI.infoPopup --UI.InfoPopup

local overlays = UI.overlays

local musPopup = UI.musPopup

local headerContainer = UI.headerContainer
local etimerBase = headerContainer.ExplosionTimer
local etimer = headerContainer.ExplosionTimer.offset
local notificationsContainer = headerContainer.Notifications

local etimerAltBase = UI.explosionTimerAlt
local etimerAlt = etimerAltBase.timer

local particleUI = UI.mainParticleContainer

local templates = clientScript.Templates
local notificationSlideText = templates.slideThroughText

local etimervisible = false
local infoShifted = false
local popupvisible = false
local shutdownExpiration,justExpired = false,false
local timerLEDActive = true
--local topframevisible = false

local warnmiddle = templates.middleInfo --info.WarningMiddle

local altTimerVisibleFlag = 0

local brokenCamera = false
local lastShakeCFrame = CFrame.identity
local cameraFOVOffset = 0

local camera = workspace.CurrentCamera do
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		camera = workspace.CurrentCamera
	end)
end

local INVALID_CFRAME = CFrame.new(Vector3.one*math.huge)
local TRUE_NIL = "TRUENILProperty!!!!!!..."

task.spawn(content.PreloadAsync,content,{ -- preload some important assets we need now/later
	-- preload UI
	"rbxassetid://18698135273",
	"rbxassetid://11424813044",
	"rbxassetid://138363533633368",
	"rbxassetid://75394014458432",
	
	-- preload warning assets
	"rbxassetid://12202086629",
	"rbxassetid://12274629436",
	"rbxassetid://12274630653",
	"rbxassetid://12459168450",
	"rbxassetid://18724466420",
	
	-- preload camera break
	"rbxassetid://6737582037",
	"rbxassetid://2971286302",
	"rbxassetid://9040512330",
	"rbxassetid://166047422",

	-- preload particles
	"rbxassetid://11556561764",
	"rbxassetid://18625878475",
	
	-- preload some workspace ui stuff
	"rbxassetid://18686830142",
	"rbxassetid://18775113410"
})

local function createsnd(sndid:string,props:{[string]: any}?,autoPlay:boolean?):Sound
	props = props or {}
	local snd = Instance.new("Sound")
	snd.SoundId = sndid
	if props then
		for i,v in pairs(props) do
			if i == "Parent" then continue end
			snd[i] = v
		end
		if props.Parent ~= TRUE_NIL then
			snd.Parent = props.Parent or plr
		end
	else
		snd.Parent = plr
	end
	if autoPlay then
		snd:Resume()
	end
	return snd
end
local function createtempsnd(sndid:string,props:{[string]: any}?)
	local snd = createsnd(sndid,props)
	snd.PlayOnRemove = true
	snd:Destroy()
end
local function createtempsndthatloopsshort(sndid:string,props:{[string]: any}?,loopTimes:number)
	task.spawn(function()
		local snd = createsnd(sndid,props)
		if not snd.IsLoaded then
			snd.Loaded:Wait()
		end
		for i = 1,loopTimes do
			snd:Play()
			task.wait(snd.TimeLength)
		end
		snd:Destroy()
	end)
end
local function quicktween(inst:Instance,twinfo:TweenInfo,goals:{[string]: any},endfunc:((Enum.PlaybackState)->())?):Tween
	local tw = twserv:Create(inst,twinfo,goals)
	tw:Play()
	if endfunc then
		tw.Completed:Connect(endfunc)
	end
	return tw
end
local function quickset<T>(instances:{Instance},prop:string,val:T)
	for i,v in pairs(instances) do
		v[prop] = val
	end
end
local function lerp(a:number,b:number,c:number):number
	return a+(b-a)*c
end

local allMusVolumes = {}
for _,mus:Sound in ipairs(sndtrack:GetChildren()) do
	if not mus:IsA("Sound") then
		continue
	end
	
	allMusVolumes[mus] = mus.Volume
end

local function playSndFromTimestamp(snd:Sound,started:number): boolean?
	if snd.SoundId == "" then
		return -- bad sound
	end
	if not snd.IsLoaded then
		local status
		while true do
			--if status then
			--	print("got unknown status",snd,status)
			--end
			content:PreloadAsync({snd},function(_,stat)
				status = stat
			end)
			if status == Enum.AssetFetchStatus.Failure then
				--print("bad load",snd,status)
				return -- bad asset
			end
			if status == Enum.AssetFetchStatus.Success or status == Enum.AssetFetchStatus.Loading then
				break
			end
			task.wait()
		end
		--print("loaded",snd,"that used",snd.SoundId)
	end
	if not snd.IsLoaded then
		snd.Loaded:Wait() -- just in case
	end
	if getservertime()-started > snd.TimeLength and not snd.Looped then
		return -- sound already played past its timelength
	end
	if getservertime()-started < 0 then
		repeat task.wait() until getservertime()-started > 0
	end
	
	local elapsed = getservertime()-started
	local start = snd.PlaybackRegionsEnabled and snd.PlaybackRegion.Min or 0
	
	snd:Resume()
	if snd.PlaybackRegionsEnabled and snd.Looped then
		local lmin,lmax = snd.LoopRegion.Min,snd.LoopRegion.Max

		if elapsed > lmin then
			snd.TimePosition = start+(((elapsed-lmin)%(lmax-lmin))+lmin)
			return true
		end
	end
	snd.TimePosition = start+(elapsed%snd.TimeLength)
	return true
end

local function getDictLength(dictionary)
	local amnt = 0
	for _ in pairs(dictionary) do
		amnt += 1
	end
	return amnt
end

local function nothingBurger() end

local lastProps = {}
local function temporaryStaticize(inst:Instance,prop:string,val:any,onNewValue:((any)->nil)?,forceEnabled:boolean?):()->()
	local tb = lastProps[inst]
	if not tb then
		tb = {
			doNotEditFurther = false,
			props = {},
			propsMaids = {},
			didPropChangeTable = {}
		}
	end

	if tb.doNotEditFurther then return nothingBurger end
	tb.doNotEditFurther = forceEnabled
	if tb.propsMaids[prop] then
		tb.propsMaids[prop]:Destroy()
	end

	local lastval = tb.props[prop] or inst[prop]

	tb.props[prop] = lastval
	inst[prop] = val

	local alive = true
	local m = maid.new()
	m:GiveTask(function()
		alive = false
		inst[prop] = lastval
		tb.doNotEditFurther = false
	end)
	m:GiveTask(inst:GetPropertyChangedSignal(prop):Connect(function()
		if tb.didPropChangeTable[prop] then tb.didPropChangeTable[prop] = false return end
		tb.didPropChangeTable[prop] = true
		lastval = inst[prop]
		if onNewValue then
			task.spawn(onNewValue,lastval)
		end
		task.defer(function()
			inst[prop] = val
		end)
	end))
	m:GiveTask(inst.Destroying:Connect(function()
		m:Destroy()
	end))
	tb.propsMaids[prop] = m

	return function()
		if not alive then return end
		m:Destroy()
		tb.propsMaids[prop] = nil
		if getDictLength(tb.propsMaids) == 0 then
			lastProps[inst] = nil
		end
	end
end

local lastCameraFOVOffset = cameraFOVOffset
local cameraFOVCutUpperBound = 0
local cameraFOVCutLowerBound = 0

local cameraFOVBound = NumberRange.new(1,120)
local function stepCameraZoom()
	local newFOV = camera.FieldOfView+(cameraFOVOffset-lastCameraFOVOffset)
	lastCameraFOVOffset = cameraFOVOffset
	if newFOV > cameraFOVBound.Max then
		lastCameraFOVOffset -= newFOV-cameraFOVBound.Max
	elseif newFOV < cameraFOVBound.Min then
		lastCameraFOVOffset += cameraFOVBound.Min-newFOV
	end
	workspace.CurrentCamera.FieldOfView = math.clamp(newFOV,cameraFOVBound.Min,cameraFOVBound.Max)
	
	--if cameraFOVOffset > 0 then
	--	local trueFOVOffset = math.max(1+(-cameraFOVOffset/90),1e-4)
	--	camera.CFrame *= CFrame.fromMatrix(Vector3.zero,Vector3.xAxis*trueFOVOffset,Vector3.yAxis*trueFOVOffset,Vector3.zAxis)
	--else
	--	camera.CFrame *= CFrame.fromMatrix(Vector3.zero,Vector3.xAxis,Vector3.yAxis,Vector3.zAxis*math.max(1+(cameraFOVOffset/90),1e-4))
	--end
end

type UIParticle = {
	Object: ImageLabel,

	Position: Vector2,
	Velocity: Vector2,
	RotationSpeed: number,

	UUID: string?,
}
type UIParticleGroup = {
	Particles: {[string]: UIParticle},
	ParticleCount: number
}
local activeParticles:{[string]:UIParticleGroup} = {}
local function getParticleGroup(groupName:string):UIParticleGroup
	local group = activeParticles[groupName]
	if not group then
		group = {
			Particles = {},
			ParticleCount = 0
		}
		activeParticles[groupName] = group
	end
	return group
end
local function addToParticleGroup(groupName:string,particleData:UIParticle)
	local group = getParticleGroup(groupName)
	local uuid = http:GenerateGUID(false)
	particleData.UUID = uuid
	group.Particles[uuid] = particleData
	group.ParticleCount += 1
	return particleData
end
local function removeObjectFromLiteralParticleGroup(group:UIParticleGroup,particleData:UIParticle)
	if not particleData.UUID then return end
	group.Particles[particleData.UUID] = nil
	group.ParticleCount -= 1
end
local function removeObjectFromParticleGroup(groupName:string,particleData:UIParticle)
	if not particleData.UUID then return end
	local group = getParticleGroup(groupName)
	removeObjectFromLiteralParticleGroup(group,particleData)
end

local function getScaledPos(pos:Vector2):Vector2
	return Vector2.new(pos.X/UI.AbsoluteSize.X,pos.Y/UI.AbsoluteSize.Y)
end

local function getTrueOffsetsBasedOff(container:GuiObject):(Vector2, Vector2)
	local sizeScale = Vector2.new(container.Size.X.Scale,container.Size.Y.Scale)
	local anchorOffset = container.AnchorPoint+Vector2.new(
		-container.Position.X.Scale/sizeScale.X,
		-container.Position.Y.Scale/sizeScale.Y
	)
	return sizeScale,anchorOffset
end

local sparkSnds = {
	"rbxassetid://473438819",
	"rbxassetid://743901241",
	"rbxassetid://743901331",
	"rbxassetid://583038257",
	"rbxassetid://583038356",
	"rbxassetid://743901405",
}
task.spawn(content.PreloadAsync,content,sparkSnds)

local particles,activeParticleStepFunctions do
	particles = {
		smoke = function(pos: Vector2, initVel: Vector2?, parent: Instance?, ZIndex: number?)
			local size = .1*rand:NextNumber(0.5,1.1)

			local smokeParticle = Instance.new("ImageLabel")
			smokeParticle.AnchorPoint = Vector2.new(.5,.5)
			smokeParticle.Image = "rbxasset://textures/particles/smoke_main.dds"
			smokeParticle.BackgroundTransparency = 1
			smokeParticle.Rotation = rand:NextNumber(0,360)
			smokeParticle.ImageTransparency = 1
			smokeParticle.Size = UDim2.fromScale(size/2,size/2)
			smokeParticle.Position = UDim2.fromScale(pos.X,pos.Y)
			smokeParticle.ZIndex = ZIndex or smokeParticle.ZIndex
			Instance.new("UIAspectRatioConstraint",smokeParticle).AspectRatio = 1
			smokeParticle.Parent = parent or particleUI

			local vel = (initVel or Vector2.zero)+Vector2.new(rand:NextNumber(-.5,.5),rand:NextNumber(-3,3))

			local particle = addToParticleGroup("smoke",{
				Object = smokeParticle,
				Position = pos,
				Velocity = vel,
				RotationSpeed = rand:NextNumber(-30,30)
			})
			quicktween(smokeParticle,TweenInfo.new(.3,Enum.EasingStyle.Linear),{ImageTransparency = 0,Size = UDim2.fromScale(size,size)},function()
				quicktween(smokeParticle,TweenInfo.new(3,Enum.EasingStyle.Linear),{ImageTransparency = 1,Size = UDim2.new()},function()
					if not smokeParticle.Parent then return end
					smokeParticle:Destroy()
					removeObjectFromParticleGroup("smoke",particle)
				end)
			end)
		end,
		spark = function(pos: Vector2, initVel: Vector2?, parent: Instance?, ZIndex: number?)
			local size = .03*rand:NextNumber(0.5,1.1)
			local sparkParticle = Instance.new("ImageLabel")
			sparkParticle.AnchorPoint = Vector2.new(.5,.5)
			sparkParticle.Image = ""
			sparkParticle.BorderSizePixel = 0
			sparkParticle.ImageTransparency = 1
			sparkParticle.BackgroundTransparency = 0
			sparkParticle.BackgroundColor3 = Color3.new(1,1,1)
			sparkParticle.Size = UDim2.fromScale(size,size)
			sparkParticle.Position = UDim2.fromScale(pos.X,pos.Y)
			sparkParticle.ZIndex = (ZIndex or sparkParticle.ZIndex)+1
			local aspect = Instance.new("UIAspectRatioConstraint",sparkParticle)
			aspect.AspectRatio = 10
			sparkParticle.Parent = parent or particleUI

			createtempsnd(sparkSnds[math.random(#sparkSnds)],{Volume = 0.4,PlaybackSpeed = 1.2*rand:NextNumber(0.85,1.2)})
			local sparkBright = Instance.new("ImageLabel")
			sparkBright.ImageColor3 = Color3.fromRGB(255, 216, 176)
			sparkBright.AnchorPoint = Vector2.new(.5,.5)
			sparkBright.Image = "rbxassetid://18625878475"
			sparkBright.BackgroundTransparency = 1
			sparkBright.Size = UDim2.fromScale(size*7,size*7)
			sparkBright.Position = UDim2.fromScale(pos.X,pos.Y)
			sparkBright.ZIndex = ZIndex or sparkParticle.ZIndex
			Instance.new("UIAspectRatioConstraint",sparkBright).AspectRatio = 1
			sparkBright.Parent = parent or particleUI
			quicktween(sparkBright,TweenInfo.new(.2,Enum.EasingStyle.Linear),{Size = UDim2.new(),ImageTransparency = 1},function()
				sparkBright:Destroy()
			end)

			local vel = (initVel or Vector2.zero)+Vector2.new(rand:NextNumber(-5,5),rand:NextNumber(-15,-7))
			local particle = addToParticleGroup("spark",{
				Object = sparkParticle,
				Position = pos,
				Velocity = vel,
				RotationSpeed = 0
			})
			quicktween(sparkParticle,TweenInfo.new(.1,Enum.EasingStyle.Linear),{BackgroundColor3 = Color3.new(1,1,.7)},function()
				--quicktween(aspect,TweenInfo.new(.3,Enum.EasingStyle.Linear),{AspectRatio = 1})
				quicktween(sparkParticle,TweenInfo.new(.7,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false),{BackgroundColor3 = Color3.new(.5,.3,0)})
				quicktween(sparkParticle,TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,.4),{
					BackgroundColor3 = Color3.new(.5,.3,0),
					BackgroundTransparency = 1,
					Size = UDim2.new()
				},function()
					if not sparkParticle.Parent then return end
					sparkParticle:Destroy()
					removeObjectFromParticleGroup("spark",particle)
				end)
			end)
		end,
		shockwave = function(pos: Vector2, initVel: Vector2?, parent: Instance?, ZIndex: number?)
			local shockParticle = Instance.new("ImageLabel")
			shockParticle.AnchorPoint = Vector2.new(.5,.5)
			shockParticle.Image = "rbxassetid://11556561764"
			shockParticle.BackgroundTransparency = 1
			shockParticle.ImageTransparency = 0.6
			shockParticle.ImageColor3 = Color3.fromRGB(255, 210, 163)
			shockParticle.ResampleMode = Enum.ResamplerMode.Pixelated
			shockParticle.Size = UDim2.new()
			shockParticle.Position = UDim2.fromScale(pos.X,pos.Y)
			shockParticle.ZIndex = ZIndex or shockParticle.ZIndex
			shockParticle.Parent = parent or particleUI
			Instance.new("UIAspectRatioConstraint",shockParticle).AspectRatio = 1
			
			createtempsnd("rbxassetid://76974269378573",{Volume = 0.6,PlaybackSpeed = 1.2*rand:NextNumber(0.85,1.2)})

			local particle = addToParticleGroup("shockwave",{
				Object = shockParticle,
				Position = pos,
				Velocity = Vector2.zero,
				RotationSpeed = 0
			})
			quicktween(shockParticle,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Size = UDim2.fromScale(16,16),ImageTransparency = 1},function()
				if not shockParticle.Parent then return end
				shockParticle:Destroy()
				removeObjectFromParticleGroup("shockwave",particle)
			end)
		end,
	}

	activeParticleStepFunctions = {
		smoke = function(group: UIParticleGroup,dt: number)
			for _,particle in pairs(group.Particles) do
				particle.Velocity += Vector2.yAxis*dt*-10
				particle.Position += particle.Velocity*dt/30
				particle.Object.Position = UDim2.fromScale(particle.Position.X,particle.Position.Y)
				particle.Object.Rotation += particle.RotationSpeed*dt

				if particle.Position.Y < -.12 then
					particle.Object:Destroy()
					removeObjectFromLiteralParticleGroup(group,particle)
				end
			end
		end,
		spark = function(group: UIParticleGroup,dt: number)
			for _,particle in pairs(group.Particles) do
				particle.Velocity += Vector2.yAxis*dt*100
				particle.Position += particle.Velocity*dt/30

				local dir = particle.Position-particle.Velocity
				local ang = math.atan2(dir.Y,dir.X*5)
				particle.Object.Position = UDim2.fromScale(particle.Position.X,particle.Position.Y)
				particle.Object.Rotation = math.deg(ang)

				if particle.Position.Y > 1.1 then
					particle.Object:Destroy()
					removeObjectFromLiteralParticleGroup(group,particle)
				end
			end
		end,
		shockwave = function(group: UIParticleGroup,dt: number)

		end,
	}
end

local gvals = {}
local boundToGValUpdates = {}

local usedAttributes = {
	"TimePlayed",
	"Rate",
	"EndTime",
	"Delay"
}
local attributeLookup = {}
local attributeReverseLookup = {}
local usedTags = {
	"AlwaysEmit",
	"SyncPlayback",
	"IsMusic"
}
local tagLookup = {}
local tagReverseLookup = {}

local function bindtovalue<T>(val:{Value: T, Changed: RBXScriptSignal},func:(T)->nil):RBXScriptConnection
	task.spawn(func,val.Value)
	return val.Changed:Connect(func) :: RBXScriptConnection
end
local function bindToGValue<T>(val:string,func:(T)->nil):()->()
	if gvals[val] ~= nil then
		task.spawn(func,gvals[val])
	end
	local tb = boundToGValUpdates[val]
	if not tb then
		tb = {}
		boundToGValUpdates[val] = tb
	end
	table.insert(tb,func)
	return function()
		local i = table.find(tb,func)
		if i then
			table.remove(tb,i)
		end
	end
end
do
	type baseBufferType = {
		Write: (buff:buffer,offset:number,val:any)->(buffer,number),
		Read: (buff:buffer,offset:number)->(any,number)
	}
	local bufferTypes:{[string]:baseBufferType} = {} do
		local function extendBufferBy(buff:buffer,extend:number):buffer
			local newBuffer = buffer.create(buffer.len(buff)+extend)
			buffer.copy(newBuffer,0,buff,0)
			return newBuffer
		end

		bufferTypes.UInt8 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,1)
				buffer.writeu8(b,offset,val)
				return b,offset+1
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readu8(buff,offset),offset+1
			end
		})
		bufferTypes.Int8 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,1)
				buffer.writei8(b,offset,val)
				return b,offset+1
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readi8(buff,offset),offset+1
			end
		})

		bufferTypes.UInt16 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,2)
				buffer.writeu16(b,offset,val)
				return b,offset+2
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readu16(buff,offset),offset+2
			end
		})
		bufferTypes.Int16 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,2)
				buffer.writei16(b,offset,val)
				return b,offset+2
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readi16(buff,offset),offset+2
			end
		})

		bufferTypes.UInt32 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,4)
				buffer.writeu32(b,offset,val)
				return b,offset+4
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readu32(buff,offset),offset+4
			end
		})
		bufferTypes.Int32 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,4)
				buffer.writei32(b,offset,val)
				return b,offset+4
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readi32(buff,offset),offset+4
			end
		})

		bufferTypes.Float32 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,4)
				buffer.writef32(b,offset,val)
				return b,offset+4
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readf32(buff,offset),offset+4
			end
		})
		bufferTypes.Float64 = table.freeze({
			Write = function(buff:buffer,offset:number,val:number):(buffer,number)
				local b = extendBufferBy(buff,8)
				buffer.writef64(b,offset,val)
				return b,offset+8
			end,
			Read = function(buff:buffer,offset:number):(number,number)
				return buffer.readf64(buff,offset),offset+8
			end
		})

		bufferTypes.String = table.freeze({
			Write = function(buff:buffer,offset:number,val:string):(buffer,number)
				local len = string.len(val)
				local buff,offset = bufferTypes.UInt32.Write(buff,offset,len)
				local b = extendBufferBy(buff,len)
				buffer.writestring(b,offset,val,len)
				return b,offset+len
			end,
			Read = function(buff:buffer,offset:number):(string,number)
				local len,offset = bufferTypes.UInt32.Read(buff,offset)
				return buffer.readstring(buff,offset,len),offset+len
			end
		})

		bufferTypes.Boolean = table.freeze({
			Write = function(buff:buffer,offset:number,val:boolean):(buffer,number)
				return bufferTypes.UInt8.Write(buff,offset,val and 1 or 0)
			end,
			Read = function(buff:buffer,offset:number):(boolean,number)
				local boolNum,offset = bufferTypes.UInt8.Read(buff,offset)
				return boolNum == 1,offset
			end
		})
	end

	local gvalsSort:{{Name: string,Type: baseBufferType}} = {
		{Name = "curPlaying",Type = bufferTypes.String},
		{Name = "startTime",Type = bufferTypes.Float64},
		{Name = "stage",Type = bufferTypes.UInt8},
		{Name = "shakeMultiplier",Type = bufferTypes.Float32},
		{Name = "pressedShutdownButtons",Type = bufferTypes.UInt8},
		{Name = "totalShutdownButtons",Type = bufferTypes.UInt8},
		{Name = "tiltingCamera",Type = bufferTypes.Boolean},
		{Name = "visible",Type = bufferTypes.Boolean},
		{Name = "altVisible",Type = bufferTypes.Boolean},
		{Name = "shiftInfo",Type = bufferTypes.Boolean},

		{Name = "musFadeStart",Type = bufferTypes.Float64},
		{Name = "musFadeEnd",Type = bufferTypes.Float64},

		{Name = "timerFrozen",Type = bufferTypes.Boolean},
		{Name = "setTimerTime",Type = bufferTypes.Float32},
		{Name = "buttonsEnabled",Type = bufferTypes.Boolean},

		{Name = "overheatTimer",Type = bufferTypes.Boolean},
		{Name = "overheatTimerStart",Type = bufferTypes.Float64},
		{Name = "overheatTimerEnd",Type = bufferTypes.Float64},
	}
	
	for _,name in pairs(usedAttributes) do
		local n = `_ATT_{name}`
		table.insert(gvalsSort,{Name = n, Type = bufferTypes.String})
	end
	for _,name in pairs(usedTags) do
		local n = `_TAG_{name}`
		table.insert(gvalsSort,{Name = n, Type = bufferTypes.String})
	end
	
	-- https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
	local function from_base64(data)
		local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
		data = string.gsub(data, '[^'..b..'=]', '')
		return data:gsub('.', function(x)
			if x == '=' then return '' end
			local r,f='',((b:find(x) or 0)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if #x ~= 8 then return '' end
			local c=0
			for i=1,8 do c+=(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end)
	end
	bindtovalue(sharedValue,function(encoded:string)
		local s = from_base64(encoded)
		local baseBuffer,offset = buffer.fromstring(s),0
		if buffer.len(baseBuffer) == 0 then return end
		for _,value in ipairs(gvalsSort) do
			local gvalsOrigin = gvals[value.Name]
			local val,oset = value.Type.Read(baseBuffer,offset)
			offset = oset
			
			if val == gvalsOrigin then continue end
			gvals[value.Name] = val
			
			local propIdent = string.sub(value.Name,1,5)
			
			if propIdent == "_ATT_" or propIdent == "_TAG_" then
				local propTblA = 
					if propIdent == "_ATT_" then attributeLookup
					else tagLookup
				local propTblB = 
					if propIdent == "_ATT_" then attributeReverseLookup
					else tagReverseLookup
				propTblA[string.sub(value.Name,6)] = val
				propTblB[val] = string.sub(value.Name,6)
			end
			
			if not boundToGValUpdates[value.Name] then continue end
			for i,v in ipairs(boundToGValUpdates[value.Name]) do
				task.spawn(v,val)
			end
		end
	end)
end

local sndUpdateFunc:((Sound)->())?
local sndGroupUpdateFunc:((SoundGroup)->())?

local importantServices = {
	game:GetService("Workspace"),
	game:GetService("Lighting"),
}
local allSounds:{Sound} = {}
local allSoundGroups:{SoundGroup} = {}
do
	local function sndAdded(snd:Sound)
		if not snd:IsA("Sound") then return end
		table.insert(allSounds,snd)
		if sndUpdateFunc then
			sndUpdateFunc(snd)
		end
	end
	local function sndGroupAdded(snd:SoundGroup)
		if not snd:IsA("SoundGroup") then return end
		table.insert(allSoundGroups,snd)
		if sndGroupUpdateFunc then
			sndGroupUpdateFunc(snd)
		end
	end
	
	for _,service in ipairs(game:GetChildren()) do
		pcall(function()
			for _,snd in ipairs(service:GetDescendants()) do
				sndAdded(snd)
				sndGroupAdded(snd)
			end
			service.DescendantAdded:Connect(sndAdded)
		end)
	end
end

local function removeSndFunct(snd:Sound,fixFunctions:{() -> ()})
	if snd.Parent and snd.Parent:HasTag(tagLookup.IsMusic) then return end
	--snd.PlayOnRemove = false
	table.insert(fixFunctions,temporaryStaticize(snd,"Volume",0))
end
local function removeSndGroupFunct(snd:SoundGroup,fixFunctions:{() -> ()})
	table.insert(fixFunctions,temporaryStaticize(snd,"Volume",0))
end
local function setSndUpdateFunc(funct:((Sound) -> ())?)
	sndUpdateFunc = funct
	
	if not funct then
		return
	end
	for _,snd in ipairs(allSounds) do
		funct(snd)
	end
end
local function setSndGroupUpdateFunc(funct:((SoundGroup)->())?)
	sndGroupUpdateFunc = funct

	if not funct then
		return
	end
	for _,snd in ipairs(allSoundGroups) do
		funct(snd)
	end
end

local altTimerWasVisible = nil
local function updateAltTimerFlag(amnt:number)
	altTimerVisibleFlag += amnt
	local altTimerVisible = altTimerVisibleFlag > 0
	if altTimerWasVisible == altTimerVisible then
		return
	end
	altTimerWasVisible = altTimerVisible

	if altTimerVisible then
		etimerAltBase.Visible = true
		createtempsnd("rbxassetid://96362701378961",{Volume = .8,PlaybackSpeed = 1.2})
		etimerAlt.Size = UDim2.fromScale(2,0)
		quicktween(etimerAlt,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
			Size = UDim2.fromScale(1,1)
		})
	else
		createtempsnd("rbxassetid://96362701378961",{Volume = .6,PlaybackSpeed = .6})
		etimerAlt.Size = UDim2.fromScale(1,1)
		quicktween(etimerAlt,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{
			Size = UDim2.fromScale(2,0)
		},function()
			etimerAltBase.Visible = false
		end)
	end
end

local lastmusicplaying:Sound
local currentMusPopupDelayThread:thread?
local musPopupVisible = false
bindToGValue("curPlaying",function(str)
	local stop = str == ""
	
	local snd:Sound?,started:number
	if not stop then
		local tbl = string.split(str,"`")
		if not tbl[1] then return end
		snd,started = sndtrack:WaitForChild(tbl[1],5),tonumber(tbl[2]) :: number
		if not snd then return end
	end
	
	if lastmusicplaying then
		twserv:Create(lastmusicplaying,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Volume = 0}):Play()
		task.delay(0.5,lastmusicplaying.Stop,lastmusicplaying)
	end
	
	if stop then
		return
	end
	if not snd then
		return -- weird typechecking part 2
	end
	lastmusicplaying = snd
	local didPlay = playSndFromTimestamp(snd,started)
	if didPlay and lastmusicplaying == snd then
		if currentMusPopupDelayThread and coroutine.status(currentMusPopupDelayThread) ~= "dead" then
			task.cancel(currentMusPopupDelayThread)
		end
		musPopupVisible = true
		musPopup.Visible = true
		musPopup.Position = UDim2.fromScale(0.005,1.05)
		musPopup.musText.Text = `{snd:GetAttribute("artist") or "Unknown Artist"} - {snd:GetAttribute("trueName") or "Unknown Music Name"}`
		musPopup.UIScale.Scale = 1.5
		quicktween(musPopup.UIScale,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = .6})
		musPopup:TweenPosition(UDim2.fromScale(0.005,1),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
		currentMusPopupDelayThread = task.delay(10,function()
			musPopup:TweenPosition(UDim2.fromScale(0.005,1.05),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.5,true,function()
				musPopupVisible = false
				musPopup.Visible = false
			end)
		end)
	end
end)

local curTimerSnd:Sound?
bindToGValue("visible",function(b)
	if b and not etimervisible then
		etimervisible = true
		headerContainer.Visible = true
		headerContainer:TweenPosition(UDim2.fromScale(0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
		if curTimerSnd then
			curTimerSnd:Destroy()
		end
		curTimerSnd = createsnd("rbxassetid://5270218400",{
			Volume = 0.4,
			PlaybackSpeed = 0.8,
			Looped = true
		},true)
	elseif not b and etimervisible then
		local endTime = gvals.stage == 3 and 5 or 0.5
		headerContainer:TweenPosition(UDim2.fromScale(0,-.35),Enum.EasingDirection.In,Enum.EasingStyle.Sine,endTime,true,function()
			headerContainer.Visible = false
			etimervisible = false
		end)
		local tsnd = curTimerSnd
		if tsnd then
			quicktween(tsnd,TweenInfo.new(endTime,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Volume = 0},function()
				tsnd:Destroy()
			end)
		end
		curTimerSnd = nil
	end
end)
bindToGValue("shiftInfo",function(b)
	if b and not infoShifted then
		infoShifted = true
		info:TweenPosition(UDim2.fromScale(.5,.75),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
		info.extraInfo:TweenSize(UDim2.fromScale(.343,.064),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
		--info:TweenSizeAndPosition(UDim2.fromScale(1,0.15),UDim2.fromScale(0,.75),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
	elseif not b and infoShifted then
		infoShifted = false
		info:TweenPosition(UDim2.fromScale(.5,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
		info.extraInfo:TweenSize(UDim2.fromScale(.343,.128),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
		--info:TweenSizeAndPosition(UDim2.fromScale(1,0.2),UDim2.fromScale(0,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,0.5,true)
	end
end)

local function get2Num(num):(number,number)
	local str = string.format("%02i",math.clamp(num,0,99)):split("")
	return tonumber(str[1]) or 0,tonumber(str[2]) or 0
end

local imgNumTweens:{[ImageLabel]: Tween} = {}

type timerContainer = Frame & {
	ones: timerNumberImage,
	tens: timerNumberImage
}
type timerNumberImage = ImageLabel & {
	highlight: ImageLabel
}
local function brightenLED(LED:timerNumberImage)
	local oldTween = imgNumTweens[LED]
	if oldTween then
		oldTween:Cancel()
	end
	LED.highlight.ImageTransparency = .2

	local tw = twserv:Create(LED.highlight,TweenInfo.new(.3,Enum.EasingStyle.Linear),{ImageTransparency = 1})
	imgNumTweens[LED] = tw
	tw.Completed:Once(function()
		imgNumTweens[LED] = nil
	end)
	tw:Play()
end

local deadLEDs = {}
local function updateNumberLED(numberContainer:timerContainer,curTime:number)
	if deadLEDs[numberContainer] then
		return
	end
	local tens,ones = get2Num(curTime)
	
	numberContainer.tens.ImageRectOffset = Vector2.new(tens*60,524)
	numberContainer.ones.ImageRectOffset = Vector2.new(ones*60,524)
	numberContainer.tens.highlight.ImageRectOffset = Vector2.new(tens*60,524)
	numberContainer.ones.highlight.ImageRectOffset = Vector2.new(ones*60,524)
end
local function updateNumberGroupLED(mainContainer,curTime:number)
	task.spawn(updateNumberLED,mainContainer.timerMinutes,math.clamp(math.floor(curTime/60),0,10))
	task.spawn(updateNumberLED,mainContainer.timerSeconds,math.clamp(math.floor(curTime%60),0,60))
	task.spawn(updateNumberLED,mainContainer.timerMilliseconds,math.clamp(math.floor((curTime%1)*100),0,99))
end
local function changeGroupLED(mainContainer,func:(any)->nil)
	task.spawn(func,mainContainer.timerMinutes)
	task.spawn(func,mainContainer.timerSeconds)
	task.spawn(func,mainContainer.timerMilliseconds)
end
--local function updatestroke()
--	etimer.UIStroke.Color = Color3.fromRGB(etimer.BackgroundColor3.R*146,etimer.BackgroundColor3.G*146,etimer.BackgroundColor3.B*146)
--end
bindToGValue("stage",function(i)
	if i == 0 then -- normal
		timerLEDActive = true
		shutdownExpiration = false
		changeGroupLED(etimer.mainTimer,function(container)
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,1,1))
		end)
		changeGroupLED(etimer.shutdownTimer,function(container)
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,1,0))
		end)
	elseif i == 1 then -- shutdown expiration
		shutdownExpiration = true
		timerLEDActive = true
		changeGroupLED(etimer.mainTimer,function(container)
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,1,0))
		end)
		changeGroupLED(etimer.shutdownTimer,function(container)
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,0,0))
		end)
	elseif i == 2 then -- finale
		shutdownExpiration = true
		timerLEDActive = true
		changeGroupLED(etimer.mainTimer,function(container)
			for i = 1,3 do
				quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,0,0))
				task.wait(.2)
				quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new())
				task.wait(.2)
			end
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,0,0))
		end)
		changeGroupLED(etimer.shutdownTimer,function(container)
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,0,0))
		end)
	elseif i == 3 then -- finale with alt timer, main timer disabled
		shutdownExpiration = true
		if not timerLEDActive then
			return
		end

		timerLEDActive = false
		
		if not gvals.overheatTimer then
			return
		end
		
		createtempsnd("rbxassetid://8060079174",{Volume = 0.4,PlaybackSpeed = 1.2*rand:NextNumber(0.85,1.2)})
		local size,anchorOffset = getTrueOffsetsBasedOff(etimer.timerParticleContainer)
		particles.shockwave(
			Vector2.new(
				etimer.mainTimer.Position.X.Scale+etimer.mainTimer.Size.X.Scale/2,
				etimer.mainTimer.Position.Y.Scale+etimer.mainTimer.Size.Y.Scale/2
			)/size+anchorOffset,nil,etimer.timerParticleContainer,
			5
		)

		if curTimerSnd then
			curTimerSnd.PlaybackSpeed = 0
		end
	end
end)

local lastFreezeTimerTime,timerFrozen = 0,false
bindToGValue("timerFrozen",function(b)
	timerFrozen = b
	if not b then return end
	changeGroupLED(etimer.mainTimer,function(container)
		for i = 1,3 do
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new(1,1,1))
			task.wait(.2)
			quickset({container.tens,container.ones,container.tens.highlight,container.ones.highlight},"ImageColor3",Color3.new())
			task.wait(.2)
		end
		quickset({container.tens,container.ones},"ImageColor3",Color3.new(1,1,1))
	end)
end)
bindToGValue("setTimerTime",function(n)
	lastFreezeTimerTime = n
end)

local lastTotal = 0
local curShutdownText = {}

local function updateButtonCount()
	local pressed:number,total:number = gvals.pressedShutdownButtons,gvals.totalShutdownButtons
	
	if total ~= lastTotal then -- recalculate shutdowndropdown stuff
		lastTotal = total
		for i,v in ipairs(curShutdownText) do
			v:Destroy()
		end
		table.clear(curShutdownText)
		for i = 1,total do
			local shutdownText = templates.shutdownText:Clone()
			shutdownText.LayoutOrder = i
			shutdownText.num.ImageRectOffset = Vector2.new(i*60,524)
			shutdownText.Parent = etimer.shutdownDropdown.base.container
			table.insert(curShutdownText,shutdownText)
		end
	end
	for i,v in ipairs(curShutdownText) do
		v.num.ImageColor3 = i > pressed and Color3.new(1,1,1) or Color3.new(0,1,0)
	end
end
bindToGValue("pressedShutdownButtons",updateButtonCount)
bindToGValue("totalShutdownButtons",updateButtonCount)
bindToGValue("buttonsEnabled",function(b)
	if b then
		etimer.shutdownDropdown.Visible = true
		etimer.shutdownDropdown:TweenPosition(UDim2.fromScale(0.5,0.7),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
		createtempsnd("rbxassetid://5986945556",{
			Volume = 0.7
		})
	else
		createtempsnd("rbxassetid://5986945556",{
			Volume = 0.7,
			PlaybackSpeed = 0.75
		})
		etimer.shutdownDropdown:TweenPosition(UDim2.fromScale(0.5,0.3),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.5,true,function()
			etimer.shutdownDropdown.Visible = false
		end)
	end
end)

local gvalueAltVisible = false
bindToGValue("altVisible",function(b)
	if gvalueAltVisible ~= b then
		gvalueAltVisible = b
		updateAltTimerFlag(gvalueAltVisible and 1 or -1)
	end
end)

local explosionmagnitudes:{
	{
		Magnitude: number,
		Duration: number,
		Effectiveness: number
	}
} = {}
local shockfollowers:{
	{
		Sound: Sound,
		ShakeMultiplier: number,
		ShakeData: {{number}}
	}
} = {}

local focusCFrame:CFrame?,lastFocusTick:number?
local wasFocused = false
local focusEnabled = false
local cameraFlingOffset:CFrame?

local function descaleExplosionTimer()
	quicktween(etimerBase.scale,TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = .75})
	quicktween(etimerAltBase.scale,TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = .75})
end
descaleExplosionTimer()

local character
local charDescAddedBind:RBXScriptConnection,charDescRemovedBind:RBXScriptConnection
local characterParts = {}
do
	local function charPartAdded(prt:BasePart)
		if not prt:IsA("BasePart") then
			return
		end

		table.insert(characterParts,prt)
	end

	local function charAdded(char)
		character = char
		characterParts = {}

		if charDescAddedBind then
			charDescAddedBind:Disconnect()
		end
		if charDescRemovedBind then
			charDescRemovedBind:Disconnect()
		end

		for _,prt in ipairs(character:GetDescendants()) do
			task.spawn(charPartAdded,prt)
		end
		charDescAddedBind = character.DescendantAdded:Connect(charPartAdded)
		charDescRemovedBind = character.DescendantRemoving:Connect(function(prt)
			if not prt:IsA("BasePart") then
				return
			end

			local i = table.find(characterParts,prt)
			if i then
				table.remove(characterParts,i)
			end
		end)
	end

	if plr.Character then
		task.spawn(charAdded,plr.Character)
	end
	plr.CharacterAdded:Connect(charAdded)
end

local kicked = false
do -- RE handler
	local currentLowerPopupText = ""

	local canLowerPopupBecomeVisible = false
	local isLowerPopupVisible = false
	local wasLowerPopupVisible = false
	local function updateLowerPopupVisibility(visible:boolean,disableSounds:boolean?)
		isLowerPopupVisible = visible
		if not canLowerPopupBecomeVisible then
			return
		end

		info.extraInfo.Visible = visible
		info.offsetLeft.screen.light.Visible = visible
		info.offsetRight.screen.light.Visible = visible
		if wasLowerPopupVisible == visible then
			return
		end
		wasLowerPopupVisible = visible
		
		if disableSounds then return end
		if visible then
			createtempsnd("rbxassetid://7851351309",{
				Volume = 0.7,
				PlaybackSpeed = 1.2
			})
			createtempsnd("rbxassetid://4398878054",{
				Volume = 0.3
			})
			createtempsnd("rbxassetid://72146209618760",{
				Volume = 0.6
			})
		else
			createtempsnd("rbxassetid://7851351309",{
				Volume = 0.7,
				PlaybackSpeed = .95
			})
		end
	end
	local function changelowerpopuptext(txt:string?)
		if not txt then
			updateLowerPopupVisibility(false)
			return
		end
		updateLowerPopupVisibility(true)
		
		info.extraInfo.text.Text = txt
	end
	local function fillinfotext(wmid,tbl:{{string|Color3}})
		for i,v in pairs(tbl) do
			local infcl = wmid.InformationContainer.InformationText:Clone()
			infcl.Name = `InformationText{#wmid.InformationContainer:GetChildren()+1}`
			infcl.Text = v[1]
			infcl.TextColor3 = v[2]
			infcl.Visible = true
			infcl.Parent = wmid.InformationContainer
		end
	end
	local function fillInfoTextForBothWarnings(wmid,wmid2,tbl:{{string|Color3}})
		fillinfotext(wmid,tbl)
		fillinfotext(wmid2,tbl)
	end
	local function defaultscalein(wmid)
		wmid.Title.Size = UDim2.fromScale(1,1)
		wmid.Header.Position = UDim2.fromScale(-1,.3)
		wmid.SideLabel.Position = UDim2.fromScale(0,1)
		wmid.InformationContainer.Position = UDim2.fromScale(1,.5)
		wmid.InformationContainer.Visible = true

		wmid.Title:TweenSize(UDim2.fromScale(1,.3),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
		task.delay(.1,function()
			wmid.Header:TweenPosition(UDim2.fromScale(0,.3),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,.5,true)
		end)
		task.delay(.2,function()
			wmid.SideLabel:TweenPosition(UDim2.fromScale(0,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,.5,true)
		end)
		task.delay(.3,function()
			wmid.InformationContainer:TweenPosition(UDim2.fromScale(0.25,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
		end)
	end
	
	local function setSideTexts(offsetFrm,txt:string)
		for _,label in ipairs(offsetFrm.info.content.contentClipped.contentScrollingLower.scrollContainer.offset:GetChildren()) do
			if label:IsA("TextLabel") then
				label.Text = txt
			end
		end
		for _,label in ipairs(offsetFrm.info.content.contentClipped.contentScrollingUpper.scrollContainer.offset:GetChildren()) do
			if label:IsA("TextLabel") then
				label.Text = txt
			end
		end
	end
	local function setBothSideTexts(txt:string)
		setSideTexts(info.offsetLeft,txt)
		setSideTexts(info.offsetRight,txt)
	end
	local function updateOffsetFrameIcons(offsetFrm,newImage:string,count:number)
		local alt = string.find(offsetFrm.Name,"Right") ~= nil
		
		for _,frm:Frame in ipairs(offsetFrm.info.content.contentClipped.middleIcons:GetChildren()) do
			if not frm:IsA("Frame") then
				continue
			end
			
			frm:TweenPosition(UDim2.fromScale(alt and 1 or -1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.3,true)
		end
		
		quicktween(
			offsetFrm.info.content.contentClipped.iconBG :: ImageLabel,
			TweenInfo.new(.3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{ImageTransparency = 1},function()
				offsetFrm.info.content.contentClipped.iconBG.Image = newImage
				quicktween(
					offsetFrm.info.content.contentClipped.iconBG :: ImageLabel,
					TweenInfo.new(.3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{ImageTransparency = .8}
				)
			end
		)
		
		local iconContainer = templates.middleIconContainer:Clone()
		for i = 1,count do
			local icon = templates.middleIcon:Clone()
			icon.Image = newImage
			icon.Parent = iconContainer
		end
		iconContainer.Position = UDim2.new(alt and 1 or -1,0)
		iconContainer.Parent = offsetFrm.info.content.contentClipped.middleIcons
		iconContainer:TweenPosition(UDim2.new(),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.3,true)
	end
	--local function updateGrandPopupUIIcons(newImage:string,count:number)
	--	updateOffsetFrameIcons(info.offsetLeft,newImage,count)
	--	updateOffsetFrameIcons(info.offsetRight,newImage,count)
	--end
	
	local function adjustOffsetUIColor(offsetFrm,newColor:Color3,newTextColor:Color3?)
		local twInfo = TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
		quicktween(offsetFrm.screen.clip.content.contentBG,twInfo,{BackgroundColor3 = newColor})
		quicktween(offsetFrm.info.content.contentBG,twInfo,{BackgroundColor3 = newColor})
		
		if newTextColor then
			quicktween(offsetFrm.info.content.contentClipped.contentScrollingUpper.topBar,twInfo,{BackgroundColor3 = newTextColor})
			quicktween(offsetFrm.info.content.contentClipped.contentScrollingUpper.bottomBar,twInfo,{BackgroundColor3 = newTextColor})
			quicktween(offsetFrm.info.content.contentClipped.contentScrollingLower.topBar,twInfo,{BackgroundColor3 = newTextColor})
			quicktween(offsetFrm.info.content.contentClipped.contentScrollingLower.bottomBar,twInfo,{BackgroundColor3 = newTextColor})
			
			for _,txt:TextLabel in ipairs(offsetFrm.info.content.contentClipped.contentScrollingUpper.scrollContainer.offset:GetChildren()) do
				if not txt:IsA("TextLabel") then
					continue
				end
				quicktween(txt,twInfo,{TextColor3 = newTextColor})
			end
			for _,txt:TextLabel in ipairs(offsetFrm.info.content.contentClipped.contentScrollingLower.scrollContainer.offset:GetChildren()) do
				if not txt:IsA("TextLabel") then
					continue
				end
				quicktween(txt,twInfo,{TextColor3 = newTextColor})
			end
		end
	end
	local function adjustGrandPopupUIColor(newColor:Color3,newTextColor:Color3?)
		adjustOffsetUIColor(info.offsetLeft,newColor,newTextColor)
		adjustOffsetUIColor(info.offsetRight,newColor,newTextColor)
	end
	local function defaultindicate(
		wmidLeft,wmidRight,
		wl:string,
		wr:string,
		wlAmnt:number,
		wrAmnt:number,
		title:string,
		header:string,
		backgroundColor:Color3,
		textColor:Color3?,
		scaleinfunc
	)
		quickset({wmidLeft.Title,wmidRight.Title},"Text",title)
		quickset({wmidLeft.Header,wmidRight.Header},"Text",header)
		
		updateOffsetFrameIcons(info.offsetLeft,wl,wlAmnt)
		updateOffsetFrameIcons(info.offsetRight,wr,wrAmnt)
		
		quickset({
			wmidLeft.Title,wmidLeft.Header,wmidLeft.SideLabel,
			wmidRight.Title,wmidRight.Header,wmidRight.SideLabel,
		},"TextColor3",textColor or Color3.new(1,1,1))
		
		scaleinfunc(wmidLeft)
		scaleinfunc(wmidRight)
		adjustGrandPopupUIColor(backgroundColor,textColor)
	end
	
	local popupfuncs:{<a>(a:any,b:any) -> ()} = {
		[0] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			adjustGrandPopupUIColor(Color3.fromRGB(33,9,0),Color3.fromRGB(255,0,0))
			quickset({
				wmidLeft.Title,wmidLeft.Header,wmidLeft.SideLabel,
				wmidRight.Title,wmidRight.Header,wmidRight.SideLabel,
			},"TextColor3",Color3.fromRGB(255,0,0))
			updateOffsetFrameIcons(info.offsetLeft,"rbxassetid://12202086629",1)
			updateOffsetFrameIcons(info.offsetRight,"rbxassetid://12202086629",1)
			
			quickset({wmidLeft.Title,wmidRight.Title},"Size",UDim2.fromScale(1,1))
			quickset({wmidLeft.Title,wmidRight.Title},"Text","WARNING!")
			
			quickset({
				wmidLeft.Header,wmidRight.Header,
				wmidLeft.SideLabel,wmidRight.SideLabel,
				wmidLeft.InformationContainer,wmidRight.InformationContainer
			},"Visible",false)
			task.wait(2)
			
			quickset({wmidLeft.Header,wmidRight.Header},"Text","Admin control has determined that the facility is too unsafe, causing the ESDS System to trigger!")
			-- for meltdowns: "The core has reached tempatures beyond its melting point, causing the ESDS System to trigger!"
			
			wmidLeft.Title:TweenSize(UDim2.fromScale(1,.3),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			wmidRight.Title:TweenSize(UDim2.fromScale(1,.3),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			

			quickset({wmidLeft.Header,wmidRight.Header},"Position",UDim2.fromScale(-1,.3))
			quickset({wmidLeft.Header,wmidRight.Header},"Size",UDim2.fromScale(1,.7))
			quickset({wmidLeft.Header,wmidRight.Header},"Visible",true)
			
			wmidLeft.Header:TweenPosition(UDim2.fromScale(0,.3),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			wmidRight.Header:TweenPosition(UDim2.fromScale(0,.3),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			task.wait(5)
			
			wmidLeft.Header:TweenSize(UDim2.fromScale(1,.2),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			wmidRight.Header:TweenSize(UDim2.fromScale(1,.2),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			quickset({wmidLeft.SideLabel,wmidRight.SideLabel},"Position",UDim2.fromScale(0,1))
			quickset({wmidLeft.SideLabel,wmidRight.SideLabel},"Visible",true)
			wmidLeft.SideLabel:TweenPosition(UDim2.fromScale(0,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
			wmidRight.SideLabel:TweenPosition(UDim2.fromScale(0,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
			task.wait(1)
			
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,255,0)">10 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,0,0)}
			})

			quickset({wmidLeft.InformationContainer,wmidRight.InformationContainer},"Position",UDim2.fromScale(1,.5))
			quickset({wmidLeft.InformationContainer,wmidRight.InformationContainer},"Visible",true)
			wmidLeft.InformationContainer:TweenPosition(UDim2.fromScale(0.25,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
			wmidRight.InformationContainer:TweenPosition(UDim2.fromScale(0.25,.5),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.5,true)
		end,
		[1] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			local unbind = bindToGValue("totalShutdownButtons",function(num:number)
				changelowerpopuptext(`You need to activate <b>{num}</b> emergency switches. They will appear shortly, go get them!`)
			end)

			defaultindicate(
				wmidLeft,wmidRight,
				"rbxassetid://12274629436","rbxassetid://12274629436",1,1,
				"HEADS UP!","The facility is going to explode!",
				Color3.fromRGB(95, 78, 0),Color3.fromRGB(255,255,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,0,0)">10 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,255,0)},
				{[[<font color="rgb(255,0,0)">5 minutes</font> until the override <b>EXPIRES</b>!]],Color3.fromRGB(255,255,0)},
			})

			task.wait(3)
			unbind()
		end,
		[2] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			changelowerpopuptext("Get to the emergency switches quick! You only have 3 minutes!")

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12274629436","rbxassetid://12274629436",1,1,
				"HEADS UP!","The facility is going to explode!",Color3.fromRGB(76, 43, 0),Color3.fromRGB(255,164,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,0,0)">8 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,164,0)},
				{[[<font color="rgb(255,0,0)">3 minutes</font> until the override <b>EXPIRES</b>!]],Color3.fromRGB(255,164,0)},
			})

			task.wait(3)
		end,
		[3] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			changelowerpopuptext("You're running out of time to shutdown the self-destruct!")
			-- for meltdowns: You're running out of time to shut this core down!

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12459168450","rbxassetid://12459168450",2,2,
				"HEADS UP!","Override is about to expire!",Color3.fromRGB(95, 34, 0),Color3.fromRGB(255,90,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,0,0)">6 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,90,0)},
				{[[<b>1 minute</b> until the override <b>expires</b>...]],Color3.fromRGB(255,0,0)},
			})

			task.wait(3)
		end,
		[4] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			changelowerpopuptext("Go to the emergency exits, you can't shut down the self-destruct anymore!")

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12459168450","rbxassetid://12274630653",3,3,
				"WARNING!","OVERRIDE EXPIRED!",Color3.fromRGB(95, 34, 0),Color3.fromRGB(255,0,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,255,0)">5 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,0,0)},
				{[[<font color="rgb(255,255,0)">4 minutes</font> until the exits <b>LOCK</b>!]],Color3.fromRGB(255,0,0)},
			})

			task.wait(3)
		end,
		[5] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			changelowerpopuptext()

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12274629436","rbxassetid://12274629436",1,1,
				"HEADS UP!","The facility is going to explode!",Color3.fromRGB(95, 27, 0),Color3.fromRGB(255,0,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,255,0)">3 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,0,0)},
				{[[<font color="rgb(255,255,0)">2 minutes</font> until the exits <b>LOCK</b>!]],Color3.fromRGB(255,0,0)},
			})

			task.wait(3)
		end,
		[6] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			changelowerpopuptext("You only have one minute left until all exits lock!")

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12459168450","rbxassetid://12459168450",2,2,
				"HEADS UP!","You're running out of time!",Color3.fromRGB(95, 35, 0),Color3.fromRGB(255,0,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,255,0)">2 minutes</font> until the facility <b>EXPLODES</b>!]],Color3.fromRGB(255,0,0)},
				{[[<font color="rgb(255,255,0)">1 minute</font> until the exits <b>LOCK</b>!]],Color3.fromRGB(255,0,0)},
			})

			task.wait(3)
		end,
		[7] = function(wmidLeft,wmidRight)
			setBothSideTexts("DANGER!")
			changelowerpopuptext("YOU HAVE ONE MINUTE LEFT, ALL EXITS ARE LOCKED!")

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12274630653","rbxassetid://12274630653",3,3,
				"DANGER!","Facility is about to explode!",Color3.fromRGB(95, 0, 6),Color3.fromRGB(255,0,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(255,255,0)">1 minute</font> until the self-destruct <b>DETONATES</b>!]],Color3.fromRGB(255,0,0)},
				{[[<font color="rgb(255,255,0)">30 seconds</font> until the bunker <b>CLOSES</b>!]],Color3.fromRGB(255,0,0)},
			})

			task.wait(3)
		end,
		[8] = function(wmidLeft,wmidRight)
			setBothSideTexts("ERROR")
			changelowerpopuptext()
			
			local snd = createsnd("rbxassetid://5665746430",{Volume = 1.3},true)
			quicktween(snd,TweenInfo.new(4,Enum.EasingStyle.Linear),{PlaybackSpeed = 0},function()
				snd:Destroy()
			end)

			local snd = createsnd("rbxassetid://1588058260",nil,true)
			task.delay(3,function()
				snd:Destroy()
			end)

			createtempsnd("rbxassetid://856658167",{Volume = 0.8,PlaybackSpeed = 0.9})

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://12202086629","rbxassetid://12202086629",5,5,
				"NO TIME LEFT","NO TIME LEFT",Color3.new(),Color3.fromRGB(255,0,0),
				defaultscalein
			)
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{string.rep("NO TIME LEFT ",5),Color3.fromRGB(255,0,0)},
				{string.rep("NO TIME LEFT ",5),Color3.fromRGB(255,0,0)},
				{string.rep("NO TIME LEFT ",5),Color3.fromRGB(255,0,0)},
				{string.rep("NO TIME LEFT ",5),Color3.fromRGB(255,0,0)},
				{string.rep("NO TIME LEFT ",5),Color3.fromRGB(255,0,0)},
			})

			task.wait(3)
		end,
		[9] = function(wmidLeft,wmidRight)
			setBothSideTexts("SUCCESS!")
			changelowerpopuptext()

			defaultindicate(
				wmidLeft,wmidRight,"rbxassetid://18724466420","rbxassetid://18724466420",1,1,
				"Success!","Self-destruct system has been halted!",Color3.fromRGB(0, 43, 116),Color3.fromRGB(255,255,255),
				defaultscalein
			)
			-- for meltdowns: "Core has been shut down!"
			fillInfoTextForBothWarnings(wmidLeft,wmidRight,{
				{[[<font color="rgb(0, 195, 255)">5 seconds</font> until the facility restarts.]],Color3.fromRGB(255,255,255)}
			})
			-- for meltdowns: [[<font color="rgb(0, 195, 255)">5 seconds</font> until the core fully shuts down.]]

			task.wait(3)
		end,
	}
	local function cleanupguis(ch)
		for i,v:GuiObject in pairs(ch) do
			if v:IsA("GuiObject") then
				v:TweenPosition(UDim2.fromScale(v.Position.X.Scale,1),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true,function()
					v:Destroy()
				end)
			else
				v:Destroy()
			end
		end
	end
	local function cleanupFrames()
		--local chA,chB = info.FRM1CONTAIN.FRM:GetChildren(),info.FRM2CONTAIN.FRM:GetChildren()
		local chA,chB = 
			info.offsetLeft.screen.clip.content.actualContent:GetChildren(),
			info.offsetRight.screen.clip.content.actualContent:GetChildren()
		if #chA > 0 then
			cleanupguis(chA)
		end
		if #chB > 0 then
			cleanupguis(chB)
		end
	end
	local extraPopupWaitThread:thread?
	local function hidePopup()
		if not popupvisible then return end
		popupvisible = false
		if extraPopupWaitThread and coroutine.status(extraPopupWaitThread) ~= "dead" then
			task.cancel(extraPopupWaitThread)
		end
		isLowerPopupVisible = false
		updateLowerPopupVisibility(false)
		canLowerPopupBecomeVisible = false

		local s = createsnd("rbxassetid://4707886983",{
			PlaybackSpeed = 1.2,
			TimePosition = 0.1,
			Volume = 0.7
		},true)
		info.offsetLeft.screen:TweenPosition(UDim2.fromScale(.15,.5),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.3,true)
		info.offsetRight.screen:TweenPosition(UDim2.fromScale(.85,.5),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.3,true,function()
			createtempsnd("rbxassetid://3908308607",{
				Volume = 0.7
			})
			s:Destroy()
			info.offsetLeft.screen.Visible = false
			info.offsetRight.screen.Visible = false
		end)
		task.delay(.2,function()
			createtempsnd("rbxassetid://9114852075",{
				Volume = 0.8,
				PlaybackSpeed = 0.8,
			})
			info.offsetLeft:TweenPosition(UDim2.fromScale(-.6,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.5,true)
			info.offsetRight:TweenPosition(UDim2.fromScale(.6,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.5,true,function()
				info.Visible = false
			end)
		end)
		descaleExplosionTimer()
	end
	local hasPopups = false
	local grandPopupQueue = {}
	local popupQueue = {}
	local currentGrandPopupQueueHandler:thread?
	local currentPopupQueueHandler:thread?
	local lastPopupVisiblityDelayTime = 0
	
	local function handleQueue(
		queueTable:{thread},
		delayBetweenIndices:number?,
		endQueue:(()->nil)?,
		lastQueueThread:thread?,
		yield:boolean?
	):thread?
		if lastQueueThread then
			task.cancel(lastQueueThread)
		end
		local queueDelay = delayBetweenIndices or 3
		local queueHandler = task.spawn(function()
			local running = coroutine.running()
			while #queueTable > 0 do
				if yield then
					coroutine.resume(queueTable[1],running)
					coroutine.yield()
				else
					task.spawn(queueTable[1])
				end
				task.wait(queueDelay)
				table.remove(queueTable,1)
			end
			if endQueue then
				endQueue()
			end
		end)
		return queueHandler
	end
	local function playGrandPopupAnim(id:string)
		local popupFunc = coroutine.create(function()
			cleanupFrames()
			local wmid,wmid2 = warnmiddle:Clone(),warnmiddle:Clone()
			local function addtodesc(tbl)
				for i,v:GuiObject in pairs(tbl) do
					if v:IsA("GuiObject") then
						v.ZIndex += 7
					end
				end
			end
			addtodesc(wmid:GetDescendants())
			addtodesc(wmid2:GetDescendants())
			
			wmid.Position = UDim2.fromScale(0,1)
			wmid2.Position = UDim2.fromScale(0,1)

			wmid.Parent,wmid2.Parent = 
				info.offsetLeft.screen.clip.content.actualContent,
				info.offsetRight.screen.clip.content.actualContent
			
			
			wmid:TweenPosition(UDim2.new(),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)
			wmid2:TweenPosition(UDim2.new(),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.5,true)

			local aID:number = byte(id)
			createtempsnd("rbxassetid://856658167",{Volume = .8})
			createtempsndthatloopsshort("rbxassetid://2595281037",{Volume = 1.1, PlaybackSpeed = .9},3)
			wmid.Visible = true
			wmid2.Visible = true
			--task.spawn(popupfuncs[aID],wmid,info.FRM1CONTAIN)
			task.spawn(popupfuncs[aID],wmid,wmid2)
		end)
		table.insert(grandPopupQueue,popupFunc)
		if hasPopups then return end
		hasPopups = true
		currentGrandPopupQueueHandler = handleQueue(grandPopupQueue,3,function()
			hasPopups = false
			task.wait(lastPopupVisiblityDelayTime-3)
			lastPopupVisiblityDelayTime = 0
			hidePopup()
			currentGrandPopupQueueHandler = nil
		end,currentGrandPopupQueueHandler)
	end
	local function playPopupAnim(txt,force,sndData)
		table.insert(popupQueue,coroutine.create(function(running)
			local notif = notificationSlideText:Clone()
			notif.Position = UDim2.fromScale(1,0)
			notif.Text = txt
			notif.Parent = notificationsContainer
			notif:TweenPosition(UDim2.fromScale(0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.2,true)
			createtempsnd("rbxassetid://1177464564",sndData or {
				Volume = 1.2
			})
			task.wait(2)
			notif:TweenPosition(UDim2.fromScale(-1,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,.2,true,function()
				notif:Destroy()
			end)
			coroutine.resume(running)
		end))
		if currentPopupQueueHandler and not force then return end
		currentPopupQueueHandler = handleQueue(popupQueue,0,function()
			currentPopupQueueHandler = nil
		end,currentPopupQueueHandler,true)
	end
	local function killGrandPopupQueue()
		if currentGrandPopupQueueHandler then
			task.cancel(currentGrandPopupQueueHandler)
			table.clear(grandPopupQueue)
		end
		descaleExplosionTimer()
	end
	
	local crackIds = {
		"rbxassetid://9113540932","rbxassetid://9113540935","rbxassetid://9113540933",
		"rbxassetid://9113542109","rbxassetid://9113542109","rbxassetid://9113542115",
		"rbxassetid://9113541226","rbxassetid://9113541093","rbxassetid://9113542208",
		"rbxassetid://9113542386","rbxassetid://9113542363","rbxassetid://9113542383",
		"rbxassetid://9113542517","rbxassetid://9113542557","rbxassetid://9113541546",
		"rbxassetid://9113541539","rbxassetid://9113541696","rbxassetid://9113539544",
		"rbxassetid://9113541700","rbxassetid://9113545988","rbxassetid://9113545978"
	}
	
	local currentActiveImpactFrames = {}
	local impactFrames:{[number]: ({[any]: any}) -> ()} = {
		[0] = function(data)
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Contrast = 1000000
			cc.Saturation = -1
			cc.Parent = lighting
			
			data.cc = cc
			
			data.fixFunctions = {}
			setSndUpdateFunc(function(snd)
				removeSndFunct(snd,data.fixFunctions)
			end)
			setSndGroupUpdateFunc(function(snd)
				removeSndGroupFunct(snd,data.fixFunctions)
			end)
			
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(1,1,0)
			highlight.OutlineTransparency = 1
			highlight.Adornee = plr.Character
			highlight.Parent = clientScript
			
			data.highlight = highlight
			
			local function patchElement(element)
				if element:IsA("ImageLabel") then
					table.insert(data.fixFunctions,temporaryStaticize(element,"ImageColor3",Color3.new()))
				elseif element:IsA("TextLabel") then
					table.insert(data.fixFunctions,temporaryStaticize(element,"TextColor3",Color3.new()))
				end
			end
			
			for _,element in ipairs(UI.headerContainer:GetDescendants()) do
				patchElement(element)
			end
			for _,element in ipairs(UI.infoPopup:GetDescendants()) do
				patchElement(element)
			end
			
			task.wait(.05)
			cc.Contrast = -1000000
		end,
		[1] = function(data)
			local explosionPos:Vector3 = data.explosionPos
			local sphereMdl = Instance.new("Model")
			
			local sphere = Instance.new("Part")
			sphere.Size = Vector3.one
			sphere.Material = Enum.Material.Neon
			sphere.CanCollide = false
			sphere.CanQuery = false
			sphere.CanTouch = false
			sphere.Anchored = true
			sphere.Position = explosionPos
			
			local sphereMesh = Instance.new("SpecialMesh")
			sphereMesh.MeshType = Enum.MeshType.Sphere
			sphereMesh.Scale = Vector3.zero
			sphereMesh.Parent = sphere
			sphere.Parent = sphereMdl
			
			sphereMdl.Parent = workspace
			
			data.sphereMdl = sphereMdl
			data.sphere = sphere
			data.sphereMesh = sphereMesh
			
			local lastCF = camera.CFrame
			local curCF = lastCF
			
			data.curFov = 0
			data.targetFov = -30
			
			local start = os.clock()
			local dist = 0

			local cc = Instance.new("ColorCorrectionEffect")
			cc.TintColor = Color3.new(1,1,1)
			cc.Parent = lighting
			data.cc = cc
			
			--quicktween(cc,TweenInfo.new(.75,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{TintColor = Color3.new()})

			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.new(1,1,1)
			highlight.FillTransparency = 0
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Adornee = sphereMdl
			highlight.Parent = plr
			
			--local highlightAlt = Instance.fromExisting(highlight)
			--highlightAlt.FillColor = Color3.new(1,1,0)
			--highlightAlt.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			--highlightAlt.Adornee = plr.Character
			--highlightAlt.Parent = plr
			
			data.highlight = highlight
			--data.highlightAlt = highlightAlt

			local cracks = true
			local transparentParts = {}

			task.spawn(function()
				data.curFov += 70
				createtempsnd("rbxassetid://9125402735",{
					Volume = 4,
					PlaybackSpeed = 0.5
				})
				
				createtempsnd("rbxassetid://9114274718",{
					Volume = 2,
					PlaybackSpeed = 0.4
				})

				local thud3 = createsnd("rbxassetid://9043176323",{
					Volume = 3,
					PlaybackSpeed = 0.7,
					PlaybackRegionsEnabled = true,
					PlaybackRegion = NumberRange.new(0.124,4.5),
				},true)

				quicktween(thud3,TweenInfo.new(2,Enum.EasingStyle.Linear),{Volume = 0,PlaybackSpeed = 0},function()
					thud3:Destroy()
				end)
			end)
			
			data.currentSounds = {}
			data.currentSounds.risersndA = createsnd("rbxassetid://9043356286",{
				Volume = 0,
				PlaybackSpeed = 0
			},true)

			data.currentSounds.risersndB = Instance.fromExisting(data.currentSounds.risersndA)
			data.currentSounds.risersndB.SoundId = "rbxassetid://1837834486"
			data.currentSounds.risersndB.PlaybackSpeed = 1.5

			data.currentSounds.risersndCTrueRiser = createsnd("rbxassetid://1835330367",{
				Volume = 4,
				PlaybackSpeed = .9,
				Looped = true,
				PlaybackRegionsEnabled = true,
				LoopRegion = NumberRange.new(0.7,1.1),
				PlaybackRegion = NumberRange.new(0,1.1)
			})

			data.currentSounds.risersndA.Parent,data.currentSounds.risersndB.Parent = plr,plr
			quicktween(data.currentSounds.risersndA,TweenInfo.new(2,Enum.EasingStyle.Linear),{Volume = .6*3,PlaybackSpeed = 1.3})
			quicktween(data.currentSounds.risersndB,TweenInfo.new(1.75,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Volume = 1.5*3})

			local lastCrack = os.clock()
			data.curCrackParts = {}
			data.curCrackSnds = {}
			data.crackTweens = {}
			
			local offset = Vector3.new(
				rand:NextNumber(-20,20),
				rand:NextNumber(20,40),
				rand:NextNumber(60,80)
			)
			local initOffset = CFrame.new(
				rand:NextNumber(-1,1),
				rand:NextNumber(-1,1),
				rand:NextNumber(-1,1)
			)*CFrame.fromOrientation(
				math.rad(rand:NextNumber(-5,-5)),
				math.rad(rand:NextNumber(-5,-5)),
				math.rad(rand:NextNumber(-5,-5))
			)
			
			quicktween(sphereMesh,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = Vector3.one*data.scaleSize})
			
			data.fixFunctions = {}

			local function patchElement(element)
				if element:IsA("ImageLabel") then
					table.insert(data.fixFunctions,temporaryStaticize(element,"ImageColor3",Color3.new()))
				elseif element:IsA("TextLabel") then
					table.insert(data.fixFunctions,temporaryStaticize(element,"TextColor3",Color3.new()))
				elseif element:IsA("Frame") then
					table.insert(data.fixFunctions,temporaryStaticize(element,"BackgroundColor3",Color3.new()))
				end
			end
			
			local setFocus = camera.Focus
			local endIStart
			
			data.stepName = "shortImpactCam"..http:GenerateGUID(false)
			
			local lastFOV = 0
			runserv:BindToRenderStep(data.stepName,Enum.RenderPriority.Camera.Value+2,function(dt:number)
				local elapsed = (os.clock()-start)/0.75 -- tween will last for 0.75 SECONDS

				--murdRoot.CFrame = lastMurdCF
				--victRoot.CFrame = lastVictCF

				data.curFov = lerp(data.curFov,lerp(80,data.targetFov,math.clamp(elapsed,0,1)),math.min(dt*4,1))
				local fovDelta = data.curFov-lastFOV
				lastFOV = data.curFov
				
				cameraFOVOffset += fovDelta
				
				local focus = plr.Character and plr.Character:GetPivot() or setFocus
				
				local pos = (CFrame.lookAt(focus.Position,explosionPos)*CFrame.new(offset)).Position
				local lookAng = CFrame.lookAt(pos,explosionPos).Rotation
				local distance = (pos-explosionPos).Magnitude

				-- getting the bounding box every frame will probably lag a bit but Me no carey
				
				local cfB = CFrame.new(explosionPos)*lookAng*CFrame.new(0,0,distance)
				local cfA = cfB*initOffset
				
				local lerpATime,lerpBTime = math.min(elapsed/0.8,1),math.min(elapsed/0.5,1)

				curCF = curCF:Lerp(lastCF:Lerp(cfA:Lerp(cfB,lerpATime),lerpBTime)*CFrame.new(0,0,-2),math.min(dt*4,1))

				local offset = CFrame.new()
				if cracks then
					offset = CFrame.new(
						rand:NextNumber(-elapsed/50,elapsed/50),
						rand:NextNumber(-elapsed/50,elapsed/50),
						rand:NextNumber(-elapsed/50,elapsed/50)
					) * CFrame.Angles(
						rand:NextNumber(-elapsed/3,elapsed/3)/180/math.pi,
						rand:NextNumber(-elapsed/3,elapsed/3)/180/math.pi,
						rand:NextNumber(-elapsed/3,elapsed/3)/180/math.pi
					)
				end
				
				local camCF = curCF*offset*lastShakeCFrame
				
				if data.endI and os.clock()-data.endI > 1 then
					data.targetFov = lerp(-30,0,math.clamp((os.clock()-data.endI-1)/1,0,1))
					camera.CFrame = camCF:Lerp(camera.CFrame,twserv:GetValue((os.clock()-data.endI-1)/2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut))
				else
					camera.CFrame = camCF
					camera.Focus = CFrame.new(focus.Position)
				end
				
				stepCameraZoom()
				
				local curDist = (focus.Position-camera.CFrame.Position).Magnitude
				for _,prt in ipairs(characterParts) do
					prt.LocalTransparencyModifier *= math.max(1-(curDist/2+0.05),0)
				end

				if cracks and os.clock()-lastCrack > .8-(elapsed*0.3) then
					--data.targetFov += 1.3
					lastCrack = os.clock()
					local highlightAddition = Instance.new("Part")
					highlightAddition.Transparency = 0
					highlightAddition.Anchored = true
					highlightAddition.CanCollide = false
					highlightAddition.CanQuery = false
					highlightAddition.CanTouch = false
					highlightAddition.Locked = true
					highlightAddition.Material = Enum.Material.Neon
					highlightAddition.Size = Vector3.one
					highlightAddition.CFrame = CFrame.Angles(
						rand:NextNumber(-math.pi,math.pi),
						rand:NextNumber(-math.pi,math.pi),
						rand:NextNumber(-math.pi,math.pi)
					) + sphere.Position
					
					local scaleStart = Vector3.new(0.1,0.1,15*(elapsed+0.5))*data.scaleSize
					local scaleEnd = Vector3.new(0,0,data.scaleSize*15)*data.scaleSize
					
					local hMesh = Instance.new("SpecialMesh")
					hMesh.MeshType = Enum.MeshType.Brick
					hMesh.Scale = scaleStart
					hMesh.Parent = highlightAddition
					
					highlightAddition.Parent = sphereMdl
					
					table.insert(data.curCrackParts,{
						prt = highlightAddition,
						mesh = hMesh
					})
					table.insert(data.crackTweens,quicktween(highlightAddition,TweenInfo.new(.8-((elapsed/3)*0.5),Enum.EasingStyle.Linear),{Size = scaleEnd},function(status)
						if status ~= Enum.PlaybackState.Completed then return end
						highlightAddition:Destroy()
					end))

					local crack = Instance.new("Sound")
					crack.SoundId = crackIds[rand:NextInteger(1,#crackIds)]
					crack.Volume = (0.4+(elapsed*0.3))*3
					crack.RollOffMaxDistance = math.huge
					crack.RollOffMinDistance = math.huge
					crack.RollOffMode = Enum.RollOffMode.Linear
					crack.PlaybackSpeed = 0.4
					crack.Parent = sphere
					crack:Play()
					data.curCrackSnds[crack] = crack.Ended:Once(function()
						crack:Destroy()
						data.curCrackSnds[crack] = nil
					end)
				end
			end)

			data.currentSounds.risersndCTrueRiser.Parent = clientScript
			local tim = 1.1/data.currentSounds.risersndCTrueRiser.PlaybackSpeed
			local del = task.delay(3-tim,function()
				if not data.currentSounds.risersndCTrueRiser.IsLoaded then
					data.currentSounds.risersndCTrueRiser.Loaded:Wait()
				end
				data.currentSounds.risersndCTrueRiser:Play()
				data.currentSounds.risersndCTrueRiser.TimePosition = (os.clock()-start)-tim
			end)

			data.currentSounds.finalKillSnd = createsnd("rbxassetid://1835348411",{
				Volume = 5,
				PlaybackSpeed = rand:NextNumber(3.5,4.5),
			})

			data.currentSounds.finalKillSndB = createsnd("rbxassetid://146750669",{
				Looped = true,
				Volume = 0,
				PlaybackSpeed = 8,
				RollOffMaxDistance = math.huge,
				RollOffMinDistance = math.huge,
				RollOffMode = Enum.RollOffMode.Linear,
				Parent = sphere
			})
			task.delay(2,function()
				data.currentSounds.finalKillSndB:Play()
				quicktween(data.currentSounds.finalKillSndB,TweenInfo.new(.5,Enum.EasingStyle.Linear),{Volume = .3,PlaybackSpeed = 9})
				task.delay(.5,function()
					quicktween(data.currentSounds.finalKillSndB,TweenInfo.new(.3,Enum.EasingStyle.Linear),{PlaybackSpeed = 5})
				end)
			end)

			task.wait(2.8) -- orignally 2.7
			cc.TintColor = Color3.new(1,0,0)
			cc.Brightness = 1
			task.cancel(del)
			cracks = false

			for _,element in ipairs(UI.headerContainer:GetDescendants()) do
				patchElement(element)
			end
			for _,element in ipairs(UI.infoPopup:GetDescendants()) do
				patchElement(element)
			end
			for _,tween in ipairs(data.crackTweens) do
				tween:Cancel()
				tween:Destroy()
			end
			for snd in pairs(data.curCrackSnds) do
				snd:Destroy()
			end

			data.currentSounds.finalKillSnd:Play()
			
			local killSoundGoal = {Volume = 0,PlaybackSpeed = 0}
			quicktween(data.currentSounds.risersndCTrueRiser,TweenInfo.new(.2,Enum.EasingStyle.Linear),killSoundGoal)
			quicktween(data.currentSounds.risersndA,TweenInfo.new(.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),killSoundGoal,function()
				data.currentSounds.risersndA:Destroy()
			end)
			quicktween(data.currentSounds.risersndB,TweenInfo.new(.2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),killSoundGoal,function()
				data.currentSounds.risersndB:Destroy()
			end)

			data.highlight.OutlineTransparency = 1
			data.highlight.FillColor = Color3.new()
			data.highlight.FillTransparency = 0

			for _,crackData in ipairs(data.curCrackParts) do
				crackData.mesh.Scale = Vector3.new(.1,.4,400)*data.scaleSize
			end

			task.wait(.12)
			data.cc.TintColor = Color3.new()
			data.highlight.OutlineTransparency = 0
			data.highlight.FillTransparency = 0.2
			data.highlight.FillColor = Color3.new(1,1,1)

			task.wait(.05)
			for _,crackData in ipairs(data.curCrackParts) do
				crackData.prt:Destroy()
			end
			data.cc.Brightness = 0
			data.currentSounds.finalKillSnd:Destroy()
			data.currentSounds.finalKillSndB:Destroy()
			data.sphere:Destroy()
		end,
	}
	
	local impactFramesEnd:{[number]: ({[any]: any}) -> ()} = {
		[0] = function(data)
			data.cc:Destroy()
			data.highlight:Destroy()

			setSndUpdateFunc()
			setSndGroupUpdateFunc()
			for _,func in ipairs(data.fixFunctions) do
				task.spawn(func)
			end
		end,
		[1] = function(data)
			for _,func in ipairs(data.fixFunctions) do
				task.spawn(func)
			end
			data.highlight:Destroy()
			--data.highlightAlt:Destroy()
			data.sphere:Destroy()
			for _,snd in pairs(data.currentSounds) do
				snd:Destroy()
			end
			for _,crackData in ipairs(data.curCrackParts) do
				crackData.prt:Destroy()
			end
			for snd in pairs(data.curCrackSnds) do
				snd:Destroy()
			end

			quicktween(data.highlight,TweenInfo.new(.75,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{FillTransparency = .9})

			data.endI = os.clock()

			data.cc.TintColor = Color3.new(1,0,1)
			quicktween(data.cc,TweenInfo.new(.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{TintColor = Color3.new(1,1,1), Saturation = 0},function()
				data.cc:Destroy()
			end)
			
			task.delay(3,function()
				runserv:UnbindFromRenderStep(data.stepName)
				cameraFOVOffset -= data.curFov
			end)
		end,
	}
	
	local scaleInfo = TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	
	local functions:{[number]: (...any) -> ()} = {
		[0] = function(vis:boolean,id:string,visTime:number?,forceEnd:boolean?) -- grand notification
			if vis then
				if id then
					lastPopupVisiblityDelayTime = visTime or 0
					playGrandPopupAnim(id)
				end
				if not popupvisible then
					popupvisible = true
					info.Visible = true
					info.offsetLeft.Position = UDim2.fromScale(rand:NextNumber(-.8,-.6),0)
					info.offsetRight.Position = UDim2.fromScale(rand:NextNumber(.6,.8),0)
					info.offsetLeft:TweenPosition(UDim2.new(),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.4,true)
					info.offsetRight:TweenPosition(UDim2.new(),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.4,true)
					
					task.delay(.2,function()
						local s = createsnd("rbxassetid://4707886983",{
							Volume = 0.7,
							TimePosition = 0.1
						},true)
						info.offsetLeft.screen.Visible = true
						info.offsetRight.screen.Visible = true
						info.offsetLeft.screen:TweenPosition(UDim2.fromScale(.5,.5),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.3,true)
						info.offsetRight.screen:TweenPosition(UDim2.fromScale(.5,.5),Enum.EasingDirection.In,Enum.EasingStyle.Linear,.3,true,function()
							s:Destroy()
							for i = 1,4 do
								particles.smoke(
									Vector2.new(.5,info.Position.Y.Scale+rand:NextNumber(-.1,.1)),
									Vector2.new(rand:NextNumber(-0.5,0.5),rand:NextNumber(.2,.3)),nil,16
								)
							end
							for i = 1,4 do
								particles.smoke(
									Vector2.new(.23,info.Position.Y.Scale+rand:NextNumber(-.1,.1)),
									Vector2.new(rand:NextNumber(-0.5,0.5),rand:NextNumber(.2,.3)),nil,16
								)
							end
							for i = 1,4 do
								particles.smoke(
									Vector2.new(.771,info.Position.Y.Scale+rand:NextNumber(-.1,.1)),
									Vector2.new(rand:NextNumber(-0.5,0.5),rand:NextNumber(.2,.3)),nil,16
								)
							end
							for i = 1,4 do
								particles.spark(
									Vector2.new(.5,info.Position.Y.Scale+rand:NextNumber(-.1,.1)),
									Vector2.new(rand:NextNumber(-0.5,0.5),rand:NextNumber(.2,.3)),nil,16
								)
							end
							createtempsnd("rbxassetid://3908308607",{
								Volume = 0.7,
							})
							createtempsnd("rbxassetid://9119623080",{
								Volume = 0.7,
							})
						end)
					end)
					
					createtempsnd("rbxassetid://9114852075",{
						Volume = 0.8,
						PlaybackSpeed = 0.8,
					})
					quicktween(etimerBase.scale,TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = 1})
					quicktween(etimerAltBase.scale,TweenInfo.new(.4,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = 1})
					
					extraPopupWaitThread = task.delay(.8,function()
						canLowerPopupBecomeVisible = true
						updateLowerPopupVisibility(isLowerPopupVisible)
					end)
				end
			elseif forceEnd then
				killGrandPopupQueue()
				cleanupFrames()
				hidePopup()
			end
		end,
		[1] = function(mag:number,dur:number,origin:Vector3,falloff:number) -- explosion shake
			mag = origin and falloff and mag*(1-(camera.CFrame.Position-origin).Magnitude/falloff) or mag
			if mag <= 0 then return end -- too far
			table.insert(explosionmagnitudes,{
				Magnitude = mag,
				Duration = dur,
				Effectiveness = 1
			})
		end,
		[2] = function(snd:Sound?) -- explosion shake but sound based
			if not snd then return end
			local shakeData = snd:GetAttribute("ShakeData")
			if shakeData then
				shakeData = http:JSONDecode(shakeData) :: {{number}}
			end
			table.insert(shockfollowers,{
				Sound = snd,
				ShakeMultiplier = snd:GetAttribute("ShakeMultiplier") or 1,
				ShakeData = shakeData
			})
		end,
		[3] = function(fov:number,dur:number) -- fov tween
			cameraFOVOffset += fov
			
			local start = os.clock()
			local lastVal = 0
			local remaining = 1
			local FOVTweenStep:RBXScriptConnection?
			FOVTweenStep = runserv.RenderStepped:Connect(function()
				local elapsed = os.clock()-start
				
				local t = twserv:GetValue(elapsed/dur,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
				local delta = t-lastVal
				lastVal = t
				
				remaining -= delta
				cameraFOVOffset -= fov*delta
				if elapsed > dur and FOVTweenStep then
					FOVTweenStep:Disconnect()
					FOVTweenStep = nil
					cameraFOVOffset -= fov*remaining
				end
			end)
		end,
		[4] = function(died:boolean,brightness:number?,tint:Color3?,wooshSound:boolean?,lengthOverride:number?) -- bright screen tint
			local timeLength = lengthOverride or (died and 10 or 2)
			
			local light = Instance.new("ColorCorrectionEffect")
			light.TintColor = Color3.new(1,1,1)
			light.Parent = lighting
			quicktween(light,TweenInfo.new(.1,Enum.EasingStyle.Linear),{Brightness = brightness or 1, TintColor = tint or Color3.new(1,1,1)},function()
				if died then task.wait(5) end
				quicktween(light,TweenInfo.new(timeLength,Enum.EasingStyle.Linear),{Brightness = 0, TintColor = Color3.new(1,1,1)},function()
					light:Destroy()
				end)
			end)
			if wooshSound then
				createtempsnd("rbxassetid://1843027392",{Volume = 1.5})
				createtempsnd("rbxassetid://9126102254",{Volume = 1})
			end
		end,
		[5] = function(txt:string,force:boolean?,sndData:{[string]: any}) -- notification
			playPopupAnim(txt,force,sndData)
		end,
		[6] = function() -- kick
			kicked = true
		end,
		[7] = function(length:number) -- break camera for a few seconds
			if brokenCamera then return end
			local prevListenerType,prevListener = sndserv:GetListener()
			overlays.cameraErrorOverlay.Visible = true
			local last = os.clock()
			local snd = createsnd("rbxassetid://6737582037",{Volume = 1.3},true)
			
			cameraFlingOffset = CFrame.new(rand:NextNumber(-.3,.3),rand:NextNumber(-.3,.3),rand:NextNumber(-.3,.3))*
				CFrame.Angles(rand:NextNumber(-1.1,1.1),rand:NextNumber(-1.1,1.1),rand:NextNumber(-1.1,1.1))
			for i = 1,3 do -- wait x frames for renderstepped and preload working
				task.wait()
			end
			overlays.cameraCut.Visible = true
			overlays.cameraCut.container.Visible = false
			overlays.cameraCut.container.info.Visible = true
			brokenCamera = true
			repeat until os.clock()-last > 0.4
			snd:Destroy()
			overlays.cameraErrorOverlay.Visible = false
			
			sndserv:SetListener(Enum.ListenerType.CFrame,INVALID_CFRAME)
			cameraFlingOffset = nil

			local bgsnd = createsnd("rbxassetid://2971286302",{Volume = 1.4,Looped = true})
			local fixFunctions = {}
			setSndUpdateFunc(function(snd)
				if snd == bgsnd then return end
				removeSndFunct(snd,fixFunctions)
			end)
			setSndGroupUpdateFunc(function(snd)
				removeSndGroupFunct(snd,fixFunctions)
			end)
			
			task.wait(.4)
			updateAltTimerFlag(1)
			overlays.cameraCut.container.title.Text = "SIGNAL LOST"
			overlays.cameraCut.container.Visible = true
			bgsnd:Play()

			local step
			step = runserv.RenderStepped:Connect(function()
				local elapsed = os.clock()-last
				overlays.cameraCut.container.info.Text = `ATTEMPTING RECONNECT IN {string.format("%.2f",math.max(length-elapsed,0))} SECONDS`
				if elapsed > length then
					step:Disconnect()
					bgsnd:Destroy()
					local reconnectsnd = createsnd("rbxassetid://9040512330",{Volume = .8,Looped = true,PlaybackSpeed = 0.4},true)
					overlays.cameraCut.container.title.Text = "RECONNECTING..."
					overlays.cameraCut.container.info.Visible = false
					task.wait(rand:NextNumber(.15,.3))
					overlays.cameraCut.container.title.Text = ""
					task.wait(rand:NextNumber(0.05,0.08))
					reconnectsnd:Destroy()
					createtempsnd("rbxassetid://166047422",{Volume = 1.2})
					local listenerType,listen = sndserv:GetListener()
					if listenerType == Enum.ListenerType.CFrame and listen == INVALID_CFRAME then
						sndserv:SetListener(prevListenerType,prevListener)
					end
					overlays.cameraCut.Visible = false
					overlays.cameraFix.Visible = true
					
					brokenCamera = false
					updateAltTimerFlag(-1)
					overlays.cameraFix.BackgroundTransparency = 0
					overlays.cameraFix.BackgroundColor3 = Color3.new()
					overlays.cameraFix.inner.BackgroundTransparency = 0
					overlays.cameraFix.inner.Size = UDim2.fromScale(0,0)
					local style = TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
					quicktween(overlays.cameraFix,style,{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 1})
					quicktween(overlays.cameraFix.inner,style,{Size = UDim2.fromScale(2,2),BackgroundTransparency = 1},function()
						overlays.cameraFix.Visible = false
					end)

					setSndUpdateFunc()
					setSndGroupUpdateFunc()
					for _,func in ipairs(fixFunctions) do
						task.spawn(func)
					end
				end
			end)
		end,
		[8] = function() -- force end grand info popup
			popupvisible = false
			hasPopups = false
			killGrandPopupQueue()
			cleanupFrames()
			--hidePopup()
			isLowerPopupVisible = false
			updateLowerPopupVisibility(false,true)
			canLowerPopupBecomeVisible = false
			
			createtempsnd("rbxassetid://511081265",{Volume = 2})
			
			local fakeScreenA,fakeScreenB = info.offsetLeft.screen:Clone(),info.offsetRight.screen:Clone()
			fakeScreenA.Parent = info.fakeFrames
			fakeScreenB.Parent = info.fakeFrames
			quickset({fakeScreenA.clip,fakeScreenB.clip},"Visible",false)
			
			fakeScreenA.Position = UDim2.fromScale(.5,.5)
			fakeScreenB.Position = UDim2.fromScale(.5,.5)
			info.offsetLeft.screen.Position = UDim2.fromScale(.15,.5)
			info.offsetRight.screen.Position = UDim2.fromScale(.85,.5)
			
			local posA = fakeScreenA.Position
			local posB = fakeScreenB.Position

			info.offsetLeft:TweenPosition(UDim2.fromScale(-.6,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,1,true)
			info.offsetRight:TweenPosition(UDim2.fromScale(1.6,0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,1,true)
			
			local initYVel1 = rand:NextNumber(-50,-120)
			local initYVel2 = rand:NextNumber(-50,-120)
			local initXVel1 = -rand:NextNumber(20,40)
			local initXVel2 = rand:NextNumber(20,40)
			
			local yVel1 = 0
			local yVel2 = 0
			
			local rotation1,rotation2 = rand:NextNumber(-30,30),rand:NextNumber(-30,30)
			local physicsStep
			
			local frm1StepActive,frm2StepActive = true,true
			
			physicsStep = runserv.RenderStepped:Connect(function(dt:number)
				local grav = dt*200
				if frm1StepActive then
					yVel1 += grav
					
					posA += UDim2.fromScale(
						(initXVel1*dt)/50,
						(yVel1*dt + initYVel1*dt)/50
					)
					fakeScreenA.Rotation += rotation1*dt*10
					
					fakeScreenA.Position = posA
					if fakeScreenA.AbsolutePosition.Y > UI.AbsoluteSize.Y+100 then
						frm1StepActive = false
						createtempsnd("rbxassetid://9116546326",{Volume = 1.2})
					end
				end
				if frm2StepActive then
					yVel2 += grav
					posB += UDim2.fromScale(
						(initXVel2*dt)/50,
						(yVel2*dt + initYVel2*dt)/50
					)
					fakeScreenB.Rotation += rotation2*dt*10
					
					fakeScreenB.Position = posB
					if fakeScreenB.AbsolutePosition.Y > UI.AbsoluteSize.Y+100 then
						frm2StepActive = false
						createtempsnd("rbxassetid://9116546593",{Volume = 1.2})
					end
				end
				
				if not frm1StepActive and not frm2StepActive then
					physicsStep:Disconnect()
					fakeScreenA:Destroy()
					fakeScreenB:Destroy()
				end
			end)
		end,
		[9] = function(impactId:string,impactData:{[any]:any}?,start:number?,del:number?,stop:boolean?) -- impact frames
			local impactId = string.byte(impactId)
			
			local iframes = impactFrames[impactId]
			if not iframes then return end
			
			local dela = del or 0
			local start = start or 0

			if dela > 0 then
				repeat task.wait() until getservertime()-start > dela
			end
			
			local activeData = currentActiveImpactFrames[impactId]
			if activeData then
				if coroutine.status(activeData.Task) ~= "dead" then
					task.cancel(activeData.Task)
				end
				currentActiveImpactFrames[impactId] = nil
			end
			
			if stop and activeData then
				local ifrmEnd = impactFramesEnd[impactId]
				if not ifrmEnd then
					return
				end
				
				task.spawn(ifrmEnd,activeData.Data)
				
				return
			end
			
			local iframeData = impactData or {}
			currentActiveImpactFrames[impactId] = {
				Task = task.spawn(iframes,iframeData),
				Data = iframeData
			}
		end,
		[10] = function(enabled:boolean,cf:CFrame) -- camera force cframe
			if enabled then
				focusCFrame = cf
			end
			focusEnabled = enabled
			lastFocusTick = os.clock()
		end,
	}

	re.Event:Connect(function(c,...)
		c = byte(c)
		if functions[c] then
			functions[c](...)
		end
	end)
end

local allFRMTexts:{TextLabel} = {}
local allOtherFRMTexts:{TextLabel} = {}
info.offsetLeft.screen.clip.content.actualContent.DescendantAdded:Connect(function(label)
	if label:IsA("TextLabel") then
		table.insert(allFRMTexts,label)
	end
end)
info.offsetRight.screen.clip.content.actualContent.DescendantAdded:Connect(function(label)
	if label:IsA("TextLabel") then
		table.insert(allOtherFRMTexts,label)
	end
end)
info.offsetLeft.screen.clip.content.actualContent.DescendantRemoving:Connect(function(label)
	if label:IsA("TextLabel") then
		local i = table.find(allFRMTexts,label)
		if i then
			table.remove(allFRMTexts,i)
		end
	end
end)
info.offsetRight.screen.clip.content.actualContent.DescendantRemoving:Connect(function(label)
	if label:IsA("TextLabel") then
		local i = table.find(allOtherFRMTexts,label)
		if i then
			table.remove(allOtherFRMTexts,i)
		end
	end
end)

local alwaysEmit = {}
local function bindToTag<T>(tag:string,func:(T)->nil)
	for i,v in ipairs(tags:GetTagged(tag)) do
		task.spawn(func,v)
	end
	tags:GetInstanceAddedSignal(tag):Connect(func)
end
bindToTag(tagLookup.SyncPlayback,function(inst:Sound)
	playSndFromTimestamp(inst,inst:GetAttribute(attributeLookup.TimePlayed))
end)
bindToTag(tagLookup.AlwaysEmit,function(inst:ParticleEmitter)
	table.insert(alwaysEmit,{
		instance = inst,
		lastTickTime = os.clock()
	})
end)

local timerWasOverheating = false

local maxTextInt = 0xFFFFF
function getRandomText(length)
	local txt = ""
	for i = 1,length do
		txt ..= utf8.char(rand:NextInteger(1,maxTextInt))
	end
	return txt
end
local function getNewRandomVectorSeeds(amnt:number?):(...Vector3)
	local amnt = math.max(amnt or 1,1)
	local tb = table.create(amnt)
	for i = 1,amnt do
		table.insert(tb,Vector3.new(rand:NextNumber(-2^16,2^16),rand:NextNumber(-2^16,2^16),0))
	end
	return table.unpack(tb)
end
local etimerOffsetLastTick = os.clock()
local etimerOffsetNoiseX,etimerOffsetNoiseY = getNewRandomVectorSeeds(2)
local etimerOffsetRotationNoise = getNewRandomVectorSeeds(1)

local lastcf = camera.CFrame
--local lastblink,blink = os.clock(),false
local blink = false
local lastValidSecond = -1
local lastValid10Seconds = -1
runserv:BindToRenderStep("MainDisasterBefore"..http:GenerateGUID(true),Enum.RenderPriority.Camera.Value-1,function()
	camera.CFrame = lastcf
end)

local lastTexts:{
	[TextLabel]: {
		PreviousText: string,
		ModifiedText: string,
		LinkedLabel: TextLabel?
	}
} = {}

local overheatSnd:Sound?
local steamSnd:Sound?
local creakSound:Sound?

local smokeTimeDelay = 0
local sparkTimeDelay = 0
local frameTime = 0
local minimumProperFrameTime = 1/60

local overheatWeightFinal = 0

local function removeRichTextTags(str:string) -- https://devforum.roblox.com/t/how-can-i-eliminate-richtext-from-my-for-loop/1173261/8
	str = str:gsub("<br%s*/>", "\n")
	return (str:gsub("<[^<>]->", ""))
end
local function updateShutdownWindowTime(ctime:number)
	if not shutdownExpiration then
		justExpired = false
		updateNumberGroupLED(etimer.shutdownTimer,ctime-300)
	elseif not justExpired then
		justExpired = true
		updateNumberGroupLED(etimer.shutdownTimer,0)
	end
end
local function tickTimerParticles(overheatWeight:number,dt:number,isProperFrame:boolean,ctime:number)
	local sizeScaleDown,anchorOffset = getTrueOffsetsBasedOff(etimer.timerParticleContainer)
	if smokeTimeDelay > 0.1 then
		smokeTimeDelay = 0
		particles.smoke(
			Vector2.new(
				etimer.smokeExitRight.Position.X.Scale,
				etimer.smokeExitRight.Position.Y.Scale+rand:NextNumber(0,etimer.smokeExitRight.Size.Y.Scale)
			)/sizeScaleDown+anchorOffset,
			Vector2.new(3,0),
			etimer.timerParticleContainer,
			1
		)

		if overheatWeight > .75 then
			particles.smoke(
				Vector2.new(
					etimer.smokeExitLeft.Position.X.Scale+etimer.smokeExitLeft.Size.X.Scale,
					etimer.smokeExitLeft.Position.Y.Scale+rand:NextNumber(0,etimer.smokeExitLeft.Size.Y.Scale)
				)/sizeScaleDown+anchorOffset,
				Vector2.new(-3,0),
				etimer.timerParticleContainer,
				1
			)
		end
	end

	if overheatWeight >= .8 then
		sparkTimeDelay += dt
	end

	if sparkTimeDelay > rand:NextNumber(0.7,2.2) then
		sparkTimeDelay = math.max(sparkTimeDelay-rand:NextNumber(0.7,1.3),0)
		particles.spark(
			Vector2.new(
				etimer.mainTimer.Position.X.Scale+rand:NextNumber(0,etimer.mainTimer.Size.X.Scale),
				etimer.mainTimer.Position.Y.Scale+rand:NextNumber(0,etimer.mainTimer.Size.Y.Scale)
			)/sizeScaleDown+anchorOffset,
			Vector2.zero,
			etimer.timerParticleContainer,
			2
		)
	end

	if isProperFrame and rand:NextInteger(1,30) == 1 then
		task.spawn(function()
			local randomToPick = {
				etimer.mainTimer.timerMinutes,
				etimer.mainTimer.timerSeconds,
				etimer.mainTimer.timerMilliseconds,
				etimer.shutdownTimer.timerMinutes,
				etimer.shutdownTimer.timerSeconds,
				etimer.shutdownTimer.timerMilliseconds,
			}

			local LED = randomToPick[math.random(#randomToPick)]
			if rand:NextInteger(1,2) == 1 and overheatWeight > 0.5 then
				updateNumberLED(LED,rand:NextInteger(0,99))
			end
			deadLEDs[LED] = true
			task.wait(rand:NextNumber(0.4,0.8))
			deadLEDs[LED] = nil
			justExpired = false
			updateShutdownWindowTime(ctime)
			justExpired = true
		end)
	end
end
runserv:BindToRenderStep("MainDisaster"..http:GenerateGUID(true),Enum.RenderPriority.Camera.Value+1,function(dt)
	local last = gvals.startTime == -1 and math.huge or gvals.startTime
	local currentServerTime = getservertime()
	local ctime = timerFrozen and lastFreezeTimerTime or math.clamp((last+600)-currentServerTime,0,600)
	if ctime >= math.huge or ctime ~= ctime then
		ctime = 600 -- 10 minutes
	end
	if timerLEDActive then
		updateNumberGroupLED(etimer.mainTimer,ctime)
		updateShutdownWindowTime(ctime)
	end
	etimer.mainTimer.Visible = timerLEDActive
	etimer.shutdownTimer.Visible = timerLEDActive

	frameTime += dt
	local isProperFrame = false
	if frameTime > minimumProperFrameTime then
		frameTime = 0
		isProperFrame = true
	end
	
	local totalshake = gvals.shakeMultiplier
	for _,data in ipairs(explosionmagnitudes) do
		if data.Effectiveness < 0 then
			table.remove(explosionmagnitudes,table.find(explosionmagnitudes,data))
			continue
		end
		totalshake += data.Magnitude*data.Effectiveness
		data.Effectiveness -= (1/data.Duration)*dt
	end
	for _,data in ipairs(shockfollowers) do
		if not data.Sound.Parent then
			table.remove(shockfollowers,table.find(shockfollowers,data))
		end
		if not data.Sound.IsPlaying then
			continue -- not playing
		end
		local add:number
		if data.ShakeData then
			local timePos = data.Sound.TimePosition
			local minimumIndex
			for ix,shakeData in ipairs(data.ShakeData) do
				if shakeData[1] > timePos then
					minimumIndex = math.max(ix-1,1)
					break
				end
			end
			if not minimumIndex then
				continue
			end
			for ix in ipairs(data.ShakeData) do
				if ix < minimumIndex then
					table.remove(data.ShakeData,1)
				else
					break
				end
			end
			
			local last,new = data.ShakeData[1],data.ShakeData[2]
			if not last then
				if not new then
					add = data.Sound.PlaybackLoudness/1000
				else
					add = new[2]
				end
			else
				add = lerp(last[2],new[2],math.clamp((timePos-last[1])/(new[1]-last[1]),0,1))
			end
		else
			add = data.Sound.PlaybackLoudness/1000
		end
		totalshake += add*data.ShakeMultiplier
	end
	
	for label,data in pairs(lastTexts) do
		if label.Text == data.ModifiedText then
			label.Text = data.PreviousText
			label.AutoLocalize = true
			if data.LinkedLabel then
				data.LinkedLabel.Text = data.PreviousText
				data.LinkedLabel.AutoLocalize = true
			end
		end
		lastTexts[label] = nil
	end
	
	if popupvisible and isProperFrame and ctime < 200 and rand:NextInteger(1,math.round(ctime/10)) == 1 and #allFRMTexts ~= 0 then
		for i = 1,rand:NextInteger(1,math.round((200-ctime)/25)) do
			local label = allFRMTexts[math.random(#allFRMTexts)]
			local text = label.Text
			if #text == 0 then
				continue
			end
			
			local allStrings = {}
			
			-- collect all RichText tags
			local lastLocation:number
			for tagLocationA:number?,tagLocationB:number? in text:gmatch("()<[^<>]->()") do
				if not tagLocationA or not tagLocationB then
					break
				end
				if lastLocation then
					table.insert(allStrings,{
						Text = string.sub(text,lastLocation,tagLocationA-1),
						IsTag = false
					})
				end
				table.insert(allStrings,{
					Text = string.sub(text,tagLocationA,tagLocationB-1),
					IsTag = true
				})
				lastLocation = tagLocationB
			end
			if not lastLocation or lastLocation-1 ~= #text then
				table.insert(allStrings,{
					Text = string.sub(text,lastLocation or 1,lastLocation and #text or -1),
					IsTag = false
				})
			end
			
			local allNonTaggedStrings = {}
			for _,data in ipairs(allStrings) do
				if not data.IsTag then
					table.insert(allNonTaggedStrings,data)
				end
			end
			for i = 1,rand:NextInteger(1,math.round((200-ctime)/50)) do
				local data = allNonTaggedStrings[math.random(#allNonTaggedStrings)]
				local strings = string.split(data.Text,"")
				
				local ix = math.random(#strings)
				local str = strings[ix]
				if not str then break end
				strings[ix] = getRandomText(rand:NextInteger(1,3))
				
				data.Text = table.concat(strings)
			end
			
			local finalString = ""
			for _,data in ipairs(allStrings) do
				finalString ..= data.Text
			end
			
			local lastTextData = lastTexts[label]
			if not lastTextData then
				local linkedTextLabel
				for _,otherLabel in ipairs(allOtherFRMTexts) do
					if otherLabel.Name == label.Name and otherLabel.Text == label.Text then
						linkedTextLabel = otherLabel
						break
					end
				end
				lastTextData = {
					PreviousText = text,
					ModifiedText = finalString,
					LinkedLabel = linkedTextLabel
				}
				lastTexts[label] = lastTextData
			else
				lastTextData.ModifiedText = finalString
			end
			label.AutoLocalize = false
			label.Text = finalString
			if lastTextData.LinkedLabel then
				lastTextData.LinkedLabel.AutoLocalize = false
				lastTextData.LinkedLabel.Text = finalString
			end
		end
	end
	
	local did1SecondTick = false
	if math.floor(ctime) ~= lastValidSecond then
		lastValidSecond = math.floor(ctime)
		did1SecondTick = true
	end
	
	if etimervisible and not brokenCamera then
		local elapsed = (os.clock()-etimerOffsetLastTick)/10
		local timerTotalShake = (totalshake/1.7)+(overheatWeightFinal/15)
		etimer.Position = UDim2.fromScale(
			.5+math.noise(elapsed,etimerOffsetNoiseX.X,etimerOffsetNoiseX.Y)*0.05,
			.5+math.noise(elapsed,etimerOffsetNoiseY.X,etimerOffsetNoiseY.Y)*0.01
		)+UDim2.fromScale(rand:NextNumber(-timerTotalShake,timerTotalShake)*0.05,rand:NextNumber(-timerTotalShake,timerTotalShake)*0.03)
		etimer.Rotation = math.noise(elapsed,etimerOffsetRotationNoise.X,etimerOffsetRotationNoise.Y)*5*(rand:NextNumber(-timerTotalShake,timerTotalShake))
		if did1SecondTick then
			createtempsnd("rbxassetid://5670209472",{
				PlaybackSpeed = 0.65,
				Volume = 0.95
			})
			
			changeGroupLED(etimer.mainTimer,function(container)
				brightenLED(container.tens)
				brightenLED(container.ones)
			end)
			if ctime > 300 then
				changeGroupLED(etimer.shutdownTimer,function(container)
					brightenLED(container.tens)
					brightenLED(container.ones)
				end)
			end
		end
		
		if math.floor(ctime/10) ~= lastValid10Seconds then
			lastValid10Seconds = math.floor(ctime/10)
			createtempsnd("rbxassetid://9062373867",{
				PlaybackSpeed = 1.5,
				Volume = 0.95
			})
		end
		
		local clock = ctime%1
		if clock < 0.5 and not blink and shutdownExpiration and timerLEDActive then
			blink = true
			quickset({etimer.evacText.imgA,etimer.evacText.imgB},"ImageColor3",Color3.new(1,0,0))
			quickset({etimer.evacText.imgA,etimer.evacText.imgB},"ImageRectOffset",Vector2.new(775,535))
		elseif (clock > 0.5 and (blink or not shutdownExpiration)) or not timerLEDActive then
			blink = false
			quickset({etimer.evacText.imgA,etimer.evacText.imgB},"ImageColor3",Color3.new())
			quickset({etimer.evacText.imgA,etimer.evacText.imgB},"ImageRectOffset",Vector2.new(669,535))
		end
		
		if gvals.overheatTimer and currentServerTime > gvals.overheatTimerStart then
			local overheatWeight = math.clamp((currentServerTime-gvals.overheatTimerStart)/(gvals.overheatTimerEnd-gvals.overheatTimerStart),0,1)
			if timerLEDActive then
				overheatWeightFinal = lerp(overheatWeightFinal,overheatWeight,dt*3)
				if not overheatSnd then
					overheatSnd = createsnd("rbxassetid://5272425616",{Volume = 0,PlaybackSpeed = .5,Looped = true},true)
				end
				if overheatSnd then -- weird strict shenanigans
					overheatSnd.Volume = math.min(overheatWeight/0.3,1)*0.5
					overheatSnd.PlaybackSpeed = 0.5+overheatWeight
				end
			elseif overheatSnd then
				overheatWeightFinal = math.max(overheatWeightFinal-dt/3,0)
				overheatSnd.PlaybackSpeed -= dt/5
				overheatSnd.Volume -= (dt/7)*0.5
				if overheatSnd.Volume <= 0 or overheatSnd.PlaybackSpeed <= 0 then
					overheatSnd:Destroy()
					overheatSnd = nil
				end
			end
			etimer.BG.ImageColor3 = Color3.new(1,1,1):Lerp(Color3.fromRGB(255, 205, 131),overheatWeight)

			if overheatWeight > 0.5 then
				smokeTimeDelay += dt
			end
			
			if timerLEDActive and overheatWeight > 0.5 then
				if not creakSound then
					creakSound = createsnd("rbxassetid://9116638811",{Volume = .7,PlaybackSpeed = 1.5},true)
				end
				if creakSound then
					creakSound.Ended:Once(function()
						if not creakSound then return end
						creakSound:Destroy()
						creakSound = nil
					end)
				end
				
				if not steamSnd then
					steamSnd = createsnd("rbxassetid://4299193607",{Volume = 1.1,PlaybackSpeed = .5,Looped = true},true)
				end
				if steamSnd then
					steamSnd.PlaybackSpeed = math.min(0.75+overheatWeight/0.5,1)
				end
			end
			
			if not timerLEDActive and creakSound then
				creakSound:Destroy()
				creakSound = nil
			end
			
			if not timerLEDActive and steamSnd then
				steamSnd.Volume -= dt*5
				if steamSnd.Volume <= 0 then
					steamSnd:Destroy()
					steamSnd = nil
				end
			end
			
			if timerLEDActive then
				tickTimerParticles(overheatWeight,dt,isProperFrame,ctime)
			end
		end
	end
	
	if altTimerWasVisible then
		etimerAlt.Time.Text = `{string.format("%.2f",ctime)}s`
		if did1SecondTick then
			lastValidSecond = math.floor(ctime)
			createtempsnd("rbxassetid://9062373867",{
				PlaybackSpeed = 1.5,
				Volume = 0.95
			})
			etimerAlt.BackgroundColor3 = Color3.fromRGB(255, 146, 25)
			quicktween(etimerAlt,TweenInfo.new(.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
				BackgroundColor3 = Color3.fromRGB(254, 202, 0)
			})
			etimerAlt.Title.TextColor3 = Color3.fromRGB(255, 143, 0)
			etimerAlt.Time.TextColor3 = Color3.fromRGB(255, 143, 0)
			quicktween(etimerAlt.Title,TweenInfo.new(.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
				TextColor3 = Color3.fromRGB(255, 229, 0)
			})
			quicktween(etimerAlt.Time,TweenInfo.new(.3,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{
				TextColor3 = Color3.fromRGB(255, 229, 0)
			})
		end
	end
	
	if not etimervisible then
		if overheatSnd then
			overheatSnd.Volume -= dt*5
			if overheatSnd.Volume <= 0 then
				overheatSnd:Destroy()
				overheatSnd = nil
			end
		end
		if steamSnd then
			steamSnd.Volume -= dt*20
			if steamSnd.Volume <= 0 then
				steamSnd:Destroy()
				steamSnd = nil
			end
		end
	end
	
	if popupvisible then
		local sine = 0.1+(math.sin(os.clock()*4)*0.1)
		info.offsetLeft.info.content.contentBG.BackgroundTransparency = sine
		info.offsetLeft.screen.clip.content.contentBG.BackgroundTransparency = sine
		info.offsetRight.info.content.contentBG.BackgroundTransparency = sine
		info.offsetRight.screen.clip.content.contentBG.BackgroundTransparency = sine

		local sineScroll = math.sin(os.clock()*math.pi/2)*0.05
		info.offsetLeft.info.content.contentClipped
			.contentScrollingLower.scrollContainer.offset.Position = UDim2.fromScale(sineScroll,0)
		info.offsetLeft.info.content.contentClipped
			.contentScrollingUpper.scrollContainer.offset.Position = UDim2.fromScale(-sineScroll,0)
		info.offsetRight.info.content.contentClipped
			.contentScrollingLower.scrollContainer.offset.Position = UDim2.fromScale(-sineScroll,0)
		info.offsetRight.info.content.contentClipped
			.contentScrollingUpper.scrollContainer.offset.Position = UDim2.fromScale(sineScroll,0)
	end
	
	if musPopupVisible and lastmusicplaying then -- TODO: make this sync with bpm? currently just does the classic playbackloudness thing
		local gradVal = Vector2.new(0,-lastmusicplaying.PlaybackLoudness/500)
		musPopup.musIcon.grad.Offset = gradVal
		musPopup.musText.grad.Offset = gradVal
	end

	lastcf = camera.CFrame
	if lastFocusTick and (focusEnabled or os.clock()-lastFocusTick < 2) then
		local weight = twserv:GetValue(math.min((os.clock()-lastFocusTick)/2,1),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)

		camera.CFrame = camera.CFrame:Lerp(focusCFrame,focusEnabled and weight or (1-weight))
		wasFocused = true

		local curDist = (camera.Focus.Position-camera.CFrame.Position).Magnitude
		for _,prt in ipairs(characterParts) do
			prt.LocalTransparencyModifier *= math.max(1-(curDist/2+0.05),0)
		end
	elseif wasFocused then
		wasFocused = false
	end

	local dist = (camera.Focus.Position-camera.CFrame.Position).Magnitude
	local shakeCFrame = CFrame.new(rand:NextNumber(-totalshake,totalshake),rand:NextNumber(-totalshake,totalshake),rand:NextNumber(-totalshake,totalshake))
		* CFrame.Angles(math.rad(rand:NextNumber(-totalshake,totalshake))*3,math.rad(rand:NextNumber(-totalshake,totalshake))*3,math.rad(rand:NextNumber(-totalshake,totalshake))*3)

	lastShakeCFrame = shakeCFrame

	if wasFocused then
		camera.CFrame *= shakeCFrame
	else
		camera.CFrame = CFrame.new(camera.Focus.Position)*camera.CFrame.Rotation*shakeCFrame*CFrame.new(0,0,dist)
	end
	
	stepCameraZoom()

	if gvals.tiltingCamera then
		camera.CFrame *= CFrame.Angles(0,0,math.rad(math.sin(os.clock()/2)*5))
	end
	if cameraFlingOffset then
		camera.CFrame *= cameraFlingOffset
	end
	
	if lastmusicplaying and gvals.musFadeStart ~= -1 and gvals.musFadeEnd ~= -1 then
		local vol:number = allMusVolumes[lastmusicplaying] or 1
		local volWeight = math.clamp((currentServerTime-gvals.musFadeStart)/(gvals.musFadeEnd-gvals.musFadeStart),0,1)
		lastmusicplaying.Volume = lerp(vol,0,volWeight)
	end
	
	if brokenCamera then
		camera.CFrame = INVALID_CFRAME
		overlays.cameraCut.container.Position = UDim2.fromOffset(rand:NextNumber(-2,2),rand:NextNumber(-2,2))
		overlays.cameraCut.background.Position = UDim2.fromScale(0.5+math.sin(os.clock()/1.5)*0.2,0)
	end
	
	for i,v in ipairs(alwaysEmit) do
		local elapsed = os.clock()-v.lastTickTime
		local rate = v.instance:GetAttribute(attributeLookup.Rate)
		local invRate = 1/rate
		if elapsed < invRate then continue end
		v.lastTickTime = os.clock()
		if v.instance.Enabled then
			v.instance:Emit(math.ceil((elapsed-invRate)*rate))
		end
	end
	if kicked then
		plr:Kick(getRandomText(300))
	end
end)

runserv.Heartbeat:Connect(function(dt:number)
	for name,group in pairs(activeParticles)  do
		task.spawn(activeParticleStepFunctions[name],group,dt)
	end
end)
		end)
	end
	
	add(game.Players.LocalPlayer)
	addedev = players.PlayerAdded:Connect(function(plr)
	print("im so cool! -"..plr.Name)
	end)
end

local preexploderemitters = modelassets.PreExploderEmitters
ignoreHandler.noInteract(preexploderemitters)

type shutdownButton = {
	buttonBase: Part,
	button: Part,
	icon: BillboardGui?,
	clickDetector: ClickDetector?
}

local totalClicked = 0
local shutdownButtons:{shutdownButton} = {}
local endTimer = false

local buttonPhase = 0


local function generateShutdownButtons()
	if not canShutdownSystem then return end
	local floors,walls = 
		geometry.getNearestSpawnParts(geometry.getFloors,2,0),
		geometry.getNonSuffocatingWalls(geometry.getNearestSpawnParts(geometry.getWalls,3,0.05))
	
	local canWall = #walls ~= 0
	local canFloor = #floors ~= 0
	if not canWall and not canFloor then return end -- no buttons to generate :(
	
	gvals.totalShutdownButtons = RANDOM:NextInteger(5,7)
	for i = 1,RANDOM:NextInteger(10,15) do -- 10-15 wall buttons will generate due to clipping
		local partTbl = RANDOM:NextInteger(1,5) < 3 and canWall and tblUtil.getRandomInList(walls) or nil
		local isFloor = not partTbl
		if not partTbl then
			partTbl = tblUtil.getRandomInList(floors)
		end
		if not partTbl then
			continue -- weird type check thing idk
		end
		local normal = tblUtil.getRandomInList(partTbl.list)
		local size = geometry.getSizeRelativeToNormal(partTbl.part,normal.normalId)
		
		local baseSize = Vector3.new(2,2)
		local baseCF = partTbl.part.CFrame
			*CFrame.lookAt(Vector3.zero,normal.normalVector)
			*CFrame.new(
				RANDOM:NextNumber(-size.X/2+baseSize.X/2,size.X/2-baseSize.X/2),
				RANDOM:NextNumber(-size.Y/2+baseSize.Y/2,size.Y/2-baseSize.Y/2),
				-size.Z/2
			)
		
		if isFloor then
			baseCF *= 
				CFrame.Angles(0,math.pi,0)
				*CFrame.Angles(math.pi/2,0,0)
				*CFrame.new(0,3+baseSize.Y/2,0)
				*CFrame.Angles(0,RANDOM:NextInteger(-math.pi,math.pi),0)
		end
		
		local btnBase = Instance.new("Part")
		btnBase.Anchored = true
		btnBase.CanCollide = false
		btnBase.Material = Enum.Material.DiamondPlate
		btnBase.Color = Color3.fromRGB(174, 158, 151)
		btnBase.Size = Vector3.new(baseSize.X,baseSize.Y,.1)
		btnBase.CFrame = baseCF*CFrame.new(0,0,-0.1)
		
		if isFloor then
			local btnHolder = Instance.fromExisting(btnBase)
			btnHolder.Size = Vector3.new(baseSize.X/2,3,.1)
			btnHolder.CFrame *= CFrame.new(0,-1.5-baseSize.Y/2,0)
			btnHolder.Parent = btnBase
		end
		
		local btn = Instance.fromExisting(btnBase)
		btn.Color = Color3.fromRGB(255, 136, 132)
		btn.Size = Vector3.new(baseSize.X/1.5,baseSize.Y/1.5,.2)
		btn.Material = Enum.Material.Neon
		btn.CFrame = baseCF*CFrame.new(0,0,-0.2)
		btn.Parent = btnBase
		
		btnBase.Parent = workspace
		table.insert(shutdownButtons,{
			buttonBase = btnBase,
			button = btn
		})
	end
end

local escapedPlayers = {}
local escapeHatches = {}
local curEscapeModel = nil
local signFont = Font.new("rbxassetid://12187367066",Enum.FontWeight.Regular,Enum.FontStyle.Italic)
local function generateEscapeHatches()
	local escapeModel = curEscapeModel
	if not escapeModel then
		escapeModel = modelassets.safeSpot:Clone()
		escapeModel:PivotTo(
			CFrame.new(setexplosionpos)*
				CFrame.new(0,10000,0)*CFrame.Angles(0,RANDOM:NextNumber(-math.pi*2,math.pi*2),0)*CFrame.new(0,0,-11000)
		)
		ignoreHandler.noInteractWithHitboxes(escapeModel)
		escapeModel.Parent = workspace
	end
	curEscapeModel = escapeModel
	
	local floors = geometry.getNearestSpawnParts(geometry.getFloors,5,0)
	local floorscl = table.clone(floors)
	
	for i = 1,RANDOM:NextInteger(6,10) do -- 6-10 escape hatches will generate
		local partTbl = table.remove(floorscl,RANDOM:NextInteger(1,#floorscl))
		if not partTbl then
			floorscl = table.clone(floors)
			partTbl = table.remove(floorscl,RANDOM:NextInteger(1,#floorscl))
		end
		if not partTbl then
			continue -- weird type check thing idk
		end
		local normal = tblUtil.getRandomInList(partTbl.list)
		local size = geometry.getSizeRelativeToNormal(partTbl.part,normal.normalId)

		local baseSize = Vector3.new(5,5)
		local baseCF = partTbl.part.CFrame
			*CFrame.lookAt(Vector3.zero,normal.normalVector)
			*CFrame.new(
				RANDOM:NextNumber(-size.X/2+baseSize.X/2,size.X/2-baseSize.X/2),
				RANDOM:NextNumber(-size.Y/2+baseSize.Y/2,size.Y/2-baseSize.Y/2),
				-size.Z/2
			)
		
		local holeBase = Instance.new("Part")
		holeBase.Anchored = true
		holeBase.CanCollide = false
		holeBase.Shape = Enum.PartType.Cylinder
		holeBase.Material = Enum.Material.Neon
		holeBase.Color = Color3.new()
		holeBase.Size = Vector3.new(.05,baseSize.X,baseSize.Y)
		holeBase.CFrame = baseCF*CFrame.new(0,0,-holeBase.Size.X/2)*CFrame.Angles(0,math.pi/2,0)
		
		local holeSignBase = Instance.fromExisting(holeBase)
		holeSignBase.Color = Color3.fromRGB(155, 141, 118)
		holeSignBase.Size = Vector3.new(.5,2,0.2)
		holeSignBase.CFrame = baseCF*CFrame.Angles(-math.pi/2,RANDOM:NextNumber(-math.pi,math.pi),0)*CFrame.new(0,holeSignBase.Size.Y/2,2)
		holeSignBase.Shape = Enum.PartType.Block
		holeSignBase.Material = Enum.Material.DiamondPlate
		holeSignBase.Parent = holeBase
		
		local holeSign = Instance.fromExisting(holeSignBase)
		holeSign.Size = Vector3.new(4,2,0.2)
		holeSign.CFrame = holeSignBase.CFrame*CFrame.new(0,holeSignBase.Size.Y/2+holeSign.Size.Y/2,0)
		holeSign.Parent = holeSignBase
		
		do
			local surf = Instance.new("SurfaceGui")
			surf.LightInfluence = 1
			surf.ResetOnSpawn = false
			surf.Face = Enum.NormalId.Front
			surf.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			
			local txt = Instance.new("TextLabel")
			txt.FontFace = signFont
			txt.Size = UDim2.fromScale(1,1)
			txt.Text = "ESCAPE HERE"
			txt.TextScaled = true
			txt.TextColor3 = Color3.new(1,1,1)
			txt.TextStrokeColor3 = Color3.new()
			txt.TextStrokeTransparency = 0
			txt.BackgroundTransparency = 1
			txt.Parent = surf
			
			surf.Parent = holeSign
		end
		
		local escapeIconContainer = Instance.new("BillboardGui") do
			local icon = Instance.new("ImageLabel")
			icon.ImageColor3 = Color3.fromRGB(255, 0, 0)
			icon.Size = UDim2.fromScale(1,1)
			icon.ImageTransparency = 0.5
			icon.BackgroundTransparency = 1
			icon.Image = "rbxassetid://18775113410"
			icon.Parent = escapeIconContainer
		end
		escapeIconContainer.StudsOffsetWorldSpace = Vector3.new(3,0,0)
		escapeIconContainer.MaxDistance = 0
		escapeIconContainer.Size = UDim2.new(5,20,5,20)
		escapeIconContainer.AlwaysOnTop = true
		escapeIconContainer.Parent = holeBase
		
		table.insert(escapeHatches,{
			hatch = holeBase,
			connection = holeBase.Touched:Connect(function(prt)
				local mod = prt.Parent
				if not mod then return end -- Thanks roblox type checker
				local hum = mod:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local root = hum.RootPart
				if not root then return end
				local plr = players:GetPlayerFromCharacter(mod)
				if not plr or escapedPlayers[plr] then return end
				escapedPlayers[plr] = true
				
				root.CFrame = escapeModel.tpPart.CFrame
				RE:Fire(char(5),"You have escaped!",false,{
					SoundId = "rbxassetid://9040533864",
					Volume = 1,
					PlaybackSpeed = 2
				})
				--math.pi/4
				--RE:Fire(char(6),
				--	CFrame.new(setexplosionpos)*CFrame.Angles(0,math.pi/4,0)*CFrame.Angles(-math.pi/4,0,0)*CFrame.new(0,0,13000),
				--	CFrame.new(setexplosionpos)
				--)
			end)
		})
		holeBase.Parent = workspace
	end
end
local function clearEscapeHatches()
	for _,hatch in ipairs(escapeHatches) do
		hatch.connection:Disconnect()
		hatch.hatch:Destroy()
	end
	table.clear(escapeHatches)
end

local function setupButtonEvents()
	for _,btnData in ipairs(shutdownButtons) do
		local btnIconContainer = Instance.new("BillboardGui") do
			local icon = Instance.new("ImageLabel")
			icon.ImageColor3 = Color3.fromRGB(255, 0, 0)
			icon.Size = UDim2.fromScale(1,1)
			icon.ImageTransparency = 0.5
			icon.BackgroundTransparency = 1
			icon.Image = "rbxassetid://18686830142"
			icon.Parent = btnIconContainer
		end
		btnIconContainer.MaxDistance = 0
		btnIconContainer.Size = UDim2.new(5,20,5,20)
		btnIconContainer.AlwaysOnTop = true
		btnIconContainer.Parent = btnData.button

		local ev
		local cd = Instance.new("ClickDetector")
		cd.MaxActivationDistance = 100
		ev = cd.MouseClick:Connect(function(plr:Player)
			if not plr.Character then return end
			if mathUtil.getMagBetweenPos(plr.Character:GetPivot(),btnData.button) > 100 then return end
			ev:Disconnect()
			cd:Destroy()
			btnIconContainer:Destroy()
			btnData.button.Color = Color3.fromRGB(127,0,0)
			gvals.pressedShutdownButtons += 1

			if gvals.pressedShutdownButtons >= gvals.totalShutdownButtons then
				if buttonPhase < 3 then
					doNewButtonWave()
				else
					endTimer = true
				end
			else
				RE:Fire(char(5),`Shutdown button pressed, {gvals.totalShutdownButtons-gvals.pressedShutdownButtons} remaining.`)
			end
		end)
		cd.Parent = btnData.button
		btnData.icon = btnIconContainer
		btnData.clickDetector = cd
	end
end
local function clearButtonHUDs()
	for _,shutdownBtn in ipairs(shutdownButtons) do
		if shutdownBtn.icon then
			shutdownBtn.icon:Destroy()
		end
		if shutdownBtn.clickDetector then
			shutdownBtn.clickDetector:Destroy()
		end
	end
end
local function clearButtons()
	for _,shutdownBtn in ipairs(shutdownButtons) do
		shutdownBtn.buttonBase:Destroy()
	end
	table.clear(shutdownButtons)
end
function doNewButtonWave(noAnnounce:boolean?,noSetupEvents:boolean?)
	buttonPhase += 1
	gvals.totalShutdownButtons = 0
	gvals.pressedShutdownButtons = 0
	clearButtons()
	generateShutdownButtons()
	if not noSetupEvents then
		setupButtonEvents()
	end
	if not noAnnounce then
		sndUtil.createTemporarySound("rbxassetid://856658167",{Volume = 1.5})
		RE:Fire(char(5),`{buttonPhase == 3 and "// FINAL PHASE //" or ""} Phase {buttonPhase}, get the remaining buttons. {buttonPhase == 3 and "// FINAL PHASE //" or ""}`)
	end
end

--task.wait(3)
--RE:Fire(char(9),char(1),{
--	explosionPos = setexplosionpos,
--	scaleSize = 400,
--},workspace:GetServerTimeNow(),.5)

--task.wait(3.5)
--RE:Fire(char(9),char(1),nil,nil,nil,true)

--task.wait(5)
--RE:Fire(char(0),true,char(0),40)
--RE:Fire(char(0),true,char(1),5)
--RE:Fire(char(0),true,char(2),5)
--RE:Fire(char(0),true,char(3),5)
--RE:Fire(char(0),true,char(4),5)
--RE:Fire(char(0),true,char(5),5)
--RE:Fire(char(0),true,char(6),5)
--RE:Fire(char(0),true,char(7),5)
--RE:Fire(char(0),true,char(8),5)
--RE:Fire(char(0),true,char(9),53)

--task.wait(5)
--RE:Fire(char(0),false,nil,nil,true)

--task.wait(2)
--RE:Fire(char(0),true,char(7),8)
--task.wait(2)
--RE:Fire(char(8))

--gvals.visible = true
--gvals.overheatTimer = true
--gvals.overheatTimerStart = workspace:GetServerTimeNow()
--gvals.overheatTimerEnd = workspace:GetServerTimeNow()+3

--RE:Fire(char(7),140)

--gvals.stage = 2
--task.wait(5)
--gvals.stage = 3

--gvals.visible = false
--task.wait(2)
--gvals.altVisible = true

--error("done")

local function getRandomExplosion(typ)
	local exFolder = typ == 1 and soundassets.bgExplosions or typ == 2 and soundassets.structureExplosions or soundassets.normalExplosions
	return tblUtil.getRandomInList(exFolder:GetChildren())
end

local flickerSnds = {
	"rbxassetid://4288784832",
	"rbxassetid://4398878054",
	"rbxassetid://4398922591"
}

local curFlickerFunctions:{()->()} = {}
local curFlickerThreads = {}
local function temporaryLightsFlicker()
	for _,thread in ipairs(curFlickerThreads) do
		task.cancel(thread)
	end
	for _,func in ipairs(curFlickerFunctions) do
		func()
	end
	table.clear(curFlickerThreads)
	table.clear(curFlickerFunctions)
	local allCurrentLights = mapDefiner.getProperLights()
	local len = #allCurrentLights
	local lightsFlickered = 0
	for _,light in ipairs(allCurrentLights) do
		if RANDOM:NextInteger(1,math.floor(lightsFlickered)+1) ~= 1 then continue end
		lightsFlickered += (1/len)*3
		local isUI = light:IsA("SurfaceGuiBase")
		table.insert(curFlickerThreads,task.delay(RANDOM:NextNumber(0,0.1),function()
			for i = 1,RANDOM:NextInteger(1,5) do
				local funcs = {}
				if light.Parent and not isUI and light.Parent:IsA("BasePart") and light.Parent.Material == Enum.Material.Neon then
					local f = staticize(light.Parent,"Color",Color3.new())
					table.insert(funcs,f)
					table.insert(curFlickerFunctions,f)
				end
				do
					local f = staticize(light,"Enabled",false)
					table.insert(funcs,f)
					table.insert(curFlickerFunctions,f)
				end
				
				task.wait(RANDOM:NextNumber(0.025,0.25))
				sndUtil.createTemporarySound(tblUtil.getRandomInList(flickerSnds),{
					Volume = 0.25,
					RollOffMaxDistance = 200,
					Parent = light.Parent
				})
				for _,func in ipairs(funcs) do
					tblUtil.removeFromTable(curFlickerFunctions,func)
					func()
				end
				table.clear(funcs)
				task.wait(RANDOM:NextNumber(0.05,0.15))
			end
		end))
	end
end
local function createRandomStructureExplosion(explodeSnd)
	if not explodeSnd then
		sndUtil.createTemporarySoundFromSound(getRandomExplosion(1))
		RE:Fire(char(1),1.25,2.3)
		temporaryLightsFlicker()
	end
	if not destroyMap then return end
	if #mapDefiner.Welds == 0 then return end
	local connectedWeldsChunks = {}
	local ignore = {}
	for _,weld in ipairs(mapDefiner.Welds) do
		local part:BasePart? = weld.Part0 or weld.Part1
		if not part then continue end
		if mapDefiner.isDescendantOfBadClass(part) or ignore[part] then continue end
		local allConnectedParts:{BasePart} = part:GetConnectedParts(true)::{any}
		local len = #allConnectedParts
		if len <= 2 then continue end
		local tb = {}
		local tbi = {}
		local good = false
		for ix,prt in ipairs(allConnectedParts) do
			if ix < 100 and mapDefiner.isDescendantOfBadClass(prt) then good = false break end
			-- dont blow up accessories pls, also only run the function if there are less than 100 parts welding to eachother
			if ignore[prt] then continue end
			ignore[prt] = true
			for _,joint in ipairs(prt:GetJoints()) do
				if tbi[joint] or joint:HasTag("DoNotInteractWeld") then continue end
				good = true
				table.insert(tb,joint)
				tbi[joint] = true
			end
		end
		if #tb == 0 or not good then continue end -- no parts, we already visited all of the parts i think
		table.insert(connectedWeldsChunks,{
			allJoints = tb,
			connectedParts = allConnectedParts
		})
	end
	if #connectedWeldsChunks == 0 then return end -- no chunks :(
	local randomParts = tblUtil.getRandomInList(connectedWeldsChunks)
	for _,joint in ipairs(randomParts.allJoints) do
		joint:Destroy()
	end
	
	local cf,size = util.getBoundingBox(randomParts.connectedParts,CFrame.identity)
	
	local pos = cf.Position+Vector3.new(
		RANDOM:NextNumber(-size.X,size.X)/5,
		RANDOM:NextNumber(-size.Y,size.Y)/5,
		RANDOM:NextNumber(-size.Z,size.Z)/5
	)
	local att = Instance.new("Attachment")
	att.Position = pos
	att.Parent = workspace.Terrain
	local ex = Instance.new("Explosion")
	ex.BlastRadius = 100
	ex.BlastPressure = 5000
	ex.DestroyJointRadiusPercent = 0
	ex.ExplosionType = Enum.ExplosionType.NoCraters
	ex.Position = pos
	ex.Parent = workspace

	for _,part:BasePart in ipairs(randomParts.connectedParts) do
		if part.Anchored then continue end
		part:ApplyImpulseAtPosition(
			CFrame.lookAt(pos,part.Position).LookVector*100*part:GetMass(),
			pos-Vector3.yAxis*3
		)
	end
	
	sndUtil.createTemporarySoundFromSound(explodeSnd or getRandomExplosion(2),{
		SoundGroup = "BAD",
		RollOffMinDistance = 500*math.max((size.Magnitude/50)*3,1),
		Parent = att
	})
	task.delay(10,att.Destroy,att)
end

local function createRandomWallExplosion(explodeSnd)
	if not destroyMap then return end
	local walls = geometry.getWalls(5,.5,true) :: {geometry.partNormalData}
	if #walls == 0 then return end

	local wall = tblUtil.getRandomInList(walls)
	local normal = tblUtil.getRandomInList(wall.list)
	
	local size = geometry.getSizeRelativeToNormal(wall.part,normal.normalId)

	local a,base = createWallHole(
		wall.part,
		wall.part.CFrame*CFrame.lookAt(Vector3.zero,normal.normalVector)*CFrame.new(0,0,size.Z/2+0.3),
		Vector3.new(size.X/2-3,size.Y/2-3,size.Z),
		Vector3.new(size.X,size.Y,size.Z),
		mapDefiner.currentDebrisTag
	)
	a.Name = normal.normalId.Name
	
	if not explodeSnd then
		RE:Fire(char(1),1.25,1.5,base.Position,150)
	end
	sndUtil.createTemporarySoundFromSound(explodeSnd or getRandomExplosion(1),{
		SoundGroup = "BAD",
		Parent = base
	})
	sndUtil.createSound("rbxassetid://9068935533",{
		SoundId = "rbxassetid://9068935533",
		RollOffMaxDistance = 150,
		Volume = .75,
		Looped = true,
		Parent = base
	})
end

local glassNoCollideName = util.genRandomText(20)
physics:RegisterCollisionGroup(glassNoCollideName)
physics:CollisionGroupSetCollidable(glassNoCollideName,glassNoCollideName,false)
local function updateCollisions()
	for _,registered in ipairs(physics:GetRegisteredCollisionGroups()) do
		physics:CollisionGroupSetCollidable(
			glassNoCollideName,
			registered.name,
			physics:CollisionGroupsAreCollidable("Default",registered.name)
		)
		physics:CollisionGroupSetCollidable(
			registered.name,
			glassNoCollideName,
			physics:CollisionGroupsAreCollidable(registered.name,"Default")
		)
	end
end
local collisionsTask = task.spawn(function()
	while task.wait(5) do
		updateCollisions()
	end
end)

local glassMaterials = {
	[Enum.Material.Glass] = true,
	[Enum.Material.Foil] = true,
	[Enum.Material.ForceField] = true, -- because people use that for glass for some reason...
	[Enum.Material.Marble] = true
}
local function isGenericGlass(prt:BasePart)
	return glassMaterials[prt.Material] or prt.Reflectance > 0.5
end
local function fullyShatterGlass(glass): {Part}
	local wedges = shatterGlass(glass)
	if not wedges then return {} end

	glass.Transparency = 1
	glass.CanCollide = false
	glass.CanQuery = false
	glass.CanTouch = false
	glass.Anchored = true

	for _,wedge in ipairs(wedges) do
		wedge.Name = mapDefiner.currentDebrisTag
		wedge.Parent = workspace
		wedge:SetNetworkOwner()
		
		task.spawn(function()
			local wedgeIdleTime = 0
			while true do
				local dt = task.wait(.5)
				if wedge.AssemblyLinearVelocity.Magnitude <= 1 and wedge.AssemblyAngularVelocity.Magnitude <= 1 then
					wedgeIdleTime = .5
				else
					wedgeIdleTime = 0
				end
				if wedgeIdleTime > 4 then
					wedge.Anchored = true
					wedge.CanCollide = false
				end
			end
		end)
	end
	return wedges
end
local function breakRandomGlass()
	if not destroyMap then return end
	local allGlass = {}
	for _,prt in ipairs(mapDefiner.Parts) do
		if prt.CanCollide and not prt:IsA("TrussPart") and
			(
				-- usual glass materials
				(isGenericGlass(prt) and prt.Transparency > 0.15) or
				
				-- unusual glass materials (definitely not neon)
				(prt.Material ~= Enum.Material.Neon and prt.Transparency > 0.23)
			)
			and prt.Transparency < 0.99 then
			table.insert(allGlass,prt)
		end
	end
	
	if #allGlass == 0 then return end
	
	local pickedToBreak = {}
	for i = 1,math.max(math.floor(#allGlass/3),1) do
		local rem = table.remove(allGlass,math.random(#allGlass))
		if not rem then break end
		table.insert(pickedToBreak,rem)
	end
	
	for _,glass in ipairs(pickedToBreak) do
		local wedges = fullyShatterGlass(glass)
		if not wedges then continue end
		for _,wedge in ipairs(wedges) do
			local directVec = wedge.Position-setexplosionpos
			task.defer(function()
				wedge:ApplyImpulse(
					(directVec.Unit+Vector3.new(RANDOM:NextNumber(-.1,.1),RANDOM:NextNumber(-.1,.1),RANDOM:NextNumber(-.1,.1)))
						*wedge.Mass*200
				)
				wedge:ApplyAngularImpulse(RANDOM:NextUnitVector()*100*wedge.Mass)
			end)
		end
		
		local glassSizeMax = math.max(glass.Size.X,glass.Size.Y,glass.Size.Z)
		local sndPart = ignoreHandler.createNonInteractableObject(true)
		sndPart.Size = Vector3.zero
		sndPart.Position = glass.Position
		local snd = sndUtil.createSoundFromSound(tblUtil.getRandomInList(soundassets.glassShatters:GetChildren()),{
			RollOffMaxDistance = math.max(glassSizeMax*5,1000),
			RollOffMinDistance = math.max(glassSizeMax*0.7,200),
			Volume = .4*RANDOM:NextNumber(.8,1.1),
			Pitch = RANDOM:NextNumber(.8,1.2),
			Parent = sndPart
		})
		sndPart.Parent = workspace
		snd.Ended:Connect(function()
			task.wait(2)
			sndPart:Destroy()
		end)
	end
end
--breakRandomGlass()
--shatterGlass(workspace.glassA)

--for i = 1,5 do
--	--createRandomStructureExplosion()
--	--task.wait(.5)
--	createRandomWallExplosion()
--	task.wait(.5)
--end
--error("hi")
local function createbgexplosion()
	local explodeSnd = getRandomExplosion(1)
	sndUtil.createTemporarySoundFromSound(explodeSnd)
	RE:Fire(char(1),1.25,1.4)
	temporaryLightsFlicker()
	if RANDOM:NextNumber(1,3) ~= 2 then return end
	if RANDOM:NextInteger(1,2) == 1 then
		createRandomWallExplosion(explodeSnd)
	else
		createRandomStructureExplosion(explodeSnd)
	end
end

local allTentacleAttachments,allTentacleBeams,allTentacleParticles = {},{},{}
local tentaclesTransparency = 0
local canTentacleFade,fadeSpeed = true,.2
local lastsecondtick = 600
local linesize = 0
local curPreExploder,lastPreExploder

local function alwaysEmitParticles(particles:ParticleEmitter)
	particles:SetAttribute(attributeLookup.Rate,particles.Rate)
	particles:AddTag(tagLookup.AlwaysEmit)
	staticize(particles,"Rate",0,function(val)
		particles:SetAttribute(attributeLookup.Rate,val)
	end)
end

local function combust()
	local shockwave = ignoreHandler.createNonInteractableObject(true)
	shockwave.Position = setexplosionpos
	shockwave.Material = Enum.Material.ForceField
	shockwave.Size = Vector3.new(1,1,1)
	shockwave.Shape = Enum.PartType.Ball
	shockwave.Color = Color3.fromRGB(255,255,255)
	local msh = Instance.new("SpecialMesh")
	msh.Scale = Vector3.zero
	msh.MeshType = Enum.MeshType.Sphere
	msh.Parent = shockwave
	shockwave.Parent = workspace
	util.playTween(msh,TweenInfo.new(5,Enum.EasingStyle.Linear),{Scale = Vector3.new(8192,8192,8192)})
	util.playTween(shockwave,TweenInfo.new(5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 1},function()
		shockwave:Destroy()
	end)
	local cls = {}
	local twinfo = TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
	for i = 1,30 do
		local prtdec = ignoreHandler.noInteract(modelassets.explodeeffect2:Clone())
		prtdec.CFrame = CFrame.new(setexplosionpos) * CFrame.Angles(math.rad(RANDOM:NextNumber(-45,45)),math.rad(RANDOM:NextNumber(-720,720)),0)
		prtdec.Mesh.MeshType = Enum.MeshType.Sphere
		prtdec.Mesh.Scale = Vector3.zero
		prtdec.Parent = workspace
		ignoreHandler.addToIgnoreList(prtdec)
		local z = 3375*(1+RANDOM:NextNumber())
		util.playTween(prtdec.Mesh,twinfo,{Scale = Vector3.new(300/(1+RANDOM:NextNumber()),300/(1+RANDOM:NextNumber()),z/3)})
		util.playTween(prtdec,twinfo,{CFrame = prtdec.CFrame * CFrame.new(0,0,-30+z+RANDOM:NextNumber(-100,100))})
		table.insert(cls,prtdec)
	end
	task.delay(3,function()
		for i,prtdec in pairs(cls) do
			util.playTween(prtdec,twinfo,{Transparency = 1},function()
				prtdec:Destroy()
			end)
		end
	end)
end
local function debindAfter(connection:RBXScriptConnection,time:number)
	task.delay(time,connection.Disconnect,connection)
end

local alarms:{{
	folder: Folder,
	soundList: {Sound}
}} = {}
local function killAlarms()
	for _,tb in ipairs(alarms) do
		for _,snd in ipairs(tb.soundList) do
			if snd:HasTag("DoNotEnd") and snd:IsDescendantOf(game) then
				snd.Parent = rs
				sndUtil.decaySound(snd)
			else
				snd:Destroy()
			end
		end
		tb.folder:Destroy()
	end
end
local function pauseAlarms(onlyLooped)
	for _,tb in ipairs(alarms) do
		for _,snd in ipairs(tb.soundList) do
			if onlyLooped and not snd.Looped then continue end
			snd:Pause()
		end
	end
	return function()
		for _,tb in ipairs(alarms) do
			for _,snd in ipairs(tb.soundList) do
				if onlyLooped and not snd.Looped then continue end
				snd:Resume()
			end
		end
	end
end
local function tempDisableLights(middle:boolean?)
	local lightFuncs = {}
	local lights = mapDefiner.getProperLights()
	local len = #lights
	for ix,light in ipairs(lights) do
		task.delay((ix/len)*RANDOM:NextNumber(0.6,0.95),function()
			local isUI = light:IsA("SurfaceGuiBase")
			table.insert(lightFuncs,staticize(light,"Enabled",false,nil,true))
			if not isUI and light.Parent and light.Parent:IsA("BasePart") and light.Parent.Material == Enum.Material.Neon then
				table.insert(lightFuncs,staticize(light.Parent,"Color",Color3.new(),nil,true))
			end
			sndUtil.createTemporarySound("rbxassetid://3466798390",{
				Volume = middle and 1 or 0.5,
				PlaybackSpeed = 0.75,
				Parent = light.Parent
			})
		end)
	end
	sndUtil.createTemporarySound("rbxassetid://6810710875",{
		Volume = middle and 2.5 or 1
	})
	sndUtil.createTemporarySound("rbxassetid://191345948",{
		Volume = middle and 1.5 or .7
	})
	return function()
		for _,func in ipairs(lightFuncs) do
			func()
		end
		sndUtil.createTemporarySound("rbxassetid://3466798390",{
			Volume = middle and 2.5 or 1
		})
		sndUtil.createTemporarySound("rbxassetid://6810668135",{
			Volume = middle and 2.5 or 1
		})
	end
end

local function killLights()
	local lightFunc = tempDisableLights(true)
	local f = pauseAlarms(true)

	createbgexplosion()
	task.wait(RANDOM:NextNumber(8,12))

	sndUtil.createTemporarySound("rbxassetid://7358028934",{
		Volume = 1.5
	})
	lightFunc()
	f()
end

local function getpartsinsiderange(range:number,usedParts:({BasePart})?)
	local tbl = {}
	for _,prt:BasePart in ipairs(usedParts or mapDefiner.Parts) do
		if not ignoreHandler.isInstanceOnIgnoreList(prt) and mathUtil.getMagBetween(prt.Position,setexplosionpos) < range then
			table.insert(tbl,prt)
		end
	end
	return tbl
end
local function getHumanoidModelsInsideRange(range):{Model}
	local tbl = {}
	for mod in pairs(mapDefiner.Humanoids) do
		local parts = {}
		for _,part in ipairs(mod:GetChildren()) do
			if part:IsA("BasePart") then
				table.insert(parts,part)
			end
		end
		if #getpartsinsiderange(range,parts) > 0 then -- BAD
			table.insert(tbl,mod)
		end
	end
	return tbl
end

local function applyCombustHitToPart(prt:BasePart,size:number)
	local directVec = prt.Position-setexplosionpos
	prt:ApplyImpulse(
		(directVec.Unit+Vector3.new(RANDOM:NextNumber(-.1,.1),RANDOM:NextNumber(-.1,.1),RANDOM:NextNumber(-.1,.1)))
			*(math.max(size-directVec.Magnitude,0)^0.55)
			*math.max(prt.AssemblyMass,1)/3.1
	)
	prt:ApplyAngularImpulse(RANDOM:NextUnitVector()*50*prt.AssemblyMass)
end
local function badCombust(color:Color3?,volume:number?)
	sndUtil.decaySound(sndUtil.createSoundFromSound(soundassets.misc.weirdexplosion,{Volume = volume and (volume/1.5) or nil}))
	RE:Fire(char(2),sndUtil.decaySound(sndUtil.createSoundFromSound(soundassets.misc.shockwave,{Volume = volume or nil})))
	RE:Fire(char(3),70,1)
	breakRandomGlass()
	local scaleTo = 32000
	local shockBall = ignoreHandler.createNonInteractableObject(true)
	shockBall.Position = setexplosionpos
	shockBall.Size = Vector3.new(1,1,1)
	shockBall.Transparency = 0.9
	shockBall.Anchored = true

	local shockBallMesh = Instance.new("SpecialMesh")
	shockBallMesh.Scale = Vector3.yAxis*100
	shockBallMesh.MeshId = "rbxassetid://16886440991"
	shockBallMesh.TextureId = "rbxassetid://16358051219"
	shockBallMesh.VertexColor = Vector3.new(
		color and color.R or 1,
		color and color.G or 1,
		color and color.B or 1
	)*255
	shockBallMesh.Parent = shockBall
	
	local shockBallInvert = Instance.fromExisting(shockBall)
	local shockBallMeshInvert = Instance.fromExisting(shockBallMesh)
	shockBallMeshInvert.MeshId = "rbxassetid://16886440991"
	shockBallMeshInvert.Parent = shockBallInvert
	shockBallInvert.Parent = shockBall
	
	local shockBallFlatA = ignoreHandler.noInteract(Instance.fromExisting(shockBall))
	--shockBallFlatA.Transparency = 0.4
	local shockBallFlatAMesh = Instance.fromExisting(shockBallMesh)
	shockBallFlatAMesh.MeshId = "rbxassetid://10468869843"
	shockBallFlatAMesh.Parent = shockBallFlatA
	
	local shockBallFlatB = ignoreHandler.noInteract(Instance.fromExisting(shockBallFlatA))
	local shockBallFlatBMesh = Instance.fromExisting(shockBallFlatAMesh)
	shockBallFlatBMesh.Parent = shockBallFlatB
	
	shockBallFlatA.CFrame *= CFrame.Angles(
		RANDOM:NextNumber(-math.pi,math.pi),
		RANDOM:NextNumber(-math.pi,math.pi),
		RANDOM:NextNumber(-math.pi,math.pi)
	)
	shockBallFlatB.CFrame = shockBallFlatA.CFrame*CFrame.Angles(math.pi/2,0,0)
	
	shockBallFlatA.Parent = shockBall
	shockBallFlatB.Parent = shockBall

	shockBall.Parent = workspace

	local alreadyHit:{[Model|BasePart]: boolean} = {}
	local hb = runserv.Heartbeat:Connect(function()
		local parts:{BasePart} = getpartsinsiderange(shockBallMesh.Scale.X/2)
		
		local rootParts:{[BasePart]: boolean} = {}
		for _,prt:BasePart in ipairs(parts) do
			if prt.Anchored or (prt.AssemblyRootPart and rootParts[prt.AssemblyRootPart]) or alreadyHit[prt] then continue end
			alreadyHit[prt] = true
			
			if prt.AssemblyRootPart and not rootParts[prt.AssemblyRootPart] then
				alreadyHit[prt.AssemblyRootPart] = true
				rootParts[prt.AssemblyRootPart] = true
			end
		end
		
		for root in pairs(rootParts) do -- to fix the great fling
			applyCombustHitToPart(root,scaleTo)
		end

		local humanoidModels = getHumanoidModelsInsideRange(shockBallMesh.Scale.X/2)
		for _,humMod:Model in ipairs(humanoidModels) do
			if alreadyHit[humMod] then continue end
			alreadyHit[humMod] = true

			local hum = humMod:FindFirstChildWhichIsA("Humanoid")
			if not hum then
				return -- ive been LIED to...
			end
			
			local plr = players:GetPlayerFromCharacter(humMod)
			if plr then
				RE:Fire(char(4),false,.3,color and color:Lerp(Color3.new(1,1,1),.5) or nil,true)
			end
			
			local allRoots = {
				[hum.RootPart] = true
			}
			
			for _,prt in ipairs(humMod:GetDescendants()) do
				if not prt:IsA("BasePart") then
					continue
				end
				
				if not prt.AssemblyRootPart then
					allRoots[prt.AssemblyRootPart] = true
				end
			end
			
			local setOwners:{{
				Part: BasePart,
				AutoNetwork: boolean,
				LastNetworkOwner: Instance?
			}} = {}
			for root in pairs(allRoots) do
				if root.Anchored then
					continue
				end
				
				local lastNetworkOwner:Instance?,wasNetworkAuto:boolean = root:GetNetworkOwner(),root:GetNetworkOwnershipAuto()
				if root:CanSetNetworkOwnership() then
					root:SetNetworkOwner()
				end

				task.defer(applyCombustHitToPart,root,scaleTo)
				table.insert(setOwners,{
					Part = root,
					LastNetworkOwner = lastNetworkOwner,
					AutoNetwork = wasNetworkAuto
				})
			end
			
			task.defer(function()
				hum.PlatformStand = true
				
				task.wait(1.2)
				hum.PlatformStand = false
				hum:ChangeState(Enum.HumanoidStateType.FallingDown)
				
				local ev
				ev = hum.StateChanged:Connect(function(_,new)
					if new ~= Enum.HumanoidStateType.FallingDown then
						ev:Disconnect()
					end
					for _,data in ipairs(setOwners) do
						if not data.Part:CanSetNetworkOwnership() then
							return -- No
						end

						local networkOwner,isNetworkAuto = data.Part:GetNetworkOwner(),data.Part:GetNetworkOwnershipAuto()

						if networkOwner or isNetworkAuto then
							return -- (auto)networkowner was set, we dont have to do anything
						end

						if data.LastNetworkOwner and not data.AutoNetwork then
							data.Part:SetNetworkOwner(data.LastNetworkOwner :: Player)
						else
							data.Part:SetNetworkOwnershipAuto()
						end
					end
				end)
			end)
		end
	end)
	
	local info = TweenInfo.new(5,Enum.EasingStyle.Linear)
	
	util.playTween(shockBallMesh,info,{Scale = Vector3.one*scaleTo},function()
		hb:Disconnect()
	end)
	util.playTween(shockBallMeshInvert,info,{Scale = -Vector3.one*scaleTo})
	util.playTween(shockBallFlatAMesh,info,{Scale = Vector3.new(RANDOM:NextNumber(2,7),0,RANDOM:NextNumber(2,7))*scaleTo/50})
	util.playTween(shockBallFlatBMesh,info,{Scale = Vector3.new(RANDOM:NextNumber(2,7),0,RANDOM:NextNumber(2,7))*scaleTo/50})
	
	util.playTween(shockBall,info,{Transparency = 1},function()
		shockBall:Destroy()
	end)
	util.playTween(shockBallInvert,info,{Transparency = 1},function()
		shockBallInvert:Destroy()
	end)
	util.playTween(shockBallFlatA,info,{Transparency = 1})
	util.playTween(shockBallFlatB,info,{Transparency = 1})
end

local function invalidMusicCheck(list:any,valueCheck:string?)
	local trueList:{Sound} = {}
	for _,mus:string in ipairs(list) do
		if valueCheck then
			mus = (mus :: any)[valueCheck] :: string
		end
		local musInst:Sound = allMus[mus]

		table.insert(trueList,musInst)
	end

	local finalLoadedList = {}
	contentProvider:PreloadAsync(trueList,function(content,status)
		local ind,val
		for i,mus:string in ipairs(list) do
			local name = mus
			if valueCheck then
				name = (name :: any)[valueCheck] :: string
			end
			local musInst:Sound = allMus[name]
			
			if musInst.SoundId == content then
				ind = i
				val = mus
				break
			end
		end
		if not ind then return end

		if status == Enum.AssetFetchStatus.Success then
			table.insert(finalLoadedList,val)
		end
	end)

	return finalLoadedList :: any
end

local function preloadStartMus()
	local loaded:{music.BeginningMusFormat} = invalidMusicCheck(music.Beginning,"Instance") -- Because i love typechecking

	if #loaded == 0 then -- fallback to default
		loaded = {music.Beginning[1]}
	end

	return loaded[math.random(#loaded)]
end

local timerOffset = 0
local startMus
if not skipIntro then
	startMus = preloadStartMus()
	timerOffset = startMus.Begin
end

local last = os.clock()

local start = workspace:GetServerTimeNow()-(600-skipto)+timerOffset
local startval,stopval
if safenames then
	startval = Instance.new("NumberValue")
	startval.Name = "destructionStart"
	startval.Value = start
	startval.Parent = mainGlobalValue.Parent

	stopval = Instance.new("BoolValue")
	stopval.Name = "disableDestructionIndicate"
	stopval.Value = false
	stopval.Parent = mainGlobalValue.Parent
end

if not onlyExplode then
	if not skipIntro then
		playtrack(allMus[startMus.Name],start-timerOffset)
		gvals.startTime = -1
		gvals.buttonsEnabled = false
		syncSoundTime(sndUtil.decaySound(sndUtil.createSoundFromSound(soundassets.misc.firstdanger)),1.6)
		
		repeat task.wait() until os.clock()-last > startMus.Popup
		RE:Fire(char(0),true,char(0),50)

		repeat task.wait() until os.clock()-last > startMus.Popup2

		gvals.shiftInfo = true
		RE:Fire(char(0),true,char(1),startMus.Begin-startMus.Popup2-3)
		gvals.visible = true
		doNewButtonWave(true,true)
		gvals.buttonsEnabled = true

		repeat task.wait() until os.clock()-last > startMus.Begin
		last += timerOffset
	else
		task.spawn(function()
			startMus = preloadStartMus()
			playtrack(allMus[startMus.Name],start-startMus.Begin)
		end)
		gvals.shiftInfo = true
		gvals.visible = true
		gvals.buttonsEnabled = canShutdownSystem
		doNewButtonWave(true,true)
	end
end
gvals.shakeMultiplier = .01
setupButtonEvents()

gvals.startTime = start

last -= 600-skipto

local currentBlackholeIdleSound,currentBlackholeIdleSoundBG
local currentBlackholeIdleSound2,currentBlackholeIdleSoundBG2

local setLineSize,resizeSpeed = 1,0.5
local events:{{(number) -> ()}} = {
	--[480+(30.236)] = {function()
	--	playtrack(allMus.surfacetension1,start+(600-480-30.236))
	--end},
	[480] = {function()
		gvals.shakeMultiplier = .03
		RE:Fire(char(0),true,char(2),8)
	end},
	[406.5] = {createbgexplosion},
	--[374.546] = {function()
	--	playtrack(allMus.franticandedgy,start+(600-374.546))
	--end},
	[360] = {function()
		RE:Fire(char(0),true,char(3),8)
	end},
	[301] = {function()
		gvals.shiftInfo = false
		sndUtil.createTemporarySoundFromSound(soundassets.misc.midexplosion)
		local prt = ignoreHandler.createNonInteractableObject(true)
		prt.Position = setexplosionpos
		prt.Size = Vector3.new(2048,2048,2048)
		prt.CanCollide = false
		prt.Material = Enum.Material.ForceField
		prt.Shape = Enum.PartType.Ball
		prt.Parent = workspace
		util.playTween(prt,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = Vector3.zero},function()
			task.wait(.5)
			for _,explosion in ipairs(soundassets.midexplosions:GetChildren()) do
				sndUtil.createTemporarySoundFromSound(explosion)
			end
			prt.Size = Vector3.new(1,1,1)
			util.playTween(prt,TweenInfo.new(4,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Size = Vector3.one*2048,Transparency = 1},function()
				prt:Destroy()
			end)
			combust()
			RE:Fire(char(1),1.5,3)
			RE:Fire(char(2),sndUtil.decaySound(sndUtil.createSoundFromSound(soundassets.misc.shockwave)))
			curPreExploder = preexploderemitters:Clone()
			curPreExploder:PivotTo(CFrame.new(setexplosionpos))
			curPreExploder.cone:Destroy()
			
			for _,emit in ipairs(curPreExploder:GetDescendants()) do
				if emit:IsA("ParticleEmitter") then
					emit:Destroy()
				end
			end
			curPreExploder.Parent = workspace
		end)
	end},
	[300] = {function()
		RE:Fire(char(3),70,4)
		RE:Fire(char(0),true,char(4),8)
		gvals.stage = 1
		gvals.shakeMultiplier = .05
		gvals.tiltingCamera = true
		gvals.buttonsEnabled = false
		clearButtons()
		generateEscapeHatches()
		breakRandomGlass()
	end},
	[RANDOM:NextNumber(210,250)] = {killLights},
	[200] = {function(tim)
		if tim > 200-3 then
			RE:Fire(char(7),4)
			createbgexplosion()
		end
	end},
	[121] = {function()
		gvals.shiftInfo = false
	end},
	[119.096] = {function(tim)
		local snd = sndUtil.decaySound(sndUtil.createSoundFromSound(soundassets.misc.overloadCrank))
		syncSoundTime(snd,1-(119.096-tim))
		
		RE:Fire(char(2),snd)
	end},
	[120] = {function(tim)
		gvals.shakeMultiplier = .07
		RE:Fire(char(0),true,char(6),8)
		badCombust()
		gvals.overheatTimer = true
		gvals.overheatTimerStart = start+(600-120)
		gvals.overheatTimerEnd = start+(600-60)

		if tim > 120-3 then
			RE:Fire(char(7),4)
		end
	end},
	[RANDOM:NextNumber(100,120)] = {killLights},
	[60] = {function()
		badCombust(Color3.fromRGB(242,156,255))
		gvals.shiftInfo = true
		createbgexplosion()
		gvals.stage = 2
		gvals.shakeMultiplier = .14
		RE:Fire(char(0),true,char(7),8)
	end},
	--[32.8] = {function()
	--end},
	[35] = {function(tim)
		if tim < 30 then
			return
		end
		RE:Fire(char(9),char(1),{
			explosionPos = setexplosionpos,
			scaleSize = 400,
		},start+(600-35),2)
	end,},
	[33] = {function(tim)
		RE:Fire(char(0),true,char(8),8)
		
		if tim < 30 then
			return
		end
		
		--for _,plr in ipairs(players:GetPlayers()) do
		--	if not plr.Character then continue end
			
		--	local root:BasePart = plr.Character:FindFirstChild("HumanoidRootPart")
		--	if not root then
		--		for _,prt in ipairs(plr.Character:GetChildren()) do
		--			if prt:IsA("BasePart") then
		--				root = prt
		--				break
		--			end
		--		end
		--		if not root then
		--			continue -- no parts :(
		--		end
		--	end
			
		--	RE:Fire(char(10),true,
		--		CFrame.lookAt((CFrame.lookAt(root.Position,setexplosionpos)*CFrame.new(
		--			RANDOM:NextNumber(-20,20),
		--			RANDOM:NextNumber(20,40),
		--			RANDOM:NextNumber(60,80)
		--		)).Position,setexplosionpos),true
		--	)
		--end
		
		-- 30+3
		RE:Fire(char(2),sndUtil.decaySound(sndUtil.createSound("rbxassetid://137887437617542",{
			Volume = 1.3
		})))
		
		local bright = ignoreHandler.createNonInteractableObject(true)
		bright.Size = Vector3.zero
		bright.Position = setexplosionpos
		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.fromScale(0,0)
		bill.AlwaysOnTop = true
		bill.ClipsDescendants = false
		bill.MaxDistance = 0
		bill.Adornee = bright
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.one/2
		img.Position = UDim2.fromScale(.5,.5)
		img.Size = UDim2.fromScale(1,1)
		img.Image = "rbxassetid://18625878475"
		img.BackgroundTransparency = 1
		img.Parent = bill
		bill.Parent = bright
		
		local bill2 = bill:Clone();
		(bill2:FindFirstChildWhichIsA("ImageLabel") :: ImageLabel).Rotation = 90
		bill2.Parent = bright
		bright.Parent = workspace
		
		util.playTween(bill2,TweenInfo.new(3-0.25,Enum.EasingStyle.Linear),{Size = UDim2.fromScale(5000,1500)})
		util.playTween(bill,TweenInfo.new(3-0.25,Enum.EasingStyle.Linear),{Size = UDim2.fromScale(5000,1500)},function()
			task.delay(.25,function()
				bright:Destroy()
			end)
		end)
		
		local lastSpawn = os.clock()
		debindAfter(runserv.Heartbeat:Connect(function()
			local elapsed = os.clock()-lastSpawn
			if elapsed < 1/90 then return end
			lastSpawn = os.clock()
			for i = 1,elapsed*90 do
				local cutter = ignoreHandler.noInteract(modelassets.explodeeffect:Clone())
				cutter.Mesh.Scale = Vector3.new(RANDOM:NextNumber(1000,1500),0,RANDOM:NextNumber(1000,500))
				local baseCF = CFrame.new(setexplosionpos)
					*CFrame.Angles(RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi))
					*CFrame.Angles(RANDOM:NextNumber(0.1,0.1),0,0)
				cutter.CFrame = baseCF*CFrame.new(0,0,-RANDOM:NextNumber(2350,3000))
				cutter.Mesh.VertexColor = Vector3.new(255,255,255)
				cutter.Transparency = 1
				cutter.Parent = workspace
				util.playTween(cutter.Mesh,TweenInfo.new(.25,Enum.EasingStyle.Linear),{
					Scale = Vector3.zero
				})
				util.playTween(cutter,TweenInfo.new(.25,Enum.EasingStyle.Linear),{CFrame = baseCF})
				util.playTween(cutter,TweenInfo.new(.05,Enum.EasingStyle.Linear),{
					Transparency = 0,
				},function()
					util.playTween(cutter,TweenInfo.new(.2,Enum.EasingStyle.Linear),{
						Transparency = 1,
					},function()
						cutter:Destroy()
					end)
				end)
			end
		end),3-0.25)
	end},
	[30+2.375] = {function()
		sndUtil.createTemporarySound("rbxassetid://138104921",{
			Volume = 5
		})
	end},
	--[30.1+.5] = {function()
		
	--	RE:Fire(char(9),char(0),nil,workspace:GetServerTimeNow(),.5)
	--end},
	[30] = {function()
		--task.delay(1,function()
		--	RE:Fire(char(10),false,nil,true)
		--end)
		RE:Fire(char(9),char(1),nil,nil,nil,true)
		RE:Fire(char(8))
		RE:Fire(char(4),false,.4,nil,false,5)
		
		gvals.stage = 3
		task.delay(2,function()
			gvals.visible = false
			task.wait(2)
			gvals.altVisible = true
		end)
		clearEscapeHatches()
		createbgexplosion()
		gvals.shakeMultiplier = .2
		combust()
		badCombust(Color3.new(1,0,1))
		canTentacleFade = false
		curPreExploder = preexploderemitters:Clone()
		curPreExploder:PivotTo(CFrame.new(setexplosionpos))
		curPreExploder.Parent = workspace
		
		local snd = sndUtil.createSoundFromSound(soundassets.misc.blackholeBreakthrough,{
			Volume = 4,
			Parent = curPreExploder.center
		})
		
		local sndBG = sndUtil.createSoundFromSound(snd,{
			Volume = 1,
			SoundGroup = allSoundGroups.backgroundExplosions,
			TimePosition = snd.TimePosition,
			Parent = rs,
		})
		
		currentBlackholeIdleSound = sndUtil.createSoundFromSound(soundassets.misc.blackholeIdle,{
			Volume = 1.2,
			Parent = curPreExploder.center,
		})
		currentBlackholeIdleSoundBG = sndUtil.createSoundFromSound(soundassets.misc.blackholeIdle,{
			Volume = .6,
			TimePosition = currentBlackholeIdleSound.TimePosition,
			SoundGroup = allSoundGroups.backgroundExplosions,
			Parent = rs,
		})
		
		currentBlackholeIdleSound2 = sndUtil.createSoundFromSound(soundassets.misc.blackholeIdle2,{
			Volume = 1.2,
			Parent = curPreExploder.center,
		})
		currentBlackholeIdleSoundBG2 = sndUtil.createSoundFromSound(soundassets.misc.blackholeIdle2,{
			Volume = .6,
			TimePosition = currentBlackholeIdleSound2.TimePosition,
			SoundGroup = allSoundGroups.backgroundExplosions,
			Parent = rs,
		})
		
		local info = TweenInfo.new(20,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
		local goals = {PlaybackSpeed = 3}
		local info2 = TweenInfo.new(20,Enum.EasingStyle.Sine,Enum.EasingDirection.Out,0,false,5)
		local goals2 = {PlaybackSpeed = 2}
		util.playTween(currentBlackholeIdleSound,info,goals)
		util.playTween(currentBlackholeIdleSoundBG,info,goals)
		util.playTween(currentBlackholeIdleSound2,info2,goals2)
		util.playTween(currentBlackholeIdleSoundBG2,info2,goals2)
		
		sndUtil.decaySound(snd)
		sndUtil.decaySound(sndBG)
	end},
	[20+2.375] = {function()
		setLineSize = 0.3
		resizeSpeed = .78
		sndUtil.createTemporarySound("rbxassetid://138104921",{
			Volume = 6
		})
	end},
	[20] = {function()
		setLineSize = 1
		linesize = 3
		resizeSpeed = .5
		badCombust(Color3.new(1,0,0),3)
	end},
	[11.578] = {function(tim)
		syncSoundTime(sndUtil.decaySound(sndUtil.createSoundFromSound(soundassets.misc.preexplosion)),1-(11.578-tim))
	end},
	[10.578] = {function()
		local info = TweenInfo.new(3,Enum.EasingStyle.Linear)
		local goal = {Volume = 0,PlaybackSpeed = 0}
		if currentBlackholeIdleSound then
			util.playTween(currentBlackholeIdleSound,info,goal,function()
				currentBlackholeIdleSound:Destroy()
			end)
		end
		if currentBlackholeIdleSoundBG then
			util.playTween(currentBlackholeIdleSoundBG,info,goal,function()
				currentBlackholeIdleSoundBG:Destroy()
			end)
		end
		if currentBlackholeIdleSound2 then
			util.playTween(currentBlackholeIdleSound2,info,goal,function()
				currentBlackholeIdleSound2:Destroy()
			end)
		end
		if currentBlackholeIdleSoundBG2 then
			util.playTween(currentBlackholeIdleSoundBG2,info,goal,function()
				currentBlackholeIdleSoundBG2:Destroy()
			end)
		end
		
		setLineSize = 0
		resizeSpeed = 3
		fadeSpeed = 1/2.5
		canTentacleFade = true
		for _,particle in ipairs(allTentacleParticles) do
			particle.Enabled = false
		end
		
		local shockwave = ignoreHandler.createNonInteractableObject()
		shockwave.Position = setexplosionpos
		shockwave.Material = Enum.Material.ForceField
		shockwave.Size = Vector3.one
		shockwave.Color = Color3.new(1,1,1)
		local msh = Instance.new("SpecialMesh")
		msh.Scale = Vector3.zero
		msh.MeshType = Enum.MeshType.Sphere
		msh.Parent = shockwave
		shockwave.Parent = workspace
		util.playTween(msh,TweenInfo.new(2,Enum.EasingStyle.Linear),{Scale = Vector3.new(8192,8192,8192)})
		util.playTween(shockwave,TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 1},function()
			shockwave:Destroy()
		end)

		local lastSpawn = os.clock()
		debindAfter(runserv.Heartbeat:Connect(function()
			local elapsed = os.clock()-lastSpawn
			if elapsed < 1/60 then return end
			lastSpawn = os.clock()
			for i = 1,elapsed*60 do
				local cutter = modelassets.explodeeffect:Clone()
				cutter.Mesh.Scale = Vector3.zero
				cutter.CFrame = CFrame.new(setexplosionpos)
					*CFrame.Angles(RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi))
					*CFrame.Angles(RANDOM:NextNumber(0.1,0.1),0,0)
				cutter.Mesh.VertexColor = Vector3.new(255,255,255)
				cutter.Parent = workspace
				util.playTween(cutter.Mesh,TweenInfo.new(.25,Enum.EasingStyle.Linear),{
					Scale = Vector3.new(500,0,500)
				})
				util.playTween(cutter,TweenInfo.new(.25,Enum.EasingStyle.Linear),{
					Transparency = 1,
					CFrame = cutter.CFrame*CFrame.new(0,0,-RANDOM:NextNumber(750,1000))
				},function()
					cutter:Destroy()
				end)
			end
		end),2)
		
		sndUtil.createTemporarySound("rbxassetid://8619298801",{
			Volume = 1.2,
			PlaybackSpeed = 0.3
		})
		
		task.wait(2.255)
		
		local bright = ignoreHandler.createNonInteractableObject(true)
		bright.Size = Vector3.zero
		bright.Position = setexplosionpos
		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.fromScale(0,0)
		bill.AlwaysOnTop = true
		bill.ClipsDescendants = false
		bill.MaxDistance = 0
		bill.Adornee = bright
		local img = Instance.new("ImageLabel")
		img.AnchorPoint = Vector2.one/2
		img.Position = UDim2.fromScale(.5,.5)
		img.Size = UDim2.fromScale(1,1)
		img.Image = "rbxassetid://18625878475"
		img.BackgroundTransparency = 1
		img.Parent = bill
		bill.Parent = bright
		bright.Parent = workspace
		
		util.playTween(bill,TweenInfo.new(7.5,Enum.EasingStyle.Linear),{Size = UDim2.fromScale(3000,1500)},function()
			util.playTween(bill,TweenInfo.new(0.8,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size = UDim2.fromScale(0,0)},function()
				bright:Destroy()
			end)
		end)
		
		local steamParticles = ignoreHandler.noInteract(modelassets.preexprt:Clone())
		local literalParticles = steamParticles.ParticleEmitter
		alwaysEmitParticles(literalParticles)
		steamParticles.Position = setexplosionpos
		steamParticles.Parent = workspace
		
		task.delay(8,function()
			literalParticles.Enabled = false
			task.wait(9.5)
			steamParticles:Destroy()
		end)

		local lastSpawnB = os.clock()
		debindAfter(runserv.Heartbeat:Connect(function()
			local elapsed = os.clock()-lastSpawnB
			if elapsed < 1/5 then return end
			lastSpawnB = os.clock()
			for i = 1,elapsed*5 do
				local shockwave = Instance.fromExisting(shockwave)
				shockwave.Transparency = 1
				shockwave.Position = setexplosionpos
				shockwave.Size = Vector3.one
				local msh = Instance.fromExisting(msh)
				msh.MeshType = Enum.MeshType.Sphere
				msh.Parent = shockwave
				shockwave.Parent = workspace
				util.playTween(msh,TweenInfo.new(.5,Enum.EasingStyle.Linear),{Scale = Vector3.zero})
				util.playTween(shockwave,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 0},function()
					shockwave:Destroy()
				end)
			end
		end),7)

		debindAfter(runserv.Heartbeat:Connect(function()
			local elapsed = os.clock()-lastSpawn
			if elapsed < 1/90 then return end
			lastSpawn = os.clock()
			img.Rotation = RANDOM:NextNumber(-4,4)
			img.Size = UDim2.fromScale(RANDOM:NextNumber(0.9,1),RANDOM:NextNumber(0.9,1))
			for i = 1,elapsed*90 do
				local cutter = ignoreHandler.noInteract(modelassets.explodeeffect:Clone())
				cutter.Mesh.Scale = Vector3.new(RANDOM:NextNumber(1000,1500),0,RANDOM:NextNumber(1000,500))
				local baseCF = CFrame.new(setexplosionpos)
					*CFrame.Angles(RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi))
					*CFrame.Angles(RANDOM:NextNumber(0.1,0.1),0,0)
				cutter.CFrame = baseCF*CFrame.new(0,0,-RANDOM:NextNumber(2350,3000))
				cutter.Mesh.VertexColor = Vector3.new(255,255,255)
				cutter.Transparency = 1
				cutter.Parent = workspace
				util.playTween(cutter.Mesh,TweenInfo.new(.25,Enum.EasingStyle.Linear),{
					Scale = Vector3.zero
				})
				util.playTween(cutter,TweenInfo.new(.25,Enum.EasingStyle.Linear),{CFrame = baseCF})
				util.playTween(cutter,TweenInfo.new(.05,Enum.EasingStyle.Linear),{
					Transparency = 0,
				},function()
					util.playTween(cutter,TweenInfo.new(.2,Enum.EasingStyle.Linear),{
						Transparency = 1,
					},function()
						cutter:Destroy()
					end)
				end)
				for i = 1,3 do
					local part = ignoreHandler.createNonInteractableObject(true)
					part.Transparency = 1
					part.CFrame = CFrame.new(setexplosionpos) * CFrame.Angles(
					RANDOM:NextNumber(-math.pi,math.pi),
					RANDOM:NextNumber(-math.pi,math.pi),
					RANDOM:NextNumber(-math.pi,math.pi)
					) * CFrame.new(0,0,RANDOM:NextNumber(2048,8000))
					part.Size = Vector3.new(50, 50, RANDOM:NextNumber(100,150))
					part.Material = Enum.Material.Neon
					part.Color = RANDOM:NextInteger(1,2) == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(203, 128, 255)
					util.playTween(part,TweenInfo.new(.1,Enum.EasingStyle.Linear),{Transparency = 0})
					local msh = Instance.new("SpecialMesh")
					msh.MeshType = Enum.MeshType.Sphere
					msh.Scale = Vector3.new(1,1,1)
					msh.Parent = part
					part.Parent = workspace
					util.playTween(part,TweenInfo.new(.4,Enum.EasingStyle.Linear),{Position = setexplosionpos},function()
						part:Destroy()
					end)
				end
			end
		end),8)
	end},
}

--events[30][1](30)
--error("ok")
local eventsRefix: {
	{
		time: number,
		functions: {(number)->()}
	}
}
local eventsRefixChecked = {}
local eventsLate = {}

local function sortRefix()
	table.sort(eventsRefix,function(a,b)
		return b.time < a.time
	end)
end

local function addToEventsList(func,time)
	local eventList = eventsRefix and eventsLate or events
	local tb = eventList[time]
	if tb then
		table.insert(tb,func)
	else
		tb = {func}
		events[time] = tb
	end
	
	if eventsRefix and not eventsRefixChecked[time] then
		eventsRefixChecked[time] = true
		
		table.insert(eventsRefix,{
			time = time,
			functions = tb
		})
		sortRefix()
	end
end

-- the audio loader, basically checks if it can load that music
-- if it cant then DONT PLAY IT

local mostRecentMusStart = 600

local function isMostRecentMusic(start)
	if start > mostRecentMusStart then
		return false
	end
	mostRecentMusStart = start
	return true
end

if not onlyExplode then
	task.spawn(function()
		local list:{music.Minutes3Format} = invalidMusicCheck(music.Minutes3,"Name")
		if #list == 0 then return end
		local min3mus = tblUtil.getRandomInList(list)
		local eventStart = 480+min3mus.StartAfter
		addToEventsList(function()
			if not isMostRecentMusic(eventStart) then return end
			playtrack(allMus[min3mus.Name],start+((600-480)-min3mus.StartAfter))
		end,eventStart)
	end)

	task.spawn(function()
		local list:{music.ExpiringFormat} = invalidMusicCheck(music.Expiring,"Name")
		if #list == 0 then return end
		local expiringMus = tblUtil.getRandomInList(list)
		local eventStart = 360+expiringMus.StartAfter
		addToEventsList(function()
			if not isMostRecentMusic(eventStart) then return end
			playtrack(allMus[expiringMus.Name],start+((600-360)-expiringMus.StartAfter))
		end,eventStart)
	end)

	task.spawn(function()
		local list:{music.ExpiredFormat} = invalidMusicCheck(music.Expired)
		if #list == 0 then return end
		local expiredMus = tblUtil.getRandomInList(list)
		local eventStart = 300
		addToEventsList(function()
			if not isMostRecentMusic(eventStart) then return end
			playtrack(allMus[expiredMus],start+(600-300))
		end,eventStart)
	end)

	task.spawn(function()
		local list:{music.FinalFormat} = invalidMusicCheck(music.Final,"Name")
		if #list == 0 then return end
		local mus = tblUtil.getRandomInList(list)
		local eventStart = mus.Time
		addToEventsList(function()
			if not isMostRecentMusic(eventStart) then return end
			playtrack(allMus[mus.Name],start+(600-mus.Time))
		end,eventStart)
	end)
end

do
	local function handle(fold)
		local tbl = string.split(fold.Name,",")
		local expOffset = fold.Parent == soundassets.expirationalarms and 300 or 0
		for _,s in pairs(tbl) do
			local num = expOffset
			if string.find(s,"-") then
				local a1,a2 = unpack(string.split(s,"-"))
				num += RANDOM:NextNumber(tonumber(a1) or 0,tonumber(a2) or 1)
			else
				num += tonumber(s) or 0
			end
			
			local f:Folder = fold:Clone()
			f.Name = safenames and `alarmcontainer{num}` or util.genRandomText(RANDOM:NextInteger(5,100))
			
			local tb:{Sound} = {}
			local ended = 0
			
			local function onEnd(snd)
				snd:Destroy()
				ended += 1
				if ended < #tb then return end
				f:Destroy()
			end
			
			for _,snd in ipairs(f:GetChildren()) do
				if not snd:IsA("Sound") then snd:Destroy() continue end
				table.insert(tb,snd)
			end

			for _,snd:Sound in ipairs(tb) do
				local endTime:number? = snd:GetAttribute("EndTime")
				local sync:boolean = snd:HasTag("SyncPlayback")
				local trueTime = num+(sync and 1 or 0)
				addToEventsList(function(curTime:number)
					if endTime and curTime < endTime then return onEnd(snd) end
					if not f.Parent then
						f.Parent = rs
					end
					
					local additionalDelay = snd:GetAttribute("Delay") or 0
					
					local loadedDelay = 0
					if not snd.IsLoaded then
						local last = os.clock()
						snd.Loaded:Wait()
						loadedDelay += os.clock()-last
					end
					
					snd.TimePosition = (snd.PlaybackRegionsEnabled and snd.PlaybackRegion.Min or 0) + loadedDelay
					if not snd.Looped and snd.TimeLength < (600-curTime)-(600-trueTime) then
						onEnd(snd)
						return
					end
					if sync then
						syncSoundTime(snd,1+additionalDelay-((600-curTime)-(600-trueTime)))
					else
						task.delay(additionalDelay,snd.Resume,snd)
					end
					snd.Ended:Once(function()
						task.wait(3)
						onEnd(snd)
					end)
				end,trueTime)
				if endTime then
					addToEventsList(function()
						onEnd(snd)
					end,endTime+expOffset)
				end
			end
			table.insert(alarms,{
				folder = f,
				soundList = tb
			})
		end
	end
	for _,fold in ipairs(soundassets.alarms:GetChildren()) do
		handle(fold)
	end
	for _,fold in ipairs(soundassets.expirationalarms:GetChildren()) do
		handle(fold)
	end
end

local function randCheck(func:(any?)->any,min:number,max:number,target:number)
	local min = math.round(min)
	local max = math.max(math.round(max),min)
	local r = RANDOM:NextInteger(min,max)
	if r == target then
		func()
	end
end

local function interp(base:number,min:number,max:number)
	return math.clamp((base-min)/(max-min),0,1)
end
local function tickExplosions(timeleft)
	if timeleft > 450 then return end

	-- timeleft < 300 and 5 or 30
	randCheck(createRandomWallExplosion,1,interp(timeleft,300,450)*25+5,1)
	if timeleft < 406.5 then
		randCheck(createbgexplosion,1,30,1)
	end
	if timeleft < 300 then
		randCheck(createRandomStructureExplosion,1,20,10)
	end
end

eventsRefix = {}
for tim,functs in pairs(events) do
	table.insert(eventsRefix,{
		time = tim,
		functions = functs
	})
end
sortRefix()

local function setupNewTentacles()
	if lastPreExploder then
		lastPreExploder:Destroy()
	end
	linesize = 0
	table.clear(allTentacleBeams)
	table.clear(allTentacleAttachments)
	table.clear(allTentacleParticles)
	for _,beam in ipairs(curPreExploder.beams:GetChildren()) do
		table.insert(allTentacleBeams,{
			beam = beam,
			noiseList = {util.getNewRandomVectorSeeds(2)}
		})
	end
	for _,inst:Attachment|ParticleEmitter in ipairs(curPreExploder:GetDescendants()) do
		if inst:IsA("Attachment") and inst.Name ~= "Attachment" then
			table.insert(allTentacleAttachments,{
				attachment = inst,
				noiseList = {util.getNewRandomVectorSeeds(4)}
			})
		elseif inst:IsA("ParticleEmitter") then
			alwaysEmitParticles(inst)
			table.insert(allTentacleParticles,inst)
		end
	end
end
local function updateTentacles()
	local elapsed = (os.clock()-last)/5
	for _,attData in ipairs(allTentacleAttachments) do
		local xmove = math.noise(elapsed,attData.noiseList[1].X,attData.noiseList[1].Y)
		local ymove = math.noise(elapsed,attData.noiseList[2].X,attData.noiseList[2].Y)
		local zmove = math.noise(elapsed,attData.noiseList[3].X,attData.noiseList[3].Y)
		local dir = Vector3.new(xmove,ymove,zmove).Unit
		if dir ~= dir or dir.Magnitude >= math.huge then -- non-NAN check
			dir = -Vector3.zAxis
		end
		local offset = math.noise(elapsed*2,attData.noiseList[4].X,attData.noiseList[4].Y)
		attData.attachment.Position = setexplosionpos+CFrame.new(Vector3.new(),dir).LookVector*(4096+(2048*offset))*linesize
	end

	local seq = NumberSequence.new{
		NumberSequenceKeypoint.new(0,tentaclesTransparency),
		NumberSequenceKeypoint.new(0.9,tentaclesTransparency),
		NumberSequenceKeypoint.new(1,1)
	}
	for _,tentacle in ipairs(allTentacleBeams) do
		tentacle.beam.Transparency = seq
		tentacle.beam.CurveSize0 = math.noise(elapsed,tentacle.noiseList[1].X,tentacle.noiseList[1].Y)*(4096*linesize)
		tentacle.beam.CurveSize1 = math.noise(elapsed,tentacle.noiseList[2].X,tentacle.noiseList[2].Y)*(4096*linesize)
	end
	for _,particle in ipairs(allTentacleParticles) do
		particle.Transparency = seq
	end
end

local sinkDelay,lastSink = 0,-math.huge
local sinkSounds = {
	"rbxassetid://1056144963",
	"rbxassetid://1056170474",
	"rbxassetid://4897520153",
	"rbxassetid://9116638811",
	"rbxassetid://9116638401",
	"rbxassetid://9116636255"
}

while true and not onlyExplode and not endTimer do
	local dt = task.wait()
	
	local ctick = os.clock() - last
	if ctick > 600 then break end
	local timeleft = 600-ctick
	if timeleft < 450 and timeleft > 60 then
		local new = math.floor(600-ctick)
		if new < lastsecondtick then
			lastsecondtick = new
			tickExplosions(timeleft)
		end
	end
	if curPreExploder then
		if curPreExploder ~= lastPreExploder then
			setupNewTentacles()
			lastPreExploder = curPreExploder
		end
		linesize = mathUtil.lerp(linesize,setLineSize,math.min(dt*resizeSpeed,1))
		updateTentacles()
		if canTentacleFade and tentaclesTransparency < 1 then -- we only fade, DELETE! (overtime)
			curPreExploder.center.Bright.BrightImage.ImageTransparency = tentaclesTransparency
			tentaclesTransparency += dt*fadeSpeed
		elseif tentaclesTransparency > 1 and curPreExploder then
			curPreExploder:Destroy()
			curPreExploder = nil
			tentaclesTransparency = 0
		end
	end
	
	if timeleft < 540 and timeleft > 30 then
		if os.clock()-lastSink > sinkDelay then
			sinkDelay = RANDOM:NextNumber(20,40)
			lastSink = os.clock()
			sndUtil.createTemporarySoundAtPos(setexplosionpos,tblUtil.getRandomInList(sinkSounds),{
				Volume = 0.6,
				RollOffMode = Enum.RollOffMode.Linear,
				RollOffMinDistance = 500,
				RollOffMaxDistance = 10000
			})
		end
	end
	--local removed = 0
	repeat -- fixes weird table.remove stuff
		local good = true
		for ix,event in ipairs(eventsRefix) do
			if event.time < timeleft then break end
			good = false
			table.remove(eventsRefix,ix)
			--removed += 1
			for _,f in ipairs(event.functions) do
				task.spawn(f,timeleft)
			end
			break
		end
	until good
	--if removed > 0 then
	--	print("--------------------------------")
	--	print(eventsRefix)
	--end
end

local function removeEverything()
	mainGlobalValue:Destroy()
	soundassets:Destroy()
	modelassets:Destroy()
	tracks:Destroy()
	sndgroups:Destroy()
end
local function removeEverythingIncluding()
	removeEverything()
	RE:Destroy()
	for _,hud in ipairs(allMDHUDs) do
		hud:Destroy()
	end
end

do
	local s,e = pcall(function()
		if collisionsTask and coroutine.status(collisionsTask) ~= "dead" then
			task.cancel(collisionsTask)
		end
	end)
	if e then
		warn(e)
	end
	physics:UnregisterCollisionGroup(glassNoCollideName) -- will cause an error but idk why this happens
end

if endTimer then
	if stopval then
		stopval.Value = true
	end
	local finalEndTime = os.clock()-last-timerOffset
	gvals.timerFrozen = true
	gvals.setTimerTime = 600-finalEndTime

	gvals.shiftInfo = false
	RE:Fire(char(0),true,char(9),5)
	clearButtonHUDs()
	task.wait(5)
	task.spawn(clearButtons)
	task.spawn(clearEscapeHatches)

	killAlarms()
	gvals.curPlaying = ""
	gvals.visible = false
	gvals.altVisible = false
	gvals.shakeMultiplier = 0
	gvals.tiltingCamera = false

	task.delay(3,removeEverythingIncluding)
	
	local lightFunc = tempDisableLights()
	task.wait(10)
	lightFunc()
	task.wait(3)
	
	script:Destroy()
	return
end

-- now heres the kicker! FINAL EXPLOSION RENDER

task.spawn(clearButtons)
task.spawn(clearEscapeHatches)
killAlarms()

gvals.visible = false
gvals.altVisible = false
gvals.tiltingCamera = false
RE:Fire(char(0),false,nil,0,false)

gvals.musFadeStart = start+605
gvals.musFadeEnd = start+615

local explosionRange = 9000
local baseExplosionRange = 9000
local explosionRangeScale = explosionRange/baseExplosionRange
local baseExplosionCF = CFrame.new(setexplosionpos)

local function getExplosionMesh(prt:BasePart):SpecialMesh
	return prt:FindFirstChildWhichIsA("SpecialMesh") :: SpecialMesh
end

local persistentModel = Instance.new("Model")
persistentModel.Name = ""
persistentModel.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
persistentModel.Parent = workspace

local prt = ignoreHandler.createNonInteractableObject(true)
prt.CFrame = baseExplosionCF
prt.Shape = Enum.PartType.Ball
prt.Material = Enum.Material.Neon
prt.Size = Vector3.new(1,1,1)
prt.Color = Color3.new(1,1,1)
prt.Transparency = 0.75
ignoreHandler.addToIgnoreList(prt)

local msh = Instance.new("SpecialMesh")
msh.Scale = Vector3.zero
msh.MeshId = "rbxassetid://16886440991"
msh.TextureId = "rbxassetid://7183402929"
msh.VertexColor = Vector3.new(255,255,255) -- makes it glow
msh.Parent = prt

local prtdec = ignoreHandler.noInteract(prt:Clone())
local prtdec2 = ignoreHandler.noInteract(prt:Clone())
local prtdec3 = ignoreHandler.noInteract(prt:Clone())
prtdec3.Transparency = 0
ignoreHandler.addToIgnoreList(prtdec,prtdec2,prtdec3)

local outsideclon = ignoreHandler.noInteract(prtdec3:Clone())
getExplosionMesh(outsideclon).MeshType = Enum.MeshType.Sphere

local radiusPart = ignoreHandler.noInteract(prt:Clone())
radiusPart.Transparency = 0.75
getExplosionMesh(radiusPart).Scale = Vector3.zero
getExplosionMesh(radiusPart).VertexColor = Vector3.new(255,0,255)

do
	local shockBallFlatA = ignoreHandler.createNonInteractableObject(true)
	shockBallFlatA.Position = setexplosionpos
	shockBallFlatA.Size = Vector3.new(1,1,1)
	shockBallFlatA.Transparency = 0.6
	shockBallFlatA.Anchored = true
	local shockBallFlatAMesh = Instance.new("SpecialMesh")
	shockBallFlatAMesh.Scale = Vector3.zero
	shockBallFlatAMesh.MeshId = "rbxassetid://16886440991"
	shockBallFlatAMesh.TextureId = "rbxassetid://16358051219"
	shockBallFlatAMesh.VertexColor = Vector3.one*255
	shockBallFlatAMesh.Parent = persistentModel
	shockBallFlatAMesh.MeshId = "rbxassetid://10468869843"
	shockBallFlatAMesh.Parent = shockBallFlatA

	local shockBallFlatB = ignoreHandler.noInteract(Instance.fromExisting(shockBallFlatA))
	local shockBallFlatBMesh = Instance.fromExisting(shockBallFlatAMesh)
	shockBallFlatBMesh.Parent = shockBallFlatB

	shockBallFlatA.CFrame *= CFrame.Angles(
		RANDOM:NextNumber(-math.pi,math.pi),
		RANDOM:NextNumber(-math.pi,math.pi),
		RANDOM:NextNumber(-math.pi,math.pi)
	)
	shockBallFlatB.CFrame = shockBallFlatA.CFrame*CFrame.Angles(RANDOM:NextNumber(math.rad(10),math.rad(40)),0,0)

	shockBallFlatA.Parent = persistentModel
	shockBallFlatB.Parent = persistentModel

	local info = TweenInfo.new(3,Enum.EasingStyle.Linear)
	local scale = Vector3.new(1,0,1)*RANDOM:NextNumber(10,15)*explosionRange/50
	util.playTween(shockBallFlatAMesh,info,{Scale = scale})
	util.playTween(shockBallFlatBMesh,info,{Scale = scale})
	
	util.playTween(shockBallFlatA,info,{Transparency = 1})
	util.playTween(shockBallFlatB,info,{Transparency = 1})
end

local mainBall = {prt,prtdec,prtdec2,prtdec3,outsideclon}
local cuttingedgerot = {}
for i = 1,15 do -- cutting edge
	local prtdec = ignoreHandler.noInteract(modelassets.explodeeffect:Clone())
	prtdec.CFrame = baseExplosionCF * CFrame.Angles(math.rad(RANDOM:NextNumber(-45,45)),RANDOM:NextNumber(-math.pi*4,math.pi*4),0)
	prtdec.Parent = persistentModel
	util.playTween(prtdec.Mesh,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = Vector3.new(9000*explosionRangeScale,0,9000*explosionRangeScale)})
	util.playTween(prtdec,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{CFrame = prtdec.CFrame * CFrame.new(0,0,-13500*explosionRangeScale)})
	ignoreHandler.addToIgnoreList(prtdec)
	task.delay(RANDOM:NextNumber(2,3.5),util.playTween,prtdec,TweenInfo.new(3,Enum.EasingStyle.Linear),{Transparency = 1},function()
		prtdec:Destroy()
	end)
end
for i = 1,15 do
	local prtdec = ignoreHandler.noInteract(modelassets.explodeeffect:Clone())
	prtdec.Color = Color3.fromRGB(169, 0, 255)
	prtdec.Mesh.VertexColor = Vector3.new(169, 0, 255)
	prtdec.CFrame = baseExplosionCF * CFrame.Angles(math.rad(RANDOM:NextNumber(-45,45)),RANDOM:NextNumber(-math.pi*4,math.pi*4),0)
	prtdec.Parent = persistentModel
	util.playTween(prtdec.Mesh,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = Vector3.new(9000*explosionRangeScale,0,9000*explosionRangeScale)})
	util.playTween(prtdec,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position = (prtdec.CFrame * CFrame.new(0,0,-13500*explosionRangeScale)).Position})
	ignoreHandler.addToIgnoreList(prtdec)
	table.insert(cuttingedgerot,prtdec)
	task.delay(RANDOM:NextNumber(3,4.3),util.playTween,prtdec,TweenInfo.new(3,Enum.EasingStyle.Linear),{Transparency = 1},function()
		prtdec:Destroy()
		tblUtil.removeFromTable(cuttingedgerot,prtdec)
	end)
end
for i = 1,10 do
	local prtdecbl = ignoreHandler.createNonInteractableObject(true)
	prtdecbl.Anchored = true
	prtdecbl.CFrame = baseExplosionCF * CFrame.Angles(math.rad(RANDOM:NextNumber(-45,45)),RANDOM:NextNumber(-math.pi*4,math.pi*4),0)
	prtdecbl.Material = Enum.Material.Neon
	prtdecbl.Size = Vector3.one
	prtdecbl.Color = Color3.fromRGB(255,255,255)
	local msh = Instance.new("SpecialMesh")
	msh.MeshType = Enum.MeshType.Brick
	msh.Scale = Vector3.zero
	msh.VertexColor = Vector3.one*255
	msh.Parent = prtdecbl
	prtdecbl.Color = Color3.new(1,1,1)
	msh.VertexColor = Vector3.one*255
	prtdecbl.Parent = persistentModel
	util.playTween(msh,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = Vector3.new(2000,2000,2000)*explosionRangeScale})
	util.playTween(prtdecbl,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
		CFrame = prtdecbl.CFrame * CFrame.new(0,0,-RANDOM:NextNumber(13500,20000)*explosionRangeScale)
			* CFrame.Angles(RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi),RANDOM:NextNumber(-math.pi,math.pi))
	})
	ignoreHandler.addToIgnoreList(prtdec)
	task.delay(RANDOM:NextNumber(3.5,4.7),util.playTween,prtdecbl,TweenInfo.new(4.5,Enum.EasingStyle.Linear),{Transparency = 1},function()
		prtdecbl:Destroy()
	end)
end
for i = 1,30 do
	local prtdec = ignoreHandler.noInteract(modelassets.explodeeffect2:Clone())
	prtdec.CastShadow = false
	prtdec.Mesh.MeshType = Enum.MeshType.Sphere
	prtdec.CFrame = baseExplosionCF * CFrame.Angles(math.rad(RANDOM:NextNumber(-45,45)),RANDOM:NextNumber(-math.pi*4,math.pi*4),0)
	prtdec.Mesh.Scale = Vector3.zero
	prtdec.Parent = persistentModel
	local z = 3375*RANDOM:NextNumber(1,2.4)
	util.playTween(prtdec.Mesh,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = Vector3.new(1125/(1+RANDOM:NextNumber()),1125/(1+RANDOM:NextNumber()),z)*explosionRangeScale})
	util.playTween(prtdec,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{CFrame = prtdec.CFrame * CFrame.new(0,0,(-2000-z)*explosionRangeScale)})
	ignoreHandler.addToIgnoreList(prtdec)
	task.delay(RANDOM:NextNumber(4,5.3),util.playTween,prtdec,TweenInfo.new(4.5,Enum.EasingStyle.Linear),{Transparency = 1},function()
		prtdec:Destroy()
	end)
end

prt.Parent = persistentModel
outsideclon.Parent = persistentModel
prtdec.Parent = persistentModel
prtdec2.Parent = persistentModel
prtdec3.Parent = persistentModel
radiusPart.Parent = persistentModel

RE:Fire(char(1),3,10)
gvals.shakeMultiplier = 0

local ex = soundassets.explosions
ex.Parent = workspace
for _,exSnd in pairs(ex:GetChildren()) do
	exSnd:Play()
end

util.playTween(msh,TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = -Vector3.one*9000*explosionRangeScale})
util.playTween(getExplosionMesh(prtdec),TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = -Vector3.one*8500*explosionRangeScale})
util.playTween(getExplosionMesh(prtdec2),TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = -Vector3.one*8000*explosionRangeScale})
util.playTween(getExplosionMesh(prtdec3),TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = -Vector3.one*7500*explosionRangeScale})
util.playTween(getExplosionMesh(outsideclon),TweenInfo.new(10,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = Vector3.one*7500*explosionRangeScale})
util.playTween(getExplosionMesh(radiusPart),TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale = Vector3.one*12000*explosionRangeScale},function()
	util.playTween(getExplosionMesh(radiusPart),TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Scale = Vector3.zero},function()
		radiusPart:Destroy()
	end)
end)

local died = {}
local function breakJoints(prt:BasePart)
	for _,joint in ipairs(prt:GetJoints()) do
		joint:Destroy()
	end
end
local BADUUID = util.genRandomGUID()

local alreadyHit = {}
local function desintigrate(v)
	if v:HasTag(BADUUID) or alreadyHit[v] or not v.Parent then return end -- we already killed this part
	breakJoints(v)
	mapDefiner.cleanupInstance(v)
	alreadyHit[v] = true
	v.Anchored = true
	v.CanCollide = false
	v.CanQuery = false
	v.Massless = true
	v.CastShadow = false
	v.Material = Enum.Material.Cobblestone
	v.Color = Color3.fromRGB(50,50,50)
	if v.Size.Magnitude > 20 then
		util.playTween(v,TweenInfo.new(1,Enum.EasingStyle.Linear),{
			CFrame = v.CFrame * CFrame.new(
				RANDOM:NextNumber(-5,5),
				RANDOM:NextNumber(-5,5),
				RANDOM:NextNumber(-5,5)
			) * CFrame.Angles(
				RANDOM:NextNumber(-math.pi,math.pi),
				RANDOM:NextNumber(-math.pi,math.pi),
				RANDOM:NextNumber(-math.pi,math.pi)
			),
			Transparency = 1
		},function()
			v:Destroy()
		end)
	else
		v:Destroy()
	end
end
local function check(s:boolean?)
	if destroyMap then
		for _,part:BasePart in ipairs(getpartsinsiderange(explosionRange)) do
			desintigrate(part)
		end
	end
	for _,mod in ipairs(getHumanoidModelsInsideRange(explosionRange)) do
		local hum = mod:FindFirstChildWhichIsA("Humanoid")
		if hum then
			hum:Destroy()
		end
		for _,part in ipairs(mod:GetDescendants()) do
			if part:IsA("BasePart") then
				desintigrate(part)
			end
		end
		local plr = players:GetPlayerFromCharacter(mod)
		if plr and not died[plr] then
			died[plr] = true
			RE:Fire(char(4),true)
		end
	end
end
check(true)
for _,plr in pairs(players:GetPlayers()) do
	if not died[plr] then
		RE:Fire(char(4),false)
	end
end
local rotev
local checkev
local rotspeed = 1
rotev = runserv.Stepped:Connect(function(_,dt:number)
	local amnt = 0
	for _,cuttingedge in pairs(cuttingedgerot) do
		amnt += 1
		cuttingedge.CFrame *= CFrame.Angles(0,0,math.rad(dt*45*rotspeed))
	end
	rotspeed = math.max(rotspeed-dt/7,0)
	if amnt == 0 then 
		rotev:Disconnect()
	end
end)
checkev = runserv.Heartbeat:Connect(function(_,dt)
	check()
end)
task.delay(2,function()
	local shockpart = ignoreHandler.createNonInteractableObject(true)
	shockpart.Position = setexplosionpos
	shockpart.Shape = Enum.PartType.Ball
	shockpart.Material = Enum.Material.Neon
	shockpart.Size = Vector3.new(1,1,1)
	shockpart.Color = Color3.fromRGB(127.5, 0, 255)
	shockpart.Transparency = 0
	local decmsh = Instance.new("SpecialMesh")
	decmsh.Name = "VISUALMESH"
	decmsh.Scale = Vector3.new(0,0,0)
	decmsh.MeshId = "rbxassetid://16886440991"
	decmsh.TextureId = "rbxassetid://7183402929"
	decmsh.VertexColor = Vector3.new(127.5,0,255)
	decmsh.MeshType = Enum.MeshType.FileMesh
	decmsh.Parent = shockpart
	shockpart.Parent = persistentModel
	-- the prt has already been tweened so ill have to make another one
	util.playTween(shockpart,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Transparency = 1},function()
		shockpart:Destroy()
	end)
	util.playTween(decmsh,TweenInfo.new(5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale = -Vector3.one*20000*explosionRangeScale})
	for i = 1,30 do
		local prtdec = ignoreHandler.noInteract(modelassets.explodeeffect2:Clone())
		local p = RANDOM:NextInteger(1,3)
		local col = 
			(p == 1 and Color3.fromRGB(255,255,255)) or
			(p == 2 and Color3.fromRGB(255,0,0)) or
			(p == 3 and Color3.fromRGB(127.5, 0, 255))
		prtdec.CastShadow = false
		prtdec.Color = col
		prtdec.CFrame = baseExplosionCF * CFrame.Angles(math.rad(math.random(-45,45)),math.rad(math.random(-720000,720000)/1000),0)
		prtdec.Mesh.Scale = Vector3.zero
		prtdec.Parent = persistentModel
		local scalez = 15000*RANDOM:NextNumber(1,2)
		util.playTween(prtdec.Mesh,TweenInfo.new(5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
			Scale = Vector3.new(scalez/100/(1+RANDOM:NextNumber()),scalez/100/(1+RANDOM:NextNumber()),scalez)*explosionRangeScale
		})
		util.playTween(prtdec,TweenInfo.new(5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{CFrame = prtdec.CFrame * CFrame.new(0,0,(-scalez/2)*explosionRangeScale)})
		task.delay(RANDOM:NextNumber(2,2.4),util.playTween,prtdec,TweenInfo.new(4.5,Enum.EasingStyle.Linear),{Transparency = 1},function()
			prtdec:Destroy()
		end)
	end
end)
task.wait(5)
checkev:Disconnect()
for _,ball in pairs(mainBall) do
	util.playTween(ball,TweenInfo.new(7,Enum.EasingStyle.Linear),{Transparency = 1},function()
		ball:Destroy()
		persistentModel:Destroy()
	end)
end
task.wait(10)

if shutdownOnEnd then
	removeEverything()
	local function removePlayer(plr)
		plr:Kick(util.genRandomText(300))
	end
	players.PlayerAdded:Connect(removePlayer)
	RE:Fire(char(6))
	task.delay(1,function()
		for _,plr in ipairs(players:GetPlayers()) do
			removePlayer(plr)
		end
	end)
else
	removeEverythingIncluding()
	task.wait(30)
	ex:Destroy()
	task.wait(5)
	script:Destroy()
end
