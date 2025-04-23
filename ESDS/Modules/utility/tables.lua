--!strict

local RANDOM = Random.new(DateTime.now().UnixTimestampMillis)

-- finds and removes a value from a table
-- returns true/false based on if it actually got removed or not
local function removeFromTable(tbl:{any},inst:any):boolean
	local i = table.find(tbl,inst)
	if i then
		table.remove(tbl,i)
		return true
	end
	return false
end

-- runs a function on every value of a table
-- if loopThrough is true, will run on every descendant of a table until it returns false
local function runOnTables(func:(any, any, any) -> boolean?,loopThrough:boolean?,...)
	for _,tbl in ipairs({...}) do
		if loopThrough then
			for ix,val in pairs(tbl) do
				if func(ix,val,tbl) == false then break end
			end
		else
			func(tbl)
		end
	end
end

-- shuffles the table to random indinces
-- usually makes it not so predictable and stuff like that
local function shuffleTable<T>(tb:{T})
	local temptbl:{T} = {}
	for i = 1,#tb do
		local ix = RANDOM:NextInteger(1,#tb)
		local rem = table.remove(tb,ix)
		if not rem then
			break
		end
		table.insert(temptbl,rem)
	end
	for _,val in ipairs(temptbl) do
		table.insert(tb,val)
	end
	return tb
end

-- gets random value in list
local function getRandomInList<T>(list:{T})
	return list[RANDOM:NextInteger(1,#list)]
end

-- gets dictionaryLength
local function getDictionaryLength(dictionary)
	local amnt = 0
	for _ in pairs(dictionary) do
		amnt += 1
	end
	return amnt
end

return {
	removeFromTable = removeFromTable,
	runOnTables = runOnTables,
	shuffleTable = shuffleTable,
	
	getRandomInList = getRandomInList,
	
	getDictionaryLength = getDictionaryLength
}
