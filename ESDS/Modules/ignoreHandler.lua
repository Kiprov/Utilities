--!strict

--[[ TYPES ]]--

type ignoreList = { [Instance]: boolean }

--[[ VARIABLES ]]--

local doNotInteractWith:ignoreList = {}

--[[ FUNCTIONS ]]--

local function addToIgnoreList(...)
	for _,inst in pairs({...}) do
		doNotInteractWith[inst] = true
	end
end
local function createNonInteractableObject(shadowless:boolean?):Part
	local prt = Instance.new("Part")
	prt.Anchored = true
	prt.CastShadow = not shadowless
	prt.CanCollide = false
	prt.CanQuery = false
	prt.CanTouch = false
	prt.Locked = true
	addToIgnoreList(prt)
	return prt
end
local function noInteract<T>(...:T):T
	for _,prt in ipairs({...}) do
		if typeof(prt) ~= "Instance" then
			continue
		end
		if prt:IsA("BasePart") then
			prt.CanCollide = false
			prt.CanQuery = false
			prt.CanTouch = false
			prt.Locked = true
			addToIgnoreList(prt)
		end
		noInteract(unpack(prt:GetChildren()))
	end
	return ...
end
local function noInteractWithHitboxes<T>(...:T):T
	for _,prt in ipairs({...}) do
		if typeof(prt) ~= "Instance" then
			continue
		end
		if prt:IsA("BasePart") then
			prt.Locked = true
			addToIgnoreList(prt)
		end
		noInteractWithHitboxes(unpack(prt:GetChildren()))
	end
	return ...
end

local function getIgnoreList():ignoreList
	return table.freeze(table.clone(doNotInteractWith))
end
local function isInstanceOnIgnoreList(inst:Instance)
	return doNotInteractWith[inst]
end

--[[ RETURN ]]--
return {
	addToIgnoreList = addToIgnoreList,
	noInteract = noInteract,
	noInteractWithHitboxes = noInteractWithHitboxes,
	createNonInteractableObject = createNonInteractableObject,
	
	getIgnoreList = getIgnoreList,
	isInstanceOnIgnoreList = isInstanceOnIgnoreList
}
