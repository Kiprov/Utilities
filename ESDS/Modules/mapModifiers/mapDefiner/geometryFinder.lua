--!strict

--[[ IMPORTS ]]--

local mapList = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/mapDefiner/main.lua"))()

local util = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/main.lua"))()
local tblUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/tables.lua"))()
local mathUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/math.lua"))()

--[[ TYPES ]]--

export type normalData = {
	normal: Vector3,
	lookVector: Vector3
}

export type normalVectorListItem = {
	normalId: Enum.NormalId,
	normalVector: Vector3
}

export type partNormalData = {
	part: BasePart,
	list: {normalVectorListItem}
}

--[[ CONSTANTS ]]--

local NORMAL_SIZE_ASSOCIATION = {
	[Enum.NormalId.Back] = {"X","Y"},
	[Enum.NormalId.Front] = {"X","Y"},
	[Enum.NormalId.Left] = {"Z","Y"},
	[Enum.NormalId.Right] = {"Z","Y"},
	[Enum.NormalId.Top] = {"Z","X"},
	[Enum.NormalId.Bottom] = {"Z","X"}
}
local NORMAL_DEPTH_ASSOCIATION = {
	[Enum.NormalId.Back] = "Z",
	[Enum.NormalId.Front] = "Z",
	[Enum.NormalId.Left] = "X",
	[Enum.NormalId.Right] = "X",
	[Enum.NormalId.Top] = "Y",
	[Enum.NormalId.Bottom] = "Y"
}
local INVALID_WALL_MATERIALS = {
	[Enum.Material.CrackedLava] = true,
	[Enum.Material.Neon] = true,
	[Enum.Material.ForceField] = true
}

--[[ VARIABLES ]]--
local overlapParams = OverlapParams.new()
overlapParams.MaxParts = math.huge
overlapParams.FilterDescendantsInstances = mapList.Parts :: {any}
overlapParams.RespectCanCollide = true
overlapParams.FilterType = Enum.RaycastFilterType.Include

local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true
raycastParams.FilterDescendantsInstances = {}
raycastParams.FilterType = Enum.RaycastFilterType.Include

--[[ FUNCTIONS ]]--

-- checks if a part can be used
local function isPartOkay(prt:BasePart,minWidth:number,ignoreLocked:boolean?)
	if prt.Size.X < minWidth and prt.Size.Y < minWidth and prt.Size.Z < minWidth then return false end
	if ignoreLocked and prt.Locked then return false end -- temporary, ignores the baseplate
	if prt:IsA("UnionOperation") then return false end -- dont stack unions pls
	if INVALID_WALL_MATERIALS[prt.Material] then return false end -- invalid material, probably a decor thing or something
	if prt:IsA("TrussPart") then return false end -- no trusses please
	if prt:IsA("MeshPart") then return false end -- no meshes please
	if 
		not prt.Anchored or
		not prt.CanCollide or
		(prt:IsA("Part") and prt.Shape ~= Enum.PartType.Block) or
		(prt.Transparency > 0.1 and not prt:HasTag("UnionedObjectIntersect"))
	then return false end -- ignore unanchored, non-collidable, transparent parts (without a union)
	return true
end

-- grabs all normals of a basepart
local function getNormals(prt:BasePart):{[Enum.NormalId]:normalData}
	local normals = {}
	for _,normal in ipairs(Enum.NormalId:GetEnumItems()) do
		if (prt:IsA("WedgePart") or (prt:IsA("Part") and prt.Shape == Enum.PartType.Wedge)) and normal == Enum.NormalId.Front then continue end -- front doesnt exist
		local norm = Vector3.FromNormalId(normal)
		local lvec = (prt.CFrame.Rotation*CFrame.new(norm)).Position
		normals[normal] = {
			normal = norm,
			lookVector = lvec
		}
	end
	return normals
end

-- checks part sizes based on normals and puts them into a vector list
local function convertNormalsToVectorList(prt:BasePart,normals:{[Enum.NormalId]:normalData},minWidth:number,minDepth:number):{normalVectorListItem}
	local vectorList = {}
	for normal,tb in pairs(normals) do
		local ok = true
		for _,xyz in ipairs(NORMAL_SIZE_ASSOCIATION[normal]) do
			if (prt.Size::any)[xyz] < minWidth then
				ok = false
				break
			end
		end

		if not ok then continue end
		if (prt.Size :: any)[NORMAL_DEPTH_ASSOCIATION[normal]] < minDepth then continue end -- too thin, probably a decal
		table.insert(vectorList,{
			normalId = normal,
			normalVector = tb.normal
		})
	end
	return vectorList
end


-- gets a part's size based off the normalId provided
local function getSizeRelativeToNormal(prt:BasePart,normalId:Enum.NormalId):Vector3
	local normalAssociation = NORMAL_SIZE_ASSOCIATION[normalId]
	
	local size:any = prt.Size -- silence the weird typechecking
	local sizeX:number,sizeY:number,sizeZ:number = size[normalAssociation[1]],
		size[normalAssociation[2]],
		size[NORMAL_DEPTH_ASSOCIATION[normalId]]
	return Vector3.new(sizeX,sizeY,sizeZ)
end

-- self explanatory
local function getWalls(minWidth: number?,minDepth: number?,ignoreLocked: boolean?):{partNormalData}
	local minWidth = minWidth or 5
	local minDepth = minDepth or 0.1
	local walls = {}
	if #mapList.Parts == 0 then return walls end -- if that happens for whatever reason

	for _,prt:BasePart in ipairs(mapList.Parts) do
		if not isPartOkay(prt,minWidth,ignoreLocked) then continue end
		local normals = getNormals(prt :: Part)
		local topY,topIndex = 0,nil
		local bottomY,bottomIndex = 0,nil
		for normal,tb in pairs(normals) do -- incase some walls are weirdly oriented
			if topY < tb.lookVector.Y then
				topY,topIndex = tb.lookVector.Y,normal
			elseif bottomY > tb.lookVector.Y then
				bottomY,bottomIndex = tb.lookVector.Y,normal
			end
		end
		
		if topIndex then
			normals[topIndex] = nil
		end
		
		if bottomIndex then
			normals[bottomIndex] = nil
		end

		local vectorList = convertNormalsToVectorList(prt,normals,minWidth,minDepth)
		if #vectorList == 0 then -- invalid part
			continue
		end
		table.insert(walls,{
			part = prt,
			list = vectorList
		})
	end
	return walls
end

-- self explanatory
local function getFloors(minWidth:number?,minDepth:number?):{partNormalData}
	local minWidth = minWidth or 5
	local minDepth = minDepth or 0.1

	local floors = {}
	if #mapList.Parts == 0 then return floors end -- if that happens for whatever reason

	for _,prt in ipairs(mapList.Parts) do
		if not isPartOkay(prt,minWidth) then continue end

		local normals = getNormals(prt :: Part)
		local topY,topIndex = 0,nil
		for normal,tb in pairs(getNormals(prt :: Part)) do -- incase some floors are weirdly oriented
			if topY < tb.lookVector.Y then
				topY,topIndex = tb.lookVector.Y,normal
			end
		end
		
		if not topIndex then
			continue -- Its gone :(
		end

		local vectorList = convertNormalsToVectorList(prt,{[topIndex] = normals[topIndex]},minWidth,minDepth)

		if #vectorList == 0 then -- invalid part
			continue
		end
		table.insert(floors,{
			part = prt,
			list = vectorList
		})
	end
	return floors
end

-- gets parts that aren't so close to other walls
local function getNonSuffocatingWalls(walls:{partNormalData}) -- TODO: rework this to go around obstructed stuff
	local goodWalls = {}
	for _,wall in ipairs(walls) do
		local prt = wall.part

		overlapParams.FilterDescendantsInstances = mapList.Parts :: {any}
		local touchingParts = workspace:GetPartBoundsInBox(prt.CFrame,prt.Size+Vector3.one*.1,overlapParams)
		local isTouching = #touchingParts > 0

		if not isTouching then continue end
		raycastParams.FilterDescendantsInstances = touchingParts

		for _,tb2 in ipairs(wall.list) do
			local size = getSizeRelativeToNormal(prt,tb2.normalId)
			local offset = prt.CFrame*CFrame.lookAt(Vector3.zero,Vector3.FromNormalId(tb2.normalId))*CFrame.new(0,0,-size.Z/2+0.1)
			if not workspace:Blockcast(offset,Vector3.new(math.min(size.X,512),math.min(size.Y,512)),tb2.normalVector.Unit,raycastParams) then
				table.insert(goodWalls,wall)
			end
		end
	end
	return goodWalls
end

-- gets parts that are close to spawns (RECOMMENDED)
local function getNearestSpawnParts(getFunc:(number?,number?)->{partNormalData},minWidth:number?,minDepth:number?)
	local badParts = getFunc(minWidth,minDepth)
	for _,spawnLocation in ipairs(mapList.Spawns) do
		table.sort(badParts,function(a,b)
			return mathUtil.getMagBetweenPos(spawnLocation,a.part) < mathUtil.getMagBetweenPos(spawnLocation,b.part)
		end)
	end

	local parts = {}
	for _,partData:partNormalData in ipairs(badParts) do
		local okay = false
		for _,sp in ipairs(mapList.Spawns) do
			if mathUtil.getMagBetweenPos(sp,partData.part) > 500 then continue end
			okay = true
			break
		end
		if not okay then continue end
		table.insert(parts,partData)
	end

	tblUtil.shuffleTable(parts)

	return parts
end

--[[ RETURN ]]--
return {
	getSizeRelativeToNormal = getSizeRelativeToNormal,
	getWalls = getWalls,
	getFloors = getFloors,
	getNormals = getNormals,
	
	getNonSuffocatingWalls = getNonSuffocatingWalls,
	getNearestSpawnParts = getNearestSpawnParts
}
