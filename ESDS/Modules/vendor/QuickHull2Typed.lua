--!strict
--[[
	QuickHull2 but more optimized and now typed
	
	Script originally made by: @MrChickenRocket
	Converted to typed by: @jnprge
--]]

local module = {}

local UNASSIGNED = -2
local INSIDE = -1
local EPSILON = 0.0001
local NaN = 0/0
--local counter = 0

--[[ TYPES ]]--
type Points = { [number]: Vector3 }
type Face = {
	Vertex0: number,
	Vertex1: number,
	Vertex2: number,

	Opposite0: number,
	Opposite1: number,
	Opposite2: number,

	Normal: Vector3
}
type PointFace = {
	Point: number,
	Face: number,
	Distance: number
}
type HorizonEdge = {
	Face: number,
	Edge0: number,
	Edge1: number
}
type HullFaces = { [number]: Face }
type OpenSet = { [number]: PointFace }
type LitFaces = { number }
type Horizon = { [number]: HorizonEdge }

--[[ FUNCTIONS ]]--

-- more accurate cross function(?)
local function Cross(a: Vector3, b: Vector3): Vector3
	return Vector3.new(
		a.Y*b.Z - a.Z*b.Y,
		a.Z*b.X - a.X*b.Z,
		a.X*b.Y - a.Y*b.X)
end

-- more accurate dot function(?)
local function Dot(a: Vector3, b: Vector3): number
	return a.X*b.X + a.Y*b.Y + a.Z*b.Z
end

local function PointFaceDistance(point: Vector3, pointOnFace: Vector3, face: Face): number
	return Dot(face.Normal, point - pointOnFace)
end

local function Normal(v0: Vector3, v1: Vector3, v2: Vector3): Vector3
	return Cross(v1 - v0, v2 - v0).Unit
end

local function AreCoincident(a:Vector3, b:Vector3): boolean
	return (a - b).Magnitude <= EPSILON
end

local function AreCollinear(a: Vector3, b: Vector3, c: Vector3): boolean
	return Cross(c - a, c - b).Magnitude <= EPSILON
end

local function AreCoplanar(a: Vector3, b: Vector3, c: Vector3, d: Vector3): boolean
	local n1 = Cross(c - a, c - b)
	local n2 = Cross(d - a, d - b)

	local m1 = n1.Magnitude
	local m2 = n2.Magnitude

	return m1 <= EPSILON
		or m2 <= EPSILON
		or AreCollinear(Vector3.zero, (1.0 / m1) * n1, (1.0 / m2) * n2)
end

local function Face(
	v0: number, v1: number, v2: number,
	o0: number, o1: number, o2: number,
	normal: Vector3
): Face
	return {
		Vertex0 = v0,
		Vertex1 = v1,
		Vertex2 = v2,
		Opposite0 = o0,
		Opposite1 = o1,
		Opposite2 = o2,
		Normal = normal,
	}
end

local function PointFace(p: number, f: number, d: number): PointFace
	return {
		Point = p,
		Face = f,
		Distance = d
	}
end

local function HorizonEdge(f: number, e0: number, e1: number): HorizonEdge
	return {
		Face = f, 
		Edge0 = e0,
		Edge1 = e1
	}
end

local function HasEdge(f: Face, e0: number, e1: number): boolean
	return (f.Vertex0 == e0 and f.Vertex1 == e1)
		or (f.Vertex1 == e0 and f.Vertex2 == e1)
		or (f.Vertex2 == e0 and f.Vertex0 == e1)
end

--[[
	Reassign points based on the new faces added by ConstructCone().

	Only points that were previous assigned to a removed face need to
	be updated, so check litFaces while looping through the open set.

	There is a potential optimization here: there's no reason to loop
	through the entire openSet here. If each face had it's own
	openSet, we could just loop through the openSets in the removed
	faces. That would make the loop here shorter.

	However, to do that, we would have to juggle A LOT more List<T>'s,
	and we would need an object pool to manage them all without
	generating a whole bunch of garbage. I don't think it's worth
	doing that to make this loop shorter, a straight for-loop through
	a list is pretty darn fast. Still, it might be worth trying
--]]
local function ReassignPoints(
	points: { [number]: Vector3 },

	litFaces: LitFaces,
	faces: HullFaces,
	openSet: OpenSet,
	openSetTail: number
): number
	local i = 0
	while i < openSetTail do
		i+=1

		--print("looking up", i-1)
		local fp = openSet[i]

		if table.find(litFaces, fp.Face) then
			local assigned = false
			local point = points[fp.Point]

			for kvpKey,kvpValue in pairs(faces) do
				local fi = kvpKey
				local face = kvpValue

				local dist = PointFaceDistance(
					point,
					points[face.Vertex0],
					face
				)

				if dist > EPSILON then
					assigned = true

					fp.Face = fi
					fp.Distance = dist

					openSet[i] = fp

					--print("Assign ", i-1)
					break
				end
			end

			if not assigned then
				--[[
					If point hasn't been assigned, then it's inside the
					convex hull. Swap it with openSetTail, and decrement
					openSetTail. We also have to decrement i, because
					there's now a new thing in openSet[i], so we need i
					to remain the same the next iteration of the loop.
				--]]
				fp.Face = INSIDE
				fp.Distance = NaN

				openSet[i] = openSet[openSetTail]
				openSet[openSetTail] = fp

				--print("Assign B", i-1)

				i-=1
				openSetTail-=1
			end
		end
	end
	
	return openSetTail
end

-- Recursively search to find the horizon or lit set.
local function SearchHorizon(
	points: Points,
	point: Vector3,
	prevFaceIndex: number,
	faceCount: number,
	face: Face,
	
	faces: HullFaces,
	horizon: Horizon,
	litFaces: LitFaces
)
	table.insert(litFaces,faceCount)

    --[[
	    Use prevFaceIndex to determine what the next face to search will
	    be, and what edges we need to cross to get there. It's important
	    that the search proceeds in counter-clockwise order from the
	    previous face.
    --]]
	local nextFaceIndex0 = 0
	local nextFaceIndex1 = 0
	local edge0 = 0
	local edge1 = 0
	local edge2 = 0

	if prevFaceIndex == face.Opposite0 then
		nextFaceIndex0 = face.Opposite1
		nextFaceIndex1 = face.Opposite2

		edge0 = face.Vertex2
		edge1 = face.Vertex0
		edge2 = face.Vertex1
	elseif prevFaceIndex == face.Opposite1 then
		nextFaceIndex0 = face.Opposite2;
		nextFaceIndex1 = face.Opposite0;

		edge0 = face.Vertex0;
		edge1 = face.Vertex1;
		edge2 = face.Vertex2;
	else
		nextFaceIndex0 = face.Opposite0
		nextFaceIndex1 = face.Opposite1

		edge0 = face.Vertex1
		edge1 = face.Vertex2
		edge2 = face.Vertex0
	end

	if not table.find(litFaces, nextFaceIndex0) then
		local oppositeFace = faces[nextFaceIndex0]

		local dist = PointFaceDistance(
			point,
			points[oppositeFace.Vertex0],
			oppositeFace
		)

		if dist <= 0 then
			table.insert(horizon,HorizonEdge(nextFaceIndex0, edge0, edge1))
		else
			SearchHorizon(points, point, faceCount, nextFaceIndex0, oppositeFace, faces, horizon, litFaces)
		end
	end

	if not table.find(litFaces, nextFaceIndex1) then
		local oppositeFace = faces[nextFaceIndex1]

		local dist = PointFaceDistance(
			point,
			points[oppositeFace.Vertex0],
			oppositeFace
		)

		if dist <= 0 then
			table.insert(horizon,HorizonEdge(nextFaceIndex1, edge1, edge2))
		else 
			SearchHorizon(points, point, faceCount, nextFaceIndex1, oppositeFace, faces, horizon, litFaces)
		end
	end
end

--[[
	Start the search for the horizon.
	
	The search is a DFS search that searches neighboring triangles in
	a counter-clockwise fashion. When it find a neighbor which is not
	lit, that edge will be a line on the horizon. If the search always
	proceeds counter-clockwise, the edges of the horizon will be found
	in counter-clockwise order.
	
	The heart of the search can be found in the recursive
	SearchHorizon() method, but the the first iteration of the search
	is special, because it has to visit three neighbors (all the
	neighbors of the initial triangle), while the rest of the search
	only has to visit two (because one of them has already been
	visited, the one you came from).
--]]
local function FindHorizon(
	points: Points,
	point: Vector3,
	fi: number,
	face: Face,
	
	faces: HullFaces
): (Horizon, LitFaces)
	local litFaces: LitFaces = {}
	local horizon: Horizon = {}

	table.insert(litFaces, fi)

	-- For the rest of the recursive search calls, we first check if the
	-- triangle has already been visited and is part of litFaces.
	-- However, in this first call we can skip that because we know it
	-- can't possibly have been visited yet, since the only thing in
	-- litFaces is the current triangle.

	local oppositeFace = faces[face.Opposite0]

	local dist = PointFaceDistance(
		point,
		points[oppositeFace.Vertex0],
		oppositeFace)

	if dist <= 0 then
		--horizon.Add(HorizonEdge(face.Opposite0,face.Vertex1,face.Vertex2))
		table.insert(horizon,HorizonEdge(face.Opposite0,face.Vertex1,face.Vertex2))
	else
		SearchHorizon(points, point, fi, face.Opposite0, oppositeFace, faces, horizon, litFaces)
	end


	if not table.find(litFaces, face.Opposite1) then
		local oppositeFace = faces[face.Opposite1]

		local dist = PointFaceDistance(
			point,
			points[oppositeFace.Vertex0],
			oppositeFace);

		if dist <= 0 then
			table.insert(horizon, HorizonEdge(face.Opposite1,face.Vertex2, face.Vertex0))
		else
			SearchHorizon(points, point, fi, face.Opposite1, oppositeFace, faces, horizon, litFaces)
		end
	end

	if not table.find(litFaces, face.Opposite2) then
		local oppositeFace = faces[face.Opposite2]

		local dist = PointFaceDistance(point, points[oppositeFace.Vertex0], oppositeFace)

		if dist <= 0 then
			table.insert(horizon, HorizonEdge(face.Opposite2, face.Vertex0, face.Vertex1))
		else
			SearchHorizon(points, point, fi, face.Opposite2, oppositeFace, faces, horizon, litFaces)
		end
	end
	
	return horizon, litFaces
end


--[[
	Find four points in the point cloud that are not coplanar for the
	seed hull
--]]	
local function FindInitialHullIndices(points: Points): (number?, number?, number?, number?)
	local count = #points

	for i0 = 1, count - 2 do
		for i1 = i0 + 1, count - 1 do
			local p0 = points[i0]
			local p1 = points[i1]

			if AreCoincident(p0, p1) then
				continue
			end

			for i2 = i1 + 1, count do
				local p2 = points[i2]

				if AreCollinear(p0, p1, p2) then
					continue
				end

				for i3 = i2 + 1, count + 1 do
					local p3 = points[i3]
					
					if not p3 then
						error("Can't generate hull, points are coplanar")
					end
					
					if AreCoplanar(p0, p1, p2, p3) then 
						continue
					end
					return i0, i1, i2, i3
				end
			end
		end
	end
	error("Can't generate hull, points are coplanar")
end

--[[
    Find points suitable for use as the seed hull. Some varieties of
    this algorithm pick extreme points here, but I'm not convinced
    you gain all that much from that. Currently what it does is just
    find the first four points that are not coplanar.
--]]
local function GenerateInitialHull(
	points: Points,
	faces: HullFaces,
	openSet: OpenSet
): (number?, number?)
	local b0, b1, b2, b3 = FindInitialHullIndices(points)
	if not b0 or not b1 or not b2 or not b3 then
		return
	end

	local v0 = points[b0]
	local v1 = points[b1]
	local v2 = points[b2]
	local v3 = points[b3]

	local above = Dot(v3 - v1, Cross(v1 - v0, v2 - v0)) > 0

	--[[
		Create the faces of the seed hull. You need to draw a diagram
		here, otherwise it's impossible to know what's going on :)

		Basically: there are two different possible start-tetrahedrons,
		depending on whether the fourth point is above or below the base
		triangle. If you draw a tetrahedron with these coordinates (in a
		right-handed coordinate-system):

		b0 = (0,0,0)
		b1 = (1,0,0)
		b2 = (0,1,0)
		b3 = (0,0,1)

		you can see the first case (set b3 = (0,0,-1) for the second
		case). The faces are added with the proper references to the
		faces opposite each vertex
	--]]


	--Bump the indices (3,1,2 etc by 1, because lua 1 array)
	local faceCount = 4 -- stays on 4, its the number of faces in the array: correct elsewhere!
	if above then
		table.insert(faces,Face(b0, b2, b1, 3+1, 1+1, 2+1, Normal(points[b0], points[b2], points[b1])))
		table.insert(faces,Face(b0, b1, b3, 3+1, 2+1, 0+1, Normal(points[b0], points[b1], points[b3])))
		table.insert(faces,Face(b0, b3, b2, 3+1, 0+1, 1+1, Normal(points[b0], points[b3], points[b2])))
		table.insert(faces,Face(b1, b2, b3, 2+1, 1+1, 0+1, Normal(points[b1], points[b2], points[b3])))
	else
		table.insert(faces,Face(b0, b1, b2, 3+1, 2+1, 1+1, Normal(points[b0], points[b1], points[b2])))
		table.insert(faces,Face(b0, b3, b1, 3+1, 0+1, 2+1, Normal(points[b0], points[b3], points[b1])))
		table.insert(faces,Face(b0, b2, b3, 3+1, 1+1, 0+1, Normal(points[b0], points[b2], points[b3])))
		table.insert(faces,Face(b1, b3, b2, 2+1, 0+1, 1+1, Normal(points[b1], points[b3], points[b2])))
	end

	--[[
		Create the openSet. Add all points except the points of the seed hull.
	--]]
	
	for i = 1,#points do
		if i == b0 or i == b1 or i == b2 or i == b3 then
			continue
		end

		table.insert(openSet, PointFace(i, UNASSIGNED, 0))
	end

	--[[
		Add the seed hull verts to the tail of the list.
	--]]

	table.insert(openSet,PointFace(b0, INSIDE, NaN))
	table.insert(openSet,PointFace(b1, INSIDE, NaN))
	table.insert(openSet,PointFace(b2, INSIDE, NaN))
	table.insert(openSet,PointFace(b3, INSIDE, NaN))

	--[[
		Set the openSetTail value. Last item in the array is
		openSet.Count - 1, but four of the points (the verts of the seed
		hull) are part of the closed set, so move openSetTail to just
		before those.
		
		(last is now #openSet !)
	--]]
	local openSetTail = #openSet - 4

	--[[
		Assign all points of the open set. This does basically the same
		thing as ReassignPoints()
	--]]

	local i = 0
	while i < openSetTail do
		i += 1

		local assigned = false
		local fp = openSet[i]

		for j = 1, 4 do
			local face = faces[j]

			local dist = PointFaceDistance(points[fp.Point], points[face.Vertex0], face);

			if dist > 0 then
				fp.Face = j
				fp.Distance = dist
				openSet[i] = fp

				assigned = true
				break
			end
		end

		if not assigned then
			-- Point is inside
			fp.Face = INSIDE
			fp.Distance = NaN

			--[[
				Point is inside seed hull: swap point with tail, and move
				openSetTail back. We also have to decrement i, because
				there's a new item at openSet[i], and we need to process
				it next iteration
			--]]
			openSet[i] = openSet[openSetTail]
			openSet[openSetTail] = fp

			openSetTail -= 1
			i -= 1
		end
	end
	
	return faceCount,openSetTail
end

--[[
	Remove all lit faces and construct new faces from the horizon in a
	"cone-like" fashion.
	
	This is a relatively straight-forward procedure, given that the
	horizon is handed to it in already sorted counter-clockwise. The
	neighbors of the new faces are easy to find: they're the previous
	and next faces to be constructed in the cone, as well as the face
	on the other side of the horizon. We also have to update the face
	on the other side of the horizon to reflect it's new neighbor from
	the cone.
--]]
local function ConstructCone(
	points: Points,
	farthestPoint: number,
	horizon: Horizon,
	litFaces: LitFaces,
	
	faceCount: number,
	faces: HullFaces
)
	for _,fi in ipairs(litFaces) do
		faces[fi] = nil
	end

	local firstNewFace = faceCount --Facecount is # of faces, make sure to +1 before using it to write/read
	
	local horizonLen = #horizon
	
	for i,edge in ipairs(horizon) do
		-- Vertices of the new face, the farthest point as well as the
		-- edge on the horizon. Horizon edge is CCW, so the triangle
		-- should be as well.
		local v0 = farthestPoint
		local v1 = edge.Edge0
		local v2 = edge.Edge1

		-- Opposite faces of the triangle. First, the edge on the other
		-- side of the horizon, then the next/prev faces on the new cone
		local o0 = edge.Face

		local o1  = if i == #horizon then (firstNewFace + 1) else (firstNewFace + i + 1)

		local o2 = if i == 1 then (firstNewFace + horizonLen) else (firstNewFace + i - 1)

		local fi = faceCount + 1
		faceCount+=1

		faces[fi] = Face(
			v0, v1, v2,
			o0, o1, o2,
			Normal(points[v0], points[v1], points[v2]))

		local horizonFace = faces[edge.Face]

		if horizonFace.Vertex0 == v1 then
			horizonFace.Opposite1 = fi
		elseif horizonFace.Vertex1 == v1 then
			horizonFace.Opposite2 = fi
		else 
			horizonFace.Opposite0 = fi
		end

		faces[edge.Face] = horizonFace
	end
	
	return faceCount
end

--[[
	Grow the hull. This method takes the current hull, and expands it
	to encompass the point in openSet with the point furthest away
	from its face.
]]--
local function GrowHull(
	points: Points,
	faces: HullFaces,
	openSet: OpenSet,
	
	faceCount: number,
	openSetTail: number
): (number, number)
	--print("GROW HULL", counter)
	--counter+=1

	-- Find farthest point and first lit face.
	local farthestPoint = 1

	local dist = openSet[1].Distance

	for i = 2, openSetTail do
		if openSet[i].Distance > dist then
			farthestPoint = i
			dist = openSet[i].Distance
		end
	end

	-- Use lit face to find horizon and the rest of the lit
	-- faces.
	local horizon,litFaces = FindHorizon(
		points,
		points[openSet[farthestPoint].Point],
		openSet[farthestPoint].Face,
		faces[openSet[farthestPoint].Face],
		
		faces
	)

	--Construct new cone from horizon
	faceCount = ConstructCone(points, openSet[farthestPoint].Point, horizon, litFaces, faceCount, faces)

	--Reassign points
	openSetTail = ReassignPoints(points, litFaces, faces, openSet, openSetTail)
	
	return faceCount,openSetTail
end

export type Tri = {Vector3}

-- generates hull for 3 or more points
local function generateHull(points: Points):{Tri}?
	if #points <= 3 then
		return -- points would automatically be coplanar if there were only 3 verts
	end

	--faceCount = 0
	--openSetTail = -1
	
	local faces: HullFaces = {}
	local openSet: OpenSet = {}

	local faceCount:number?,openSetTail:number? = GenerateInitialHull(points,faces,openSet)
	if not faceCount or not openSetTail then
		return -- bad hull, points are coplanar
	end

	while openSetTail >= 1 do
		faceCount,openSetTail = GrowHull(points,faces,openSet,faceCount,openSetTail)
	end

	--unroll
	local tris:{Tri} = {}
	for key,value in pairs(faces) do
		table.insert(tris, {
			points[value.Vertex0],
			points[value.Vertex1],
			points[value.Vertex2]
		})
	end
	return tris
end

return {
	generateHull = generateHull,
	arePointsCoplanar = AreCoplanar
}
