local function GetGitSound(GithubSnd,SoundName,sound)
    local url=GithubSnd
    if not isfile(SoundName..".mp3") then
        writefile(SoundName..".mp3", game:HttpGet(url))
    end
    sound.SoundId=(getcustomasset or getsynasset)(SoundName..".mp3")
    sound.TimePosition = 0
    return sound
end
local originSpeed = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed
local linkMain = "https://github.com/Kiprov/Utilities/blob/main/DOORS/Baldi%20Seek/SFX/SchoolhouseEscape.mp3?raw=true"
local link1 = "https://github.com/Kiprov/Utilities/blob/main/DOORS/Baldi%20Seek/SFX/Exit1.mp3?raw=true"
local link2 = "https://github.com/Kiprov/Utilities/blob/main/DOORS/Baldi%20Seek/SFX/Exit2.mp3?raw=true"
local link3 = "https://github.com/Kiprov/Utilities/blob/main/DOORS/Baldi%20Seek/SFX/Exit3.mp3?raw=true"
local notebooks = "https://github.com/Kiprov/Utilities/blob/main/DOORS/Baldi%20Seek/SFX/BaldiAngry.mp3?raw=true"
local sequence = 0
local tint = game.Lighting.MainColorCorrection
local connection
connection = game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function()
wait(3.5)
if not workspace:FindFirstChild("SeekMovingNewClone") then sequence = -1 print(sequence) return end
    local RealSeek = workspace:FindFirstChild("SeekMovingNewClone")
    local RealFigure = RealSeek:FindFirstChild("Figure")
    local RealSeekRig = RealSeek:FindFirstChild("SeekRig")
    RealSeekRig.Head.Eye:Destroy()
    RealSeekRig.Head.Black:Destroy()
    RealSeekRig.SeekPuddle:Destroy()
    spawn(function()
        while game["Run Service"].Heartbeat:Wait() and RealSeek do
            for i,v in pairs(RealSeek.Figure:GetChildren()) do
                RealSeek.Figure.Footsteps:Stop()
                RealSeek.Figure.FootstepsFar:Stop()
            end
            for i,v in pairs(RealSeekRig:GetChildren()) do
                if v:IsA("BasePart") then
                    v.Transparency = 1
                    elseif v:IsA("Beam") then
                    v.Enabled = false
                end
            end
        end
    end)
    local idle = "rbxassetid://2355911010"
local slapID = "rbxassetid://5666700248"
local frame1,frame2,frame3,frame4,frame5 = "rbxassetid://2113157767","rbxassetid://2113159514","rbxassetid://2113160411","rbxassetid://2113160988","rbxassetid://2113157176"
local gui = Instance.new("BillboardGui",RealFigure)
gui.Enabled = true
gui.Size = UDim2.new(5,0,9,0)
local gui2 = gui:Clone()
gui2.Parent = RealFigure
local idleImage = Instance.new("ImageLabel",gui)
idleImage.Size = UDim2.new(1,0,1,0)
idleImage.BackgroundTransparency = 1
local slap1,slap2,slap3,slap4,slap5 = idleImage:Clone(),idleImage:Clone(),idleImage:Clone(),idleImage:Clone(),idleImage:Clone()
local slapSnd = Instance.new("Sound",RealFigure)
local angrySnd = slapSnd:Clone()
slapSnd.Volume = 0.5
angrySnd.Volume = 2
angrySnd.MaxDistance = 100
angrySnd.RollOffMode = "InverseTapered"
angrySnd.Parent = RealFigure
slapSnd.SoundId = slapID
slapSnd.MaxDistance = 100
slapSnd.RollOffMode = "InverseTapered"
slap1.Image = frame1
slap1.Name = "1"
slap2.Image = frame2
slap2.Name = "2"
slap3.Image = frame3
slap3.Name = "3"
slap4.Image = frame4
slap4.Name = "4"
slap5.Image = frame5
slap5.Name = "5"
idleImage.Image = idle
idleImage.Name = "Idle"
slap1.Parent = gui2
slap2.Parent = gui2
slap3.Parent = gui2
slap4.Parent = gui2
slap5.Parent = gui2
slap2.Visible = false
slap3.Visible = false
slap4.Visible = false
slap5.Visible = false
gui2.Enabled = false
local ANGRY = GetGitSound(notebooks,"BAL_7NotebooksNULL",angrySnd)
local function Slap(time)
wait(time)
slapSnd:Play()
for i = #gui2:GetChildren(),0,-1 do
if i ~= 0 then
gui2[i].Visible = true
wait(0.05)
gui2[i].Visible = false
else
slap5.Visible = true
end
end
for i = 1,#gui2:GetChildren() do
gui2[i].Visible = true
wait(0.05)
gui2[i].Visible = false
end
slapSnd:Stop()
end
    local seksound = RealSeek.SeekMusic
    local baldsound = GetGitSound(linkMain,"SchoolhouseEscape",seksound)
    seksound.Played:Connect(function()
    sequence = -1
    spawn(function()
    game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()
    sequence = 0
    end)
    ANGRY:Play()
    wait(7)
            gui.Enabled = false
            gui2.Enabled = true
            Slap(0)
            Slap(0)
            Slap(0)
            Slap(0)
            spawn(function()
        while true do
        Slap(0)
        end
        end)
            end)
            spawn(function()
            game.ReplicatedStorage.GameData.LatestRoom.Changed:Connect(function()
            if sequence == 0 then
            local baldsound = GetGitSound(link1,"Exit1",seksound)
            sequence += 1
            local tween1 = game.TweenService:Create(tint,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TintColor = Color3.new(1,0,0)})
            tween1:Play()
            elseif sequence == 1 then
            local baldsound = GetGitSound(link2,"Exit2",seksound)
            sequence += 1
            local tween1 = game.TweenService:Create(tint,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Contrast = 0.2, Saturation = -0.7})
            tween1:Play()
            elseif sequence == 2 then
            local baldsound = GetGitSound(link3,"Exit3",seksound)
            sequence += 1
            local tween1 = game.TweenService:Create(tint,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Brightness = -0.3,Contrast = 1, Saturation = 0.5})
            tween1:Play()
            elseif game.Players.LocalPlayer.Character.Humanoid.WalkSpeed == originSpeed then
            sequence = -1
            local tween1 = game.TweenService:Create(tint,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{TintColor = Color3.new(1,1,1),Brightness = 0,Contrast = 0, Saturation = 0})
            tween1:Play()
            baldsound.Ended:Wait()
            local baldsound = GetGitSound(linkMain,"SchoolhouseEscape",seksound)
            end
            end)
            end)
        end)
print("Baldi Seek Skin Mod is running!")
