-- Services

local Players = game:GetService("Players")
local ReSt = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local CG = game:GetService("CoreGui")
local pathfindingService = game:GetService("PathfindingService")
-- Variables
local Plr = Players.LocalPlayer
local Player = Plr
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local tweensv = game:GetService("TweenService")
local Character = Char
local Hum = Char:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

local StaticRushSpeed = 60

local FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
local WorldToViewportPoint = Camera.WorldToViewportPoint

local MainModels = game:GetObjects("rbxassetid://17394237675")[1]
local Portal = MainModels.Repentance
local ToolHandle = nil
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local Camera = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	Camera.CFrame = Camera.CFrame * shakeCf
end)
camShake:Start()


function hell(oldentity,entity)
	local Entity
	camShake:ShakeOnce(10,30,0.7,0.5)

	Entity = oldentity:Clone()
	oldentity:SetAttribute("BeingCrucifixed",true)
	entity:Pause()
	Entity.Name = "Fake_"..oldentity.Name
	Entity.Parent = workspace
	entity:Despawn()

	local primary = Entity.PrimaryPart or Entity:FindFirstChildOfClass("Part")
	task.spawn(function()
		if Entity:GetAttribute("Repent") == "Normal" then
			primary:FindFirstChild("PlaySound"):Stop()
			primary:FindFirstChild("Footsteps"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif Entity:GetAttribute("Repent") == "Quick" then
			primary:FindFirstChild("PlaySound"):Stop()
			primary:FindFirstChild("Footsteps"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentParticle2 = primary.Attachment:FindFirstChild("RepentParticle2")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			wait(1)
			RepentParticle2.Enabled = true
			task.wait(0.8)
			RepentParticle.Enabled = false
			RepentParticle2.Enabled = false
		elseif Entity:GetAttribute("Repent") == "Eyes" then
			primary:FindFirstChild("Ambience"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif Entity:GetAttribute("Repent") == "Screech" then
			primary:FindFirstChild("Sound"):Stop()
			local RepentAnim = entity:FindFirstChild("RepentAnim")
			local RepentSound = primary:FindFirstChild("Crucifix")
			RepentSound:Play()
			RepentAnim.Enabled = true
		else
			--No Repent
		end
	end)

	--CAST A RAY

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { Character, Entity }

	local ray = workspace:Raycast(primary.Position, Vector3.new(0,-1,0) * 20, params)




	local gate = Portal:Clone()
	gate.Parent = workspace

	local pentagram = gate.Pentagram

	if ray then
		local part = Instance.new("Part")
		part.Anchored = true
		part.Position = ray.Position + Vector3.new(0, 1, 0)

		gate:PivotTo(part.CFrame * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, 0))

		part:Destroy()
	end

	--Spinning


	local spinrate = 2
	local crucifix_spin = Instance.new("NumberValue")
	local spinrate_changed = Instance.new("NumberValue")

	local gate_spin = game:GetService("RunService").Heartbeat:Connect(function()
		--pentagram.RingAddonA.Orientation = Vector3.new(0, spinrate, 0)
		--pentagram.RingAddonB.Orientation = Vector3.new(0, -spinrate, 0)
		--pentagram.RingAddonC.Orientation = Vector3.new(0, spinrate * 0.8, 0)
		--pentagram.Base.Orientation = Vector3.new(0, -spinrate * 0.5, 0)

		gate.Crucifix.Glow.Orientation = gate.Crucifix.Glow.Orientation + Vector3.new(0, crucifix_spin.Value, 0)
	end)

	spinrate_changed.Changed:Connect(function(V)
		spinrate = V
	end)

	for _,v in pairs(Entity:GetDescendants()) do
		if v:IsA("BasePart") then 
			v.Anchored = true
			--v.Position = gate.Entity.Position + Vector3.new(0, 2, 0)
		end
	end

	local Stored = gate.Crucifix.Glow.CFrame  

	gate.Crucifix.Glow.Sound.TimePosition = 0
	gate.Crucifix.Glow.SoundFail.TimePosition = 0

	--gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://15746677967"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://15746691911"

	gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://6555668806"
	gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://6555668806"

	gate.Crucifix.Glow.Sound:Play()

	gate.Crucifix.Glow.CFrame = ToolHandle.CFrame

	local PLAYER_HUMANOIDROOTPART = Character.HumanoidRootPart
	local PLAYER_POSITION = PLAYER_HUMANOIDROOTPART.Position
	local PLAYER_DIRECTION = PLAYER_HUMANOIDROOTPART.CFrame.LookVector
	local PLAYER_ROTATION = PLAYER_HUMANOIDROOTPART.CFrame - Vector3.new(PLAYER_POSITION, PLAYER_POSITION + PLAYER_DIRECTION)

	local PART_POSITION = PLAYER_POSITION + PLAYER_DIRECTION * 5

	local C = Player.Character
	local NewPos = CFrame.new(PART_POSITION, PART_POSITION + PLAYER_ROTATION.LookVector)

	spawn(function()

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			--CFrame = Stored,
			CFrame = NewPos,
		}):Play()

		task.wait(.6)

		tweensv:Create(crucifix_spin, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Value = 50,
		}):Play()
	end)

	spawn(function()

		task.wait(1)

		tweensv:Create(gate.Crucifix.Glow.Light, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Range = 15,
			Brightness = 3
		}):Play()
	end)


	tweensv:Create(pentagram.Circle, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = pentagram.Circle.Position - Vector3.new(0, 10, 0),
	}):Play()

	camShake:ShakeOnce(10,15,4,5)

	--tweensv:Create(spinrate_changed, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
	--	Value = 5,
	--}):Play()

	--[[
	
	tweensv:Create(crucifix_spin, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 50,
		}):Play()
		
	]]

	local function move(part)
		task.wait(2.5)
		tweensv:Create(gate.Entity, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = gate.Entity.Position + Vector3.new(0,10,0),
		}):Play()

		tweensv:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = part.Position + Vector3.new(0,10,0),
		}):Play()

		tweensv:Create(pentagram.Base.LightAttach.Light, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Range = 60,
			Brightness = 5
		}):Play()

		task.wait(1)

		tweensv:Create(part, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = part.Position - Vector3.new(0,50,0),
		}):Play()


		tweensv:Create(gate.Entity, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Position = gate.Entity.Position - Vector3.new(0,50,0),
		}):Play()




		--Sound fade

		for _,v in pairs(Entity:GetDescendants()) do
			if v:IsA("Sound") then
				tweensv:Create(v, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Volume = 0,
				}):Play()
			elseif v:IsA("Light") then
				tweensv:Create(v, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Range = 0,
				}):Play()
			end
		end

		task.wait(1)

		tweensv:Create(gate.Crucifix.Glow.Light, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 25,
			Range = 30,
		}):Play()

		tweensv:Create(pentagram.Base.LightAttach.Light, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Range = 0,
			Brightness = 2
		}):Play()

		--Gate

		tweensv:Create(spinrate_changed, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 0,
		}):Play()

		for _,v in pairs(pentagram:GetChildren()) do
			if v.Name == "BeamFlat" then
				spawn(function()
					if v:GetAttribute("Delay") ~= 0 then
						task.wait(v:GetAttribute("Delay"))
					end

					tweensv:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Brightness = 0,
					}):Play()

				end)
			end
		end



	end

	--Entity fix
	for _,v in pairs(Entity:GetDescendants()) do
		if v:IsA("BasePart") then
			spawn(function()
				move(v)
			end)
		end	
	end





	--Portal closing

	spawn(function()

		task.wait(5)

		tweensv:Create(crucifix_spin, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 0,
		}):Play()

		task.wait(1.5)

		--Crucifix

		tweensv:Create(gate.Crucifix.Glow.Light, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = 60,
		}):Play()

		camShake:ShakeOnce(3,10,0.7,0.5)

		gate.Crucifix.Glow.ExplodeParticle:Emit(50)

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = gate.Crucifix.Glow.Size * 4,
		}):Play()

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		}):Play()

		task.wait(5)

		gate:Destroy()

		gate_spin:Disconnect()
	end)


	task.wait(10)

	pcall(function()
		gate:Destroy()

		gate_spin:Disconnect()
	end)
	Entity:Destroy()
	ToolHandle = nil
end

function hellfail(oldentity,entity)
	local Entity = oldentity
	entity:Pause()
	camShake:ShakeOnce(10,30,0.7,0.5)


	local primary = Entity.PrimaryPart or Entity:FindFirstChildOfClass("Part")
	task.spawn(function()
		if Entity:GetAttribute("Repent") == "Normal" then
			primary:FindFirstChild("PlaySound"):Stop()
			primary:FindFirstChild("Footsteps"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif Entity:GetAttribute("Repent") == "Quick" then
			primary:FindFirstChild("PlaySound"):Stop()
			primary:FindFirstChild("Footsteps"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentParticle2 = primary.Attachment:FindFirstChild("RepentParticle2")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			wait(1)
			RepentParticle2.Enabled = true
			task.wait(0.8)
			RepentParticle.Enabled = false
			RepentParticle2.Enabled = false
		elseif Entity:GetAttribute("Repent") == "Eyes" then
			primary:FindFirstChild("Ambience"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif Entity:GetAttribute("Repent") == "Screech" then
			primary:FindFirstChild("PSST"):Stop()
			entity:SetAttribute("Idled",false)
			local RepentAnim = entity.Monster:LoadAnimation(entity:FindFirstChild("Crucifix_Config").Animation.Working.Animation)
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentAnim:Play()
		else
			--No Repent
		end
	end)

	--CAST A RAY

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { Character, Entity }

	local ray = workspace:Raycast(primary.Position, Vector3.new(0,-1,0) * 20, params)




	local gate = Portal:Clone()
	gate.Parent = workspace

	local pentagram = gate.Pentagram

	if ray then
		local part = Instance.new("Part")
		part.Anchored = true
		part.Position = ray.Position + Vector3.new(0, 1, 0)

		gate:PivotTo(part.CFrame * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 0, 0))

		part:Destroy()
	end

	--Spinning


	local spinrate = 2
	local crucifix_spin = Instance.new("NumberValue")
	local spinrate_changed = Instance.new("NumberValue")

	local gate_spin = game:GetService("RunService").Heartbeat:Connect(function()
		--pentagram.RingAddonA.Orientation = Vector3.new(0, spinrate, 0)
		--pentagram.RingAddonB.Orientation = Vector3.new(0, -spinrate, 0)
		--pentagram.RingAddonC.Orientation = Vector3.new(0, spinrate * 0.8, 0)
		--pentagram.Base.Orientation = Vector3.new(0, -spinrate * 0.5, 0)

		gate.Crucifix.Glow.Orientation = gate.Crucifix.Glow.Orientation + Vector3.new(0, crucifix_spin.Value, 0)
	end)

	spinrate_changed.Changed:Connect(function(V)
		spinrate = V
	end)

	for _,v in pairs(Entity:GetDescendants()) do
		if v:IsA("BasePart") then 
			v.Anchored = true
			--v.Position = gate.Entity.Position + Vector3.new(0, 2, 0)
		end
	end

	local Stored = gate.Crucifix.Glow.CFrame  

	gate.Crucifix.Glow.Sound.TimePosition = 0
	gate.Crucifix.Glow.SoundFail.TimePosition = 0

	-- gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://12657890777"
	-- gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://12664891904"

	--gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://15746677967"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://15746691911"

	gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://6555668806"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://6555668806"

	gate.Crucifix.Glow.SoundFail:Play()
	gate.Crucifix.Glow.Sound:Stop()

	gate.Crucifix.Glow.CFrame = ToolHandle.CFrame

	local PLAYER_HUMANOIDROOTPART = Character.HumanoidRootPart
	local PLAYER_POSITION = PLAYER_HUMANOIDROOTPART.Position
	local PLAYER_DIRECTION = PLAYER_HUMANOIDROOTPART.CFrame.LookVector
	local PLAYER_ROTATION = PLAYER_HUMANOIDROOTPART.CFrame - Vector3.new(PLAYER_POSITION, PLAYER_POSITION + PLAYER_DIRECTION)

	local PART_POSITION = PLAYER_POSITION + PLAYER_DIRECTION * 5

	local C = Player.Character
	local NewPos = CFrame.new(PART_POSITION, PART_POSITION + PLAYER_ROTATION.LookVector)

	spawn(function()

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			--CFrame = Stored,
			CFrame = NewPos,
		}):Play()

		task.wait(.6)

		tweensv:Create(crucifix_spin, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Value = 50,
		}):Play()
	end)

	spawn(function()

		task.wait(1)

		tweensv:Create(gate.Crucifix.Glow.Light, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Range = 15,
			Brightness = 3
		}):Play()
	end)


	tweensv:Create(pentagram.Circle, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = pentagram.Circle.Position - Vector3.new(0, 10, 0),
	}):Play()

	camShake:ShakeOnce(10,15,4,5)

	--tweensv:Create(spinrate_changed, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
	--	Value = 5,
	--}):Play()

	--[[
	
	tweensv:Create(crucifix_spin, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 50,
		}):Play()
		
	]]

	local function move(part)
		task.wait(2.5)
		tweensv:Create(gate.Entity, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = gate.Entity.Position + Vector3.new(0,10,0),
		}):Play()

		--tweensv:Create(part, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		--	Position = part.Position + Vector3.new(0,10,0),
		--}):Play()

		tweensv:Create(pentagram.Base.LightAttach.Light, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Range = 60,
			Brightness = 5
		}):Play()

		task.wait(1.5)

		local tween = tweensv:Create(crucifix_spin, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 0,
		})

		tween:Play()


		for i, COLORING in pairs(pentagram:GetDescendants()) do

			if COLORING:IsA("Beam") then
				COLORING.Color = ColorSequence.new(Color3.new(1, 0.509804, 0.509804))
			elseif COLORING:IsA("PointLight") then
				local TWEEN_PLIGHT = tweensv:Create(COLORING, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {Color = Color3.new(1, 0.509804, 0.509804)})
				TWEEN_PLIGHT:Play()
			elseif COLORING:IsA("ParticleEmitter") then
				COLORING.Color = ColorSequence.new(Color3.new(1, 0.509804, 0.509804))
			end

		end

		for i, COLORING in pairs(gate.Crucifix.Glow:GetDescendants()) do

			if COLORING:IsA("PointLight") then
				local TWEEN_PLIGHT = tweensv:Create(COLORING, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0), {Color = Color3.new(1, 0.509804, 0.509804)})
				TWEEN_PLIGHT:Play()
			elseif COLORING:IsA("ParticleEmitter") then
				COLORING.Color = ColorSequence.new(Color3.new(1, 0.509804, 0.509804))
			end

		end

		gate.Crucifix.Glow.Color = Color3.new(1, 0.509804, 0.509804)
		tween.Completed:Wait()

		--tweensv:Create(part, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		--	Position = part.Position - Vector3.new(0,50,0),
		--}):Play()






		--Sound fade

		--for _,v in pairs(Entity:GetDescendants()) do
		--	if v:IsA("Sound") then
		--		tweensv:Create(v, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		--			Volume = 0,
		--		}):Play()
		--	elseif v:IsA("Light") then
		--		tweensv:Create(v, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		--			Range = 0,
		--		}):Play()
		--	end
		--end



	end

	--Entity fix

	for _,v in pairs(Entity:GetDescendants()) do
		if v:IsA("BasePart") then
			spawn(function()
				move(v)
			end)
		end	
	end





	--Portal closing

	spawn(function()

		task.wait(5)

		task.wait(2)

		tweensv:Create(pentagram.Base.LightAttach.Light, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Range = 0,
			Brightness = 2
		}):Play()

		--Gate

		tweensv:Create(spinrate_changed, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Value = 0,
		}):Play()

		for _,v in pairs(pentagram:GetChildren()) do
			if v.Name == "BeamFlat" then
				spawn(function()
					if v:GetAttribute("Delay") ~= 0 then
						task.wait(v:GetAttribute("Delay"))
					end

					tweensv:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Brightness = 0,
					}):Play()

				end)
			end
		end


		for _,v in pairs(pentagram:GetChildren()) do
			if v.Name == "BeamChain" then
				spawn(function()
					if v:GetAttribute("Delay") ~= 0 then
						task.wait(v:GetAttribute("Delay"))
					end

					tweensv:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Brightness = 0,
					}):Play()

				end)
			end
		end



		task.wait(2.5)

		--Crucifix

		tweensv:Create(gate.Crucifix.Glow.Light, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = 60,
		}):Play()

		gate.Crucifix.Glow.ExplodeParticle:Emit(50)

		camShake:ShakeOnce(3,10,0.7,0.5)

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = gate.Crucifix.Glow.Size * 4,
		}):Play()

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		}):Play()
		task.spawn(function()
			if Entity:GetAttribute("Repent") == "Normal" then
				primary:FindFirstChild("PlaySound"):Play()
				primary:FindFirstChild("Footsteps"):Play()
				local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentParticle.Enabled = false
				primary.Attachment:FindFirstChild("BlackTrail").Enabled = true
			elseif Entity:GetAttribute("Repent") == "Quick" then
				primary:FindFirstChild("PlaySound"):Play()
				primary:FindFirstChild("Footsteps"):Play()
				local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
				local RepentParticle2 = primary.Attachment:FindFirstChild("RepentParticle2")
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentParticle.Enabled = false
				RepentParticle2.Enabled = false
			elseif Entity:GetAttribute("Repent") == "Eyes" then
				primary:FindFirstChild("Ambience"):Play()
				local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentParticle.Enabled = false
			elseif Entity:GetAttribute("Repent") == "Screech" then
				primary:FindFirstChild("PSST"):Play()
				entity:SetAttribute("Idled",true)
				local RepentAnim = entity.Monster:LoadAnimation(entity:FindFirstChild("Crucifix_Config").Animation.Working.Animation)
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentAnim:Stop()
				entity.LoopIdle.Enabled = false
				entity.LoopIdle.Enabled = true
			else
				--No Repent
			end
		end)

		task.wait(10)

		gate:Destroy()

		gate_spin:Disconnect()
	end)

	task.wait(10)
	entity:Resume()
	Entity:SetAttribute("BeingCrucifixedFail",false)
	ToolHandle = nil
end

local SelfModules = {
	DefaultConfig = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/main/ENDLESS%20DOORS/Entity%20Spawner/DefaultConfig.lua"))(),
	Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/main/Functions.lua"))(),
}
local ModuleScripts = {}
local EntityConnections = {}

local Spawner = {}

Raycast = function(Player,Part,Distance,entityTable)
	if Player.Character.Humanoid.Health > 0 then
		local Params = RaycastParams.new()
		Params.FilterDescendantsInstances = {
			Part
		}
		local dir = CFrame.lookAt(Part.Position, Player.Character.PrimaryPart.Position).LookVector * Distance
		local Cast = workspace:Raycast(Part.Position, dir)

		if Cast and Cast.Instance then
			local Hit = Cast.Instance

			if Hit:IsDescendantOf(Player.Character) and (Player.Character.Hiding.Value == false or Player.Character.Hiding.Parent == nil) then
				if Player.Character:FindFirstChild("Crucifix") then
					if entityTable.Config.Crucifixion.Enabled == true then
					ToolHandle = Player.Character:FindFirstChild("Crucifix").Handle
					task.spawn(entityTable.Debug.CrucifixionOverwrite)
					end
				else
				Character.Humanoid.Health = Character.Humanoid.Health - entityTable.Config.Damage.Amount
				task.spawn(entityTable.Debug.OnDamagePlayer, Player.Character.Humanoid.Health)
				end
			end
		end
	end
end

-- Misc Functions

function getPlayerRoot()
	return Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Head")
end

local function IsScreen(entity)
	local isOnScreen = select(2, Camera:WorldToViewportPoint(entity.PrimaryPart.Position));
	if isOnScreen then
		return true
	end
end


function loadSound(entityModel)
	for _,snd in next, entityModel:GetDescendants() do
		if snd:IsA("Sound") then
			task.spawn(function()
				local sndorigvolume = snd.Volume
				snd.Volume = 0
				snd:Play()
				local tween = game.TweenService:Create(snd,TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Volume = sndorigvolume})
				tween:Play()
			end)
		end
	end
end

function unloadSound(entityModel)
	for _,snd in next, entityModel:GetDescendants() do
		if snd:IsA("Sound") then
			local tween = game.TweenService:Create(snd,TweenInfo.new(1),{Volume = 0})
			tween:Play()
			tween.Completed:Connect(function()
				snd:Stop()
				snd.Volume = 1
			end)
		end
	end
end

function unloadEntity(entityConnections,entityTable)
	for _, v in next, entityConnections do
		v:Disconnect()
	end
	task.spawn(entityTable.Debug.OnDespawned)
end

--function dragEntity(entityModel, pos, speed)
--	local entityConnections = EntityConnections[entityModel]

--	if entityConnections.movementNode then
--		entityConnections.movementNode:Disconnect()
--	end

--	entityConnections.movementNode = RS.Stepped:Connect(function(_, step)
--		if entityModel.Parent and not entityModel:GetAttribute("NoAI") then
--			local rootPos = entityModel.PrimaryPart.Position
--			local diff = Vector3.new(pos.X, pos.Y, pos.Z) - rootPos

--			if diff.Magnitude > 0.1 then
--				entityModel:PivotTo(CFrame.new(rootPos + diff.Unit * math.min(step * speed, diff.Magnitude)))
--			else
--				entityConnections.movementNode:Disconnect()
--			end
--		end
--	end)

--	repeat task.wait() until not entityConnections.movementNode.Connected
--end

function dragEntity(entityModel,object,speed,offset)
	local alpha = 0
	local object = object or entityModel.PrimaryPart
	local offset = offset or error("offset Recommended")
	local speed = speed
	local distance = (entityModel.PrimaryPart.Position - object.Position).Magnitude
	local relativeSpeed = distance / speed
	local startCFrame = entityModel.PrimaryPart.CFrame
	local loop
	local reachedEvent = Instance.new("BindableEvent")
	loop = RS.Heartbeat:Connect(function(delta)
		if entityModel.Parent and not entityModel:GetAttribute("NoAI") then
			local goalCFrame = startCFrame:Lerp(object.CFrame + offset, alpha)
			entityModel:PivotTo(goalCFrame)
			alpha = alpha + delta / relativeSpeed
			if alpha >= 1 then
				loop:Disconnect()
				reachedEvent:Fire()
			end
		end
	end)
	reachedEvent.Event:Wait()
end

function dragBlitz(entityModel,object,speed,offset)
	local alpha = 0
	local object = object or error("object must be part.")
	local offset = offset or error("offset Recommended")
	local speed = speed
	local distance = (entityModel.PrimaryPart.Position - object.Position).Magnitude
	local relativeSpeed = distance / speed
	local startCFrame = entityModel.PrimaryPart.CFrame
	local loop
	local reachedEvent = Instance.new("BindableEvent")
	loop = RS.Heartbeat:Connect(function(delta)
		if entityModel.Parent and entityModel:GetAttribute("NoAI") and not entityModel:GetAttribute("Despawned") then
			local goalCFrame = startCFrame:Lerp(object.CFrame + offset, alpha)
			entityModel:PivotTo(goalCFrame)
			alpha = alpha + delta / relativeSpeed
			if alpha >= 1 then
				loop:Disconnect()
				reachedEvent:Fire()
			end
		end
	end)
	reachedEvent.Event:Wait()
end

function dragHumanoidEntity(entityModel,object,speed,offset)
	local alpha = 0
	local object = object or error("object must be part.")
	local offset = offset or error("offset Recommended")
	-- object.CFrame = object.CFrame + offset
	local speed = speed
	local distance = (entityModel.PrimaryPart.Position - object.Position).Magnitude
	local relativeSpeed = distance / speed
	local startCFrame = entityModel.PrimaryPart.CFrame
	local loop
	local reachedEvent = Instance.new("BindableEvent")
	entityModel.Head.CanCollide = false
	entityModel.Torso.CanCollide = false
	entityModel["Left Arm"].CanCollide = false
	--entityModel["Left Leg"].CanCollide = false
	entityModel["Right Arm"].CanCollide = false
	--entityModel["Right Leg"].CanCollide = false
	local hum = entityModel.Humanoid

	local path = pathfindingService:CreatePath({
		AgentHeight = 6,
		AgentRadius = 3,
		AgentCanJump = true,
		AgentCanClimb = true,

		Costs = {

		},
	})
	path:ComputeAsync(entityModel.Torso.Position,object.Position)
	local waypoints = path:GetWaypoints()
	for i,v in pairs(waypoints) do
		if v.Action == Enum.PathWaypointAction.Jump then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		hum:MoveTo(v.Position)
		hum.MoveToFinished:Wait()
	end
end

local function GetClosetsInRoom(room)
	if room:FindFirstChild("Models") then
		if room.Models:FindFirstChild("Wardrobe") or room.Assets:FindFirstChild("Toolshed") then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- Functions

Spawner.Create = function(config)
	for i, v in next, SelfModules.DefaultConfig do
		if config[i] == nil then
			config[i] = v
		end
	end

	config.Movement.Speed = StaticRushSpeed / 100 * config.Movement.Speed

	-- Model

	local entityModel = nil
	if typeof(config.Entity.Asset) == "string" then
	entityModel = LoadCustomInstance(config.Entity.Asset)
	elseif typeof(config.Entity.Asset) ~= "string" and config.Entity.Asset:IsA("Model") then
	entityModel = config.Entity.Asset:Clone()
	end
	if config.Entity.SmoothTransition == true then
	loadSound(entityModel)
	end

	if typeof(entityModel) == "Instance" and entityModel.ClassName == "Model" then
		entityModel.PrimaryPart = entityModel.PrimaryPart or entityModel:FindFirstChildWhichIsA("BasePart")

		if entityModel.PrimaryPart then
			entityModel.PrimaryPart.Anchored = true

			if config.Entity.Name then
				entityModel.Name = config.Entity.Name
			end

			entityModel:SetAttribute("IsCustomEntity", true)
			entityModel:SetAttribute("NoAI", false)
			entityModel:SetAttribute("Repent",config.Crucifixion.Repent)

			-- EntityTable

			local entityTable = {
				Model = entityModel,
				Config = config,
				Debug = {
					OnSpawned = function() end,
					OnDespawned = function() end,
					OnDespawning = function() end,
					OnStartMoving = function() end,
					OnReachNode = function() end,
					OnRebounding = function() end,
					OnEnterRoom = function() end,
					OnLookAt = function() end,
					OnDamagePlayer = function() end,
					OnBreakLights = function() end,
					CrucifixionOverwrite = function() end,
				}
			}
			
			function entityTable:SetCallback(cbName,callback)
				if entityTable.Debug[cbName] then
					entityTable.Debug[cbName] = callback
				end
			end
			
			entityTable:SetCallback("CrucifixionOverwrite",function()
				if entityTable.Config.Crucifixion.Resist == false then
					hell(entityModel,entityTable)
				elseif entityTable.Config.Crucifixion.Resist == true then
					hellfail(entityModel,entityTable)
				end
			end)
			
			function entityTable:Run()
				spawn(function()
					if GetClosetsInRoom(workspace.Game.Rooms["Room"..tostring(Char.RoomInsideNumber.Value)]) == true then
						-- Nodes
	
						local nodes = {}
	
						for i = 0,workspace.Game.Values.RoomsNumber.Value do
							if workspace.Game.Rooms:FindFirstChild("Room"..tostring(i)) then
								local room = workspace.Game.Rooms["Room"..tostring(i)]
	
								local pathfindNodes = room:FindFirstChild("Nodes")
	
								if pathfindNodes then
									pathfindNodes = pathfindNodes:GetChildren()
								else
									local fakeNode = Instance.new("Part")
									fakeNode.Name = "1"
									fakeNode.Size = Vector3.new(1,1,1)
									fakeNode.Shape = "Ball"
									fakeNode.Anchored = true
									fakeNode.CFrame = room:WaitForChild("RootPart").CFrame - Vector3.new(0, room.RootPart.Size.Y / 2, 0)
									fakeNode.Parent = game.ReplicatedStorage
									local fakeNode2 = fakeNode:Clone()
									fakeNode2.Name = "2"
									fakeNode2.CFrame = room.Door:WaitForChild("RootPart").CFrame - Vector3.new(0, room.Door.RootPart.Size.Y / 2, 0)
									fakeNode2.Parent = game.ReplicatedStorage
									
	
									pathfindNodes = {fakeNode,fakeNode2}
								end
	
								table.sort(pathfindNodes, function(a, b)
									return tonumber(a.Name) < tonumber(b.Name)
								end)
	
								for _, node in next, pathfindNodes do
									nodes[#nodes + 1] = node
								end
							end
						end
						
						if entityTable.Config.Movement.Reversed then
							local inverseNodes = {}
							local backNodes = {}
							for i,v in next, workspace.Game.Rooms:GetChildren() do
								local room = v
								local pathfindNodes = room:FindFirstChild("Nodes")
	
								if pathfindNodes then
									pathfindNodes = pathfindNodes:GetChildren()
								else
									local fakeNode = Instance.new("Part")
									fakeNode.Name = "1"
									fakeNode.Size = Vector3.new(1,1,1)
									fakeNode.Shape = "Ball"
									fakeNode.Anchored = true
									fakeNode.CFrame = room:WaitForChild("RootPart").CFrame - Vector3.new(0, room.RootPart.Size.Y / 2, 0)
									fakeNode.Parent = game.ReplicatedStorage
									local fakeNode2 = fakeNode:Clone()
									fakeNode2.Name = "2"
									fakeNode2.CFrame = room.Door:WaitForChild("RootPart").CFrame - Vector3.new(0, room.Door.RootPart.Size.Y / 2, 0)
									fakeNode2.Parent = game.ReplicatedStorage
									
	
									pathfindNodes = {fakeNode,fakeNode2}
								end
	
								table.sort(pathfindNodes, function(a, b)
									return tonumber(a.Name) < tonumber(b.Name)
								end)
	
								for _, node in next, pathfindNodes do
									backNodes[#backNodes + 1] = node
								end
							end
	
							for nodeIdx = #backNodes, 1, -1 do
								inverseNodes[#inverseNodes + 1] = backNodes[nodeIdx]
							end
	
							nodes = inverseNodes
						end
	
						-- Spawn
	
						local entityModel = entityTable.Model
						local humanoidEntity = false
						if entityModel:FindFirstChild("Humanoid") then
							humanoidEntity = true
						end
						local startNodeIndex = entityTable.Config.Movement.Reversed and 1 or 1
						local startNodeOffset = entityTable.Config.Movement.Reversed and -100 or 50
						local startNode = nodes[startNodeIndex]
	
						EntityConnections[entityModel] = {}
						local entityConnections = EntityConnections[entityModel]
						if humanoidEntity == true then
							entityModel:PivotTo(startNode.CFrame + Vector3.new(0, 0 + entityTable.Config.Entity.HeightOffset, 0))
						else
							entityModel:PivotTo(startNode.CFrame * CFrame.new(0, 0, startNodeOffset) + Vector3.new(0, 0 + entityTable.Config.Entity.HeightOffset, 0))
						end
						if entityTable.Config.Visualization.Enabled == true then
							local a = Instance.new("BoxHandleAdornment",entityModel)
							a.AlwaysOnTop = true
							a.Size = entityModel.PrimaryPart.Size
							a.Color = BrickColor.new("Really red")
							a.Adornee = entityModel
							for i = 1,10 do
								a.ZIndex = 100
							end
						end
						if humanoidEntity == true then
							local pchar = entityModel
							if pchar and not pchar:FindFirstChild("Floating") then
								task.spawn(function()
									local Float = Instance.new('Part')
									Float.Name = "Floating"
									Float.Parent = pchar
									Float.Transparency = 1
									Float.Size = Vector3.new(2,0.2,1.5)
									Float.Anchored = true
									local FloatValue = -3.1
									local floatDied
									local FloatingFunc
									Float.CFrame = pchar.PrimaryPart.CFrame * CFrame.new(0,FloatValue,0)
									floatDied = pchar:FindFirstChildOfClass('Humanoid').Died:Connect(function()
										FloatingFunc:Disconnect()
										Float:Destroy()
										floatDied:Disconnect()
									end)
									local function FloatPadLoop()
										if pchar:FindFirstChild("Floating") and pchar.PrimaryPart then
											Float.CFrame = pchar.PrimaryPart.CFrame * CFrame.new(0,FloatValue,0)
										else
											FloatingFunc:Disconnect()
											Float:Destroy()
											floatDied:Disconnect()
										end
									end			
									FloatingFunc = game:GetService("RunService").Heartbeat:Connect(FloatPadLoop)
								end)
							end
						end
						entityModel.Parent = workspace.Game.Entities
						if humanoidEntity then
							entityModel.PrimaryPart.Anchored = false
						end
						if entityModel.PrimaryPart:FindFirstChildOfClass("BodyVelocity") or entityModel.PrimaryPart:FindFirstChildOfClass("BodyGyro") or entityModel.PrimaryPart:FindFirstChildOfClass("BodyPosition") then
							entityModel.PrimaryPart:FindFirstChildOfClass("BodyVelocity"):Destroy()
							entityModel.PrimaryPart:FindFirstChildOfClass("BodyGyro"):Destroy()
						end
						task.spawn(entityTable.Debug.OnSpawned,entityModel)
											local updatingNodes = true
						spawn(function()
							repeat
								wait(0.1)
								for i = 1,10 do
									nodes = {}
	
									for i = 0,workspace.Game.Values.RoomsNumber.Value do
							if workspace.Game.Rooms:FindFirstChild("Room"..tostring(i)) then
								local room = workspace.Game.Rooms["Room"..tostring(i)]
	
								local pathfindNodes = room:FindFirstChild("Nodes")
	
								if pathfindNodes then
									pathfindNodes = pathfindNodes:GetChildren()
								else
									local fakeNode = Instance.new("Part")
									fakeNode.Name = "1"
									fakeNode.Size = Vector3.new(1,1,1)
									fakeNode.Shape = "Ball"
									fakeNode.Anchored = true
									fakeNode.CFrame = room:WaitForChild("RootPart").CFrame - Vector3.new(0, room.RootPart.Size.Y / 2, 0)
									fakeNode.Parent = game.ReplicatedStorage
									local fakeNode2 = fakeNode:Clone()
									fakeNode2.Name = "2"
									fakeNode2.CFrame = room.Door:WaitForChild("RootPart").CFrame - Vector3.new(0, room.Door.RootPart.Size.Y / 2, 0)
									fakeNode2.Parent = game.ReplicatedStorage
									
	
									pathfindNodes = {fakeNode,fakeNode2}
								end
	
								table.sort(pathfindNodes, function(a, b)
									return tonumber(a.Name) < tonumber(b.Name)
								end)
	
								for _, node in next, pathfindNodes do
									nodes[#nodes + 1] = node
								end
							end
						end
									
									if entityTable.Config.Movement.Reversed then
										local inverseNodes = {}
										local backNodes = {}
										for i,v in next, workspace.Game.Rooms:GetChildren() do
											local room = v
											local pathfindNodes = room:FindFirstChild("Nodes")
				
											if pathfindNodes then
												pathfindNodes = pathfindNodes:GetChildren()
											else
												local fakeNode = Instance.new("Part")
												fakeNode.Name = "1"
												fakeNode.Size = Vector3.new(1,1,1)
												fakeNode.Shape = "Ball"
												fakeNode.Anchored = true
												fakeNode.CFrame = room:WaitForChild("RootPart").CFrame - Vector3.new(0, room.RootPart.Size.Y / 2, 0)
												fakeNode.Parent = game.ReplicatedStorage
												local fakeNode2 = fakeNode:Clone()
												fakeNode2.Name = "2"
												fakeNode2.CFrame = room.Door:WaitForChild("RootPart").CFrame - Vector3.new(0, room.Door.RootPart.Size.Y / 2, 0)
												fakeNode2.Parent = game.ReplicatedStorage
												
				
												pathfindNodes = {fakeNode,fakeNode2}
											end
				
											table.sort(pathfindNodes, function(a, b)
												return tonumber(a.Name) < tonumber(b.Name)
											end)
				
											for _, node in next, pathfindNodes do
												backNodes[#backNodes + 1] = node
											end
										end
				
										for nodeIdx = #backNodes, 1, -1 do
											inverseNodes[#inverseNodes + 1] = backNodes[nodeIdx]
										end
				
										nodes = inverseNodes
									end
								end
							until updatingNodes == false
						end)
	
						-- Mute entity on spawn
	
						--if CG:FindFirstChild("JumpscareGui") or (Plr.PlayerGui.MainUI.Death.HelpfulDialogue.Visible and not Plr.PlayerGui.MainUI.DeathPanelDead.Visible) then
						--	warn("on death screen, mute entity")
	
						--	for _, v in next, entityModel:GetDescendants() do
						--		if v.ClassName == "Sound" and v.Playing then
						--			v:Stop()
						--		end
						--	end
						--end
	
						-- Flickering
	
						if entityTable.Config.Lights.Flicker.Enabled then
							
						end
	
						-- Movement
	
						task.wait(entityTable.Config.Movement.Delay)
	
						local enteredRooms = {}
	
						entityConnections.movementTick = RS.Stepped:Connect(function()
							if entityModel.Parent and not entityModel:GetAttribute("NoAI") and entityTable.Config.Rebounding.Type ~= "Blitz" and entityModel:GetAttribute("BeingCrucifixed") ~= true and entityModel:GetAttribute("BeingCrucifixedFail") ~= true or entityModel.Parent and not entityModel:GetAttribute("NoAI") and entityTable.Config.Rebounding.Type == "Blitz" and entityModel:GetAttribute("BeingCrucifixed") ~= true and entityModel:GetAttribute("BeingCrucifixedFail") ~= true or entityModel.Parent and entityModel:GetAttribute("NoAI") and entityTable.Config.Rebounding.Type == "Blitz" and entityModel:GetAttribute("BeingCrucifixed") ~= true and entityModel:GetAttribute("BeingCrucifixedFail") ~= true then
								local entityPos = entityModel.PrimaryPart.Position
								local ignoreTable = {}
								table.insert(ignoreTable,entityModel)
								local floors = {"Floor","Carpet","CarpetLight"}
								local floorRay = FindPartOnRayWithIgnoreList(workspace, Ray.new(entityPos, Vector3.new(0, -10, 0)), ignoreTable)
								if entityTable.Config.Damage.Enabled == true then
									for _,plr in next, Players:GetChildren() do
										Raycast(plr,entityModel.PrimaryPart,entityTable.Config.Damage.Range or 50,entityTable)
									end
								end
	
								-- Entered room
	
								if floorRay ~= nil and table.find(floors,floorRay.Name) then
									for _, room in next, workspace.Game.Rooms:GetChildren() do
										if floorRay:IsDescendantOf(room) and not table.find(enteredRooms, room) then
											enteredRooms[#enteredRooms + 1] = room
											task.spawn(entityTable.Debug.OnEnterRoom, room, true)
	
											-- Break lights
	
											if entityTable.Config.Lights.Shatter and not room:GetAttribute("BrokenLights") then
												room:SetAttribute("BrokenLights",true)
												task.spawn(entityTable.Debug.OnBreakLights,entityModel)
											end
	
											break
										elseif floorRay:IsDescendantOf(room) and table.find(enteredRooms, room) then
											--task.spawn(entityTable.Debug.OnEnterRoom, room, false)
											break
										end
									end
								end
								
								--[[if IsScreen(entityModel) then
									delay(1,function()
									task.spawn(entityTable.Debug.OnLookAt,true)
									end)
								else
									delay(1,function()
									task.spawn(entityTable.Debug.OnLookAt,false)
									end)
								end]]--
	
								-- Camera shaking
								local shakeConfig = entityTable.Config.CameraShake
	
								if shakeConfig.Enabled then
									local shakeRep = {}
	
									local shakeMag = (getPlayerRoot().Position - entityModel.PrimaryPart.Position).Magnitude
	
									for i,v in next, shakeConfig.Values do
										if i ~= nil then
											shakeRep[i] = v
										end
									end
	
									if not shakeMag then
										shakeMag = 0
									end
	
	
									shakeRep[1] = shakeConfig.Values[1] / shakeConfig.Range * (shakeConfig.Range - shakeMag)
	
									if shakeMag < shakeConfig.Range then
										camShake:ShakeOnce(table.unpack(shakeRep))
									end
								end
							elseif entityModel.Parent and entityModel:GetAttribute("NoAI") == true and entityModel:GetAttribute("BeingCrucifixed") == true and entityModel:GetAttribute("BeingCrucifixedFail") ~= true then
								unloadEntity(entityConnections,entityTable)
							end
						end)
	
						task.spawn(entityTable.Debug.OnStartMoving)
	
						-- Cycles
	
						local cyclesConfig = entityTable.Config.Rebounding
	
						--for cycle = 1, math.max(math.random(cyclesConfig.Min, cyclesConfig.Max), 1) do
						--	for nodeIdx = 1, #nodes, 1 do
						--		dragEntity(entityModel, nodes[nodeIdx].Position + Vector3.new(0, 0 + entityTable.Config.HeightOffset, 0), entityTable.Config.Speed)
						--	end
	
						--	if cyclesConfig.Max > 1 then
						--		for nodeIdx = #nodes, 1, -1 do
						--			dragEntity(entityModel, nodes[nodeIdx].Position + Vector3.new(0, 0 + entityTable.Config.HeightOffset, 0), entityTable.Config.Speed)
						--		end
						--	end
	
						--	-- Rebound finished
	
						--	task.spawn(entityTable.Debug.OnEntityFinishedRebound)
	
						--	if cycle < cyclesConfig.Max then
						--		task.wait(cyclesConfig.WaitTime)
						--	end
						--end
						for cycle = 1, math.max(math.random(cyclesConfig.Min, cyclesConfig.Max), 1) do
							if cyclesConfig.Type ~= "Blitz" then
								task.spawn(entityTable.Debug.OnRebounding,true)
							end
							if cyclesConfig.Type == "Rebound" then
								--print("StartNode:"..startNodeIndex)
								--print("Calculation:"..startNodeIndex-#workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value + 1].PathfindNodes:GetChildren()+1)
								if humanoidEntity == true then
									entityModel:PivotTo(startNode.CFrame + Vector3.new(0, 0 + entityTable.Config.Entity.HeightOffset, 0))
								else
									entityModel:PivotTo(startNode.CFrame * CFrame.new(0, 0, startNodeOffset) + Vector3.new(0, 0 + entityTable.Config.Entity.HeightOffset, 0))
								end
								startNodeOffset = entityTable.Config.Movement.Reversed and -250 or 50
							end
							if cyclesConfig.Type == "Blitz" then
								spawn(function()
									for cycle = 1, math.max(math.random(cyclesConfig.Min, cyclesConfig.Max), 1) do
										task.wait(cyclesConfig.Delay)
										entityModel:SetAttribute("NoAI",true)
										local ogPos = entityModel.PrimaryPart:Clone()
										local backPos = ogPos:Clone()
										backPos.CFrame = ogPos.CFrame:ToWorldSpace(CFrame.new(0,0,math.random(30,50)))
										task.spawn(entityTable.Debug.OnRebounding,true)
										--local rng = math.random(2,3)
										--for nodeIdx = rng, 1, -1 do
										--	if humanoidEntity == true then
										--		dragHumanoidEntity(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
										--	else
										--		dragBlitz(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
										--	end
										--end
										--dragBlitz(entityModel,nodes[currentNodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
										dragBlitz(entityModel,backPos,entityTable.Config.Movement.Speed,Vector3.new(0,0,0))
										task.wait(cyclesConfig.Delay)
										task.spawn(entityTable.Debug.OnRebounding,false)
										--for nodeIdx = 1, rng, 1 do
										--	if humanoidEntity == true then
										--		dragHumanoidEntity(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
										--	else
										--		dragBlitz(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
										--	end
										--end
										dragBlitz(entityModel,ogPos,entityTable.Config.Movement.Speed,Vector3.new(0,0,0))
										ogPos:Destroy()
										nodes = {}
	
										for i = 0,workspace.Game.Values.RoomsNumber.Value do
							if workspace.Game.Rooms:FindFirstChild("Room"..tostring(i)) then
								local room = workspace.Game.Rooms["Room"..tostring(i)]
	
								local pathfindNodes = room:FindFirstChild("Nodes")
	
								if pathfindNodes then
									pathfindNodes = pathfindNodes:GetChildren()
								else
									local fakeNode = Instance.new("Part")
									fakeNode.Name = "1"
									fakeNode.Size = Vector3.new(1,1,1)
									fakeNode.Shape = "Ball"
									fakeNode.Anchored = true
									fakeNode.CFrame = room:WaitForChild("RootPart").CFrame - Vector3.new(0, room.RootPart.Size.Y / 2, 0)
									fakeNode.Parent = game.ReplicatedStorage
									local fakeNode2 = fakeNode:Clone()
									fakeNode2.Name = "2"
									fakeNode2.CFrame = room.Door:WaitForChild("RootPart").CFrame - Vector3.new(0, room.Door.RootPart.Size.Y / 2, 0)
									fakeNode2.Parent = game.ReplicatedStorage
									
	
									pathfindNodes = {fakeNode,fakeNode2}
								end
	
								table.sort(pathfindNodes, function(a, b)
									return tonumber(a.Name) < tonumber(b.Name)
								end)
	
								for _, node in next, pathfindNodes do
									nodes[#nodes + 1] = node
								end
							end
						end
										if entityTable.Config.Movement.Reversed then
											local inverseNodes = {}
											local backNodes = {}
	
											for i,v in next, workspace.Game.Rooms:GetChildren() do
												local room = v
	
												local pathfindNodes = room:FindFirstChild("PathfindNodes")
	
												if pathfindNodes then
													pathfindNodes = pathfindNodes:GetChildren()
												else
													local fakeNode = Instance.new("Part")
													fakeNode.Name = "1"
													fakeNode.Size = Vector3.new(1,1,1)
													fakeNode.Shape = "Ball"
													fakeNode.Anchored = true
													fakeNode.CFrame = room:WaitForChild("RootPart").CFrame - Vector3.new(0, room.RootPart.Size.Y / 2, 0)
													fakeNode.Parent = game.ReplicatedStorage
													local fakeNode2 = fakeNode:Clone()
													fakeNode2.Name = "2"
													fakeNode2.CFrame = room.Door:WaitForChild("RootPart").CFrame - Vector3.new(0, room.Door.RootPart.Size.Y / 2, 0)
													fakeNode2.Parent = game.ReplicatedStorage
													
					
													pathfindNodes = {fakeNode,fakeNode2}
												end
	
												table.sort(pathfindNodes, function(a, b)
													return tonumber(a.Name) < tonumber(b.Name)
												end)
	
												for _, node in next, pathfindNodes do
													backNodes[#backNodes + 1] = node
												end
											end
	
											for nodeIdx = #backNodes, 1, -1 do
												inverseNodes[#inverseNodes + 1] = backNodes[nodeIdx]
											end
	
											nodes = inverseNodes
										end
										entityModel:SetAttribute("NoAI",false)
									end
								end)
							end
							for nodeIdx = 1, #nodes, 1 do
								if humanoidEntity == true then
									dragHumanoidEntity(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
									task.spawn(entityTable.Debug.OnReachNode,nodes[nodeIdx])
								else
									dragEntity(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
									task.spawn(entityTable.Debug.OnReachNode,nodes[nodeIdx])
								end
							end
	
	
							if cyclesConfig.Enabled then
								if cyclesConfig.Type == "Ambush" then
									for nodeIdx = #nodes, 1, -1 do
										if humanoidEntity == true then
											dragHumanoidEntity(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
											task.spawn(entityTable.Debug.OnReachNode,nodes[nodeIdx])
										else
											dragEntity(entityModel,nodes[nodeIdx],entityTable.Config.Movement.Speed,Vector3.new(0,0+entityTable.Config.Entity.HeightOffset,0))
											task.spawn(entityTable.Debug.OnReachNode,nodes[nodeIdx])
										end
									end
								elseif cyclesConfig.Type == "Rebound" then
									--nothing cuz rebound teleports
								elseif cyclesConfig.Type == "Blitz" then
									break
								end
							end
	
							-- Rebound finished
	
							task.spawn(entityTable.Debug.OnRebounding,false)
	
							if cycle < cyclesConfig.Max and cyclesConfig.Type ~= "Blitz" then
								task.wait(cyclesConfig.Delay)
							end
						end
	
						-- Destroy
	
						if not entityModel:GetAttribute("NoAI") then
							for _, v in next, entityConnections do
								v:Disconnect()
							end
	
							if cyclesConfig.Max ~= 1 then
								entityModel:SetAttribute("Despawned",true)
								entityModel.PrimaryPart.Anchored = false
								entityModel.PrimaryPart.CanCollide = false
								local room = workspace.Game.Rooms["Room"..tostring(Char.RoomInsideNumber.Value)]
								task.spawn(entityTable.Debug.OnDespawning,room)
								local bv = Instance.new("BodyVelocity",entityModel.PrimaryPart)
								bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
								bv.P = math.huge
								bv.Velocity = Vector3.new(0,0,0)
								unloadSound(entityModel)
								bv.Velocity = Vector3.new(0,100,0)
								game:GetService("Debris"):AddItem(entityModel,5)
								local room = workspace.Game.Rooms["Room"..tostring(Char.RoomInsideNumber.Value)]
								delay(5,function()
									task.spawn(entityTable.Debug.OnDespawned)
								end)
							elseif cyclesConfig.Max <= 1 and cyclesConfig.Type == "Blitz" or cyclesConfig.Max <= 1 and cyclesConfig.Type ~= "Blitz" or cyclesConfig.Max ~= 1 and cyclesConfig.Type == "Blitz" then
								entityModel:SetAttribute("Despawned",true)
								entityModel.PrimaryPart.Anchored = false
								entityModel.PrimaryPart.CanCollide = false
								local room = workspace.Game.Rooms["Room"..tostring(Char.RoomInsideNumber.Value)]
								task.spawn(entityTable.Debug.OnDespawning,room)
								local bv = Instance.new("BodyVelocity",entityModel.PrimaryPart)
								bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
								bv.Velocity = Vector3.new(0,0,0)
								unloadSound(entityModel)
								bv.Velocity = entityModel.PrimaryPart.CFrame.LookVector*100
								game:GetService("Debris"):AddItem(entityModel,5)
								delay(5,function()
									task.spawn(entityTable.Debug.OnDespawned)
								end)
							end
						end
					else
						print("Entity cannot spawn due to the lack of closets.")
						task.spawn(entityTable.Debug.OnDespawning,room)
						task.spawn(entityTable.Debug.OnDespawned,room)
					end
				end)
			end
			
			function entityTable:Pause()
				if entityModel:GetAttribute("NoAI") == false then
					entityModel:SetAttribute("NoAI",true)
				end
			end
			
			function entityTable:Resume()
				if entityModel:GetAttribute("NoAI") == true then
					entityModel:SetAttribute("NoAI",false)
				end
			end
			
			function entityTable:IsPaused()
				if entityModel:GetAttribute("NoAI") == false then
					return false
				elseif entityModel:GetAttribute("NoAI") == true then
					return true
				end
			end
			
			function entityTable:Despawn()
				entityModel:SetAttribute("NoAI",true)
				task.spawn(entityTable.Debug.OnDespawning,room)
			        task.spawn(entityTable.Debug.OnDespawned,room)
				entityModel:Destroy()
			end

			return entityTable
		end
	end
end

return Spawner
