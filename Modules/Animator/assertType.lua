--!optimize 2
--!native
-- ceat_ceat

--[[
	assetType - type checkers
]]

local typeof = typeof
local ipairs = ipairs
local error = error
local tableConcat = table.concat

local function assertType(methodName, value, types, argNum)
	local t = typeof(value)
	for _, expectedType in types do
		if t == expectedType then
			return
		end
	end
	error(`invalid argument #{argNum} to '{methodName}' ({tableConcat(types, " or ")} expected, got {t})`)
end

local function assertClass(methodName, instance, classes, argNum)
	assertType(methodName, instance, {"Instance"}, argNum)
	if type(classes) == "string" then
		classes = {classes}
	end
	local class = instance.ClassName
	for _, className in classes do
		if class == className then
			return
		end
	end
	error(`invalid argument #{argNum} to '{methodName}' ({table.concat(classes, ", or ")} expected, got {class})`)
end

return {
	assertType = assertType,
	assertClass = assertClass
}