--[[
Preload Asset Service

A service module that helps to preload assets for exploits.
]]--
local preloadService = {}
preloadService.__index = preloadService

function preloadService:SetDirectory(directoryName)
if not isfolder(directoryName) then
makefolder(directoryName)
end
self.Directory = directoryName
end

function preloadService:SetSpawn(bool)
self.shouldSpawn = bool or false
end

function GetGitSound(new,GithubSnd,SoundName,FileFormat)
	local url=GithubSnd
	local FileFormat = FileFormat or ".mp3"
	if not isfile(self.Directory.."/"..SoundName..FileFormat) then
		writefile(self.Directory.."/"..SoundName..FileFormat, game:HttpGet(url))
	end
	local sound=new or Instance.new("Sound")
	sound.SoundId=getcustomasset(self.Directory.."/"..SoundName..FileFormat,true)
	return sound
end

function GetGitModel(GitRBXM,ModelName,FileFormat)
local url=GitRBXM
local FileFormat = FileFormat or ".rbxm"
if not isfile(self.Directory.."/"..ModelName..FileFormat) then
writefile(self.Directory.."/"..ModelName..FileFormat,game:HttpGet(url))
end
local model=game:GetObjects(getcustomasset(self.Directory.."/"..ModelName..FileFormat,true))[1]
return model
end

function preloadService:Preload(assetType,...)
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
tempAsset = GetGitSound(asset,url,name,format)
end)
else
tempAsset = GetGitSound(asset,url,name,format)
end
return tempAsset
elseif assetType == "Model" then
-- GitHub RBXM Model
if url == nil then return end
if self.shouldSpawn then
spawn(function()
tempAsset = GetGitModel(url,name,format)
end)
else
tempAsset = GetGitModel(url,name,format)
end
return tempAsset
end
end
function preloadService.new()
local self = {}
self.Directory = "null"
self.shouldSpawn = false
setmetatable(self,preloadService)
return self
end
return preloadService



