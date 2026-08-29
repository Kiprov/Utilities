if getgenv().KiprovCrucifixFunctions then return getgenv().KiprovCrucifixFunctions end
local module = {}
local isOld = false
if game.PlaceId == 110258689672367 then
    isOld = true
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()

local ROOT = "https://github.com/Kiprov/Utilities/raw/main/DOORS/Crucifix%20Functions"
local Assets = {
	Repentance = LoadCustomInstance(ROOT.."/Assets/Repentance.rbxm")
}

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Humanoid.RootPart or Character.PrimaryPart
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local ModulesClient = not isOld and ReplicatedStorage:WaitForChild("ModulesClient") or ReplicatedStorage:WaitForChild("ClientModules") :: Folder
local Modules = {
	Module_Events = require(ModulesClient.Module_Events :: ModuleScript),
	Main_Game = require(PlayerGui.MainUI.Initiator.Main_Game :: ModuleScript)
}
local function OnCharacterAdded(char: Model)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
    RootPart = Humanoid.RootPart or char.PrimaryPart

    Modules.Main_Game = require(PlayerGui:WaitForChild("MainUI").Initiator.Main_Game :: ModuleScript)
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

--// Functions
local function WaitUntil(sound: Sound, t: number)
    repeat RunService.RenderStepped:Wait() until sound.TimePosition >= t
end

local function FadeOut(pentagram: Model)
    for _, v in pentagram:GetChildren() do
        if v.Name == "BeamFlat" then
            task.delay(v:GetAttribute("Delay") or 0, function()
                TweenService:Create(
                    v,
                    TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                    { Brightness = 0 }
                ):Play()
            end)
        elseif v.Name == "BeamChain" then
            TweenService:Create(
                v,
                TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                { Brightness = 0 }
            ):Play()
        end
    end
end

function module:CrucifyEntity(entity: any)
    -- \\ Setup
    local model = entity.Model
	local config = entity.Config

	local resist = config.Crucifixion.Resist
	local entityPivot = model:GetPivot()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, model}
	
    local result = workspace:Raycast(entityPivot.Position, Vector3.new(0, -1000, 0), params)
    if not result then return end

    model:SetAttribute("BeingBanished", true)
    model:SetAttribute("Paused", true)
	if resist == false then
	    model = model:Clone()
	    model.Name = "Fake_"..model.Name
        model.Parent = workspace
	    entity:Despawn()
	end

    -- \\ Variables
    local CamShaker = Modules.Main_Game.camShaker
	local TheShake = CamShaker:StartShake(5, 20, 2, Vector3.zero)

	local Repentance = Assets.Repentance:Clone()
	local Crucifix = Repentance.Crucifix
    local Handle = Crucifix.Handle
	local Pentagram = Repentance.Pentagram
	local EntityPart = Repentance.Entity
	local Sound = Handle[resist and "SoundFail" or "Sound"]

    -- \\ Repentance setup
	Repentance:PivotTo(CFrame.new(result.Position))
	Crucifix:PivotTo(Character:GetPivot())
	EntityPart.CFrame = entityPivot
	Repentance.Parent = workspace
	Sound:Play()

    -- \\ Lock entity model to EntityPart
	task.spawn(function()
        if not resist then
            while EntityPart.Parent do
                model:PivotTo(EntityPart.CFrame)
                RunService.RenderStepped:Wait()
            end
            model:Destroy()
        end
	end)

	-- \\ Pentagram animation
	TweenService:Create(
        Pentagram.Circle,
        TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
        { CFrame = Pentagram.Circle.CFrame - Vector3.new(0, 25, 0) }
    ):Play()

	task.delay(2, Pentagram.Circle.Destroy, Pentagram.Circle)

    -- \\ Crucifix hover
    Handle.BodyPosition.Position = (Character:GetPivot() * CFrame.new(1, 4, -6)).Position

	TweenService:Create(
        Handle.BodyAngularVelocity,
        TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
        { AngularVelocity = Vector3.new(0, 40, 0) }
    ):Play()

    task.delay(3, function()
        -- \\ Break off shards
        for _, shard in next, Handle.Shards:GetChildren() do
            shard.CollisionGroup = "NoPlayer"
            shard.CanCollide = true
            shard.Weld:Destroy()
            shard.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- \\ Start raising entity
    TweenService:Create(
        EntityPart,
        TweenInfo.new(3, Enum.EasingStyle.Elastic, Enum.EasingDirection.In),
        { CFrame = EntityPart.CFrame + Vector3.new(0, 2, 0) }
    ):Play()

    -- \\ Ritual animation
	task.spawn(function()
        WaitUntil(Sound, 2.625)
		
        TweenService:Create(
            Pentagram.Base.LightAttach.LightBright,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 5, Range = 40 }
        ):Play()
        TweenService:Create(
            Handle.Light,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 11.25, Range = 30 }
        ):Play()
		
        task.wait(1.5)
		
        TweenService:Create(Pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()
        TweenService:Create(Handle.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()

		if not resist then
            -- \\ Big light things
            TweenService:Create(
                Handle.Light,
                TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
                { Brightness = 15, Range = 40 }
            ):Play()

            TheShake:StartFadeOut(3)
            FadeOut(Pentagram)

            TweenService:Create(
                Handle.BodyAngularVelocity,
                TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                { AngularVelocity = Vector3.zero }
            ):Play()
        end
	end)

	-- \\ Crucifix actions
	if not resist then
		WaitUntil(Sound, 2.5)
		
        -- \\ Lower entity
        TweenService:Create(
            EntityPart,
            TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { CFrame = EntityPart.CFrame - Vector3.new(0, 50, 0) }
        ):Play()
		
        -- \\ Mute entity sounds
        for _, s in next, model:QueryDescendants("Sound") do
            if s:GetAttribute("VolumeIgnore") then continue end

            TweenService:Create(
                s,
                TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Volume = 0 }
            ):Play()
        end

        WaitUntil(Sound, 6.75)
	else
		WaitUntil(Sound, 4)

		TweenService:Create(
            Handle.BodyAngularVelocity,
            TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { AngularVelocity = Vector3.zero }
        ):Play()
		TweenService:Create(
            Pentagram.Base.LightAttach.LightBright,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }
        ):Play()
		TweenService:Create(
            Handle.Light,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }
        ):Play()
		
        TheShake:StartFadeOut(3)

        -- \\ Fade pentagram to red
		task.spawn(function()
			local color = Instance.new("Color3Value")
			color.Value = Color3.fromRGB(137, 207, 255)

			local tween = TweenService:Create(
                color,
                TweenInfo.new(0.5, Enum.EasingStyle.Sine),
                { Value = Color3.fromRGB(255, 116, 130) }
            )
			tween:Play()

			while tween.PlaybackState == Enum.PlaybackState.Playing do
				for _, d in next, Repentance:GetDescendants() do
					if d.ClassName == "Beam" then
						d.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, color.Value),
                            ColorSequenceKeypoint.new(1, color.Value)
                        })
					elseif d.Name == "Glow" then
						d.Color = color.Value
					end
				end
				task.wait()
			end
		end)

		WaitUntil(Sound, 9.625)
	end

	-- \\ Crucifix glow explode
	TweenService:Create(
        Handle.Glow,
        TweenInfo.new(1),
        { Size = Handle.Glow.Size * 3, Transparency = 1 }
    ):Play()
	TweenService:Create(
        Pentagram.Base.LightAttach.LightBright,
        TweenInfo.new(1),
        { Brightness = 0, Range = 0 }
    ):Play()
	TweenService:Create(
        Handle.Light,
        TweenInfo.new(1),
        { Brightness = 0, Range = 0 }
    ):Play()

	if not resist then
		Handle.ExplodeParticle:Emit(math.random(20, 30))
		CamShaker:ShakeOnce(7.5, 7.5, 0.25, 1.5)
	else
		model:SetAttribute("BeingBanished", false)
		model:SetAttribute("Paused", false)
		FadeOut(Pentagram)
	end

	task.delay(5, Repentance.Destroy, Repentance)
end

function module:CrucifyEntityWithoutConfig(entity: Model, resist: boolean)
    -- \\ Setup
    local model = entity

	local entityPivot = model:GetPivot()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {Character, model}
	
    local result = workspace:Raycast(entityPivot.Position, Vector3.new(0, -1000, 0), params)
    if not result then return end

    model:SetAttribute("BeingBanished", true)
    model:SetAttribute("Paused", true)
	if resist == false then
	    model = model:Clone()
	    model.Name = "Fake_"..model.Name
        model.Parent = workspace
	    entity:Destroy()
	end

    -- \\ Variables
    local CamShaker = Modules.Main_Game.camShaker
	local TheShake = CamShaker:StartShake(5, 20, 2, Vector3.zero)

	local Repentance = Assets.Repentance:Clone()
	local Crucifix = Repentance.Crucifix
    local Handle = Crucifix.Handle
	local Pentagram = Repentance.Pentagram
	local EntityPart = Repentance.Entity
	local Sound = Handle[resist and "SoundFail" or "Sound"]

    -- \\ Repentance setup
	Repentance:PivotTo(CFrame.new(result.Position))
	Crucifix:PivotTo(Character:GetPivot())
	EntityPart.CFrame = entityPivot
	Repentance.Parent = workspace
	Sound:Play()

    -- \\ Lock entity model to EntityPart
	task.spawn(function()
        if not resist then
            while EntityPart.Parent do
                model:PivotTo(EntityPart.CFrame)
                RunService.RenderStepped:Wait()
            end
            model:Destroy()
        end
	end)

	-- \\ Pentagram animation
	TweenService:Create(
        Pentagram.Circle,
        TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
        { CFrame = Pentagram.Circle.CFrame - Vector3.new(0, 25, 0) }
    ):Play()

	task.delay(2, Pentagram.Circle.Destroy, Pentagram.Circle)

    -- \\ Crucifix hover
    Handle.BodyPosition.Position = (Character:GetPivot() * CFrame.new(1, 4, -6)).Position

	TweenService:Create(
        Handle.BodyAngularVelocity,
        TweenInfo.new(4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
        { AngularVelocity = Vector3.new(0, 40, 0) }
    ):Play()

    task.delay(3, function()
        -- \\ Break off shards
        for _, shard in next, Handle.Shards:GetChildren() do
            shard.CollisionGroup = "NoPlayer"
            shard.CanCollide = true
            shard.Weld:Destroy()
            shard.AssemblyAngularVelocity = Vector3.zero
        end
    end)

    -- \\ Start raising entity
    TweenService:Create(
        EntityPart,
        TweenInfo.new(3, Enum.EasingStyle.Elastic, Enum.EasingDirection.In),
        { CFrame = EntityPart.CFrame + Vector3.new(0, 2, 0) }
    ):Play()

    -- \\ Ritual animation
	task.spawn(function()
        WaitUntil(Sound, 2.625)
		
        TweenService:Create(
            Pentagram.Base.LightAttach.LightBright,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 5, Range = 40 }
        ):Play()
        TweenService:Create(
            Handle.Light,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 11.25, Range = 30 }
        ):Play()
		
        task.wait(1.5)
		
        TweenService:Create(Pentagram.Base.LightAttach.LightBright, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()
        TweenService:Create(Handle.Light, TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Range = 0
		}):Play()

		if not resist then
            -- \\ Big light things
            TweenService:Create(
                Handle.Light,
                TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
                { Brightness = 15, Range = 40 }
            ):Play()

            TheShake:StartFadeOut(3)
            FadeOut(Pentagram)

            TweenService:Create(
                Handle.BodyAngularVelocity,
                TweenInfo.new(3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                { AngularVelocity = Vector3.zero }
            ):Play()
        end
	end)

	-- \\ Crucifix actions
	if not resist then
		WaitUntil(Sound, 2.5)
		
        -- \\ Lower entity
        TweenService:Create(
            EntityPart,
            TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { CFrame = EntityPart.CFrame - Vector3.new(0, 50, 0) }
        ):Play()
		
        -- \\ Mute entity sounds
        for _, s in next, model:QueryDescendants("Sound") do
            if s:GetAttribute("VolumeIgnore") then continue end

            TweenService:Create(
                s,
                TweenInfo.new(3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Volume = 0 }
            ):Play()
        end

        WaitUntil(Sound, 6.75)
	else
		WaitUntil(Sound, 4)

		TweenService:Create(
            Handle.BodyAngularVelocity,
            TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { AngularVelocity = Vector3.zero }
        ):Play()
		TweenService:Create(
            Pentagram.Base.LightAttach.LightBright,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }
        ):Play()
		TweenService:Create(
            Handle.Light,
            TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
            { Brightness = 0, Range = 0, Color = Color3.fromRGB(255, 116, 130) }
        ):Play()
		
        TheShake:StartFadeOut(3)

        -- \\ Fade pentagram to red
		task.spawn(function()
			local color = Instance.new("Color3Value")
			color.Value = Color3.fromRGB(137, 207, 255)

			local tween = TweenService:Create(
                color,
                TweenInfo.new(0.5, Enum.EasingStyle.Sine),
                { Value = Color3.fromRGB(255, 116, 130) }
            )
			tween:Play()

			while tween.PlaybackState == Enum.PlaybackState.Playing do
				for _, d in next, Repentance:GetDescendants() do
					if d.ClassName == "Beam" then
						d.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, color.Value),
                            ColorSequenceKeypoint.new(1, color.Value)
                        })
					elseif d.Name == "Glow" then
						d.Color = color.Value
					end
				end
				task.wait()
			end
		end)

		WaitUntil(Sound, 9.625)
	end

	-- \\ Crucifix glow explode
	TweenService:Create(
        Handle.Glow,
        TweenInfo.new(1),
        { Size = Handle.Glow.Size * 3, Transparency = 1 }
    ):Play()
	TweenService:Create(
        Pentagram.Base.LightAttach.LightBright,
        TweenInfo.new(1),
        { Brightness = 0, Range = 0 }
    ):Play()
	TweenService:Create(
        Handle.Light,
        TweenInfo.new(1),
        { Brightness = 0, Range = 0 }
    ):Play()

	if not resist then
		Handle.ExplodeParticle:Emit(math.random(20, 30))
		CamShaker:ShakeOnce(7.5, 7.5, 0.25, 1.5)
	else
		model:SetAttribute("BeingBanished", false)
		model:SetAttribute("Paused", false)
		FadeOut(Pentagram)
	end

	task.delay(5, Repentance.Destroy, Repentance)
end

getgenv().KiprovCrucifixFunctions = module
return module
