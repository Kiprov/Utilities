--!strict

-- gets the distance between 2 points
local function getMagBetween(a: Vector3,b: Vector3): number
	return (a-b).Magnitude
end

-- gets the distance between 2 BaseParts/CFrames
local function getMagBetweenPos(a: BasePart|CFrame,b: BasePart|CFrame): number
	return getMagBetween(a.Position,b.Position)
end

-- returns a number interpolated between start and goal by the fraction alpha
-- (ripped from roblox's wiki)
local function lerp(start:number,goal:number,alpha:number)
	return start+(goal-start)*alpha
end

return {
	getMagBetween = getMagBetween,
	getMagBetweenPos = getMagBetweenPos,
	
	lerp = lerp
}
