--!strict

--[[ IMPORTS ]]--
local partTypeVerts = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/getTrisForObj/PartVerts.lua"))()
local quickHull = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/vendor/QuickHull2Typed.lua"))()

--[[ TYPES ]]--

type rec = {
	n: Vector3,
	ed: number,
	tri: quickHull.Tri
}

--[[ VARIABLES ]]--
local cachedMeshVerts = {}
local hullParams = RaycastParams.new()
hullParams.RespectCanCollide = false
hullParams.FilterType = Enum.RaycastFilterType.Include
hullParams.IgnoreWater = true

--[[ FUNCTIONS ]]--

local function AddUnique(list:{Vector3}, point:Vector3)
	for key,value in pairs(list) do
		if (value-point).Magnitude < 0.1 then
			return
		end
	end
	table.insert(list, point)
end

local function IsUnique(list:{rec}, normal:Vector3, d:number)
	local EPS = 0.01
	local normalTol = 0.95

	for _, rec in pairs(list) do
		if math.abs(rec.ed - d) < EPS and rec.n:Dot(normal) > normalTol then
			return false
		end
	end
	return true
end

local function IsUniquePoint(list:{Vector3}, point:Vector3)
	local EPS = 0.001

	for _, src in pairs(list) do
		if (src-point).Magnitude < EPS then
			return false
		end
	end
	return true
end


-- code ripped directly from Chickynoid because i didnt feel like reinventing the wheel
-- attempts to get a part's hull from raycasting a lot and then caches it
local function getHullVertsOfObject(obj:BasePart):{Vector3}?
	local points
	if obj:IsA("MeshPart") then
		points = cachedMeshVerts[obj.MeshId]
	end
	
	if not points then
		points = {}
		
		local worldModel = Instance.new("WorldModel")
		local objClone = Instance.fromExisting(obj)
		objClone.Size = Vector3.one
		objClone.CFrame = CFrame.identity
		objClone.CanQuery = true
		objClone.Parent = worldModel
		worldModel.Parent = game.ReplicatedStorage

		hullParams.FilterDescendantsInstances = {objClone}

		local step = 0.2
		for x=-0.5, 0.5, step do
			for y=-0.5, 0.5, step do
				local pos = Vector3.new(x,-2,y)
				local dir = Vector3.new(0,4,0)
				local result = worldModel:Raycast(pos, dir, hullParams)
				if result then 
					AddUnique(points, result.Position)

					--we hit something, trace from the other side too
					local pos = Vector3.new(x,2,y)
					local dir = Vector3.new(0,-4,0)
					local result = worldModel:Raycast(pos, dir, hullParams)
					if result then 
						AddUnique(points, result.Position)
					end
				end
			end
		end

		for x=-0.5, 0.5, step do
			for y=-0.5, 0.5, step do
				local pos = Vector3.new(-2,x,y)
				local dir = Vector3.new(4,0,0)
				local result = worldModel:Raycast(pos, dir, hullParams)
				if result then 
					AddUnique(points, result.Position)

					--we hit something, trace from the other side too
					local pos = Vector3.new(2,x,y)
					local dir = Vector3.new(-4,0,0)
					local result = worldModel:Raycast(pos, dir, hullParams)
					if result then 
						AddUnique(points, result.Position)
					end
				end
			end
		end

		for x=-0.5, 0.5, step do
			for y=-0.5, 0.5, step do
				local pos = Vector3.new(x,y,-2)
				local dir = Vector3.new(0,0,4)
				local result = worldModel:Raycast(pos, dir, hullParams)
				if result then 
					AddUnique(points, result.Position)

					--we hit something, trace from the other side too
					local pos = Vector3.new(x,y,2)
					local dir = Vector3.new(0,0,-4)
					local result = worldModel:Raycast(pos, dir, hullParams)
					if result then 
						AddUnique(points, result.Position)
					end
				end
			end
		end

		worldModel:Destroy()
		
		local hull = quickHull.generateHull(points)
		if hull then
			local recs:{rec} = {}

			for _, tri in pairs(hull) do
				local normal = (tri[1] - tri[2]):Cross(tri[1] - tri[3]).Unit
				local ed = tri[1]:Dot(normal) --expanded distance

				if IsUnique(recs, normal, ed) then
					table.insert(recs, {
						n = normal,
						ed = ed, --expanded
						tri = tri
					})
				end
			end
			local points = {}
			for key,record in pairs(recs) do

				if IsUniquePoint(points, record.tri[1]) then
					table.insert(points,record.tri[1])
				end
				if IsUniquePoint(points, record.tri[2]) then
					table.insert(points,record.tri[2])
				end
				if IsUniquePoint(points, record.tri[3]) then
					table.insert(points,record.tri[3])
				end
			end
			if obj:IsA("MeshPart") then
				cachedMeshVerts[obj.MeshId] = points
			end
		else
			print("BAD HULL")
			return
		end
	end

	local stretched = {}
	local size = obj.Size

	for _,point in pairs(points) do
		table.insert(stretched,obj.CFrame:PointToWorldSpace(point*size))	
	end
	
	return stretched
end

local function pointsToTris(points:{Vector3})
	local amnt = #points
	if amnt > 4 then
		return quickHull.generateHull(points) or {}
	end
	
	if amnt == 4 then
		return {
			{points[1],points[2],points[3]},
			{points[4],points[2],points[3]}
		}
	elseif amnt == 3 then
		return {
			{points[1],points[2],points[3]},
		}
	else
		return {}
	end
end

-- gets the triangles for a part, may not be accurate sometimes
local function getTrisForPart(prt:BasePart,mergeDistance:number?)
	local tris:{{Vector3}} = {}
	if prt:IsA("WedgePart") then
		tris = pointsToTris(partTypeVerts[Enum.PartType.Wedge](prt,mergeDistance))
	elseif prt:IsA("CornerWedgePart") then
		tris = pointsToTris(partTypeVerts[Enum.PartType.CornerWedge](prt,mergeDistance))
	elseif prt:IsA("TrussPart") then
		tris = pointsToTris(partTypeVerts[Enum.PartType.Block](prt,mergeDistance))
	elseif prt:IsA("Part") then
		tris = pointsToTris(partTypeVerts[prt.Shape](prt,mergeDistance))
	else
		local verts = getHullVertsOfObject(prt)

		if not verts then
			tris = pointsToTris(partTypeVerts[Enum.PartType.Block](prt,mergeDistance))
		else
			local points:{Vector3} = {}
			for _, point in ipairs(verts) do
				table.insert(points, point)
			end
			
			tris = pointsToTris(points)
		end
	end
	
	return tris
end

--[[ RETURN ]]--
return getTrisForPart
