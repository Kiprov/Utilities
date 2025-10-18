-- gonna get patched soon, have fun while you still can
Start = function()
local fpdh = workspace.FallenPartsDestroyHeight + 5
local roothidecf = CFrame.new(0,fpdh,0) -- -255





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
 end
 return {Start = Start}
