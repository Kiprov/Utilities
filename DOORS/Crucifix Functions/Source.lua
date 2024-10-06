local module = {}

local Player = game.Players.LocalPlayer
local Character = Player.Character
local Hum = Character.Humanoid
local MainModels = game:GetObjects("rbxassetid://17394237675")[1]
local Portal = MainModels.Repentance
local tweensv = game:GetService("TweenService")
local LatestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local Camera = workspace.CurrentCamera
local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	Camera.CFrame = Camera.CFrame * shakeCf
end)

camShake:Start()

--// main code
local Portal = MainModels.Repentance

function module:CrucifyEntity(config,oldentity,ToolHandle)
	local entity


	entity = oldentity:Clone()
    oldentity:SetAttribute("Paused",true)
	oldentity:SetAttribute("BeingBanished",true)
	entity.Name = "Fake_"..oldentity.Name
	entity.Parent = workspace
    config:Despawn()


	game.ReplicatedStorage.GameData.ChaseInSession.Value = false

	local primary = entity.PrimaryPart or entity:FindFirstChildOfClass("Part")
	task.spawn(function()
		if entity:GetAttribute("Repent") == "Normal" then
			primary:FindFirstChild("PlaySound"):Stop()
			primary:FindFirstChild("Footsteps"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif entity:GetAttribute("Repent") == "Quick" then
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
		elseif entity:GetAttribute("Repent") == "Eyes" then
			primary:FindFirstChild("Ambience"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif entity:GetAttribute("Repent") == "Screech" then
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
	params.FilterDescendantsInstances = { Character, entity }

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
		--pentagram.RingAddonA.Orientation += Vector3.new(0, spinrate, 0)
		--pentagram.RingAddonB.Orientation += Vector3.new(0, -spinrate, 0)
		--pentagram.RingAddonC.Orientation += Vector3.new(0, spinrate * 0.8, 0)
		--pentagram.Base.Orientation += Vector3.new(0, -spinrate * 0.5, 0)

		gate.Crucifix.Glow.Orientation += Vector3.new(0, crucifix_spin.Value, 0)
	end)

	spinrate_changed.Changed:Connect(function(V)
		spinrate = V
	end)

	for _,v in pairs(entity:GetDescendants()) do
		if v:IsA("BasePart") then 
			v.Anchored = true
			--v.Position = gate.Entity.Position + Vector3.new(0, 2, 0)
		end
	end

	local Stored = gate.Crucifix.Glow.CFrame  

	gate.Crucifix.Glow.Sound.TimePosition = 0
	gate.Crucifix.Glow.SoundFail.TimePosition = 0

	gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://6555668806"
	gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://6555668806"

	--gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://15746677967"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://15746691911"

	--gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://6555668806"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://6555668806"

	gate.Crucifix.Glow.Sound:Play()

	gate.Crucifix.Glow.CFrame = ToolHandle:GetPivot()

	local PLAYER_HUMANOIDROOTPART = Character.HumanoidRootPart
	local PLAYER_POSITION = PLAYER_HUMANOIDROOTPART.Position
	local PLAYER_DIRECTION = PLAYER_HUMANOIDROOTPART.CFrame.LookVector
	local PLAYER_ROTATION = PLAYER_HUMANOIDROOTPART.CFrame - Vector3.new(PLAYER_POSITION, PLAYER_POSITION + PLAYER_DIRECTION)

	local PART_POSITION = PLAYER_POSITION + PLAYER_DIRECTION * 5

	local C = Character
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

	camShake:FireClient(Player,10,15,4,5)

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
			Position = gate.Entity.Position + Vector3.new(0,5,0),
		}):Play()

		tweensv:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Position = part.Position + Vector3.new(0,5,0),
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

		for _,v in pairs(entity:GetDescendants()) do
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
	for _,v in pairs(entity:GetDescendants()) do
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

		camShake:FireClient(Player,3,10,0.7,0.5)

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


	entity:Destroy()
end

function module:FailCrucifyEntity(config,oldentity,ToolHandle)
	local entity = oldentity
    entity:SetAttribute("Paused",true)
    entity:SetAttribute("BeingBanished",true)
	game.ReplicatedStorage.GameData.ChaseInSession.Value = false


	local primary = entity.PrimaryPart or entity:FindFirstChildOfClass("Part")
	task.spawn(function()
		if entity:GetAttribute("Repent") == "Normal" then
			primary:FindFirstChild("PlaySound"):Stop()
			primary:FindFirstChild("Footsteps"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif entity:GetAttribute("Repent") == "Quick" then
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
		elseif entity:GetAttribute("Repent") == "Eyes" then
			primary:FindFirstChild("Ambience"):Stop()
			local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
			local RepentSound = primary:FindFirstChild("Repent")
			RepentSound:Play()
			RepentParticle.Enabled = true
			primary.Attachment:FindFirstChild("BlackTrail").Enabled = false
		elseif entity:GetAttribute("Repent") == "Screech" then
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
	params.FilterDescendantsInstances = { Character, entity }

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
		--pentagram.RingAddonA.Orientation += Vector3.new(0, spinrate, 0)
		--pentagram.RingAddonB.Orientation += Vector3.new(0, -spinrate, 0)
		--pentagram.RingAddonC.Orientation += Vector3.new(0, spinrate * 0.8, 0)
		--pentagram.Base.Orientation += Vector3.new(0, -spinrate * 0.5, 0)

		gate.Crucifix.Glow.Orientation += Vector3.new(0, crucifix_spin.Value, 0)
	end)

	spinrate_changed.Changed:Connect(function(V)
		spinrate = V
	end)

	for _,v in pairs(entity:GetDescendants()) do
		if v:IsA("BasePart") then 
			v.Anchored = true
			--v.Position = gate.Entity.Position + Vector3.new(0, 2, 0)
		end
	end

	local Stored = gate.Crucifix.Glow.CFrame  

	gate.Crucifix.Glow.Sound.TimePosition = 0
	gate.Crucifix.Glow.SoundFail.TimePosition = 0

	--gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://12657890777"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://12664891904"

	--gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://15746677967"
	--gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://15746691911"

	gate.Crucifix.Glow.Sound.SoundId = "rbxassetid://6555668806"
	gate.Crucifix.Glow.SoundFail.SoundId = "rbxassetid://6555668806"

	gate.Crucifix.Glow.SoundFail:Play()
	gate.Crucifix.Glow.Sound:Stop()

	gate.Crucifix.Glow.CFrame = ToolHandle:GetPivot()

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

	camShake:FireClient(Player,10,15,4,5)

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
			Position = gate.Entity.Position + Vector3.new(0,5,0),
		}):Play()

		--tweensv:Create(part, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		--	Position = part.Position + Vector3.new(0,5,0),
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

		--for _,v in pairs(entity:GetDescendants()) do
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

	for _,v in pairs(entity:GetDescendants()) do
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

		camShake:FireClient(Player,3,10,0.7,0.5)

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = gate.Crucifix.Glow.Size * 4,
		}):Play()

		tweensv:Create(gate.Crucifix.Glow, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
		}):Play()

		task.spawn(function()
			if entity:GetAttribute("Repent") == "Normal" then
				primary:FindFirstChild("PlaySound"):Play()
				primary:FindFirstChild("Footsteps"):Play()
				local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentParticle.Enabled = false
				primary.Attachment:FindFirstChild("BlackTrail").Enabled = true
			elseif entity:GetAttribute("Repent") == "Quick" then
				primary:FindFirstChild("PlaySound"):Play()
				primary:FindFirstChild("Footsteps"):Play()
				local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
				local RepentParticle2 = primary.Attachment:FindFirstChild("RepentParticle2")
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentParticle.Enabled = false
				RepentParticle2.Enabled = false
			elseif entity:GetAttribute("Repent") == "Eyes" then
				primary:FindFirstChild("Ambience"):Play()
				local RepentParticle = primary.Attachment:FindFirstChild("RepentParticle")
				local RepentSound = primary:FindFirstChild("Repent")
				RepentSound:Stop()
				RepentParticle.Enabled = false
			elseif entity:GetAttribute("Repent") == "Screech" then
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
	entity:SetAttribute("Paused",false)
	entity:SetAttribute("BeingBanished",false)
	game.ReplicatedStorage.GameData.ChaseInSession.Value = true
end

return module
