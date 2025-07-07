--!optimize 2
--!native
-- ceat_ceat

--[[
	easing - create a lookup table for TweenService GetValue calls in advance
	to mimize __index calls on instances + reintroduction of the Cubic reversed
	EasingDirections bug
]]

local TweenService = game:GetService("TweenService")

-- localize so it doesnt have to go thru as many scopes
local round = math.round
local getValue = TweenService.GetValue
local easingDirections = Enum.EasingDirection:GetEnumItems()

local easingFuncs = {}
-- pose easing style doesnt have all the regular easing styles for some reason whos fault is this
for _, poseEasingStyle in Enum.PoseEasingStyle:GetEnumItems() do
	-- handled separately
	if poseEasingStyle == Enum.PoseEasingStyle.Constant or poseEasingStyle == Enum.PoseEasingStyle.CubicV2 then
		continue
	end
	local success, easingStyle = pcall(function()
		return Enum.EasingStyle[poseEasingStyle.Name]
	end)
	if not success then
		warn(`unable to process {poseEasingStyle.Name} easing style, some animations may cause the animator to error`)
		continue
	end
	local directions = {}
	for _, direction in easingDirections do
		-- EasingDirection maps directly to PoseEasingDirection
		directions[direction.Value] = function(a)
			return getValue(TweenService, a, easingStyle, direction)
		end
	end
	easingFuncs[poseEasingStyle.Value] = directions
end

easingFuncs[Enum.PoseEasingStyle.Constant.Value] = {
	[0] = round,
	[1] = round,
	[2] = round,
}

local cubic = easingFuncs[Enum.PoseEasingStyle.Cubic.Value]
easingFuncs[Enum.PoseEasingStyle.CubicV2.Value] = table.clone(cubic) -- usual cubic is cubicv2
cubic[0], cubic[1] = cubic[1], cubic[0] -- add back the incorrectly reversed easing directions that cubic has
-- (cubicv2 was made to fix this)

local function getLerpAlpha(a, poseEasingStyleValue, poseEasingDirectionValue)
	return easingFuncs[poseEasingStyleValue][poseEasingDirectionValue](a)
end

return getLerpAlpha