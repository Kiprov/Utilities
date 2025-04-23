-- grabbed from https://devforum.roblox.com/t/lesssimplezone-a-more-precise-optimized-extension-of-simplezone/3388245/26

local function closeEnough(pointA:Vector3,pointB:Vector3,dist:number)
	return (pointA-pointB).Magnitude <= dist
end

local partTypeVerts = table.freeze({
	[Enum.PartType.Block] = function(part: Part, mergeDistance: number?)
		local mergeDistance = mergeDistance or 0.06
		local pos = part.Position
		local cf = part.CFrame
		local size = part.Size

		local s2 = size/2

		local xvec = cf.XVector.Unit * s2.X
		local yvec = cf.YVector.Unit * s2.Y
		local zvec = cf.ZVector.Unit * s2.Z
		
		-- we merge to 4 verts if we're below merge distance
		if s2.X <= mergeDistance then
			return {
				pos + yvec + zvec,
				pos + yvec - zvec,
				pos - yvec + zvec,
				pos - yvec - zvec
			}
		elseif s2.Y <= mergeDistance then
			return {
				pos + xvec + zvec,
				pos + xvec - zvec,
				pos - xvec + zvec,
				pos - xvec - zvec
			}
		elseif s2.Z <= mergeDistance then
			return {
				pos + xvec + yvec,
				pos + xvec - yvec,
				pos - xvec + yvec,
				pos - xvec - yvec
			}
		end
		
		-- otherwise u have the full cube
		return { 
			pos + xvec + yvec + zvec,
			pos + xvec + yvec - zvec,
			pos + xvec - yvec + zvec,
			pos + xvec - yvec - zvec,
			pos - xvec + yvec + zvec,
			pos - xvec + yvec - zvec,
			pos - xvec - yvec + zvec,
			pos - xvec - yvec - zvec,
		}
	end,
	[Enum.PartType.Wedge] = function(part: Part, mergeDistance: number?)
		local mergeDistance = mergeDistance or 0.06
		local pos = part.Position
		local cf = part.CFrame
		local size = part.Size

		local s2 = size / 2

		local xvec = cf.XVector.Unit * s2.X
		local yvec = cf.YVector.Unit * s2.Y
		local zvec = cf.ZVector.Unit * s2.Z
		
		if s2.X <= mergeDistance then
			return {
				pos + zvec + yvec, -- backwards, up
				pos + zvec - yvec, -- backwards, down
				pos - zvec - yvec -- forwards, down
			}
		elseif s2.Y <= mergeDistance then
			return {
				pos + xvec + zvec, -- backwards, right
				pos - xvec + zvec, -- backwards, left
				pos + xvec - zvec, -- forwards, right
				pos - xvec - zvec -- forwards, left
			}
		elseif s2.Z <= mergeDistance then
			return {
				pos + xvec + yvec, -- right, up
				pos - xvec + yvec, -- left, up
				pos + xvec - yvec, -- right, down
				pos - xvec - yvec -- left, down
			}
		end

		return {
			pos + xvec + zvec + yvec, -- backwards, right, up
			pos - xvec + zvec + yvec, -- backwards, left, up
			pos + xvec + zvec - yvec, -- backwards, right, down
			pos - xvec + zvec - yvec, -- backwards, left, down
			pos + xvec - zvec - yvec, -- forwards, right, down
			pos - xvec - zvec - yvec, -- forwards, left, down
		}
	end,
	[Enum.PartType.CornerWedge] = function(part: Part, mergeDistance: number?)
		local mergeDistance = mergeDistance or 0.06
		local pos = part.Position
		local cf = part.CFrame
		local size = part.Size

		local s2 = size / 2

		local xvec = cf.XVector.Unit * s2.X
		local yvec = cf.YVector.Unit * s2.Y
		local zvec = cf.ZVector.Unit * s2.Z
		
		if s2.X <= mergeDistance then
			return {
				pos - zvec + yvec, -- forwards, up
				pos - zvec - yvec, -- forwards, down
				pos + zvec - yvec -- backwards, down
			}
		elseif s2.Y <= mergeDistance then
			return {
				pos + xvec - zvec, -- forwards, right
				pos - xvec - zvec, -- forwards, left
				pos + xvec + zvec, -- backwards, right
				pos - xvec + zvec -- backwards, left
			}
		elseif s2.Z <= mergeDistance then
			return {
				pos + xvec + yvec, -- right, up
				pos + xvec - yvec, -- right, down
				pos - xvec - yvec -- left, down
			}
		end

		return {
			pos + xvec - zvec + yvec, -- forwards, right, up
			pos + xvec - zvec - yvec, -- forwards, right, down
			pos - xvec - zvec - yvec, -- forwards, left, down
			pos + xvec + zvec - yvec, -- backwards, right, down
			pos - xvec + zvec - yvec, -- backwards, left, down
		}
	end,
	[Enum.PartType.Cylinder] = function(part: Part, mergeDistance: number?)
		local mergeDistance = mergeDistance or 0.06
		local pos = part.Position
		local cf = part.CFrame
		local size = part.ExtentsSize

		-- get height and radius
		local height = size.X
		local radius = size.Y / 2

		local topCenter = pos + cf.XVector * height / 2
		local bottomCenter = pos - cf.XVector * height / 2 

		-- how detailed?
		local numVertices = 16
		local vertices = {}
		
		if height <= mergeDistance then
			topCenter = pos
		end

		-- top circle
		for i = 0, numVertices - 1 do
			local angle = (i / numVertices) * math.pi * 2
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			local topVertex = (topCenter+(cf.XVector*(i%2)*0.05)) + cf.ZVector * z + cf.YVector * x
			table.insert(vertices, topVertex)
		end
		

		-- bottom circle
		if height > mergeDistance then
			for i = 0, numVertices - 1 do
				local angle = (i / numVertices) * math.pi * 2
				local x = math.cos(angle) * radius
				local z = math.sin(angle) * radius
				local bottomVertex = bottomCenter + cf.ZVector * z + cf.YVector * x
				table.insert(vertices, bottomVertex)
			end
		end

		return vertices
	end,
	[Enum.PartType.Ball] = function(part: Part)
		local pos = part.Position
		local cf = part.CFrame
		local size = part.ExtentsSize

		local radius = size.X / 2

		local numSlices = 8
		local numStacks = 8

		local vertices = {}

		for stack = 0, numStacks do
			local phi = math.pi * (stack / numStacks)
			local y = math.cos(phi) * radius
			local ringRadius = math.sin(phi) * radius

			for slice = 0, numSlices - 1 do
				local theta = 2 * math.pi * (slice / numSlices)
				local x = math.cos(theta) * ringRadius
				local z = math.sin(theta) * ringRadius

				local vertex = pos + cf.XVector * x + cf.YVector * y + cf.ZVector * z
				table.insert(vertices, vertex)
			end
		end

		return vertices
	end,
})

return partTypeVerts
