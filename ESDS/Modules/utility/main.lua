--!strict

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local MAXCHAR = 0xFFFFF
local RANDOM = Random.new(DateTime.now().UnixTimestampMillis)

--local specials = {
--	"œ","∑","´","®","†","¥",
--	"¨","ˆ","ø","“","å","ß",
--	"∂","ƒ","©","˙","∆","˚",
--	"¬","Ω","≈","Ç","√","∫",
--	"˜","µ","≤","≥","`","¡",
--	"™","£","¢","∞","§","¶",
--	"•","ª","º","–","≠","Œ",
--	"„","´","‰","ˇ","Á","¨",
--	"ˆ","Ø","∏","Å","Í","Î",
--	"Ï","˝","Ó","Ô","","Ú",
--	"Æ","¸","˛","Ç","◊","ı",
--	"˜","Â","¯","˘","¿","`",
--	"—","±","⁄","€","‹","›",
--	"ﬁ","ﬂ","‡","·","°","‚"
--}
--local specialsLen = #specials

-- generates a random string of text that is [length] length
local function genRandomText(length:number):string
	local txt = ""
	for i = 1,length do
		txt ..= utf8.char(RANDOM:NextInteger(1,MAXCHAR))
	end
	return txt
end

-- generates a random GUID without any dashes
local function genRandomGUID():string
	local length = math.random(16,48)
	local name = HttpService:GenerateGUID(false):gsub("-","")
	if length > 32 then
		name ..= HttpService:GenerateGUID(false):gsub("-","")
	end
	return string.sub(name,1,length)
end

-- converts string to base64
-- origin: https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
local function tobase64(data:string):string
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

local function _getExtentsSizeInternal(cframe: CFrame, size: Vector3, extentsOrientation: CFrame?): (Vector3, Vector3)
	local extentsOrientation = extentsOrientation or CFrame.identity
	local cframe = extentsOrientation:ToObjectSpace(cframe)

	local sx: number, sy: number, sz: number = size.X, size.Y, size.Z

	local x: number, y: number, z: number,
	R00: number, R01: number, R02: number,
	R10: number, R11: number, R12: number,
	R20: number, R21: number, R22: number = cframe:GetComponents()

	local wsx: number = 0.5 * (math.abs(R00) * sx + math.abs(R01) * sy + math.abs(R02) * sz)
	local wsy: number = 0.5 * (math.abs(R10) * sx + math.abs(R11) * sy + math.abs(R12) * sz)
	local wsz: number = 0.5 * (math.abs(R20) * sx + math.abs(R21) * sy + math.abs(R22) * sz)

	return Vector3.new(x + wsx, y + wsy, z + wsz), Vector3.new(x - wsx, y - wsy, z - wsz)
end

-- rotates a part's
-- https://devforum.roblox.com/t/getextentssize-of-one-part-without-model/404945/7
local function getExtentsSize(cframe: CFrame, size: Vector3, extentsOrientation: CFrame?): Vector3
	local vecA,vecB = _getExtentsSizeInternal(cframe,size,extentsOrientation)

	return vecA - vecB
end

-- gets the bounding box of all parts
local function getBoundingBox(parts: {BasePart}, orientation: CFrame?)
	local orientation = orientation or CFrame.identity

	local inf = math.huge
	local minx, miny, minz = inf, inf, inf
	local maxx, maxy, maxz = -inf, -inf, -inf

	for _, obj in ipairs(parts) do
		if not obj:IsA("BasePart") then
			continue
		end
		local vecA,vecB = _getExtentsSizeInternal(orientation:ToObjectSpace(obj.CFrame),obj.Size)

		minx,miny,minz = math.min(minx,vecB.X),math.min(miny,vecB.Y),math.min(minz,vecB.Z)
		maxx,maxy,maxz = math.max(maxx,vecA.X),math.max(maxy,vecA.Y),math.max(maxz,vecA.Z)
	end

	local omin, omax = Vector3.new(minx, miny, minz), Vector3.new(maxx, maxy, maxz)

	return orientation.Rotation + orientation:PointToWorldSpace((omax+omin)/2), omax-omin
end

-- generates and returns vectors used for seeds and stuff like that
local function getNewRandomVectorSeeds(amnt:number?): (...Vector3)
	local amnt = math.max(amnt or 1,1)
	local tb = table.create(amnt)
	for i = 1,amnt do
		table.insert(tb,Vector3.new(RANDOM:NextNumber(-2^16,2^16),RANDOM:NextNumber(-2^16,2^16),0))
	end
	return table.unpack(tb)
end

-- 
local function playTween(obj:Instance,info:TweenInfo,props:{[string]:any},ended:(()->nil)?)
	local tw = TweenService:Create(obj,info,props)
	tw:Play()
	tw.Completed:Once(function()
		if ended then
			ended()
		end
		tw:Destroy()
		tw = nil
	end)
end

return {
	genRandomText = genRandomText,
	genRandomGUID = genRandomGUID,
	
	tobase64 = tobase64,
	
	getNewRandomVectorSeeds = getNewRandomVectorSeeds,
	
	getExtentsSize = getExtentsSize,
	getBoundingBox = getBoundingBox,
	
	playTween = playTween
}
