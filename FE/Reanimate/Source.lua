--[[
Multi-Reanimate made by Kip.
Idea originally taken from MelonScripter.
Please do not remove these credits, thanks.
]]--
if not MultiReanimate then
getgenv().MultiReanimate = {
	ScriptName = "Script",
	Framework = "Limb"
}
end
Services = setmetatable({}, {
    __index = function(self, name)
        local success, cache = pcall(function()
            return cloneref(game:GetService(name))
        end)
        if success then
            rawset(self, name, cache)
            return cache
        else
            error("Invalid Roblox Service: " .. tostring(name))
        end
    end
})
getgenv().LoadLibrary=function(lib)
	if(lib:lower()=="rbxutility")then
		return setmetatable({
			Create = function(ty)
				return function(data)
					local obj = Instance.new(ty)
					for k, v in pairs(data) do
						if type(k) == 'number' then
							v.Parent = obj
						else
							obj[k] = v
						end
					end
					return obj
				end
			end
		},{__index=function(_,v) return ({})[v] end})
	else
		return {}
	end
end

COREGUI = Services.CoreGui
Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
function chatMessage(str)
    str = tostring(str)
    if not isLegacyChat then
        TextChatService.TextChannels.RBXGeneral:SendAsync(str)
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
    end
end
getgenv().chatMessage = chatMessage
chatMessage("Multi-Reanimate made by Kip.")
local config = getgenv().MultiReanimate
script.Name = config.ScriptName
local cas = game:GetService("ContextActionService")
_G.CAS = cas
Framework = config.Framework
Reanimate = Framework

if Reanimate == "Hatless" then
local Hatless = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/Reanimate/Reanimates/hatless.lua"))()
_G.Character = Hatless.FakeCharacter
_G.Reanimate = {
	fling = function() end,
}
elseif Reanimate == "Krypton" then
KryptonConfiguration = {
	WaitTime = 0.251,
	FakeRigScale = 1,
	DestroyHeightOffset = 50,
	TeleportOffsetRadius = 20,
	RefitHatCount = 2,

	RigName = "Tetris",

	ReturnOnDeath = true,

	Flinging = { -- UNFINISHED
		Enabled = true,
		MethodUsed = "Tool", -- Tool, Hat, HatTouch
		FlingMagnitude = 8000,
	},

	Reclaim = false,
	Refit = true,
	SetCharacter = true,
	Animations = true,

	NoCollisions = true,
	AntiVoiding = true,
	SetSimulationRadius = true,
	DisableCharacterScripts = true,
	AccessoryFallbackDefaults = true,
	OverlayFakeCharacter = false,
	LimitHatsPerLimb = false,
	NoBodyNearby = true,
	PermanentDeath = true,

	Hats = {
		["Right Arm"] = {
			{Texture = "14255544465", Mesh = "14255522247", Name = "RARM", Offset = CFrame.Angles(0, 0, math.rad(90))},
			{Texture = "4645402630", Mesh = "3030546036", Name = "International Fedora", Offset = CFrame.new(0.25,0,0) * CFrame.Angles(math.rad(-90), 0, math.rad(-90))},
		},

		["Left Arm"] = {
			{Texture = "14255544465", Mesh = "14255522247", Name = "LARM", Offset = CFrame.Angles(0, 0, math.rad(90))},
			{Texture = "3650139425", Mesh = "3030546036", Name = "International Fedora", Offset = CFrame.new(-0.25,0,0) * CFrame.Angles(math.rad(-90), 0, math.rad(90))}
		},

		["Right Leg"] = {
			{Texture = "17374768001", Mesh = "17374767929", Name = "Accessory (RARM)", Offset = CFrame.Angles(0, 0, math.rad(90))},
			{Texture = "4622077774", Mesh = "3030546036", Name = "International Fedora", Offset = CFrame.Angles(math.rad(-90), 0, math.rad(90))},
			{Texture = "3360978739", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(math.rad(-90), 0, math.rad(90))},
		},

		["Left Leg"] = {
			{Texture = "17374768001", Mesh = "17374767929", Name = "Accessory (LARM)", Offset = CFrame.Angles(0, 0, math.rad(90))},
			{Texture = "3860099469", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(math.rad(-90), 0, math.rad(-90))},
			{Texture = "3409604993", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(math.rad(-90), 0, math.rad(-90))}
		},

		["Torso"] = {
			{Texture = "13415110780", Mesh = "13421774668", Name = "MeshPartAccessory", Offset = CFrame.identity},
			{Texture = "4819722776", Mesh = "4819720316", Name = "MeshPartAccessory", Offset = CFrame.Angles(0, 0, math.rad(-15))}
		},
	},
}
local Reanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/KadeTheExploiter/Krypton/main/Module.luau"))()
repeat wait() until Reanimate ~= nil
_G.Character = Reanimate:GetCharacter()
_G.Reanimate = {
	fling = Reanimate.CallFling
}
elseif Reanimate == "Empyrean" then
local Reanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/Reanimate/Reanimates/empyrean.lua"))()
emp = Reanimate.Start({
	Accessories = {
		--{ MeshId = "", Name = "", Offset = CFrame.identity, TextureId = "" },

		{ MeshId = "137702817952968", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "135650240593878" },--84451219120140
		{ MeshId = "137702817952968", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "135650240593878" },--72292903231768

		{ MeshId = "137702817952968", Names = { "Left Leg", "Right Leg", "Left Arm", "Right Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "73798034827573" },--108186273151388
		{ MeshId = "137702817952968", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "73798034827573" },--139904067056008

		{ MeshId = "12344207333", Names = { "Left Arm", "Right Arm" }, Offset = CFrame.Angles(- 2.094, 0, 0), TextureId = "12344207341" },--12344545199
		{ MeshId = "12344206657", Names = { "Right Arm", "Left Arm" }, Offset = CFrame.Angles(- 2.094, 0, 0), TextureId = "12344206675" },--12344591101

		{ MeshId = "11449386931", Names = { "Left Arm", "Right Arm" }, Offset = CFrame.Angles(- 2.094, 0, 0), TextureId = "11439439606" },--11449687315
		{ MeshId = "11449388499", Names = { "Right Arm", "Left Arm" }, Offset = CFrame.Angles(- 2.094, 0, 0), TextureId = "11439439606" },--11449703382

		{ MeshId = "12652772399", Names = { "Left Leg", "Right Leg" }, Offset = CFrame.identity, TextureId = "12652775021" },--12652786974

		{ MeshId = "11263221350", Names = { "Left Leg", "Right Leg", "Left Arm", "Right Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "11263219250" },--11263254795
		{ MeshId = "11159370334", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "11159284657" },--11159410305
		{ MeshId = "11159370334", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "11159285454" },--11159483910

		{ MeshId = "105141400603933", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "71060417496309" },--102599402682100
		{ MeshId = "99608462237958", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "130809869695496" },--140395948277978

		{ MeshId = "90736849096372", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "79186624401216" },--90960046381276
		{ MeshId = "139733645770094", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "130809869695496" },--82942681251131

		{ MeshId = "125405780718494", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "136752500636691" },--85392395166623
		{ MeshId = "125405780718494", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "136752500636691" },--131385506535381

		{ MeshId = "125405780718494", Names = { "Left Leg", "Right Leg", "Left Arm", "Right Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "136752500636691" },--106249329428811
		{ MeshId = "125405780718494", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "136752500636691" },--129462518582032

		{ MeshId = "14255522247", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255543546" },--14255556501
		{ MeshId = "14255522247", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255543546" },--14255554762

		{ MeshId = "17374767929", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17374768001" },--17374851733
		{ MeshId = "17374767929", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17374768001" },--17374846953

		{ MeshId = "14255522247", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255544465" },--14255560646
		{ MeshId = "14255522247", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255544465" },--14255562939

		{ MeshId = "18640914129", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.identity, TextureId = "18640914168" },--18641142410
		{ MeshId = "18640914129", Names = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }, Offset = CFrame.identity, TextureId = "18640914168" },--18641077392

		{ MeshId = "18640901641", Names = { "Left Leg", "Right Leg", "Left Arm", "Right Arm" }, Offset = CFrame.identity, TextureId = "18640901676" },--18641187217
		{ MeshId = "18640901641", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.identity, TextureId = "18640901676" },--18641157833

		{ MeshId = "17387586286", Names = { "Left Leg", "Right Leg", "Left Arm", "Right Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17387586304" },--17387616772
		{ MeshId = "17387586286", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17387586304" },--17393641992

		{ MeshId = "3030546036", Names = { "Left Arm", "Left Leg", "Right Arm", "Right Leg" }, Offset = CFrame.Angles(- 1.57, 0, 0), TextureId = "" },
		{ MeshId = "4324138105", Names = { "Left Arm", "Left Leg", "Right Arm", "Right Leg" }, Offset = CFrame.Angles(- 1.57, 0, 0), TextureId = "" },

		{ MeshId = "18640899369", Name = "Torso", Offset = CFrame.identity, TextureId = "18640899481" },--18641046146
		{ MeshId = "14241018198", Name = "Torso", Offset = CFrame.identity, TextureId = "14251599953" },--14255528083
		{ MeshId = "110684113028749", Name = "Torso", Offset = CFrame.identity, TextureId = "70661572547971" },--138364679836274
		{ MeshId = "4819720316", Name = "Torso", Offset = CFrame.Angles(0, 0, -0.249), TextureId = "4819722776" },--4819740796
		{ MeshId = "126825022897778", Name = "Torso", Offset = CFrame.identity, TextureId = "125975972015302" },--95290698984301
		
		{ MeshId = "617474228", Name = "Head", Offset = CFrame.identity, TextureId = "617406825" },--617605556
	},
	ApplyDescription = true,
	BreakJointsDelay = 0.255,
	ClickFling = false,
	DefaultFlingOptions = {
		HatFling = true,--{ MeshId="", TextureId = ""},
		Highlight = true,
		PredictionFling = true,
		Timeout = 1,
		ToolFling = false,--"Boombox",
	},
	DisableCharacterCollisions = true,
	DisableHealthBar = true,
	DisableRigCollisions = true,
	HatDrop = false,
	HideCharacter = Vector3.new(0, - 30, 0),
	ParentCharacter = true,
	PermanentDeath = true,
	Refit = true,
	RigSize = 1,
	RigTransparency = 1,
	R15 = false,
	SetCameraSubject = true,
	SetCameraType = true,
	SetCharacter = true,
	SetCollisionGroup = true,
	SimulationRadius = 2147483647,
	TeleportRadius = 12,
	UseServerBreakJoints = true,
})
_G.Character = emp.Rig
_G.Reanimate = {
	fling = emp.Fling
}
elseif Reanimate == "MW" then
local Reanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/Reanimate/Reanimates/mw.lua"))()
mw = Reanimate.Start()
_G.Character = game.Players.LocalPlayer.Character
_G.Reanimate = {
	fling = mw.fling
}
elseif Reanimate == "Limb" then
local Reanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/Reanimate/Reanimates/limb.lua"))()
Reanimate.Start()
_G.Reanimate = {
	fling = getgenv().fling,
}
_G.Character = game.Players.LocalPlayer.Character
elseif Reanimate == "Gelatek" then
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/Reanimate/Reanimates/gelatek.lua"))()
_G.Character = game.Players.LocalPlayer.Character
_G.Reanimate = {
	fling = function() end,
}
else
print('choose an api next time :(')
return
end
local fakeChar
fakeChar = _G.Character:FindFirstChildWhichIsA("Model")
if fakeChar then
for i,v in next, fakeChar:GetDescendants() do
if v:IsA("BasePart") then
v.CanTouch = false
end
end
end

chatMessage("Successfully reanimated with "..Framework.." Reanimate.")
