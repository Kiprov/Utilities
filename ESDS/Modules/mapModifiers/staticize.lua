--!strict

--[[ IMPORTS ]]--

local maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/vendor/Maid.lua"))()
local tblUtil = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/tables.lua"))()

--[[ VARIABLES ]]--

local lastProps = {}
local function nothingBurger() end

--[[ FUNCTIONS ]]--

local function temporaryStaticize(inst:Instance,prop:string,val:any,onNewValue:((any)->nil)?,forceEnabled:boolean?):()->()
	local tb = lastProps[inst]
	if not tb then
		tb = {
			doNotEditFurther = false,
			props = {},
			propsMaids = {},
			didPropChangeTable = {}
		}
	end

	if tb.doNotEditFurther then return nothingBurger end
	tb.doNotEditFurther = forceEnabled
	if tb.propsMaids[prop] then
		tb.propsMaids[prop]:Destroy()
	end

	local lastval = tb.props[prop] or (inst :: any)[prop]

	tb.props[prop] = lastval;
	(inst :: any)[prop] = val

	local alive = true
	local m = maid.new()
	m:GiveTask(function()
		alive = false
		(inst :: any)[prop] = lastval
		tb.doNotEditFurther = false
	end)
	m:GiveTask(inst:GetPropertyChangedSignal(prop):Connect(function()
		if tb.didPropChangeTable[prop] then tb.didPropChangeTable[prop] = false return end
		tb.didPropChangeTable[prop] = true
		lastval = (inst :: any)[prop]
		if onNewValue then
			task.spawn(onNewValue,lastval)
		end
		task.defer(function()
			(inst :: any)[prop] = val
		end)
	end))
	m:GiveTask(inst.Destroying:Connect(function()
		m:Destroy()
	end))
	tb.propsMaids[prop] = m

	return function()
		if not alive then return end
		m:Destroy()
		tb.propsMaids[prop] = nil
		if tblUtil.getDictionaryLength(tb.propsMaids) == 0 then
			lastProps[inst] = nil
		end
	end
end

--[[ RETURN ]]--
return temporaryStaticize
