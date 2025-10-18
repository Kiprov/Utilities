local Hatless = {}
local Motors = {
["Left Hip"] = 0,
["Neck"] = 0,
["Left Shoulder"] = 0,
["Right Hip"] = 0,
["Right Shoulder"] = 0
}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
game.Players.LocalPlayer.Character.Archivable = true
local FakeCharacter = game.Players.LocalPlayer.Character:Clone()
Hatless.FakeCharacter = FakeCharacter

Player.Character:BreakJoints()
Player.Character = nil
coroutine.wrap(function()
local Connection
Connection = game.Workspace.DescendantAdded:Connect(function(c)
if c.Name == "Animate" and c.Parent == Player.Character then
c.Enabled = false
Connection:Disconnect()
end
end)

repeat task.wait() until game.Players.LocalPlayer.Character
task.wait(0.1)
local RealChar = Player.Character
RealChar.Archivable = true
FakeCharacter.Name = Player.Name .. "_Fake"
FakeCharacter.Parent = workspace
RealChar:WaitForChild("Humanoid"):ChangeState(16)
workspace.FallenPartsDestroyHeight = 0/0
task.spawn(function()
for i, LS in ipairs(FakeCharacter:GetChildren()) do
if LS:IsA("LocalScript") then
LS.Enabled = false
task.wait(0.1)
LS.Enabled = false
end
end
end)

for i, Part in ipairs(FakeCharacter:GetDescendants()) do
if Part:IsA("BasePart") and Part.Name ~= "HumanoidRootPart" then
Part.Transparency = 0.75
end
end

for i, Decal in ipairs(FakeCharacter:GetDescendants()) do
if Decal:IsA("Decal") then
Decal.Transparency = 0.75
end
end
workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
Player.Character = FakeCharacter
RealChar.Parent = FakeCharacter
local function MotorAngle()
if RealChar:FindFirstChild("Torso") then
for MotorName, Motor6DAngle in pairs(Motors) do
if RealChar:FindFirstChild("Torso"):FindFirstChild(MotorName) then
RealChar:FindFirstChild("Torso"):FindFirstChild(MotorName).CurrentAngle = Motor6DAngle
RealChar:FindFirstChild("Torso"):FindFirstChild(MotorName).DesiredAngle = Motor6DAngle
end
end
end
end
local function SetAngles()
if FakeCharacter:FindFirstChild("Torso") then
for MotorName, Motor6DAngle in pairs(Motors) do
if FakeCharacter:FindFirstChild("Torso"):FindFirstChild(MotorName) then
local Motor = FakeCharacter:FindFirstChild("Torso"):FindFirstChild(MotorName)
local rx, ry, rz = Motor.Part1.CFrame:ToObjectSpace(FakeCharacter:FindFirstChild("Torso").CFrame):ToEulerAnglesXYZ()
if Motor.Name == "Right Shoulder" then
Motors[MotorName] = -rx
end
if Motor.Name == "Left Shoulder" then
Motors[MotorName] = rx
end
if Motor.Name == "Right Hip" then
Motors[MotorName] = -rx
end
if Motor.Name == "Left Hip" then
Motors[MotorName] = rx
end
if Motor.Name == "Neck" then
Motors[MotorName] = -ry
end
end
end
end
end

local function BaseCol()
for i, Part in ipairs(RealChar:GetChildren()) do
if Part:IsA("BasePart") then
Part.CanCollide = false
Part.AssemblyLinearVelocity = Vector3.new(0,0,0)
end
end
end
local sin = math.sin
local antisleepMultiplier=Vector3.new(.0025,.005,.0025)
RunService.Heartbeat:Connect(function()
sine=os.clock
local antisleep=sin(sine()*100)*antisleepMultiplier
SetAngles()
MotorAngle()
if RealChar:FindFirstChild("HumanoidRootPart") and FakeCharacter:FindFirstChild("Torso") then
RealChar.HumanoidRootPart.CFrame = FakeCharacter.Torso.CFrame + antisleep
end
end)

RunService.PreSimulation:Connect(function()
BaseCol()
end)

end)()

return Hatless
