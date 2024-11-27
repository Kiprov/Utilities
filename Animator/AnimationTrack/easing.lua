-- ceat_ceat
local TweenService = game:GetService("TweenService")

-- localize so it doesnt have to go thru as many scopes
local round = math.round
local getValue = TweenService.GetValue
local easingDirections = Enum.EasingDirection:GetEnumItems()

local easingFuncs = {}
-- pose easing style doesnt have all the regular easing styles for some reason whos fault is this
for _, poseEasingStyle in Enum.PoseEasingStyle:GetEnumItems() do
	if poseEasingStyle == Enum.PoseEasingStyle.Constant then
		continue
	elseif poseEasingStyle == Enum.PoseEasingStyle.CubicV2 then
		poseEasingStyle = Enum.PoseEasingStyle.Cubic
	end
	local directions = {}
	local easingStyle = Enum.EasingStyle[poseEasingStyle.Name]
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

local function getLerpAlpha(a, poseEasingStyleValue, poseEasingDirectionValue)
	return easingFuncs[poseEasingStyleValue][poseEasingDirectionValue](a)
end

return getLerpAlpha
