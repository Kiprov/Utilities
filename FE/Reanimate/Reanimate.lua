local config = getgenv().MultiReanimate
script.Name = config.ScriptName
local cas = game:GetService("ContextActionService")
_G.CAS = cas
Framework = config.Framework
Reanimate = Framework

if Reanimate == "Hatless" then
local Hatless = loadstring(game:HttpGet("https://raw.githubusercontent.com/MelonsStuff/DisbeliefHub/refs/heads/main/Reanimate/Hatless.lua"))()
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
Reclaim = false,
Refit = true,
SetCharacter = true,
Animations = true,
NoCollisions = true,
AntiVoiding = false,
SetSimulationRadius = true,
DisableCharacterScripts = true,
AccessoryFallbackDefaults = true,
OverlayFakeCharacter = false,
LimitHatsPerLimb = false,
NoBodyNearby = true,
PermanentDeath = true,
Hats = {
["Torso"] = {
{Texture = "4819722776", Mesh = "4819720316", Name = "MeshPartAccessory", Offset = CFrame.Angles(0, 0, -0.25)},
{Texture = "14251599953", Mesh = "14241018198", Name = "Black", Offset = CFrame.Angles(0, 0, 0)},
{Texture = "131014325980101", Mesh = "127552124837034", Name = "Accessory (Toorso)", Offset = CFrame.Angles(0, 0, 0)},
},
["Right Arm"] = {
{Texture = "129264637819824", Mesh = "121342985816617", Name = "Accessory (SnakeRight)", Offset = CFrame.Angles(0, 3.15, 1.57)},
{Texture = "3409604993", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(-1.57, 0, -1.57)},
{Texture = "12344206675", Mesh = "12344206657", Name = "Extra Right hand (Blocky)_white", Offset = CFrame.new(-0.05, 0.05, -0.075) * CFrame.Angles(-1.95, 0, 0)},
{Texture = "14255543546", Mesh = "14255522247", Name = "RARM", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "17374768001", Mesh = "17374767929", Name = "Accessory (RARM)", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "120169691545791", Mesh = "117287001096396", Name = "Accessory (RARM)", Offset = CFrame.Angles(0, 0, 0)},
},
["Left Arm"] = {
{Texture = "129264637819824", Mesh = "121342985816617", Name = "Accessory (SnakeLeft)", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "3033903209", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(-1.57, 0, 1.57)},
{Texture = "12344207341", Mesh = "12344207333", Name = "Extra Left hand (Blocky)_white", Offset = CFrame.new(-0.05, 0.05, -0.075) * CFrame.Angles(-1.95, 0, 0)},
{Texture = "14255543546", Mesh = "14255522247", Name = "LARM", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "17374768001", Mesh = "17374767929", Name = "Accessory (LARM)", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "120169691545791", Mesh = "117287001096396", Name = "Accessory (LARM)", Offset = CFrame.Angles(0, 0, 0)},
},
["Right Leg"] = {
{Texture = "3033898741", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(-1.57, 0, -1.57)},
{Texture = "17387586304", Mesh = "17387586286", Name = "Accessory (LLeg)", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "11263219250", Mesh = "11263221350", Name = "MeshPartAccessory", Offset = CFrame.Angles(0, 0, 1.57)},
{Texture = "131014325980101", Mesh = "121304376791439", Name = "Accessory (LeftLeg)", Offset = CFrame.Angles(0, 0, 0)},
{Texture = "84429400539007", Mesh = "123388937940630", Name = "Accessory (LeftShoulder)", Offset = CFrame.Angles(0, 1.57, 0)},
},
["Left Leg"] = {
{Texture = "3360978739", Mesh = "3030546036", Name = "InternationalFedora", Offset = CFrame.Angles(-1.57, 0, 1.57)},
{Texture = "17387586304", Mesh = "17387586286", Name = "Accessory (rightleg)", Offset = CFrame.Angles(0, 1.57, 1.57)},
{Texture = "11159284657", Mesh = "11159370334", Name = "Unloaded head", Offset = CFrame.Angles(0, 1.57, 1.57)},
{Texture = "131014325980101", Mesh = "121304376791439", Name = "Accessory (RightLeg)", Offset = CFrame.Angles(0, 0, 0)},
{Texture = "84429400539007", Mesh = "117554824897780", Name = "Accessory (RightShoulder)", Offset = CFrame.Angles(0, -1.57, 0)},
},
},
}
local Reanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/KadeTheExploiter/Krypton/main/Module.luau"))()
_G.Character = Reanimate:GetCharacter()
_G.Reanimate = {
	fling = Reanimate.CallFling
}
elseif Reanimate == "Empyrean" then
local Reanimate = loadstring(game:HttpGet("https://raw.githubusercontent.com/MelonsStuff/DisbeliefHub/refs/heads/main/Reanimate/Empyrean.lua"))()
emp = Reanimate.Start({
Accessories = {
-- SB Rig
{ MeshId = "125443585075666", Name = "Torso", Offset = CFrame.Angles(0, 3.15, 0), TextureId = "121023324229475" },
{ MeshId = "121342985816617", Name = "Left Arm", Offset = CFrame.Angles(0, 0, 1.57), TextureId = "129264637819824" },
{ MeshId = "121342985816617", Name = "Right Arm", Offset = CFrame.Angles(0, 3.15, 1.57), TextureId = "129264637819824" },
{ MeshId = "83395427313429", Names = { "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "97148121718581" },--18641142410
-- Free Rig
{ MeshId = "4819720316", Name = "Torso", Offset = CFrame.Angles(0, 0, -0.25), TextureId = "4819722776" },
{ MeshId = "3030546036", Name = "Left Arm", Offset = CFrame.Angles(-1.57, 0, 1.57), TextureId = "3033903209" },
{ MeshId = "3030546036", Name = "Right Arm", Offset = CFrame.Angles(-1.57, 0, -1.57), TextureId = "3360978739" },
{ MeshId = "3030546036", Name = "Left Leg", Offset = CFrame.Angles(-1.57, 0, 1.57), TextureId = "3033898741" },
{ MeshId = "3030546036", Name = "Right Leg", Offset = CFrame.Angles(-1.57, 0, -1.57), TextureId = "3409604993" },
-- Prosthetics
{ MeshId = "117554824897780", Name = "Right Leg", Offset = CFrame.Angles(0, -1.57, 0), TextureId = "99077561039115" },
{ MeshId = "123388937940630", Name = "Left Leg", Offset = CFrame.Angles(0, 1.57, 0), TextureId = "99077561039115" },
{ MeshId = "117554824897780", Name = "Right Leg", Offset = CFrame.Angles(0, -1.57, 0), TextureId = "84429400539007" },
{ MeshId = "123388937940630", Name = "Left Leg", Offset = CFrame.Angles(0, 1.57, 0), TextureId = "84429400539007" },
-- Classic Cheap Rig
{ MeshId = "12344206657", Name = "Left Arm", Offset = CFrame.new(0.05, 0.05, -0.075) * CFrame.Angles(-2, 0, 0), TextureId = "12344206675" },
{ MeshId = "12344207333", Name = "Right Arm", Offset = CFrame.new(-0.05, 0.05, -0.075) * CFrame.Angles(-1.95, 0, 0), TextureId = "12344207341" },
{ MeshId = "11159370334", Name = "Left Leg", Offset = CFrame.Angles(1.57, 1.57, 0), TextureId = "11159284657" },
{ MeshId = "11263221350", Name = "Right Leg", Offset = CFrame.Angles(1.57, -1.57, 0), TextureId = "11263219250" },
-- Grey Mesh Rig 
{ MeshId = "127552124837034", Names = {"Torso"}, Offset = CFrame.Angles(0, 0, 0), TextureId = "131014325980101" },--14255556501
{ MeshId = "117287001096396", Names = { "Left Arm", "Right Arm"}, Offset = CFrame.Angles(0, 0, 0), TextureId = "120169691545791" },--14255556501
{ MeshId = "121304376791439", Names = { "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 0), TextureId = "131014325980101" },--18641142410
-- offsale below
-- Classical Products rig (white/black arms)
{ MeshId = "14241018198", Names = {"Torso"}, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14251599953" },
{ MeshId = "17374767929", Names = { "Left Arm", "Right Arm"}, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17374768001" },
{ MeshId = "17387586286", Names = { "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "17387586304" },
{ MeshId = "14255522247", Names = { "Left Arm", "Right Arm"}, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14255543546" },
-- Noob Rig
{ MeshId = "18640899369", Name = "Torso", Offset = CFrame.Angles(0, 0, 0), TextureId = "18640899481" },
{ MeshId = "18640914129", Names = { "Left Arm", "Right Arm"}, Offset = CFrame.Angles(0, 0, 0), TextureId = "18640914168" },
{ MeshId = "18640901641", Names = { "Left Leg", "Right Leg"}, Offset = CFrame.Angles(0, 0, 0), TextureId = "18640901676" },
-- request
{ MeshId = "14768666349", Name = "Torso", Offset = CFrame.Angles(0, 0, 0), TextureId = "14768664565" },

{ MeshId = "14768684979", Names = { "Left Arm", "Right Arm"}, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "14768683674" },
{ MeshId = "137702817952968", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "135650240593878" },--84451219120140
{ MeshId = "137702817952968", Names = { "Left Arm", "Right Arm", "Left Leg", "Right Leg" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "135650240593878" },--72292903231768
{ MeshId = "137702817952968", Names = { "Left Leg", "Right Leg", "Left Arm", "Right Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "73798034827573" },--108186273151388
{ MeshId = "137702817952968", Names = { "Right Leg", "Left Leg", "Right Arm", "Left Arm" }, Offset = CFrame.Angles(0, 0, 1.57), TextureId = "73798034827573" },--139904067056008
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
},
ApplyDescription = true,
BreakJointsDelay = 0.255,
ClickFling = true,
DefaultFlingOptions = {
HatFling = true,--{ MeshId="", TextureId = ""},
Highlight = true,
PredictionFling = true,
Timeout = 1,
ToolFling = true,--"Boombox",
},
DisableCharacterCollisions = true,
DisableHealthBar = true,
DisableRigCollisions = true,
HatDrop = false,
HideCharacter = Vector3.new(0, -30, 0),
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
if script.Name == "VoidBoss" then
game.Players.LocalPlayer.Character["VANS_Umbrella"].Handle.Mesh:Destroy()
game.Players.LocalPlayer.Character["PlaneModel"].Handle.Mesh:Destroy()
game.Players.LocalPlayer.Character["PogoStick"].Handle.Mesh:Destroy()
game.Players.LocalPlayer.Character["RunningBull"].Handle.Mesh:Destroy() --Metashard

local c = game.Players.LocalPlayer.Character
for i, v in pairs({"Right Arm", "Left Arm"}) do
    local arm = c[v]
    arm.Parent = nil
    arm.Transparency = 1
    arm.Parent = c
end

local c = game.Players.LocalPlayer.Character
for i, v in pairs({"Right Leg", "Left Leg"}) do
    local Leg = c[v]
    Leg.Parent = nil
    Leg.Transparency = 1
    Leg.Parent = c
end
end
--reanimate by MyWorld#4430 discord.gg/pYVHtSJmEY
--the code that looks trash and works great
local healthHide = false --moves your head away every 3 seconds so players dont see your health bar (alignmode 4 only)
local reclaim = true --if you lost control over a part this will move your primary part to the part so you get it back (alignmode 4)
local novoid = true --prevents parts from going under workspace.FallenPartsDestroyHeight if you control them (alignmode 4 only)
local physp = nil --PhysicalProperties.new(0.01, 0, 1, 0, 0) --sets .CustomPhysicalProperties to this for each part
local noclipAllParts = false --set it to true if you want noclip
local antiragdoll = true --removes hingeConstraints and ballSocketConstraints from your character
local newanimate = true --disables the animate script and enables after reanimation
local discharscripts = true --disables all localScripts parented to your character before reanimation
local R15toR6 = true --tries to convert your character to r6 if its r15
local hatcollide = true --makes hats cancollide (credit to ShownApe) (works only with reanimate method 0)
local humState16 = true --enables collisions for limbs before the humanoid dies (using hum:ChangeState)
local addtools = false --puts all tools from backpack to character and lets you hold them after reanimation
local hedafterneck = true --disable aligns for head and enable after neck or torso is removed
local simrad = 2147483647 --simulation radius with sethiddenproperty (nil to disable)
local loadtime = game:GetService("Players").RespawnTime + 0.5 --anti respawn delay
local method = 2 --reanimation method
if config.ScriptName == "VoidBoss" then
method = 0
end
--method 1,2 work the best
--method 3 also works the best, but makes torso follow
--method 4,5 are broken
--method 0, missing torso, semi-best
--methods:
--0 - breakJoints (takes [loadtime] seconds to load)
--1 - limbs
--2 - limbs + anti respawn
--3 - limbs + breakJoints after [loadtime] seconds
--4 - remove humanoid + breakJoints
--5 - remove humanoid + limbs
local alignmode = 4 --AlignPosition mode
--modes:
--1 - AlignPosition rigidity enabled true
--2 - 2 AlignPositions rigidity enabled both true and false
--3 - AlignPosition rigidity enabled false
--4 - no AlignPosition, CFrame only
local flingpart = "HumanoidRootPart" --name of the part or the hat used for flinging
--the fling function
--usage: fling(target, duration, velocity)
--target can be set to: basePart, CFrame, Vector3, character model or humanoid (flings at mouse.Hit if argument not provided)
--duration (fling time in seconds) can be set to a number or a string convertable to a number (0.5s if not provided)
--velocity (fling part rotation velocity) can be set to a vector3 value (Vector3.new(20000, 20000, 20000) if not provided)

local lp = game:GetService("Players").LocalPlayer
local rs, ws, sg = game:GetService("RunService"), game:GetService("Workspace"), game:GetService("StarterGui")
local stepped, heartbeat, renderstepped = rs.Stepped, rs.Heartbeat, rs.RenderStepped
local twait, tdelay, rad, inf, abs, mclamp = task.wait, task.delay, math.rad, math.huge, math.abs, math.clamp
local cf, v3, angles = CFrame.new, Vector3.new, CFrame.Angles
local v3_0, cf_0 = v3(0, 0, 0), cf(0, 0, 0)

local c = lp.Character
if not (c and c.Parent) then
    return
end

c:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (c and c.Parent) then
        c = nil
    end
end)

local destroy = c.Destroy

local function gp(parent, name, className)
    if typeof(parent) == "Instance" then
        for i, v in pairs(parent:GetChildren()) do
            if (v.Name == name) and v:IsA(className) then
                return v
            end
        end
    end
    return nil
end

local v3_xz, v3_net = v3(8, 0, 8), v3(0.1, 25.1, 0.1)
local function getNetlessVelocity(realPartVelocity) --edit this if you have a better netless method
    if realPartVelocity.Magnitude < 0.1 then return v3_net end
    return realPartVelocity * v3_xz + v3_net
end

if type(simrad) == "number" then
    local shp = getfenv().sethiddenproperty
    if shp then
        local con = nil
        con = heartbeat:Connect(function()
            if not c then return con:Disconnect() end
            shp(lp, "SimulationRadius", simrad)
        end)
    end
end

healthHide = healthHide and ((method == 0) or (method == 2) or (method == 3)) and gp(c, "Head", "BasePart")

local reclaim, lostpart = reclaim and c.PrimaryPart, nil

local v3_hide = v3(0, 3000, 0)
local function align(Part0, Part1)
    
    local att0 = Instance.new("Attachment")
    att0.Position, att0.Orientation, att0.Name = v3_0, v3_0, "att0_" .. Part0.Name
    local att1 = Instance.new("Attachment")
    att1.Position, att1.Orientation, att1.Name = v3_0, v3_0, "att1_" .. Part1.Name

    if alignmode == 4 then
    
        local hide = false
        if Part0 == healthHide then
            healthHide = false
            tdelay(0, function()
                while twait(2.9) and Part0 and c do
                    hide = #Part0:GetConnectedParts() == 1
                    twait(0.1)
                    hide = false
                end
            end)
        end
        
        local rot = rad(0.05)
        local con0, con1 = nil, nil
        con0 = stepped:Connect(function()
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            Part0.RotVelocity = Part1.RotVelocity
        end)
        local lastpos, vel = Part0.Position, Part0.Velocity
        con1 = heartbeat:Connect(function(delta)
            if not (Part0 and Part1 and att1) then return con0:Disconnect() and con1:Disconnect() end
            if (not Part0.Anchored) and (Part0.ReceiveAge == 0) then
                if lostpart == Part0 then
                    lostpart = nil
                end
                local newcf = Part1.CFrame * att1.CFrame
                local vel = (newcf.Position - lastpos) / delta
                Part0.Velocity = getNetlessVelocity(vel)
                if vel.Magnitude < 1 then
                    rot = -rot
                    newcf *= angles(0, 0, rot)
                end
                lastpos = newcf.Position
                if lostpart and (Part0 == reclaim) then
                    newcf = lostpart.CFrame
                elseif hide then
                    newcf += v3_hide
                end
                if novoid and (newcf.Y < workspace.FallenPartsDestroyHeight + 0.1) then
                    newcf += v3(0, workspace.FallenPartsDestroyHeight + 0.1 - newcf.Y, 0)
                end
                Part0.CFrame = newcf
            elseif (not Part0.Anchored) and (abs(Part0.Velocity.X) < 45) and (abs(Part0.Velocity.Y) < 25) and (abs(Part0.Velocity.Z) < 45) then
                lostpart = Part0
            end
        end)
    
    else
        
        Part0.CustomPhysicalProperties = physp
        if (alignmode == 1) or (alignmode == 2) then
            local ape = Instance.new("AlignPosition")
            ape.MaxForce, ape.MaxVelocity, ape.Responsiveness = inf, inf, inf
            ape.ReactionForceEnabled, ape.RigidityEnabled, ape.ApplyAtCenterOfMass = false, true, false
            ape.Attachment0, ape.Attachment1, ape.Name = att0, att1, "AlignPositionRtrue"
            ape.Parent = att0
        end
        
        if (alignmode == 2) or (alignmode == 3) then
            local apd = Instance.new("AlignPosition")
            apd.MaxForce, apd.MaxVelocity, apd.Responsiveness = inf, inf, inf
            apd.ReactionForceEnabled, apd.RigidityEnabled, apd.ApplyAtCenterOfMass = false, false, false
            apd.Attachment0, apd.Attachment1, apd.Name = att0, att1, "AlignPositionRfalse"
            apd.Parent = att0
        end
        
        local ao = Instance.new("AlignOrientation")
        ao.MaxAngularVelocity, ao.MaxTorque, ao.Responsiveness = inf, inf, inf
        ao.PrimaryAxisOnly, ao.ReactionTorqueEnabled, ao.RigidityEnabled = false, false, false
        ao.Attachment0, ao.Attachment1 = att0, att1
        ao.Parent = att0
        
        local con0, con1 = nil, nil
        local vel = Part0.Velocity
        con0 = renderstepped:Connect(function()
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            --Part0.Velocity = framevel
        end)
        local lastpos = Part0.Position
        con1 = heartbeat:Connect(function(delta)
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            vel = Part0.Velocity
            Part0.Velocity = getNetlessVelocity((Part1.Position - lastpos) / delta)
            lastpos = Part1.Position
        end)
    
    end

    att0:GetPropertyChangedSignal("Parent"):Connect(function()
        Part0 = att0.Parent
        if not Part0:IsA("BasePart") then
            att0 = nil
            if lostpart == Part0 then
                lostpart = nil
            end
            Part0 = nil
        end
    end)
    att0.Parent = Part0
    
    att1:GetPropertyChangedSignal("Parent"):Connect(function()
        Part1 = att1.Parent
        if not Part1:IsA("BasePart") then
            att1 = nil
            Part1 = nil
        end
    end)
    att1.Parent = Part1
end

local function respawnrequest()
    local ccfr, c = workspace.CurrentCamera.CFrame, lp.Character
    lp.Character = nil
    lp.Character = c
    local con = nil
    con = workspace.CurrentCamera.Changed:Connect(function(prop)
        if (prop ~= "Parent") and (prop ~= "CFrame") then
            return
        end
        workspace.CurrentCamera.CFrame = ccfr
        con:Disconnect()
    end)
end

local destroyhum = (method == 4) or (method == 5)
local breakjoints = (method == 0) or (method == 4)
local antirespawn = (method == 0) or (method == 2) or (method == 3)

hatcollide = hatcollide and (method == 0)

addtools = addtools and lp:FindFirstChildOfClass("Backpack")

if antiragdoll then
    antiragdoll = function(v)
        if v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
            v.Parent = nil
        end
    end
    for i, v in pairs(c:GetDescendants()) do
        antiragdoll(v)
    end
    c.DescendantAdded:Connect(antiragdoll)
end

if antirespawn then
    respawnrequest()
end

if method == 0 then
    twait(loadtime)
    if not c then
        return
    end
end

if discharscripts then
    for i, v in pairs(c:GetDescendants()) do
        if v:IsA("LocalScript") then
            v.Disabled = true
        end
    end
elseif newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate and (not animate.Disabled) then
        animate.Disabled = true
    else
        newanimate = false
    end
end

if addtools then
    for i, v in pairs(addtools:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = c
        end
    end
end

pcall(function()
    settings().Physics.AllowSleep = false
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

local OLDscripts = {}

for i, v in pairs(c:GetDescendants()) do
    if v.ClassName == "Script" then
        OLDscripts[v.Name] = true
    end
end

local scriptNames = {}

for i, v in pairs(c:GetDescendants()) do
    if v:IsA("BasePart") then
        local newName, exists = tostring(i), true
        while exists do
            exists = OLDscripts[newName]
            if exists then
                newName = newName .. "_"    
            end
        end
        table.insert(scriptNames, newName)
        Instance.new("Script", v).Name = newName
    end
end

local hum = c:FindFirstChildOfClass("Humanoid")
if hum then
    for i, v in pairs(hum:GetPlayingAnimationTracks()) do
        v:Stop()
    end
end
c.Archivable = true
local cl = c:Clone()
if hum and humState16 then
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    if destroyhum then
        twait(1.6)
    end
end
if destroyhum then
    pcall(destroy, hum)
end

if not c then
    return
end

local head, torso, root = gp(c, "Head", "BasePart"), gp(c, "Torso", "BasePart") or gp(c, "UpperTorso", "BasePart"), gp(c, "HumanoidRootPart", "BasePart")
if hatcollide then
    pcall(destroy, torso)
    pcall(destroy, root)
    pcall(destroy, c:FindFirstChildOfClass("BodyColors") or gp(c, "Health", "Script"))
end

local model = Instance.new("Model", c)
model:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (model and model.Parent) then
        model = nil
    end
end)

for i, v in pairs(c:GetChildren()) do
    if v ~= model then
        if addtools and v:IsA("Tool") then
            for i1, v1 in pairs(v:GetDescendants()) do
                if v1 and v1.Parent and v1:IsA("BasePart") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity, bv.MaxForce, bv.P, bv.Name = v3_0, v3(1000, 1000, 1000), 1250, "bv_" .. v.Name
                    bv.Parent = v1
                end
            end
        end
        v.Parent = model
    end
end

if breakjoints then
    model:BreakJoints()
else
    if head and torso then
        for i, v in pairs(model:GetDescendants()) do
            if v:IsA("JointInstance") then
                local save = false
                if (v.Part0 == torso) and (v.Part1 == head) then
                    save = true
                end
                if (v.Part0 == head) and (v.Part1 == torso) then
                    save = true
                end
                if save then
                    if hedafterneck then
                        hedafterneck = v
                    end
                else
                    pcall(destroy, v)
                end
            end
        end
    end
    if method == 3 then
        task.delay(loadtime, pcall, model.BreakJoints, model)
    end
end

cl.Parent = ws
for i, v in pairs(cl:GetChildren()) do
    v.Parent = c
end
pcall(destroy, cl)

local uncollide, noclipcon = nil, nil
if noclipAllParts then
    uncollide = function()
        if c then
            for i, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            noclipcon:Disconnect()
        end
    end
else
    uncollide = function()
        if model then
            for i, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            noclipcon:Disconnect()
        end
    end
end
noclipcon = stepped:Connect(uncollide)
uncollide()

for i, scr in pairs(model:GetDescendants()) do
    if (scr.ClassName == "Script") and table.find(scriptNames, scr.Name) then
        local Part0 = scr.Parent
        if Part0:IsA("BasePart") then
            for i1, scr1 in pairs(c:GetDescendants()) do
                if (scr1.ClassName == "Script") and (scr1.Name == scr.Name) and (not scr1:IsDescendantOf(model)) then
                    local Part1 = scr1.Parent
                    if (Part1.ClassName == Part0.ClassName) and (Part1.Name == Part0.Name) then
                        align(Part0, Part1)
                        pcall(destroy, scr)
                        pcall(destroy, scr1)
                        break
                    end
                end
            end
        end
    end
end

for i, v in pairs(c:GetDescendants()) do
    if v and v.Parent and (not v:IsDescendantOf(model)) then
        if v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("BasePart") then
            v.Transparency = 1
            v.Anchored = false
        elseif v:IsA("ForceField") then
            v.Visible = false
        elseif v:IsA("Sound") then
            v.Playing = false
        elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
end

if newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate then
        animate.Disabled = false
    end
end

if addtools then
    for i, v in pairs(c:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = addtools
        end
    end
end

local hum0, hum1 = model:FindFirstChildOfClass("Humanoid"), c:FindFirstChildOfClass("Humanoid")
if hum0 then
    hum0:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (hum0 and hum0.Parent) then
            hum0 = nil
        end
    end)
end
if hum1 then
    hum1:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (hum1 and hum1.Parent) then
            hum1 = nil
        end
    end)

    workspace.CurrentCamera.CameraSubject = hum1
    local camSubCon = nil
    local function camSubFunc()
        camSubCon:Disconnect()
        if c and hum1 then
            workspace.CurrentCamera.CameraSubject = hum1
        end
    end
    camSubCon = renderstepped:Connect(camSubFunc)
    if hum0 then
        hum0:GetPropertyChangedSignal("Jump"):Connect(function()
            if hum1 then
                hum1.Jump = hum0.Jump
            end
        end)
    else
        respawnrequest()
    end
end

local rb = Instance.new("BindableEvent", c)
rb.Event:Connect(function()
    pcall(destroy, rb)
    sg:SetCore("ResetButtonCallback", true)
    if destroyhum then
        if c then c:BreakJoints() end
        return
    end
    if model and hum0 and (hum0.Health > 0) then
        model:BreakJoints()
        hum0.Health = 0
    end
    if antirespawn then
        respawnrequest()
    end
end)
sg:SetCore("ResetButtonCallback", rb)

tdelay(0, function()
    while c do
        if hum0 and hum1 then
            hum1.Jump = hum0.Jump
        end
        wait()
    end
    sg:SetCore("ResetButtonCallback", true)
end)

R15toR6 = R15toR6 and hum1 and (hum1.RigType == Enum.HumanoidRigType.R15)
if R15toR6 then
    local part = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "UpperTorso", "BasePart") or gp(c, "LowerTorso", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
    if part then
        local cfr = part.CFrame
        local R6parts = { 
            head = {
                Name = "Head",
                Size = v3(2, 1, 1),
                R15 = {
                    Head = 0
                }
            },
            torso = {
                Name = "Torso",
                Size = v3(2, 2, 1),
                R15 = {
                    UpperTorso = 0.2,
                    LowerTorso = -0.8
                }
            },
            root = {
                Name = "HumanoidRootPart",
                Size = v3(2, 2, 1),
                R15 = {
                    HumanoidRootPart = 0
                }
            },
            leftArm = {
                Name = "Left Arm",
                Size = v3(1, 2, 1),
                R15 = {
                    LeftHand = -0.849,
                    LeftLowerArm = -0.174,
                    LeftUpperArm = 0.415
                }
            },
            rightArm = {
                Name = "Right Arm",
                Size = v3(1, 2, 1),
                R15 = {
                    RightHand = -0.849,
                    RightLowerArm = -0.174,
                    RightUpperArm = 0.415
                }
            },
            leftLeg = {
                Name = "Left Leg",
                Size = v3(1, 2, 1),
                R15 = {
                    LeftFoot = -0.85,
                    LeftLowerLeg = -0.29,
                    LeftUpperLeg = 0.49
                }
            },
            rightLeg = {
                Name = "Right Leg",
                Size = v3(1, 2, 1),
                R15 = {
                    RightFoot = -0.85,
                    RightLowerLeg = -0.29,
                    RightUpperLeg = 0.49
                }
            }
        }
        for i, v in pairs(c:GetChildren()) do
            if v:IsA("BasePart") then
                for i1, v1 in pairs(c:GetChildren()) do
                    if v1:IsA("Motor6D") then
                        v1.Part0 = nil
                    end
                end
            end
        end
        part.Archivable = true
        for i, v in pairs(R6parts) do
            local part = part:Clone()
            part:ClearAllChildren()
            part.Name, part.Size, part.CFrame, part.Anchored, part.Transparency, part.CanCollide = v.Name, v.Size, cfr, false, 1, false
            for i1, v1 in pairs(v.R15) do
                local R15part = gp(c, i1, "BasePart")
                local att = gp(R15part, "att1_" .. i1, "Attachment")
                if R15part then
                    local weld = Instance.new("Weld")
                    weld.Part0, weld.Part1, weld.C0, weld.C1, weld.Name = part, R15part, cf(0, v1, 0), cf_0, "Weld_" .. i1
                    weld.Parent = R15part
                    R15part.Massless, R15part.Name = true, "R15_" .. i1
                    R15part.Parent = part
                    if att then
                        att.Position = v3(0, v1, 0)
                        att.Parent = part
                    end
                end
            end
            part.Parent = c
            R6parts[i] = part
        end
        local R6joints = {
            neck = {
                Parent = R6parts.torso,
                Name = "Neck",
                Part0 = R6parts.torso,
                Part1 = R6parts.head,
                C0 = cf(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
                C1 = cf(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            },
            rootJoint = {
                Parent = R6parts.root,
                Name = "RootJoint" ,
                Part0 = R6parts.root,
                Part1 = R6parts.torso,
                C0 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
                C1 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            },
            rightShoulder = {
                Parent = R6parts.torso,
                Name = "Right Shoulder",
                Part0 = R6parts.torso,
                Part1 = R6parts.rightArm,
                C0 = cf(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
                C1 = cf(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            },
            leftShoulder = {
                Parent = R6parts.torso,
                Name = "Left Shoulder",
                Part0 = R6parts.torso,
                Part1 = R6parts.leftArm,
                C0 = cf(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
                C1 = cf(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            },
            rightHip = {
                Parent = R6parts.torso,
                Name = "Right Hip",
                Part0 = R6parts.torso,
                Part1 = R6parts.rightLeg,
                C0 = cf(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
                C1 = cf(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            },
            leftHip = {
                Parent = R6parts.torso,
                Name = "Left Hip" ,
                Part0 = R6parts.torso,
                Part1 = R6parts.leftLeg,
                C0 = cf(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
                C1 = cf(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            }
        }
        for i, v in pairs(R6joints) do
            local joint = Instance.new("Motor6D")
            for prop, val in pairs(v) do
                joint[prop] = val
            end
            R6joints[i] = joint
        end
        if hum1 then
            hum1.RigType, hum1.HipHeight = Enum.HumanoidRigType.R6, 0
        end
    end
end

local torso1 = torso
torso = gp(c, "Torso", "BasePart") or ((not R15toR6) and gp(c, torso.Name, "BasePart"))
if (typeof(hedafterneck) == "Instance") and head and torso and torso1 then
    local conNeck, conTorso, conTorso1 = nil, nil, nil
    local aligns = {}
    local function enableAligns()
        conNeck:Disconnect()
        conTorso:Disconnect()
        conTorso1:Disconnect()
        for i, v in pairs(aligns) do
            v.Enabled = true
        end
    end
    conNeck = hedafterneck.Changed:Connect(function(prop)
        if table.find({"Part0", "Part1", "Parent"}, prop) then
            enableAligns()
        end
    end)
    conTorso = torso:GetPropertyChangedSignal("Parent"):Connect(enableAligns)
    conTorso1 = torso1:GetPropertyChangedSignal("Parent"):Connect(enableAligns)
    for i, v in pairs(head:GetDescendants()) do
        if v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
            i = tostring(i)
            aligns[i] = v
            v:GetPropertyChangedSignal("Parent"):Connect(function()
                aligns[i] = nil
            end)
            v.Enabled = false
        end
    end
end

local flingpart0 = gp(model, flingpart, "BasePart") or gp(gp(model, flingpart, "Accessory"), "Handle", "BasePart")
local flingpart1 = gp(c, flingpart, "BasePart") or gp(gp(c, flingpart, "Accessory"), "Handle", "BasePart")

local fling = function() end
if flingpart0 and flingpart1 then
    flingpart0:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (flingpart0 and flingpart0.Parent) then
            flingpart0 = nil
            fling = function() end
        end
    end)
    flingpart0.Archivable = true
    flingpart1:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (flingpart1 and flingpart1.Parent) then
            flingpart1 = nil
            fling = function() end
        end
    end)
    local att0 = gp(flingpart0, "att0_" .. flingpart0.Name, "Attachment")
    local att1 = gp(flingpart1, "att1_" .. flingpart1.Name, "Attachment")
    if att0 and att1 then
        att0:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (att0 and att0.Parent) then
                att0 = nil
                fling = function() end
            end
        end)
        att1:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (att1 and att1.Parent) then
                att1 = nil
                fling = function() end
            end
        end)
        local lastfling = nil
        local mouse = lp:GetMouse()
        fling = function(target, duration, rotVelocity)
            if typeof(target) == "Instance" then
                if target:IsA("BasePart") then
                    target = target.Position
                elseif target:IsA("Model") then
                    target = gp(target, "HumanoidRootPart", "BasePart") or gp(target, "Torso", "BasePart") or gp(target, "UpperTorso", "BasePart") or target:FindFirstChildWhichIsA("BasePart")
                    if target then
                        target = target.Position
                    else
                        return
                    end
                elseif target:IsA("Humanoid") then
                    target = target.Parent
                    if not (target and target:IsA("Model")) then
                        return
                    end
                    target = gp(target, "HumanoidRootPart", "BasePart") or gp(target, "Torso", "BasePart") or gp(target, "UpperTorso", "BasePart") or target:FindFirstChildWhichIsA("BasePart")
                    if target then
                        target = target.Position
                    else
                        return
                    end
                else
                    return
                end
            elseif typeof(target) == "CFrame" then
                target = target.Position
            elseif typeof(target) ~= "Vector3" then
                target = mouse.Hit
                if target then
                    target = target.Position
                else
                    return
                end
            end
            if target.Y < workspace.FallenPartsDestroyHeight + 5 then
                target = v3(target.X, workspace.FallenPartsDestroyHeight + 5, target.Z)
            end
            lastfling = target
            if type(duration) ~= "number" then
                duration = tonumber(duration) or 0.5
            end
            if typeof(rotVelocity) ~= "Vector3" then
                rotVelocity = v3(20000, 20000, 20000)
            end
            if not (target and flingpart0 and flingpart1 and att0 and att1) then
                return
            end
            flingpart0.Archivable = true
            local flingpart = flingpart0:Clone()
            flingpart.Transparency = 1
            flingpart.CanCollide = false
            flingpart.Name = "flingpart_" .. flingpart0.Name
            flingpart.Anchored = true
            flingpart.Velocity = v3_0
            flingpart.RotVelocity = v3_0
            flingpart.Position = target
            flingpart:GetPropertyChangedSignal("Parent"):Connect(function()
                if not (flingpart and flingpart.Parent) then
                    flingpart = nil
                end
            end)
            flingpart.Parent = flingpart1
            if flingpart0.Transparency > 1 then
                flingpart0.Transparency = 1
            end
            att1.Parent = flingpart
            local con = nil
            local rotchg = v3(0, rotVelocity.Unit.Y * -1000, 0)
            con = heartbeat:Connect(function(delta)
                if target and (lastfling == target) and flingpart and flingpart0 and flingpart1 and att0 and att1 then
                    flingpart.Orientation += rotchg * delta
                    flingpart0.RotVelocity = rotVelocity
                else
                    con:Disconnect()
                end
            end)
            if alignmode ~= 4 then
                local con = nil
                con = renderstepped:Connect(function()
                    if flingpart0 and target then
                        flingpart0.RotVelocity = v3_0
                    else
                        con:Disconnect()
                    end
                end)
            end
            twait(duration)
            if lastfling ~= target then
                if flingpart then
                    if att1 and (att1.Parent == flingpart) then
                        att1.Parent = flingpart1
                    end
                    pcall(destroy, flingpart)
                end
                return
            end
            target = nil
            if not (flingpart and flingpart0 and flingpart1 and att0 and att1) then
                return
            end
            flingpart0.RotVelocity = v3_0
            att1.Parent = flingpart1
            pcall(destroy, flingpart)
        end
    end
end

lp:GetMouse().Button1Down:Connect(fling) --click fling
if script.Name == "VoidBoss" then
local cplayer = game.Players.LocalPlayer.Character
local hat2 = gp(cplayer, "VANS_Umbrella", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Head"]
att2.Position = Vector3.new(-0, -0, 0)
att2.Rotation = Vector3.new(0, 0, 0)

local hat2 = gp(cplayer, "PlaneModel", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Right Leg"]
att2.Position = Vector3.new(-0, -0, 0)
att2.Rotation = Vector3.new(90, 0, 0)

local hat2 = gp(cplayer, "PogoStick", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Left Leg"]
att2.Position = Vector3.new(-0, -0, 0)
att2.Rotation = Vector3.new(0, 0, 110)

local hat2 = gp(cplayer, "RunningBull", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Head"]
att2.Position = Vector3.new(-1, 0.3, -1.65)
att2.Rotation = Vector3.new(90, -0, 0)  --HandleAccessory

local hat2 = gp(cplayer, "Metashard", "Accessory")
local handle2 = gp(hat2, "Handle", "BasePart")
local att2 = gp(handle2, "att1_Handle", "Attachment")
att2.Parent = cplayer["Head"]
att2.Position = Vector3.new(1, 0.3, -1.5)
att2.Rotation = Vector3.new(0, -0, 0)--HandleAccessory
end
_G.Character = game.Players.LocalPlayer.Character
_G.Reanimate = {
	fling = fling
}
elseif Reanimate == "Limb" then
-- gonna get patched soon, have fun while you still can
local roothidecf = CFrame.new(0,-255,0)





if not game.IsLoaded then
	game.Loaded:Wait()
end
local desiredmode = false

local zeropointone = 0.1
local twait = task.wait
local tspawn = task.spawn
local currentfakechar = nil
local vector3zero = Vector3.zero
local getgenv = getgenv or function()
	return _G
end

local NaN = 0/0

local dummypart = Instance.new("Part")

local GetDescendants = dummypart.GetDescendants
local IsA = dummypart.IsA
local Destroy = dummypart.Destroy

local math_random = math.random
local Vector3_new = Vector3.new

local usedefaultanims =  false

local transparency_level =  1

local disablescripts =  true

local fakecollisions =  true

local nametoexcludefromtransparency = {}

local parentrealchartofakechar = false

local respawncharacter = (function() if _G["Respawn character"] == nil then return true else return _G["Respawn character"] end end)()

local instantrespawn =true

local LocalPlayer = game:GetService("Players").LocalPlayer

	local exploit = "shitsploit"

if not LocalPlayer.Character then
	LocalPlayer.CharacterAdded:Wait()
	twait(zeropointone)
	if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType ~= Enum.HumanoidRigType.R6 then
		error("Script is only compatible with R6 type rigs")
		return
	end
end

local function removeAnims(character)
	if character == currentfakechar then
		return
	end
	local humanoid = character:WaitForChild("Humanoid", 5)
	local animator = humanoid:FindFirstChildWhichIsA("Animator")
	if animator then
		Destroy(animator)
	end
	local animateScript = character:FindFirstChild("Animate")
	if animateScript then
		Destroy(animateScript)
	end
	local a = nil
	a = humanoid.DescendantAdded:Connect(function(child)
		if child:IsA("Animator") then
			Destroy(child)
			a:Disconnect()
			a = nil
		end
	end)
end

LocalPlayer.CharacterAdded:Once(removeAnims)

		_G.OxideRealChar =LocalPlayer.Character
LocalPlayer.Character.Archivable = true
local originalChar = LocalPlayer.Character
local char = originalChar:Clone()
char.Name = "non"
local signaldiedbackend = LocalPlayer.ConnectDiedSignalBackend
local signalkill = LocalPlayer.Kill

if respawncharacter then
	if instantrespawn then
		if replicatesignal then
			replicatesignal(signaldiedbackend)
			twait(game.Players.RespawnTime - 0.05)
			replicatesignal(signalkill)
			LocalPlayer.CharacterAdded:Wait()
			char.Parent = workspace
			currentfakechar = char
		end
	else
		originalChar:BreakJoints()
		LocalPlayer.CharacterAdded:Wait()
		char.Parent = workspace
		currentfakechar = char
	
	end
end

twait(zeropointone)

local newChar = LocalPlayer.Character
newChar.Archivable = true

if disablescripts then
	tspawn(function()
		for _, obj in ipairs(char:GetChildren()) do
			if obj:IsA("LocalScript") then
				obj.Enabled = false
			end
		end
	end)
end

for _, part in ipairs(char:GetDescendants()) do
	if part:IsA("BasePart") or part:IsA("Decal") then
			part.Transparency = transparency_level
	end
end

twait(0.4)
	LocalPlayer.Character.Parent = char
LocalPlayer.Character = char
if parentrealchartofakechar then
	newChar.Parent = char
end
		_G.OxideRealChar =char
	
char.Humanoid.RequiresNeck = false 
char.Humanoid:SetStateEnabled(15,false) 

local newcharTorso = newChar:WaitForChild("Torso")
local fakecharTorso = char:WaitForChild("Torso")
local newcharRoot = newChar:WaitForChild("HumanoidRootPart")
local fakecharRoot = char:WaitForChild("HumanoidRootPart")

local limbmapping = {
	Neck = char:WaitForChild("Head"),
    RootJoint = char:WaitForChild("Torso"),
	["Left Shoulder"] = char:WaitForChild("Left Arm"),
	["Right Shoulder"] = char:WaitForChild("Right Arm"),
	["Left Hip"] = char:WaitForChild("Left Leg"),
	["Right Hip"] = char:WaitForChild("Right Leg")
}

local jointmapping = {
	Neck = newcharTorso:WaitForChild("Neck"),
    RootJoint = newChar.HumanoidRootPart:WaitForChild("RootJoint"),
	["Left Shoulder"] = newcharTorso:WaitForChild("Left Shoulder"),
	["Right Shoulder"] = newcharTorso:WaitForChild("Right Shoulder"),
	["Left Hip"] = newcharTorso:WaitForChild("Left Hip"),
	["Right Hip"] = newcharTorso:WaitForChild("Right Hip")
}

local function RCA6dToCFrame(Motor6D, TargetPart, ReferencePart)
    local rel = ReferencePart.CFrame:Inverse() * TargetPart.CFrame
    local delta = Motor6D.C0:Inverse() * rel * Motor6D.C1
    local axis, angle = delta:ToAxisAngle()
    local newangle = axis * angle
	local offset = Vector3.zero 
	if TargetPart:FindFirstChildOfClass("SpecialMesh") then 
		offset = TargetPart:FindFirstChildOfClass("SpecialMesh").Offset
	end
    sethiddenproperty(Motor6D, 'ReplicateCurrentOffset6D', delta.Position + offset)
    sethiddenproperty(Motor6D, 'ReplicateCurrentAngle6D', newangle)
end

local ToObjectSpace = CFrame.new().ToObjectSpace
local ToEulerAnglesXYZ = CFrame.new().ToEulerAnglesXYZ
local task_spawn = task.spawn
local function stepReanimate()
    --// YES the code is badly formatted YES the code barely works
    --// YES it is unstable. im working on a fix.
	for joint, limb in pairs(limbmapping) do
		   local realJoint = jointmapping[joint]
		   	realJoint.MaxVelocity = 9e9
	end
task_spawn(function()


for joint, limb in pairs(limbmapping) do
    newcharRoot.CFrame = roothidecf + Vector3_new(0, 0, math_random(1, 2) / 326.19)
    newcharRoot.Velocity = vector3zero
    newcharRoot.RotVelocity = vector3zero
			local relativecframe = ToObjectSpace(limb.CFrame, fakecharTorso.CFrame)
	local pitch, yaw, _ = ToEulerAnglesXYZ(relativecframe)
	local angle = 0

	if joint == "Neck" then
		angle = -yaw
	elseif joint == "Left Shoulder" or joint == "Left Hip" then
		angle = pitch
	elseif joint == "Right Shoulder" or joint == "Right Hip" then
		angle = -pitch
	end
    local realJoint = jointmapping[joint]
	
	 realJoint:SetDesiredAngle(angle)
		realJoint.MaxVelocity = 9e9
    if joint == "RootJoint" then
RCA6dToCFrame(realJoint, fakecharTorso, newcharTorso)
else
	 if desiredmode == false then 
RCA6dToCFrame(realJoint, limb, fakecharTorso)
    end
end
end



end)
end


local function setdestroyheight(height)
	local sucess, result = pcall(function()
		workspace.FallenPartsDestroyHeight = height
	end)
	if not sucess then
	end
end

local currentheight = workspace.FallenPartsDestroyHeight

local function flinginternal(character, time)
	local time = time or 5

	flinging = true
	local start = tick()
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if tick() - start >= time then
			setdestroyheight(currentheight)
			flinging = false
			connection:Disconnect()
			--break
		end
		if character then
			if character:FindFirstChild("HumanoidRootPart") then
				local velocity = character.HumanoidRootPart.Velocity
				local direction = velocity.Magnitude > 1 and velocity.Unit or Vector3_new(0, 0, 0)
				local predictedPosition = (character.PrimaryPart.CFrame or character.HumanoidRootPart.CFrame).Position + direction * math_random(5, 12)

				newcharRoot.CFrame = CFrame.new(predictedPosition)
				newcharRoot.Velocity = Vector3_new(9e7, 9e7 * 10, 9e7)
				newcharRoot.RotVelocity = Vector3_new(9e8, 9e8, 9e8)
			else
				flinging = false
				connection:Disconnect()
				--break
			end
		else
			flinging = false
			connection:Disconnect()
			--break
		end
	end)

end

getgenv().fling = function(character, time, yield)
	setdestroyheight(NaN)
	local yield = yield or false
	if yield then
		flinginternal(character, time)
	else
		tspawn(flinginternal, character, time)
	end
end

local function disableCollisions()
	pcall(function()
		for _, char in ipairs({ newChar }) do
			for _, obj in ipairs(GetDescendants(char)) do
				if IsA(obj, "BasePart") then
					obj.CanCollide = false
					obj.Massless = true
				end
			end
		end
	end)
end

local function disableCollisionsWithFakeChar()
	pcall(function()
		for _, char in ipairs({ newChar, char }) do
			for _, obj in ipairs(GetDescendants(char)) do
				if IsA(obj, "BasePart") then
					obj.CanCollide = false
					obj.Massless = true
				end
			end
		end
	end)
end

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(stepReanimate)

local humanoidnewchar = newChar:WaitForChild("Humanoid")

humanoidnewchar.PlatformStand = true
humanoidnewchar.AutoRotate = false

if fakecollisions then
	RunService.PreSimulation:Connect(disableCollisions)
else
	RunService.PreSimulation:Connect(disableCollisionsWithFakeChar)
end

workspace.CurrentCamera.CameraSubject = char:WaitForChild("Humanoid")

finished = true


local uis = game:GetService("UserInputService")
uis.InputBegan:Connect(function(k,chatting)
	if chatting then return end
if k.KeyCode == Enum.KeyCode.Comma then 
desiredmode = not desiredmode
elseif k.KeyCode == Enum.KeyCode.Minus then 
    roothidecf = fakecharRoot.CFrame
end
end) 
newcharRoot.Transparency = 0.5
	local speaker = game:GetService("Players").LocalPlayer
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	antifling = RunService.Stepped:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= speaker and player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
		end
	end)
	local seatdebounce = 3 
local cansit = true 
	char:FindFirstChild("Left Leg").Touched:Connect(function(p)
    if p:IsA("Seat") and cansit == true then 
        local sw = Instance.new("Weld",p)
        sw.Name = "SeatWeld"
        sw.Part0 = p 
        sw.Part1 = char:FindFirstChild("HumanoidRootPart")
        sw.C0 = CFrame.new(0, 0.2, 0, 1, 0, -0, 0, 0, 1, 0, -1, 0)
        sw.C1 = CFrame.new(0, -1.5, 0, 1, 0, -0, 0, 0, 1, 0, -1, 0)
         char:FindFirstChildOfClass("Humanoid").Sit = true
        char:FindFirstChildOfClass("Humanoid").Jumping:Wait()
        sw:Destroy()
         char:FindFirstChildOfClass("Humanoid").Sit = false 
         cansit = false
         task.spawn(function()
             task.wait(seatdebounce)
             cansit = true 
             end)
    end 
	end) 
 pcall(function()
     char.ForceField:Destroy()
 end)
  pcall(function()
     char.OverheadGUI:Destroy()
 end)
_G.Reanimate = {
	fling = getgenv().fling,
}
_G.Character = game.Players.LocalPlayer.Character
elseif Reanimate == "Gelatek" then
--[[
	Gelatek - Everything
	Emper - Optimization Tips
	Syndi/Mizt - Hat Renamer (to be changed with own one later)
]]
local Game = game
local RunService = Game:GetService("RunService")
local StartGui = Game:GetService("StarterGui")
local TestService = Game:GetService("TestService")
local Workspace = Game:GetService("Workspace")
local Players = Game:GetService("Players")
local PreSim = RunService.PreSimulation
local PostSim = RunService.PostSimulation
local CurrentCam = Workspace.CurrentCamera

local Speed = tick()
local Warn = warn
local Error = error

local Wait = task.wait
local Infinite = math.huge
local V3new = Vector3.new
local INew = Instance.new
local CFNew = CFrame.new
local CFAngles = CFrame.Angles
local MathRandom = math.random
local Insert = table.insert
local Clear = table.clear
local Type = type

local Global = (getgenv and getgenv()) or shared

if not Global.RayfieldConfig then Global.RayfieldConfig = {} end
local PermanentDeath = Global.RayfieldConfig["Permanent Death"]  or true
local CollideFling = Global.RayfieldConfig["Torso Fling"]  or true
local BulletEnabled = Global.RayfieldConfig["Bullet Enabled"] or false
local KeepHairWelds = Global.RayfieldConfig["Keep Hats On Head"] or true
local HeadlessPerma = Global.RayfieldConfig["Headless On Perma"] or false
local DisableAnimations = Global.RayfieldConfig["Disable Anims"] or false
local Collisions = Global.RayfieldConfig["Enable Collisions"] or false
local AntiVoid = Global.RayfieldConfig["Anti Void"] or true
if CollideFling and BulletEnabled then CollideFling = false end
if not Global.TableOfEvents then Global.TableOfEvents = {} end

local Player = Players.LocalPlayer
local Character = Player.Character
if Character.Name == "GelatekReanimate" then Error("Reanimation Already Working") end
if (not Character:FindFirstChildOfClass("Humanoid")) or Character:FindFirstChildOfClass("Humanoid").Health == 0 then Error("Player Is Dead.") end

local PlayerDied = false
local IGNORETORSOCHECK = "Torso"
local Is_NetworkOwner = isnetworkowner or function(Part) return Part.ReceiveAge == 0 end
local HiddenProps = sethiddenproperty or function() end 

local SpawnPoint = Workspace:FindFirstChildOfClass("SpawnLocation",true) and Workspace:FindFirstChildOfClass("SpawnLocation",true) or CFrame.new(0,20,0)

-- [[ Events ]] --
local PostSimEvent
local PreSimEvent
local TorsoFlingEvent
local DeathEvent
local ResetEvent

local BulletInfo = nil
local HatData = nil

local CF0 = CFNew(0,0,0)
local Velocity = V3new(0,-26,0)


Global.PartDisconnected = false
local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
if not Humanoid then return end
local RootPart = Character:FindFirstChild("HumanoidRootPart")
local R15 = Humanoid.RigType.Name == "R15" and true or false
local Sin, Cos, Inf, Clamp, Clock = math.sin, math.cos, math.huge, math.clamp, os.clock
local FakeHats = INew("Folder"); do FakeHats.Name = "FakeHats"; FakeHats.Parent = TestService end
Character.Archivable = true
Humanoid:ChangeState(16)


for Index, RagdollStuff in pairs(Character:GetDescendants()) do
	if RagdollStuff:IsA("BallSocketConstraint") or RagdollStuff:IsA("HingeConstraint") then
		RagdollStuff:Destroy()
	end
end


-- Mizt's Hat Renamer
local HatsNames = {}
for Index, Accessory in pairs(Character:GetDescendants()) do
	if Accessory:IsA("Accessory") then
		if HatsNames[Accessory.Name] then
			if HatsNames[Accessory.Name] == "Unknown" then
				HatsNames[Accessory.Name] = {}
			end
			Insert(HatsNames[Accessory.Name], Accessory)
		else
			HatsNames[Accessory.Name] = "Unknown"
		end	
	end
end
for Index, Tables in pairs(HatsNames) do
	if Type(Tables) == "table" then
		local Number = 1
		for Index2, Names in ipairs(Tables) do
			Names.Name = Names.Name .. Number
			Number = Number + 1
		end		
	end
end
Clear(HatsNames)

local Figure = INew("Model"); do
	local Limbs = {}
	local Attachments = {}
	local function CreateJoint(Name,Part0,Part1,C0,C1)
		local Joint = INew("Motor6D"); Joint.Name = Name
		Joint.Part0 = Part0; Joint.Part1 = Part1
		Joint.C0 = C0; Joint.C1 = C1
		Joint.Parent = Part0
	end
	for i = 0,18 do
		local Attachment = INew("Attachment")
		Attachment.Axis,Attachment.SecondaryAxis = V3new(1,0,0), V3new(0,1,0)
		Insert(Attachments, Attachment)
	end
	for i = 0,3 do
		local Limb = INew("Part")
		Limb.Size = V3new(1, 2, 1); Limb.CanCollide = false
		Limb.Parent = Figure
		Insert(Limbs, Limb)
	end
	Limbs[1].Name = "Right Arm"; Limbs[2].Name = "Left Arm"
	Limbs[3].Name = "Right Leg"; Limbs[4].Name = "Left Leg"
	local Head = INew("Part")
	Head.Size = V3new(2,1,1)
	Head.Locked = true; Head.CanCollide = false
	Head.Name = "Head"
	Head.Parent = Figure
	local Torso = INew("Part")
	Torso.Size = V3new(2, 2, 1)
	Torso.Locked = true; Torso.CanCollide = false
	Torso.Name = "Torso"
	Torso.Parent = Figure
	local Root = Torso:Clone()
	Root.Transparency = 1
	Root.Name = "HumanoidRootPart"
	Root.Parent = Figure
	CreateJoint("Neck", Torso, Head, CFNew(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFNew(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0))
	CreateJoint("RootJoint", Root, Torso, CFNew(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFNew(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0))
	CreateJoint("Right Shoulder", Torso, Limbs[1], CFNew(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0), CFNew(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0))
	CreateJoint("Left Shoulder", Torso, Limbs[2], CFNew(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFNew(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
	CreateJoint("Right Hip", Torso, Limbs[3], CFNew(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0), CFNew(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0))
	CreateJoint("Left Hip", Torso, Limbs[4], CFNew(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFNew(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
	local Humanoid = INew("Humanoid")
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	Humanoid.Parent = Figure
	local Animator = INew("Animator", Humanoid)
	local HumanoidDescription = INew("HumanoidDescription", Humanoid)
	local HeadMesh = INew("SpecialMesh")
	HeadMesh.Scale = V3new(1.25, 1.25, 1.25)
	HeadMesh.Parent = Head
	local Face = INew("Decal")
	Face.Name = "face"
	Face.Texture = "http://www.roblox.com/asset/?id=158044781"
	Face.Parent = Head
	local Animate = INew("LocalScript")
	Animate.Name = "Animate"
	Animate.Parent = Figure
	local Health = INew("Script")
	Health.Name = "Health"
	Health.Parent = Figure
	Attachments[1].Name = "FaceCenterAttachment"; Attachments[1].Position = V3new(0, 0, 0)
	Attachments[2].Name = "FaceFrontAttachment"; Attachments[2].Position = V3new(0, 0, -0.6)
	Attachments[3].Name = "HairAttachment"; Attachments[3].Position = V3new(0, 0.6, 0)
	Attachments[4].Name = "HatAttachment"; Attachments[4].Position = V3new(0, 0.6, 0)
	Attachments[5].Name = "RootAttachment"; Attachments[5].Position = V3new(0, 0, 0)
	Attachments[6].Name = "RightGripAttachment"; Attachments[6].Position = V3new(0, -1, 0)
	Attachments[7].Name = "RightShoulderAttachment"; Attachments[7].Position = V3new(0, 1, 0)
	Attachments[8].Name = "LeftGripAttachment"; Attachments[8].Position = V3new(0, -1, 0)
	Attachments[9].Name = "LeftShoulderAttachment"; Attachments[9].Position = V3new(0, 1, 0)
	Attachments[10].Name = "RightFootAttachment"; Attachments[10].Position = V3new(0, -1, 0)
	Attachments[11].Name = "LeftFootAttachment"; Attachments[11].Position = V3new(0, -1, 0)
	Attachments[12].Name = "BodyBackAttachment"; Attachments[12].Position = V3new(0, 0, 0.5)
	Attachments[13].Name = "BodyFrontAttachment"; Attachments[13].Position = V3new(0, 0, -0.5)
	Attachments[14].Name = "LeftCollarAttachment"; Attachments[14].Position = V3new(-1, 1, 0)
	Attachments[15].Name = "NeckAttachment"; Attachments[15].Position = V3new(0, 1, 0)
	Attachments[16].Name = "RightCollarAttachment"; Attachments[16].Position = V3new(1, 1, 0)
	Attachments[17].Name = "WaistBackAttachment"; Attachments[17].Position = V3new(0, -1, 0.5)
	Attachments[18].Name = "WaistCenterAttachment"; Attachments[18].Position = V3new(0, -1, 0)
	Attachments[19].Name = "WaistFrontAttachment"; Attachments[19].Position = V3new(0, -1, -0.5)
	Attachments[1].Parent = Head; Attachments[2].Parent = Head; Attachments[3].Parent = Head Attachments[4].Parent = Head
	Attachments[5].Parent = Root
	Attachments[6].Parent = Limbs[1]; Attachments[7].Parent = Limbs[1]
	Attachments[8].Parent = Limbs[2]; Attachments[9].Parent = Limbs[2]
	Attachments[10].Parent = Limbs[3]; Attachments[11].Parent = Limbs[4]
	for i = 0,7 do Attachments[12 + i].Parent = Torso end
	Figure.Name = "GelatekReanimate"
	Figure.PrimaryPart = Head
	Figure.Archivable = true
	Figure.Parent = Workspace
	Figure:MoveTo(RootPart.Position)
end

local FigureHum = Figure:FindFirstChildWhichIsA("Humanoid")
Figure:MoveTo(Character.Head.Position + V3new(0, 2.5, 0))
for i,v in pairs(Figure:GetDescendants()) do
	if v:IsA("BasePart") or v:IsA("Decal") then
		v.Transparency = 1
	end
end

local FigureDescendants = Figure:GetDescendants()
local CharacterChildren = Character:GetChildren()

local function VoidEvent()
	if AntiVoid == true then
		Figure:MoveTo(SpawnPoint.Position)
	else
		if PostSimEvent then PostSimEvent:Disconnect() end
		if PreSimEvent then PreSimEvent:Disconnect() end
		if DeathEvent then DeathEvent:Disconnect() end
		if TorsoFlingEvent then TorsoFlingEvent:Disconnect() end
		if ResetEvent then ResetEvent:Disconnect() end
		if FakeHats then FakeHats:Destroy() end
		pcall(function()
			CurrentCam.FieldOfView = 70
			Global.Stopped = true
			for i,v in pairs(Global.TableOfEvents) do v:Disconnect() end
			Character.Parent = Workspace
			Player.Character = Workspace[Character.Name]
			Humanoid:ChangeState(15)
			if Figure then Figure:Destroy() end
			if TestService:FindFirstChild("ScriptCheck") then
				TestService:FindFirstChild("ScriptCheck"):Destroy()
			end
			Wait(0.125)
			Global.RealChar = nil
			Global.Stopped = false
		end)
	end
end

		
for i,v in pairs(Character:GetDescendants()) do -- Disable Scripts / Accessories
	if v:IsA("BasePart") then
		v.RootPriority = 127
		local ClaimInfo = INew("SelectionBox"); do
			ClaimInfo.Adornee = v
			ClaimInfo.Name = "ClaimCheck"
			ClaimInfo.Transparency = 1
			ClaimInfo.Parent = v
		end
	end
	
	if v:IsA("Motor6D") and v.Name ~= "Neck" then
		v:Destroy()
	end
	
	if v:IsA("Script") then
		v.Disabled = true
	end
	
	if v:IsA("Accessory") then
		local FakeAccessory = v:Clone()
		local Handle = FakeAccessory:FindFirstChild("Handle")
		if Handle then
		pcall(function() Handle:FindFirstChildWhichIsA("Weld"):Destroy() end)
		local Weld = INew("Weld"); do
			Weld.Name = "AccessoryWeld"
			Weld.Part0 = Handle
		end
		local Attachment = Handle:FindFirstChildOfClass("Attachment")
		if Attachment then
			Weld.C0 = Attachment.CFrame
			Weld.C1 = Figure:FindFirstChild(tostring(Attachment), true).CFrame
			Weld.Part1 = Figure:FindFirstChild(tostring(Attachment), true).Parent
		else
			Weld.Part1 = Figure:FindFirstChild("Head")
			Weld.C1 = CFNew(0,Figure:FindFirstChild("Head").Size.Y / 2,0) * FakeAccessory.AttachmentPoint:Inverse()
		end
		Handle.CFrame = Weld.Part1.CFrame * Weld.C1 * Weld.C0:Inverse()
		Handle.Transparency = 1
		Weld.Parent = Handle
		FakeAccessory.Parent = Figure
		local FakeAccessory2 = FakeAccessory:Clone()
		FakeAccessory2.Parent = FakeHats
		end
	end
end
for i, v in next, Humanoid:GetPlayingAnimationTracks() do
	v:Stop();
end

if BulletEnabled == true then
	if R15 == false then
		if PermanentDeath == true then
			Character:FindFirstChild("HumanoidRootPart").Name = "Bullet"
			BulletInfo = {Character:FindFirstChild("Bullet"), Figure:FindFirstChild("HumanoidRootPart"), CF0}
			HatData = nil
		else
			Character:FindFirstChild("Right Leg").Name = "Bullet"
			BulletInfo = {Character:FindFirstChild("Bullet"), Figure:FindFirstChild("Right Leg"), CF0}
			if Character:FindFirstChild("Robloxclassicred") then
				HatData = {Character:FindFirstChild("Robloxclassicred"), Figure:FindFirstChild("Right Leg"), CFAngles(math.rad(90),0,0)}
				Character:FindFirstChild("Robloxclassicred").Handle:FindFirstChild("Mesh"):Destroy()
			else HatData = nil end
		end
	else
		Character:FindFirstChild("LeftUpperArm").Name = "Bullet"
		BulletInfo = {Character:FindFirstChild("Bullet"), Figure:FindFirstChild("Left Arm"), CFNew(0, 0.4085, 0)}
		if Character:FindFirstChild("SniperShoulderL") then
			HatData = {Character:FindFirstChild("SniperShoulderL"), Figure:FindFirstChild("Left Arm"), CFNew(0, 0.5, 0)}
		else HatData = nil end
	end
	if HatData then
		HatData[1].Handle:BreakJoints()
	end
	
	local Bullet = Character:FindFirstChild("Bullet")
	local Highlight = INew("SelectionBox"); do
		local Extra 
		Highlight.Adornee = Bullet
		Highlight.Name = "Highlight"
		Highlight.Color3 = Color3.fromRGB(0, 223, 37)
		Highlight.Parent = Bullet
		Extra = PreSim:Connect(function()
			if not Figure and Figure.Parent then Extra:Disconnect() end
			if (not TestService:FindFirstChild("ScriptCheck")) or Figure:FindFirstChild("AnimPlayer") then
				Highlight.Transparency = 1
			else
				Highlight.Transparency = 0
			end
		end)
	end
end

-- Collide Fling
if CollideFling == true then
	if R15 == false then
		local Torso = Character:FindFirstChild("Torso")
		if PermanentDeath == true then
			IGNORETORSOCHECK = "adfasdkogpasdfjopghsfdjofipsdjghsfopgjospadgjsaj"
			task.spawn(function()
				Wait(1)
				local BodyAngularVelocity = INew("BodyAngularVelocity")
				BodyAngularVelocity.MaxTorque = V3new(1,1,1) * Infinite
				BodyAngularVelocity.P = math.huge
				BodyAngularVelocity.AngularVelocity = V3new(1950,1950,1950)
				BodyAngularVelocity.Name = "TorsoFlinger"
				BodyAngularVelocity.Parent = Character:FindFirstChild("HumanoidRootPart")
			end)
		else
			TorsoFlingEvent = PostSim:Connect(function()
				if FigureHum.MoveDirection.Magnitude < 0.1 then
					Torso.Velocity = Velocity
				elseif FigureHum.MoveDirection.Magnitude > 0.1 then
					Torso.Velocity = V3new(1250,1250,1250)+Velocity
				end
			end)
		end
	else
		local Torso = Character:FindFirstChild("UpperTorso")
		TorsoFlingEvent = PostSim:Connect(function()
			if FigureHum.MoveDirection.Magnitude < 0.1 then
				Torso.RotVelocity = V3new()
			elseif FigureHum.MoveDirection.Magnitude > 0.1 then
				Torso.RotVelocity = V3new(2500,2500,2500)
			end
		end)
	end
end

if not TestService:FindFirstChild("OwnershipBoost") then
	local Part = INew("Part")
	Part.Name = "OwnershipBoost"
	Part.Parent = TestService
	PreSim:Connect(function()
		HiddenProps(Player, "MaximumSimulationRadius", 10e+5)
		HiddenProps(Player, "SimulationRadius", Player.MaximumSimulationRadius)
	end)
end
local FallHeight = Workspace.FallenPartsDestroyHeight
local function MiniRandom() return "0." .. MathRandom(6, 8) .. MathRandom(1, 9) .. MathRandom(1, 9) end
PreSimEvent = PreSim:Connect(function() -- Noclip
	local AntiVoidOffset = Global.RayfieldConfig["Anti Void Offset"] or 75
	if Figure.HumanoidRootPart.Position.Y <= FallHeight + AntiVoidOffset then VoidEvent() end
	for _,v in pairs(CharacterChildren) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	
	if not Collisions then
		for _,v in pairs(FigureDescendants) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

for i,v in pairs(Character:GetDescendants()) do -- Break Joints
	if v:IsA("Motor6D") and v.Name ~= "Neck" then
		v:Destroy()
	end
end

for i,v in pairs(Character:GetChildren()) do
	if v:IsA("Accessory") then
		local Attachment = v.Handle:FindFirstChildWhichIsA("Attachment")
		if KeepHairWelds == true and Attachment.Name ~= "HatAttachment" and Attachment.Name ~= "FaceFrontAttachment" and Attachment.Name ~= "HairAttachment" and Attachment.Name ~= "FaceCenterAttachment" then
			if v:FindFirstChild("Handle") then
			v.Handle:BreakJoints()
			end
		end
		if KeepHairWelds == false or PermanentDeath == true then -- Overwrites the check if perma is on
			if v:FindFirstChild("Handle") then
			v.Handle:BreakJoints()
			end
		end
	end
end

local function Align(Part0, Part1, Offset)
	local CFOffset = Offset or CF0
	local OwnerShip = Part0:FindFirstChild("ClaimCheck")
	if Is_NetworkOwner(Part0) == true then
		if OwnerShip then OwnerShip.Transparency = 1 end
		if (CollideFling and Part0.Name ~= IGNORETORSOCHECK) or not CollideFling then 
			Part0.AssemblyLinearVelocity = V3new(MathRandom(-2,2), -30 - MiniRandom(), MathRandom(-2,2)) + FigureHum.MoveDirection * (Part0.Mass * 10)
		end
		if (CollideFling and Part0.Name ~= "HumanoidRootPart") or not CollideFling then Part0.RotVelocity = Part1.RotVelocity end
		Part0.CFrame = Part1.CFrame * CFOffset * CFNew(0.0085 * Cos(Clock() * 10), 0.0085 * Sin(Clock() * 10), 0)
	else
		if OwnerShip then OwnerShip.Transparency = 0 end
	end
end

local Offsets;
if not R15 then 
	Offsets = {
		["HumanoidRootPart"] = {Figure:FindFirstChild("HumanoidRootPart"), CF0},
		["Torso"] = {Figure:FindFirstChild("Torso"), CF0},
		["Right Arm"] = {Figure:FindFirstChild("Right Arm"), CF0},
		["Left Arm"] = {Figure:FindFirstChild("Left Arm"), CF0},
		["Right Leg"] = {Figure:FindFirstChild("Right Leg"), CF0},
		["Left Leg"] = {Figure:FindFirstChild("Left Leg"), CF0},
	}
else 
	Offsets = {
		["UpperTorso"] = {Figure:FindFirstChild("Torso"), CFNew(0, 0.194, 0)},
		["LowerTorso"] = {Figure:FindFirstChild("Torso"), CFNew(0, -0.79, 0)},
		["HumanoidRootPart"] = {Character:FindFirstChild("UpperTorso"), CF0},
		
		["RightUpperArm"] = {Figure:FindFirstChild("Right Arm"), CFNew(0, 0.4085, 0)},
		["RightLowerArm"] = {Figure:FindFirstChild("Right Arm"), CFNew(0, -0.184, 0)},
		["RightHand"] = {Figure:FindFirstChild("Right Arm"), CFNew(0, -0.83, 0)},

		["LeftUpperArm"] = {Figure:FindFirstChild("Left Arm"), CFNew(0, 0.4085, 0)},
		["LeftLowerArm"] = {Figure:FindFirstChild("Left Arm"), CFNew(0, -0.184, 0)},
		["LeftHand"] = {Figure:FindFirstChild("Left Arm"), CFNew(0, -0.83, 0)},

		["RightUpperLeg"] = {Figure:FindFirstChild("Right Leg"), CFNew(0, 0.575, 0)},
		["RightLowerLeg"] = {Figure:FindFirstChild("Right Leg"), CFNew(0, -0.199, 0)},
		["RightFoot"] = {Figure:FindFirstChild("Right Leg"), CFNew(0, -0.849, 0)},

		["LeftUpperLeg"] = {Figure:FindFirstChild("Left Leg"), CFNew(0, 0.575, 0)},
		["LeftLowerLeg"] = {Figure:FindFirstChild("Left Leg"), CFNew(0, -0.199, 0)},
		["LeftFoot"] = {Figure:FindFirstChild("Left Leg"), CFNew(0, -0.849, 0)}
	}
end

local PostSimEvent = PostSim:Connect(function()
	for i,v in pairs(Offsets) do -- Body Align [2]
		if Character:FindFirstChild(i) then
			Align(Character:FindFirstChild(i), v[1], v[2])
		end
	end
	for i,v in pairs(CharacterChildren) do
		if v:IsA("Accessory") then
			if (HatData and v.Name ~= HatData[1].Name) or not HatData then
				if v:FindFirstChild("Handle") then
				Align(v.Handle, Figure[v.Name].Handle)
				end
			end
		end
	end
	if HatData then
		if HatData[1]:FindFirstChild("Handle") then
		Align(HatData[1].Handle, HatData[2], HatData[3])
		end
	end
	if BulletInfo then
		BulletInfo[1].Velocity = Velocity
		if Global.PartDisconnected == false then
			Align(BulletInfo[1], BulletInfo[2], BulletInfo[3])
		end
	end
end)

-- Permanent Death
if PermanentDeath then
	task.spawn(function()
		Wait(game:FindFirstChildWhichIsA("Players").RespawnTime + 0.5)
		if HeadlessPerma == true then
			Character:FindFirstChild("Head"):Remove()
		else
			Character:FindFirstChild("Head"):BreakJoints()
			Offsets["Head"] = {Figure:FindFirstChild("Head"), CF0}
		end
	end)
end

-- Ending Process
Global.RealChar = Character	
Character.Parent = Figure
Player.Character = Figure
CurrentCam.CameraSubject = FigureHum

DeathEvent = FigureHum.Died:Connect(function()
	if PostSimEvent then PostSimEvent:Disconnect() end
	if PreSimEvent then PreSimEvent:Disconnect() end
	if DeathEvent then DeathEvent:Disconnect() end
	if TorsoFlingEvent then TorsoFlingEvent:Disconnect() end
	if ResetEvent then ResetEvent:Disconnect() end
	if FakeHats then FakeHats:Destroy() end
	for i,v in pairs(Global.TableOfEvents) do v:Disconnect() end
	pcall(function()
		CurrentCam.FieldOfView = 70
		Global.Stopped = true
		Character.Parent = Workspace
		Player.Character = Workspace[Character.Name]
		Humanoid:ChangeState(15)
		if Figure then Figure:Destroy() end
		if TestService:FindFirstChild("ScriptCheck") then
			TestService:FindFirstChild("ScriptCheck"):Destroy()
		end
		Wait(0.125)
		Global.RealChar = nil
		Global.Stopped = false
	end)
end)

ResetEvent = Character:GetPropertyChangedSignal("Parent"):Connect(function(Parent)
	if Parent == nil then
		if PostSimEvent then PostSimEvent:Disconnect() end
		if PreSimEvent then PreSimEvent:Disconnect() end
		if DeathEvent then DeathEvent:Disconnect() end
		if TorsoFlingEvent then TorsoFlingEvent:Disconnect() end
		if ResetEvent then ResetEvent:Disconnect() end
		if FakeHats then FakeHats:Destroy() end
		for i,v in pairs(Global.TableOfEvents) do v:Disconnect() end
		pcall(function()
			if Figure then Figure:Destroy() end
			CurrentCam.FieldOfView = 70
			Global.RealChar = nil
			Global.Stopped = true
			if TestService:FindFirstChild("ScriptCheck") then TestService:FindFirstChild("ScriptCheck"):Destroy() end
			Wait(0.125)
			Global.Stopped = false
		end)
	end
end)

Warn("Reanimated in " .. string.sub(tostring(tick()-Speed),1,string.find(tostring(tick()-Speed),".")+5))
if not DisableAnimations then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Gelatekussy/GelatekReanimate/main/Addons/Animations.lua"))()
end
Wait(game:FindFirstChildWhichIsA("Players").RespawnTime + 0.5)
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