--[[
                                                                            
Awesome's Easily Customizable F3X Reanimate.
[Also known as F3Xanim8ion, very original name. I know.]

- Made By: Awesomeboy74001/Hahayeshfunny (ON ROBLOX), mverb (ON DISCORD).
- Made For: The beginners of F3X exploiting :3 (you guys).
- Version: 1.0.2.

,-,
|Ü| Enjoy the script!
'-'
Edited by Kip.
]]

--// Options

Mode = "Normal" -- Made this so you can easily add your OWN characters!

--[[
These are the following moves you can use down there.
vvvvv
Normal
Noob
Gee Cee
Shownape
]]

--// Reanimate Starts Here
--// F3X Wrapper
getgenv().F3X = loadstring(game:HttpGet("https://raw.githubusercontent.com/bqmb3/f3x-wrapper/main/loader.lua",true))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()

--// Variables
local torso = chr.Torso
local head  = chr.Head
local humanoid = chr.Humanoid
local larm  = chr["Left Arm"]
local rarm  = chr["Right Arm"]
local lleg  = chr["Left Leg"]
local rleg  = chr["Right Leg"]

--// Random name
local function randomstring()
	local len = math.random(10, 20)
	local t = {}
	for i = 1, len do
		t[i] = string.char(math.random(32, 126))
	end
	return table.concat(t)
end

--// Hide Character
for _, p in ipairs({rleg, rarm, lleg, larm, torso, head}) do
    F3X:SetTransparency(p, 1)
end
if head:FindFirstChild("face") then F3X:SetTransparency(head.face, 1) end

for _, acc in ipairs(chr:GetChildren()) do
	if acc:IsA("Accessory") or acc:IsA("Hat") then
		local h = acc:FindFirstChild("Handle")
		if h then F3X:SetTransparency(h, 1) end
	end
end

--// Add Parts
getgenv().addPart = function(name,size,col,m,t,s,o)
	col = col or Color3.fromRGB(163, 162, 165)
	s = s or Vector3.one
	o = o or Vector3.zero
	t = t or 0
	local aa = F3X:CreatePart("Normal", torso.CFrame + Vector3.new(0, 1000, 0))
	if m ~= nil then
	    --// Creation of the file mesh and properties.
		F3X:CreateMeshesOnParts({aa})
		F3X:SetMeshes({{["Part"] = aa, ["MeshType"] = Enum.MeshType.FileMesh, ["Scale"] = s, ["Offset"] = o, ["MeshId"] = "rbxassetid://"..m, ["TextureId"] = "rbxassetid://"..t}})
	end
	--// Changing server part properties.
	F3X:SetName(aa, randomstring())
	F3X:Resize(aa, size)
	F3X:SetColor(aa, col)
	F3X:SetCollision(aa, false)
	--// Renaming the server part.
	aa.CanTouch = false
	aa.CanQuery = false
	aa.Name = name
	return aa
end

--// Rig Configuration
--This is the part where you can add your own rigs with the simple mode system.
local parts = {}
if Mode == "Normal" then
	parts[#parts + 1] = addPart("torsog", Vector3.new(2,2,1), Color3.fromRGB(163,162,165), 126825022897778)
	parts[#parts + 1] = addPart("headg",  Vector3.new(1,1,1), Color3.fromRGB(163,162,165), 90598001824705)
	parts[#parts + 1] = addPart("leftArmg",  Vector3.new(1,2,1), Color3.fromRGB(163,162,165), 1553264838)
	parts[#parts + 1] = addPart("rightArmg", Vector3.new(1,2,1), Color3.fromRGB(163,162,165), 1553264838)
	parts[#parts + 1] = addPart("leftLegg",  Vector3.new(1,2,1), Color3.fromRGB(163,162,165), 1553264838)
	parts[#parts + 1] = addPart("rightLegg", Vector3.new(1,2,1), Color3.fromRGB(163,162,165), 1553264838)
elseif Mode == "Noob" then
	parts[#parts + 1] = addPart("torsog", Vector3.new(2,2,1), Color3.fromRGB(163, 162, 165),126825022897778, 125975972015302)
	parts[#parts + 1] = addPart("headg", Vector3.new(1,1,1), Color3.fromRGB(163, 162, 165), 90598001824705, 118775118661888)
	parts[#parts + 1] = addPart("leftArmg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),137702817952968, 135650240593878)
	parts[#parts + 1] = addPart("rightArmg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),137702817952968, 135650240593878)
	parts[#parts + 1] = addPart("leftLegg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),137702817952968, 73798034827573)
	parts[#parts + 1] = addPart("rightLegg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),137702817952968, 73798034827573)
elseif Mode == "Gee Cee" then
	parts[#parts + 1] = addPart("torsog", Vector3.new(2,2,1), Color3.fromRGB(163, 162, 165),129421617196869, 97317588751777)
	parts[#parts + 1] = addPart("headg", Vector3.new(1,1,1), Color3.fromRGB(163, 162, 165), 74574560097635, 97317588751777, Vector3.new(1,1,1), Vector3.new(0.05, 0.3, -0.04))
	parts[#parts + 1] = addPart("leftArmg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),100086244609401, 97317588751777)
	parts[#parts + 1] = addPart("rightArmg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),100086244609401, 97317588751777)
	parts[#parts + 1] = addPart("leftLegg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),96582973765612, 97317588751777)
	parts[#parts + 1] = addPart("rightLegg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),96582973765612, 97317588751777)
elseif Mode == "Shownape" then
	parts[#parts + 1] = addPart("torsog", Vector3.new(2,2,1), Color3.fromRGB(163, 162, 165),111645870367299, 112953113919346, Vector3.new(1,1,1), Vector3.new(0.075,0.175,0.025))
	parts[#parts + 1] = addPart("headg", Vector3.new(1,1,1), Color3.fromRGB(163, 162, 165), 74664151205596, 112953113919346, Vector3.new(1,1,1), Vector3.new(0, 0.3, -0.1))
	parts[#parts + 1] = addPart("leftArmg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),100086244609401, 112953113919346)
	parts[#parts + 1] = addPart("rightArmg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),100086244609401, 112953113919346)
	parts[#parts + 1] = addPart("leftLegg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),96582973765612, 112953113919346)
	parts[#parts + 1] = addPart("rightLegg", Vector3.new(1,2,1),Color3.fromRGB(163, 162, 165),96582973765612, 112953113919346)
end

--// Decals

if Mode == "Normal" then
    F3X:CreateTextures({{["Part"] = parts[2], ["Face"] = Enum.NormalId.Front, ["TextureType"] = "Decal"}})
    F3X:SetTextures({{["Part"] = parts[2], ["Face"] = Enum.NormalId.Front, ["TextureType"] = "Decal", ["Texture"] = "rbxasset://textures/face.png"}})
end

--// Cleanup

local function stop()
    F3X:RemoveParts(parts)
end

--// Sync Parts
--This is the part where you can rotate your own rig limbs with the simple mode system.

local leftArmG  = workspace:WaitForChild("leftArmg")
local rightArmG = workspace:WaitForChild("rightArmg")
local leftLegG  = workspace:WaitForChild("leftLegg")
local rightLegG = workspace:WaitForChild("rightLegg")
local torsoG    = workspace:WaitForChild("torsog")
local headG     = workspace:WaitForChild("headg")
local limbs = {["leftArmg"] = larm, ["rightArmg"] = rarm, ["leftLegg"] = lleg, ["rightLegg"] = rleg, ["torsog"] = torso, ["headg"] = head}

getgenv().getCFrameWithOffset = function(part, x, y, z)
	return part.CFrame * CFrame.Angles(
		math.rad(x or 0),
		math.rad(y or 0),
		math.rad(z or 0)
	)
end
local connect = RunService.RenderStepped:Connect(function()
	pcall(function()
		if Mode == "Normal" then
		    for i, v in parts do
		        local cframe = getCFrameWithOffset(limbs[v.Name], 0, (v.Name == "headg" and 180 or 0), 0)
		        F3X:Move(v, cframe)
		    end
		elseif Mode == "Noob" then
		    for i, v in parts do
		        local cframe = getCFrameWithOffset(limbs[v.Name], 0, (v.Name == "headg" and 180 or 0), (v.Name ~= "headg" and 90 or 0))
		        F3X:Move(v, cframe)
		    end
		elseif Mode == "Gee Cee" or Mode == "Shownape" then
		    for i, v in parts do
		        local cframe = getCFrameWithOffset(limbs[v.Name], 0, 180, 0)
		        F3X:Move(v, cframe)
		    end
		end
	end)
end)

--// Stop On Death? [unsure if this works]

humanoid.Died:Once(function()
	connect:Disconnect()
	stop()
end)

--\\ End Reanimate
