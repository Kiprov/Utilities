--[[Preload Asset Service
Made by Kip.
I decided to make a service module, that preloads assets on exploits.
]]--
local preloadService = {}
local preloads = {
SFX = {},
Models = {},
}
local shouldSpawn = false
local directory

function preloadService:SetDirectory(directoryName)
if not isFolder(directoryName) then
makeFolder(directoryName)
end
directory = directoryName
end

function preloadService:SetSpawn(bool)
shouldSpawn = bool or false
end

function GetGitSound(new,GithubSnd,SoundName,FileFormat)
	local url=GithubSnd
	local FileFormat = FileFormat or ".mp3"
	if not isfile(directory.."/"..SoundName..FileFormat) then
		writefile(directory.."/"..SoundName..FileFormat, game:HttpGet(url))
	end
	local sound=new or Instance.new("Sound")
	sound.SoundId=getcustomasset(directory.."/"..SoundName..FileFormat)
	return sound
end

function GetGitModel(GitRBXM,ModelName,FileFormat)
local url=GitRBXM
local FileFormat = FileFormat or ".rbxm"
if not isfile(directory.."/"..ModelName..FileFormat) then
writefile(directory.."/"..ModelName..FileFormat,game:HttpGet(url))
end
local model=getcustomasset(directory.."/"..ModelName..FileFormat)
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
if preloads.SFX[name] then
tempAsset = preloads.SFX[name]
if asset and asset:IsA("Sound") then
asset.SoundId = tempAsset.SoundId
end
return tempAsset
else
if url == nil then return end
if not asset:IsA("Sound") then return end
if shouldSpawn then
spawn(function()
tempAsset = GetGitSound(asset,url,name,format)
end)
else
tempAsset = GetGitSound(asset,url,name,format)
end
preloads.SFX[name] = tempAsset
return tempAsset
end
elseif assetType == "Model" then
-- GitHub RBXM Model
if preloads.Models[name] then
tempAsset = preloads.Models[name]
if asset then
asset = tempAsset
end
return tempAsset
else
if url == nil then return end
if shouldSpawn then
spawn(function()
tempAsset = GetGitModel(url,name,format)
end)
else
tempAsset = GetGitModel(url,name,format)
end
preloads.Models[name] = tempAsset
return tempAsset
end
end
end
return preloadService