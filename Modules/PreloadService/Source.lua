--[[
Preload Asset Service

A service module that helps to preload assets for exploits.
]]--
local preloadService = {}
preloadService.__index = preloadService

function preloadService:SetDirectory(directoryName)
assert(self.Service == true,"Please create a new PreloadService object, before using functions.")
if not isfolder(directoryName) then
makefolder(directoryName)
end
self.Directory = directoryName
end

function preloadService:SetSpawn(bool)
assert(self.Service == true,"Please create a new PreloadService object, before using functions.")
self.shouldSpawn = bool or false
end

function preloadService:GetGitSound(new,GithubSnd,SoundName,FileFormat)
	assert(self.Service == true,"Please create a new PreloadService object, before using functions.")
	local url=GithubSnd
	local FileFormat = FileFormat or ".mp3"
	if not isfile(self.Directory.."/"..SoundName..FileFormat) then
		writefile(self.Directory.."/"..SoundName..FileFormat, game:HttpGet(url))
	end
	local sound=new or Instance.new("Sound")
	sound.SoundId=getcustomasset(self.Directory.."/"..SoundName..FileFormat,true)
	return sound
end

function preloadService:GetGitModel(GitRBXM,ModelName,FileFormat)
assert(self.Service == true,"Please create a new PreloadService object, before using functions.")
local url=GitRBXM
local FileFormat = FileFormat or ".rbxm"
if not isfile(self.Directory.."/"..ModelName..FileFormat) then
writefile(self.Directory.."/"..ModelName..FileFormat,game:HttpGet(url))
end
local model=game:GetObjects(getcustomasset(self.Directory.."/"..ModelName..FileFormat,true))[1]
return model
end

function preloadService:Preload(assetType,...)
assert(self.Service == true,"Please create a new PreloadService object, before using functions.")
local args = {...}
local url = args[1] or nil
local name = args[2] or nil
local asset = args[3] or nil
local format = args[4] or nil
local tempAsset
if assetType == "SFX" then
-- GitHub Sound
if url == nil then return end
if asset ~= nil then
if not asset:IsA("Sound") then return end
end
if self.shouldSpawn then
spawn(function()
tempAsset = self:GetGitSound(asset,url,name,format)
end)
else
tempAsset = self:GetGitSound(asset,url,name,format)
end
return tempAsset
elseif assetType == "Model" then
-- GitHub RBXM Model
if url == nil then return end
if self.shouldSpawn then
spawn(function()
tempAsset = self:GetGitModel(url,name,format)
end)
else
tempAsset = self:GetGitModel(url,name,format)
end
return tempAsset
end
end
function preloadService.new()
local self = {}
self.Service = true
self.Directory = "null"
self.shouldSpawn = false
setmetatable(self,preloadService)
return self
end
return preloadService


