--!strict

--[[ IMPORTS ]]--
local getTrisForObj = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/mapModifiers/getTrisForObj/main.lua"))()
local quickHull = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/vendor/QuickHull2Typed.lua"))()

--[[ FUNCTIONS ]]--

local function applyTexOnAllFaces(prt:BasePart,tex:Decal)
	for _,id in ipairs(Enum.NormalId:GetEnumItems()) do
		local texClone:Decal = Instance.fromExisting(tex)
		texClone.Archivable = true
		texClone.Face = id
		texClone.Parent = prt
	end
end

local function copyPartAttributesTo(fromPart:BasePart,toPart:BasePart)
	toPart.Transparency = fromPart.Transparency
	toPart.Reflectance = fromPart.Reflectance
	toPart.Color = fromPart.Color
	toPart.CastShadow = fromPart.CastShadow
	toPart.Locked = fromPart.Locked
	if fromPart.CustomPhysicalProperties then
		toPart.CustomPhysicalProperties = fromPart.CurrentPhysicalProperties
	end
	toPart.Massless = fromPart.Massless
	toPart.AssemblyLinearVelocity = fromPart.AssemblyLinearVelocity
	toPart.AssemblyAngularVelocity = fromPart.AssemblyAngularVelocity
	toPart.EnableFluidForces = fromPart.EnableFluidForces
	toPart.Material = fromPart.Material
	toPart.CanQuery = fromPart.CanQuery
	toPart.CanTouch = fromPart.CanTouch
	toPart.MaterialVariant = fromPart.MaterialVariant
	
	toPart.TopSurface = fromPart.TopSurface
	toPart.BottomSurface = fromPart.BottomSurface
	toPart.LeftSurface = fromPart.LeftSurface
	toPart.RightSurface = fromPart.RightSurface
	toPart.FrontSurface = fromPart.FrontSurface
	toPart.BackSurface = fromPart.BackSurface

	for _,tex in ipairs(fromPart:GetChildren()) do
		if tex:IsA("Texture") or tex:IsA("Decal") then
			applyTexOnAllFaces(toPart,tex)
		end
	end
end

-- originally made by @EgoMoose
local function getWedgeCoordinatesFromTri(a: Vector3, b: Vector3, c: Vector3)
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if (abd > acd and abd > bcd) then
		c, a = a, c
	elseif (acd > bcd and acd > abd) then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local right = ac:Cross(ab).Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit

	local height = math.abs(ab:Dot(up))
	
	local coordsA = {
		CFrame = CFrame.fromMatrix((a + b)/2, right, up, back),
		Size = Vector3.new(0.05, height, math.abs(ab:Dot(back))),
	}
	
	local coordsB = {
		CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back),
		Size = Vector3.new(0.05, height, math.abs(ac:Dot(back)))
	}

	return coordsA, coordsB
end

local function subdivideTri(tri:quickHull.Tri,amnt)
	local tris = {tri}
	for i = 1,amnt do
		local newTris = {}
		for _,tri in ipairs(tris) do
			local center = (tri[1]+tri[2]+tri[3])/3

			local threePointsA = {tri[1],tri[1]:Lerp(tri[2],.5),tri[2]}
			local threePointsB = {tri[2],tri[2]:Lerp(tri[3],0.5),tri[3]}
			local threePointsC = {tri[1],tri[1]:Lerp(tri[3],0.5),tri[3]}

			table.insert(newTris,{threePointsA[1],center,threePointsA[2]})
			table.insert(newTris,{threePointsA[2],center,threePointsA[3]})
			table.insert(newTris,{threePointsB[1],center,threePointsB[2]})
			table.insert(newTris,{threePointsB[2],center,threePointsB[3]})
			table.insert(newTris,{threePointsC[1],center,threePointsC[2]})
			table.insert(newTris,{threePointsC[2],center,threePointsC[3]})
		end
		tris = newTris
	end
	return tris
end

local function subdivideTrisByAmnt(tris:{quickHull.Tri},amnt:number)
	local newTris = {}
	for _,tri in ipairs(tris) do
		for _,newTri in ipairs(subdivideTri(tri,amnt)) do
			table.insert(newTris,newTri)
		end
	end
	return newTris
end

local function shouldNotSubdivide(obj:BasePart)
	return obj:IsA("MeshPart") or
		(obj:IsA("Part") and (obj.Shape == Enum.PartType.Cylinder or obj.Shape == Enum.PartType.Ball))
end

local function shatterGlass(glassObj:BasePart): {Part}?
	if glassObj:IsA("TrussPart") then return end
	local tris = getTrisForObj(glassObj,.7)
	
	local canSubdivide = not shouldNotSubdivide(glassObj)
	
	local finalTris = {}
	for _,tri in ipairs(tris) do
		local magA,magB,magC = 
			(tri[1]-tri[2]).Magnitude,
			(tri[2]-tri[3]).Magnitude,
			(tri[1]-tri[3]).Magnitude

		local hyp = math.max(magA,magB,magC)
		local opp,adj

		if hyp == magA then
			opp = math.min(magB,magC)
			adj = math.max(magB,magC)
		elseif hyp == magB then
			opp = math.min(magA,magC)
			adj = math.max(magA,magC)
		else
			opp = math.min(magA,magB)
			adj = math.max(magA,magB)
		end

		local sizeRatio = adj/opp
		if sizeRatio > 200 then
			continue -- too thin
		end
		
		local center = (tri[1]+tri[2]+tri[3])/3
		local distA,distB,distC = 
			(center-tri[1]).Magnitude,
			(center-tri[2]).Magnitude,
			(center-tri[3]).Magnitude

		local finalDist = (distA+distB+distC)/3

		local tris = {tri}
		local subAmnt = canSubdivide and math.min(math.ceil((finalDist/sizeRatio)/20)-1,2) or 0
		if subAmnt > 0 then
			tris = subdivideTrisByAmnt(tris,subAmnt)
		end
		for _,tri in ipairs(tris) do
			table.insert(finalTris,tri)
		end
	end
	
	local wedgeCoordinates = {}
	for _,tri in ipairs(finalTris) do
		local coordsA,coordsB = getWedgeCoordinatesFromTri(tri[1],tri[2],tri[3])
		table.insert(wedgeCoordinates,coordsA)
		table.insert(wedgeCoordinates,coordsB)
	end
	
	local wedges:{Part} = {}
	for _,wedgeCoords in ipairs(wedgeCoordinates) do
		local wedge = Instance.new("Part")
		copyPartAttributesTo(glassObj,wedge)
		wedge.Massless = true
		wedge.CanTouch = false
		wedge.CanQuery = false
		wedge.Anchored = false
		wedge.Shape = Enum.PartType.Wedge
		wedge.CFrame = wedgeCoords.CFrame
		wedge.Size = Vector3.new(.7,wedgeCoords.Size.Y,wedgeCoords.Size.Z)
		wedge.EnableFluidForces = false
		
		table.insert(wedges,wedge)
	end
	
	return wedges
end

--[[ RETURN ]]--
return shatterGlass
