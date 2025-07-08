--!strict

--[[ IMPORTS ]]--

local util = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/main.lua"))()
local tblUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/tables.lua"))()
local maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/vendor/Maid.lua"))()
local ignore = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/ignoreHandler.lua"))()

--[[ VARIABLES ]]--

local debrisTag = util.genRandomGUID()
local initialized = false

local allBinds = {}
local allParts:{BasePart},allWelds:{JointInstance},allLights:{Light|SurfaceGuiBase},allSpawns:{SpawnLocation} = {},{},{},{}
local allHumanoids:{[Model]: {Humanoid}},allVehicles:{[any]: {VehicleSeat}},allTools:{[any]: {Tool}} = {},{},{}

--[[ FUNCTIONS ]]--

local function isDescendantOfClass(inst:Instance,classTable:{[any]: {any}})
	local parMod:Instance? = inst
	while parMod and parMod ~= workspace do
		parMod = parMod.Parent
		if not parMod then return false end
		if classTable[parMod] and #classTable[parMod] > 0 then return true end -- HUMANoid...
		if
			not parMod.Parent or
			parMod == workspace or
			parMod.Parent == workspace or
			not parMod.Parent:IsA("Model")
		then return false end
	end
	return false
end
local function isDescendantOfBadClass(inst:Instance)
	return isDescendantOfClass(inst,allHumanoids) or isDescendantOfClass(inst,allVehicles) or isDescendantOfClass(inst,allTools)
end

local function cleanupInstance(inst:any)
	local b = allBinds[inst]
	if b then
		b:Disconnect()
		allBinds[inst] = nil
	end
	if tblUtil.removeFromTable(allParts,inst) then return end
	if tblUtil.removeFromTable(allWelds,inst) then return end
	if tblUtil.removeFromTable(allLights,inst) then return end
	if tblUtil.removeFromTable(allSpawns,inst) then return end
end

local function getParent(v:Instance):Instance?
	if v:IsA("VehicleSeat") then
		local par:Instance = v
		while true do
			local newpar:Model? = par:FindFirstAncestorOfClass("Model")
			if newpar then
				par = newpar
				continue
			end
			return par
		end
	elseif v:IsA("Humanoid") then
		return v.Parent
	end

	return
end

local function addClass(v:Instance,type:string,classTbl:{[any]: any}):boolean?
	if not v:IsA(type) then return false end
	local lastPar = nil
	local m = maid.new()

	local ancestryChanged:((ch:Instance,par:Instance?)->())?
	ancestryChanged = function(ch:Instance,par:Instance?)
		if (ch == v and par == workspace) or not par then m:Destroy() return end
		if ch ~= v then return end
		par = getParent(v)
		if par == lastPar then return end
		if classTbl[lastPar] then
			tblUtil.removeFromTable(classTbl[lastPar],v)
			if #classTbl[lastPar] == 0 then
				classTbl[lastPar] = nil
			end
		end
		lastPar = par
		classTbl[par] = classTbl[par] or {}
		table.insert(classTbl[par],v)
	end
	m:GiveTask(function()
		m = nil
		ancestryChanged = nil
		if not classTbl[lastPar] then return end
		tblUtil.removeFromTable(classTbl[lastPar],v)
		if #classTbl[lastPar] == 0 then
			classTbl[lastPar] = nil
		end
	end)
	if ancestryChanged then
		m:GiveTask(v.AncestryChanged:Connect(ancestryChanged))
		m:GiveTask(v.Destroying:Connect(function()
			m:Destroy()
		end))
		ancestryChanged(v,v.Parent)
	end

	return
end

local function addExternals(v:Instance)
	if v:IsA("Humanoid") then
		addClass(v,"Humanoid",allHumanoids)
	elseif v:IsA("VehicleSeat") then
		addClass(v,"VehicleSeat",allVehicles)
	elseif v:IsA("Tool") then
		addClass(v,"Tool",allTools)
	end
end

local function parentChangeCheck(inst:Instance,tb:{[any]: any},checkFunc:(()->boolean?)?)
	-- main checks, if any of this is true/false then the instance is no longer valid / becomes valid
	-- also we do NOT want HUMANOIDS!!!! they did nothing wrong...

	local bad = isDescendantOfBadClass(inst) or (checkFunc and not checkFunc())
	local isInTable = table.find(tb,inst)
	if bad and isInTable then
		tblUtil.removeFromTable(tb,inst)
		return
	elseif not bad and not isInTable then
		table.insert(tb,inst)
	end
end

local function defaultAncChangedCheck(inst:Instance,tb:{[any]: any},checkFunc:(()->boolean?)?)
	parentChangeCheck(inst,tb,checkFunc)
	allBinds[inst] = inst.AncestryChanged:Connect(function()
		parentChangeCheck(inst,tb,checkFunc)
	end)
end

local function addInst(v:BasePart|JointInstance|WeldConstraint|Light|SurfaceGuiBase|Humanoid)
	if not initialized and addExternals(v) then return end
	if v:IsA("Terrain") then return end -- exclude terrain, idk why its a basepart
	if ignore.isInstanceOnIgnoreList(v) then return end -- we do not interact with this please
	if v:IsA("BasePart") and v.Name ~= debrisTag then -- is most likely map geometry
		defaultAncChangedCheck(v,v:IsA("SpawnLocation") and allSpawns or allParts)
	elseif (v:IsA("JointInstance") or v:IsA("WeldConstraint")) and not v:IsA("Motor6D") and not v:HasTag("DoNotInteractWeld") then
		defaultAncChangedCheck(v,allWelds)
	elseif v:IsA("Light") or v:IsA("SurfaceGuiBase") then
		defaultAncChangedCheck(v,allLights,function()
			return v.Parent and v.Parent:IsA("BasePart") and v.Parent ~= workspace.Terrain
		end)
	end
end

local function getLights()
	local tb = {}
	for _,light in ipairs(allLights) do
		if light:IsA("SurfaceGui") and light.LightInfluence > 0.5 then continue end -- surface is a light, but still needs to have no light influence
		table.insert(tb,light)
	end
	return tb
end

--[[ MAIN ]]--
for _,inst in ipairs(workspace:GetDescendants()) do
	addExternals(inst) -- do humanoids first
end
initialized = true
for _,inst in ipairs(workspace:GetDescendants()) do
	addInst(inst)
end
initialized = false
workspace.DescendantAdded:Connect(addInst)
workspace.DescendantRemoving:Connect(cleanupInstance)

--[[ RETURN ]]--
return {
	Parts = allParts,
	Welds = allWelds,
	Humanoids = allHumanoids,
	Spawns = allSpawns,
	Vehicles = allVehicles,
	Tools = allTools,
	Lights = allLights,
	
	getProperLights = getLights,
	
	isDescendantOfClass = isDescendantOfClass,
	isDescendantOfBadClass = isDescendantOfBadClass,
	cleanupInstance = cleanupInstance,
	
	currentDebrisTag = debrisTag
}
