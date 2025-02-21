--[[
    __      __          _            _       ______       _   _ _            _____                                       __      _____  
    \ \    / /         (_)          ( )     |  ____|     | | (_) |          / ____|                                      \ \    / /__ \ 
     \ \  / /   _ _ __  ___  ___   _|/ ___  | |__   _ __ | |_ _| |_ _   _  | (___  _ __   __ ___      ___ __   ___ _ __   \ \  / /   ) |
      \ \/ / | | | '_ \| \ \/ / | | | / __| |  __| | '_ \| __| | __| | | |  \___ \| '_ \ / _` \ \ /\ / / '_ \ / _ \ '__|   \ \/ /   / / 
       \  /| |_| | | | | |>  <| |_| | \__ \ | |____| | | | |_| | |_| |_| |  ____) | |_) | (_| |\ V  V /| | | |  __/ |       \  /   / /_ 
        \/  \__, |_| |_|_/_/\_\\__,_| |___/ |______|_| |_|\__|_|\__|\__, | |_____/| .__/ \__,_| \_/\_/ |_| |_|\___|_|        \/   |____|
             __/ |                                                   __/ |        | |                                                   
            |___/                                                   |___/         |_|
]]--

if VynixuEntitySpawnerV2 then return VynixuEntitySpawnerV2 end

--Very Important Check
local isOld = false
if game.PlaceId == 110258689672367 then
    isOld = true
end
warn("[SPAWNER]: Hotel- Status: ",isOld)
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local reboundCon = nil

-- Variables
local localPlayer = Players.LocalPlayer
local localChar = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localHum = localChar:WaitForChild("Humanoid")
local localCamera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")
local gameStats = ReplicatedStorage:WaitForChild("GameStats")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local floorReplicated = isOld == false and ReplicatedStorage:WaitForChild("FloorReplicated") or nil
local remotesFolder = isOld == false and ReplicatedStorage:WaitForChild("RemotesFolder") or ReplicatedStorage:WaitForChild("Bricks")

local lastRespawn;
local BaseEntitySpeed = 65
local colourGuiding = Color3.fromRGB(137, 207, 255)
local colourCurious = Color3.fromRGB(253, 255, 133)

local vynixuModules = {
	Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))(),
	CrucifixFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/DOORS/Crucifix%20Functions/Source.lua"))()
}
local moduleScripts = {
	Module_Events = require(ReplicatedStorage.ClientModules.Module_Events),
	Main_Game = require(playerGui.MainUI.Initiator.Main_Game),
	Earthquake = isOld == false and require(remotesFolder.RequestAsset:InvokeServer("Earthquake")) or function() end,
}
local defaultEntityAttributes = {
    Running = false,
	CustomEntity = true,
	Paused = false,
	BeingBanished = false,
	Despawning = false,
	Damage = true,
    LastEnteredRoom = -1,
	Repent = "None"
}
local defaultPlayerAttributes = {
	SpawnProtection = 5
}
local defaultDebug = {
	OnSpawned = function() end,
	OnStartMoving = function() end,
	OnReachedNode = function() end,
	OnEnterRoom = function() end,
	OnLookAt = function() end,
	OnRebounding = function() end,
	OnDespawning = function() end,
	OnDespawned = function() end,
	OnDamagePlayer = function() end,
	CrucifixionOverwrite = ""
}
local defaultConfig = {
	Entity = {
		Name = "Template Entity",
		Asset = "https://github.com/RegularVynixu/Utilities/blob/main/Doors%20Entity%20Spawner/Models/Rush.rbxm?raw=true",
		HeightOffset = 0,
		SpawnOffset = 0,
		SmoothSound = false,
		CanSpawnWithoutClosets = true,
	},
	Movement = {
		Speed = 100,
		Delay = 2,
		Reversed = false
	},
	Damage = {
		Enabled = true,
		Range = 40,
		Amount = 125
	},
	Rebounding = {
		Enabled = true,
		Type = "Ambush", -- "Blitz"
		Min = 2,
		Max = 4,
		Delay = 2
	},
	Lights = {
		Flicker = {
			Enabled = true,
			Duration = 1
		},
		Shatter = true,
		Repair = false
	},
	Earthquake = {
		Enabled = true
	},
	CameraShake = {
		Enabled = true,
		Values = {1.5, 20, 0.1, 1}, -- Magnitude, Roughness, FadeIn, FadeOut
		Range = 100
	},
	Crucifixion = {
		Type = "Curious", -- "Guiding"
		Enabled = true,
		Range = 40,
		Resist = false,
		Break = true
	},
	Death = {
		Type = "Guiding", -- "Curious"
		Hints = {},
        Cause = ""
	}
}
local ambientStorage = {}
local deathTypes = {
	["Yellow"] = {"yellow", "curious"},
	["Blue"] = {"blue", "guiding"}
}
local spawner = {}

-- Functions
function CloneTable(tbl)
    local cloned = {}
    for key, value in pairs(tbl) do
        if typeof(value) == "table" then
            cloned[key] = CloneTable(value)
        else
            cloned[key] = value
        end
    end
    return cloned
end

function OnCharacterAdded(char)
	lastRespawn = tick()
	localChar, localHum = char, char:WaitForChild("Humanoid")
end

function GetCurrentRoom(latest)
    if latest then
        return workspace.CurrentRooms:GetChildren()[#workspace.CurrentRooms:GetChildren()]
    end
    return workspace.CurrentRooms:FindFirstChild(localPlayer:GetAttribute("CurrentRoom"))
end

local IT = Instance.new
local V3 = Vector3.new
local CF = CFrame.new
local C3 = Color3.new
local ANGLES = CFrame.Angles
local ps = game:GetService("PathfindingService")

function GetNodesFromRoom(room, reversed, entityTable)
	local nodes = {}
	local roomEntrance = isOld == false and room:FindFirstChild("RoomEntrance") or room:FindFirstChild("RoomStart")
	if roomEntrance then
		local n = roomEntrance:Clone()
		n.Name = "0"
		n.CFrame -= Vector3.new(0, 3, 0)
		nodes[1] = n
	end
	
	local roomExit = isOld == false and room:FindFirstChild("RoomExit") or room:FindFirstChild("RoomEnd")

	local nodesFolder = isOld == false and room:FindFirstChild("PathfindNodes") or room:FindFirstChild("Nodes")
	if nodesFolder then
		for _, n in nodesFolder:GetChildren() do
			nodes[#nodes + 1] = n
		end
		else
		if not roomEntrance or not roomExit then return nodes end
		local path = ps:CreatePath()
		path:ComputeAsync(roomEntrance:GetPivot().Position,roomExit:GetPivot().Position)
		nodesFolder = path:GetWaypoints()
		local fold = Instance.new("Folder")
		for i,v in next, nodesFolder do
local node = IT("Part")
node.Name = i
node.Anchored = true
node.Size = V3(1,1,1)
node.CanCollide = false
node.Material = "ForceField"
node.Shape = "Ball"
node.Color = C3(0,1,1)
node.Transparency = 0
node.Position = v.Position
node.Parent = fold
end
nodesFolder = fold
for _, n in nodesFolder:GetChildren() do
			nodes[#nodes + 1] = n
		end
	end
	if roomExit then
		local index = #nodes + 1
		local n = roomExit:Clone()
		n.Name = index
		n.CFrame -= Vector3.new(0, 3, 0)
		nodes[index] = n
	end

	table.sort(nodes, function(a, b)
        if reversed then
            return tonumber(a.Name) > tonumber(b.Name)
        else
            return tonumber(a.Name) < tonumber(b.Name)
        end
	end)

	return nodes
end

function GetPathfindNodesAmbush(entityTable)
	local pathfindNodes = {}
    local rooms = workspace.CurrentRooms:GetChildren()
    local config = entityTable.Config
    if config.Movement.Reversed == false then
        for i = 1, #rooms, 1 do
            local room = rooms[i]
            local roomNodes = GetNodesFromRoom(room, false, entityTable)
            for _, node in roomNodes do
                pathfindNodes[#pathfindNodes + 1] = node
            end
        end
    else
        for i = #rooms, 1, -1 do
            local room = rooms[i]
            local roomNodes = GetNodesFromRoom(room, true, entityTable)
            for _, node in roomNodes do
                pathfindNodes[#pathfindNodes + 1] = node
            end
        end
    end
	return pathfindNodes
end

function GetPathfindNodesA120(entityTable)
	local pathfindNodes = {}
	local config = entityTable.Config
	local node = IT("Part")
	node.Name = "0"
	node.Anchored = true
	node.Size = V3(1,1,1)
	node.CanCollide = false
	node.Material = "ForceField"
	node.Shape = "Ball"
	node.Color = C3(0,1,1)
	node.Transparency = 0
	node:PivotTo(localChar:GetPivot())
	pathfindNodes[#pathfindNodes + 1] = node
	local node = IT("Part")
	node.Name = #pathfindNodes + 1
	node.Anchored = true
	node.Size = V3(1,1,1)
	node.CanCollide = false
	node.Material = "ForceField"
	node.Shape = "Ball"
	node.Color = C3(0,1,1)
	node.Transparency = 0
	local pivot = localChar:GetPivot()
	local lookV = pivot.LookVector
	local zval = nil
	if lookV.Z < 0 then
	    zval = config.Movement.Reversed and 100 or -100
	else
	    zval = config.Movement.Reversed and -100 or 100
	end
	node:PivotTo(pivot*CFrame.new(0,0,zval))
	pathfindNodes[#pathfindNodes + 1] = node
	return pathfindNodes
end

function GetPathfindNodesBlitz(entityTable)
	local nodesToCurrent, nodesToEnd = {}, {}
	local currentRoomIndex = localPlayer:GetAttribute("CurrentRoom")
    local rooms = workspace.CurrentRooms:GetChildren()
    local config = entityTable.Config

    if config.Movement.Reversed == false then
        for _, room in rooms do
            local roomNodes = GetNodesFromRoom(room, false, entityTable)
            local roomIndex = tonumber(room.Name)
    
            for _, node in roomNodes do
                if roomIndex <= currentRoomIndex then
                    nodesToCurrent[#nodesToCurrent + 1] = node
                else
                    nodesToEnd[#nodesToEnd + 1] = node
                end
            end
        end
    else
        for i = #rooms, 1, -1 do
            local room = rooms[i]
            local roomNodes = GetNodesFromRoom(room, true, entityTable)
            local roomIndex = tonumber(room.Name)
    
            for _, node in roomNodes do
                if roomIndex >= currentRoomIndex then
                    nodesToCurrent[#nodesToCurrent + 1] = node
                else
                    nodesToEnd[#nodesToEnd + 1] = node
                end
            end
        end 
    end

	return nodesToCurrent, nodesToEnd
end

function PlayerInLineOfSight(model, config)
	local origin = model:GetPivot().Position
	local charOrigin = localChar:GetPivot().Position

	if (charOrigin - origin).Magnitude <= config.Damage.Range then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {localChar, model}

		local result = workspace:Raycast(origin, charOrigin - origin, params)
		return (result == nil), result
	end
	return false
end

function PlayerHasItemEquipped(name)
	local tool = localChar:FindFirstChildOfClass("Tool")
	if tool and tool.Name == name then
		return true, tool
	end
	return false
end

function CrucifixEntity(entityTable, tool)
	local model = entityTable.Model
	local config = entityTable.Config

	local resist = config.Crucifixion.Resist
	local toolHandle = tool.Handle
	if not resist then
		vynixuModules.CrucifixFunctions:CrucifyEntity(entityTable,model,toolHandle)
	else
		vynixuModules.CrucifixFunctions:FailCrucifyEntity(entityTable,model,toolHandle)
	end
end

function PlayerIsProtected()
	return (tick() - lastRespawn) <= localPlayer:GetAttribute("SpawnProtection")
end

function DamagePlayer(entityTable)
	if localHum.Parent:FindFirstChild("Crucifix") then return end
	if localHum.Health > 0 and not PlayerIsProtected() then
		local config = entityTable.Config
		local newHealth = math.clamp(localHum.Health - config.Damage.Amount, 0, localHum.MaxHealth)

		if newHealth == 0 then
			-- Death hints
			if #config.Death.Hints > 0 then
				-- Get death type
				local colour;
				for name, values in deathTypes do
					if table.find(values, config.Death.Type:lower()) then
						colour = name
					end
				end
				if not colour then
					for _, c in playerGui.MainUI.Initiator.Main_Game.Health.Music:GetChildren() do
						if c.Name:lower() == config.Death.Type:lower() then
							colour = c.Name
						end
					end
				end
				if not colour then
					colour = "Blue"
				end
				
				-- Set death hints and type (thanks oogy)
				if firesignal then
					firesignal(remotesFolder.DeathHint.OnClientEvent, config.Death.Hints, colour)
				else
					warn("firesignal not supported, ignore death hints.")
				end
			end

			-- Set death cause
			local deathCause = config.Entity.Name
			if config.Death.Cause ~= "" then
				deathCause = config.Death.Cause
			end
			gameStats["Player_".. localPlayer.Name].Total.DeathCause.Value = deathCause
		end

		-- Update health
		localHum.Health = newHealth
		task.spawn(entityTable.RunCallback, entityTable, "OnDamagePlayer", newHealth) -- OnDamagePlayer
	end
end

function GetRoomAtPoint(vector3)
	local whitelist = {}
	for _, room in workspace.CurrentRooms:GetChildren() do
		local p = room:FindFirstChild(room.Name)
		if p then
			whitelist[#whitelist + 1] = p
		end
	end

	if #whitelist > 0 then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = whitelist
		params.CollisionGroup = "BaseCheck"

		local result = workspace:Raycast(vector3, Vector3.new(0, -100, 0), params)
		if result then
			for _, room in workspace.CurrentRooms:GetChildren() do
				if result.Instance.Parent == room then
					return room
				end
			end
		end
	end
end

function FixRoomLights(room)
	if not room:FindFirstChild("RoomEntrance") then
		return
	end

    -- Clear shards
    for _, c in localCamera:GetChildren() do
        if c.Name == "Piece" then
            c:Destroy()
        end
    end
    
    -- Set room ambient
    require(ReplicatedStorage.ClientModules.Module_Events).toggle(room, true, ambientStorage[room])

    -- Fix lights
    local stuff = {}
    for _, d in room:GetDescendants() do
        if d:IsA("Model") and (d.Name == "LightStand" or d.Name == "Chandelier") then
            table.insert(stuff, d)
        end
    end

    local random = Random.new(tick())
    for _, v in stuff do
        if v:GetAttribute("Shattered") then
			local r1 = random:NextInteger(-10, 10) / 50
			local r2 = random:NextInteger(5, 20) / 100
	
			task.delay((room.RoomEntrance.Position - v.PrimaryPart.Position).Magnitude / 150 + r1, function()
				local neon = v:FindFirstChild("Neon", true)
				for _, d in pairs(v:GetDescendants()) do
					if d:IsA("Light") then
						TweenService:Create(d, TweenInfo.new(r2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							Brightness = d:GetAttribute("OGBrightness")
						}):Play()
					elseif d:IsA("Sound") then
						TweenService:Create(d, TweenInfo.new(r2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							Volume = d:GetAttribute("OGVolume")
						}):Play()
					end
				end
				if neon then
					neon.Transparency = 0.9
					neon.Material = Enum.Material.Neon
					TweenService:Create(neon, TweenInfo.new(r2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
						Transparency = 0.2
					}):Play()
					task.wait(r2)
				end
				v:SetAttribute("Shattered", false)
			end)
		end
    end
end

function EntityMoveTo(model, cframe, speed)
	local alpha = 0
	local speed = speed
	local distance = (model.PrimaryPart.Position - cframe.Position).Magnitude
	local relativeSpeed = distance / speed
	local startCFrame = model.PrimaryPart.CFrame
	local loop
	local reachedEvent = Instance.new("BindableEvent")
	loop = RunService.Heartbeat:Connect(function(delta)
		if not model:GetAttribute("Paused") then
			local goalCFrame = startCFrame:Lerp(cframe, alpha)
			model:PivotTo(goalCFrame)
			alpha += delta / relativeSpeed
			if alpha >= 1 then
				loop:Disconnect()
				reachedEvent:Fire()
			end
		end
	end)
	reachedEvent.Event:Wait()
	--Old Source below!
	--[[local reached = false
	local connection; connection = RunService.Stepped:Connect(function(_, step)
		if not model:GetAttribute("Paused") then
			local pivot = model:GetPivot()
			local difference = (cframe.Position - pivot.Position)
			local unit = difference.Unit
			local magnitude = difference.Magnitude

			if magnitude > 0.1 then
				model:PivotTo(pivot + unit * math.min(step * speed, magnitude))
			else
				connection:Disconnect()
				reached = true
			end
		end
	end)
	repeat RunService.Stepped:Wait() until reached]]--
end

function ApplyConfigDefaults(tbl, defaults)
    for key, value in defaults do
		if tbl[key] == nil then
            tbl[key] = value

        elseif typeof(value) == "table" then
            if not tbl[key] or typeof(tbl[key]) ~= "table" then
                tbl[key] = {}
            end
            ApplyConfigDefaults(tbl[key], value)
        end
    end
end

function GetAllDatatypes(config, datatype, ignoreList) -- thanks ChatGPT lmao
	ignoreList = ignoreList or {}
	
	local function traverseConfig(tbl, path, results)
		for key, value in tbl do
			local newPath = path ~= "" and (path .. "." .. key) or key
			if type(value) == datatype then
				table.insert(results, {path = newPath, value = value})
			elseif type(value) == "table" then
				traverseConfig(value, newPath, results)
			end
		end
	end

	local results = {}
	traverseConfig(config, "", results)

	-- Exclude paths from ignoreList
	local filteredResults = {}
	for _, item in results do
		local shouldIgnore = false
		for _, ignorePath in ignoreList do
			if item.path:find(ignorePath, 1, true) then
				shouldIgnore = true
				break
			end
		end
		if not shouldIgnore then
			table.insert(filteredResults, item)
		end
	end

	return filteredResults
end

function PrerunCheck(entityTable)
	local config = entityTable.Config
	local rebounding = config.Rebounding

	if entityTable.Model:GetAttribute("Running") then
        warn("Entity awweady wunnying :3 sowwy")
        return false

	elseif rebounding.Enabled and (rebounding.Min <= 0 or rebounding.Max <= 0 or rebounding.Min > rebounding.Max) then
		warn("Invalid rebounding values, returning.")
		return false
	end
	
	-- Check for invalid number values
	for _, v in GetAllDatatypes(config, "number", {"Entity.SpawnOffset","Entity.HeightOffset", "CameraShake.Values", "Delay"}) do
		if v.value <= 0 then
			warn(("Invalid number value: '%s', returning."):format(v.path))
			return false
		end
	end
	
	return true
end

function loadSound(entityTable,entityModel)
	for _,snd in next, entityModel:GetDescendants() do
		if snd:IsA("Sound") then
			task.spawn(function()
				local sndorigvolume = snd.Volume
				snd.Volume = 0
				snd:Play()
				snd.SoundGroup = game:GetService("SoundService").Main
				wait(0.1)
				local tween = game.TweenService:Create(snd,TweenInfo.new(entityTable.Movement.Delay,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Volume = sndorigvolume})
				tween:Play()
			end)
		end
	end
end

function unloadSound(entityTable, entityModel)
	for _,snd in next, entityModel:GetDescendants() do
		if snd:IsA("Sound") then
			local tween = game.TweenService:Create(snd,TweenInfo.new(entityTable.Config.Movement.Delay),{Volume = 0})
			tween:Play()
			tween.Completed:Connect(function()
				snd:Stop()
				snd.Volume = 1
			end)
		end
	end
end
local function GetClosetsInRoom(room)
	if room:FindFirstChild("Assets") then
		if room.Assets:FindFirstChild("Wardrobe") or room.Assets:FindFirstChild("Toolshed") then
			return true
		else
			return false
		end
	else
		return false
	end
end

spawner.Create = function(config)
	ApplyConfigDefaults(config, defaultConfig)
	config.Movement.Speed = BaseEntitySpeed / 100 * config.Movement.Speed

	-- Load and set up entity model
	local asset = config.Entity.Asset
	local success, entityModel;

	if typeof(asset) == "Instance" and asset:IsA("Model") then
		success, entityModel = true, asset

	elseif typeof(asset) == "string" then
		success, entityModel = pcall(function()
			local m = LoadCustomInstance(asset)
			if m then
				if m.ClassName ~= "Model" then
					warn("Entity asset is not a model, returning.")
					return
				end
			else
				warn("Failed to load entity asset, returning.")
				return
			end
			return m
		end)
	else
		warn("Invalid entity asset type, returning.")
		return
	end

	-- Construct and return entityTable
	if success and entityModel then
		if config.Entity.SmoothSound then
			loadSound(config,entityModel)
		end
		local root = entityModel.PrimaryPart or entityModel:FindFirstChildWhichIsA("BasePart")
		if root then
			root.Anchored = true
			entityModel.PrimaryPart = root

			-- Entity custom name
			local c = config.Entity
			if c.Name and c.Name ~= "" then
				entityModel.Name = c.Name
			end

			-- Entity default attributes
			for name, value in defaultEntityAttributes do
				if name == "Repent" then
					if config.Crucifixion.Repent ~= "None" then
						entityModel:SetAttribute(name, config.Crucifixion.Repent)
					else
						entityModel:SetAttribute(name, value)
					end
				else
					entityModel:SetAttribute(name, value)
				end
			end
		end

		-- RoomsEntered folder
		local f = Instance.new("Configuration")
		f.Name = "RoomsEntered"
		f.Parent = entityModel

		-- EntityTable
		local entityTable = {
			Model = entityModel,
			Config = config,
			Debug = CloneTable(defaultDebug),
			SetCallback = function(self, key, callback)
				if self.Debug[key] then
					if typeof(callback) == "function" then
						self.Debug[key] = callback
					else
						warn("Failed to set callback, invalid callback datatype.")
					end
				else
					warn("Failed to set callback, invalid callback key.")
				end
			end,
			RunCallback = function(self, key, ...)
				local callback = self.Debug[key]
				if callback then
					local success, result = pcall(callback, ...)
					if not success then
						warn(("Error in callback: '%s' for entity: '%s':\n%s"):format(key, self.Config.Entity.Name, result))
					end
				end
			end,
			Pause = function(self, bool)
				if self.Model then
					self.Model:SetAttribute("Paused", bool)
				end
			end,
			Despawn = function(self)
				if self.Model then
					self.Model:Destroy()
					self.Model = nil
					task.spawn(self.RunCallback, self, "OnDespawned") -- OnDespawned
				end
			end
		}
		
		entityTable.Run = function(self)
			spawner.Run(self)
		end

		return entityTable
	end
end

spawner.Run = function(entityTable)
	task.spawn(function()
		if not entityTable.Config.Entity.CanSpawnWithoutClosets then
			if GetClosetsInRoom(workspace.CurrentRooms[gameData.LatestRoom.Value]) == false then
				return
			end
		end
		if PrerunCheck(entityTable) == false then
			return
		end
	
		local model = entityTable.Model
		local config = entityTable.Config
		local debug = entityTable.Debug
		
		model:SetAttribute("Running", true)
	
		-- Spawning
		local spawnPoint;
		local function setupSpawn()
		local rooms = workspace.CurrentRooms:GetChildren()
		if config.Movement.Reversed then
			spawnPoint = isOld == false and rooms[#rooms]:FindFirstChild("RoomExit") or rooms[#rooms]:FindFirstChild("RoomEnd")
		else
			spawnPoint = isOld == false and rooms[1]:FindFirstChild("RoomEntrance") or rooms[1]:FindFirstChild("RoomStart")
			if not spawnPoint then
			warn("spawn point not found, trying 2nd pre-deletion room")
			spawnPoint = isOld == false and rooms[2]:FindFirstChild("RoomEntrance") or rooms[2]:FindFirstChild("RoomStart")
			end
		end
		end
		
		setupSpawn()
	
		if spawnPoint then
		-- Offset
		local configNum = config.Entity.SpawnOffset
		if typeof(configNum) ~= "number" then
		--Use defaults
		warn(configNum.." is not a number, using defaults.")
		configNum = 0
		else
		configNum = math.abs(configNum)
		end
		local offsetNum = config.Movement.Reversed and -configNum or configNum
		local offset = CFrame.new(0,0,offsetNum)
			-- Spawning
			model:PivotTo(spawnPoint.CFrame * offset + Vector3.new(0, config.Entity.HeightOffset, 0))
			model.Parent = workspace
			task.spawn(entityTable.RunCallback, entityTable, "OnSpawned") -- OnSpawned
	
			-- Flickering lights
			if config.Lights.Flicker.Enabled then
				local currentRoom = GetCurrentRoom(false)
				if currentRoom then
					if isOld == false then
					moduleScripts.Module_Events.flicker(currentRoom, config.Lights.Flicker.Duration)
					else
					moduleScripts.Module_Events.flickerLights(currentRoom, config.Lights.Flicker.Duration)
					end
				end
			end
			-- Earthquake
			if config.Earthquake.Enabled then
				moduleScripts.Earthquake(moduleScripts.Main_Game, currentRoom)
			end
	
			-- Movement detection handling
			task.wait(config.Movement.Delay)
			task.spawn(entityTable.RunCallback, entityTable, "OnStartMoving") -- OnStartMoving
			task.spawn(function()
				while model.Parent do
					if not model:GetAttribute("Paused") then
						local pivot = model:GetPivot()
						local charPivot = localChar:GetPivot()
						local inSight = PlayerInLineOfSight(model, config)
	
						-- Player look detection
						if localHum.Health > 0 then
							local _, isVisible = localCamera:WorldToViewportPoint(pivot.Position)
							if isVisible then
								task.spawn(entityTable.RunCallback, entityTable, "OnLookAt", inSight) -- OnLookAt
							end
						end
						
						-- Room detection
						do
							local room = GetRoomAtPoint(pivot.Position)
							if room then
								local index = tonumber(room.Name)
								if index ~= model:GetAttribute("LastEnteredRoom") then
									model:SetAttribute("LastEnteredRoom", index)
	
									local roomsEntered = model:FindFirstChild("RoomsEntered")
									if roomsEntered then
										local firstTime = (roomsEntered:GetAttribute(room.Name) == nil)
										task.spawn(entityTable.RunCallback, entityTable, "OnEnterRoom", room, firstTime) -- OnEnterRoom
	
										if firstTime then
											roomsEntered:SetAttribute(room.Name, true)
										end
										
										local latestRoom = GetCurrentRoom(true)
										if room ~= latestRoom then
											if config.Lights.Shatter then -- Shatter lights
												if isOld == false then
												moduleScripts.Module_Events.shatter(room)
												else
												moduleScripts.Module_Events.breakLights(room)
												end
		
											elseif config.Lights.Repair then -- Repair lights
												FixRoomLights(room)
											end
										end
									end
								end
							end
						end
	
						-- Crucifixion detection
						local usedCrucifix = false
						do
							local c = config.Crucifixion
							if c.Enabled and c.Range > 0 and (charPivot.Position - pivot.Position).Magnitude <= c.Range and inSight then
								local hasTool, tool = PlayerHasItemEquipped("Crucifix")
								if hasTool and tool and not model:GetAttribute("BeingBanished") then
									-- Crucifixion
									if typeof(debug.CrucifixionOverwrite) == "function" then
										entityTable:RunCallback("CrucifixionOverwrite") -- CrucifixionOverwrite
									else
										model:SetAttribute("Paused", true)
										CrucifixEntity(entityTable, tool)
									end
									usedCrucifix = true
								end
							end
						end
	
						-- Damage detection
						if not model:GetAttribute("Paused") and not usedCrucifix then
							local c = config.Damage
							if c.Enabled and c.Range > 0 and localHum.Health > 0 and not localChar:GetAttribute("Hiding") and model:GetAttribute("Damage") and not model:GetAttribute("BeingBanished") and (charPivot.Position - pivot.Position).Magnitude <= c.Range and inSight then
								model:SetAttribute("Damage", false)
								DamagePlayer(entityTable)
							end
						end
	
						-- Camera shaking
						do
							local c = config.CameraShake
							if c.Enabled then
								local mag = (charPivot.Position - pivot.Position).Magnitude
								if mag <= c.Range then
									local cloned = {}
									for i, v in c.Values do
										cloned[i] = v
									end
	
									cloned[1] = c.Values[1] / c.Range * (c.Range - mag) -- Magnitude
									cloned[2] = c.Values[2] / c.Range * (c.Range - mag) -- Roughness
									moduleScripts.Main_Game.camShaker:ShakeOnce(table.unpack(cloned))
								end
							end
						end
					end
					task.wait()
				end
			end)
			
			-- Pathfinding
			task.spawn(function()
				local reboundType = config.Rebounding.Type:lower()
				if reboundType == "blitz" then
					-- Blitz rebounding
					local nodesToCurrent, nodesToEnd = GetPathfindNodesBlitz(entityTable)
	
					for _, n in nodesToCurrent do
						local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
					end
					
					-- Rebounding handling
					if config.Rebounding.Enabled then
						local currentRoom = GetCurrentRoom(false)
						if not currentRoom then
							warn("Failed to obtain current room, returning.")
							return
						end
						local roomNodes = GetNodesFromRoom(currentRoom, config.Movement.Reversed)
						if #roomNodes == 1 then
							warn("Failed to obtain current room nodes, returning.")
							return
						end
						local randomNode;
						if config.Movement.Reversed == false then
							randomNode = roomNodes[math.random(1, #roomNodes - 1)]
						else
							randomNode = roomNodes[math.random(2, #roomNodes)]
						end
						if not randomNode then
							warn("Failed to obtain current room Blitz node, returning.")
							return
						end
	
						local reboundsCount = math.random(config.Rebounding.Min, config.Rebounding.Max)
						for i = 1, reboundsCount, 1 do
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding
							
							local nodeIndex = tonumber(randomNode.Name)
							for i = #roomNodes, nodeIndex, -1 do
								local cframe = roomNodes[math.clamp(i, 1, #roomNodes)].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
							end
							
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding
		
							for i = nodeIndex, #roomNodes, 1 do
								local cframe = roomNodes[math.clamp(i, 1, #roomNodes)].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
							end
						end
					end
					
					local _, updatedToEnd = GetPathfindNodesBlitz(entityTable)
					for _, n in updatedToEnd do
						local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachNode", n) -- OnReachNode
					end
				elseif reboundType == "rebound" then
					-- Rebound rebounding
					local pathfindNodes = GetPathfindNodesAmbush(entityTable)
					reboundCon = true
					spawn(function()
						repeat
							wait()
							for i = 1,10 do
								pathfindNodes = GetPathfindNodesAmbush(entityTable)
							end
						until reboundCon == false
					end)
					for nodeIdx = 1, #pathfindNodes, 1 do
						if not pathfindNodes[nodeIdx] then continue end
						local cframe = pathfindNodes[nodeIdx].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[nodeIdx]) -- OnReachNode
					end

					-- Rebounding handling
					if config.Rebounding.Enabled then
						local reboundsCount = math.random(config.Rebounding.Min, config.Rebounding.Max)
						for i = 1, reboundsCount, 1 do
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding
							setupSpawn()
									-- Offset
		local configNum = config.Entity.SpawnOffset
		if typeof(configNum) ~= "number" then
		--Use defaults
		warn(configNum.." is not a number, using defaults.")
		configNum = 0
		else
		configNum = math.abs(configNum)
		end
		local offsetNum = config.Movement.Reversed and -configNum or configNum
		local offset = CFrame.new(0,0,offsetNum)
											model:PivotTo(spawnPoint.CFrame * offset + Vector3.new(0, config.Entity.HeightOffset, 0))
							for _, n in pathfindNodes do
								local cframe = n.CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", n) -- OnReachNode
							end
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding
							setupSpawn()
									-- Offset
		local configNum = config.Entity.SpawnOffset
		if typeof(configNum) ~= "number" then
		--Use defaults
		warn(configNum.." is not a number, using defaults.")
		configNum = 0
		else
		configNum = math.abs(configNum)
		end
		local offsetNum = config.Movement.Reversed and -configNum or configNum
		local offset = CFrame.new(0,0,offsetNum)
											model:PivotTo(spawnPoint.CFrame * offset + Vector3.new(0, config.Entity.HeightOffset, 0))
							pathfindNodes = GetPathfindNodesAmbush(entityTable)

							-- Run forwards through nodes
							for nodeIdx = 1, #pathfindNodes, 1 do
								if not pathfindNodes[nodeIdx] then continue end
								local cframe = pathfindNodes[nodeIdx].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[nodeIdx]) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding

							-- Delay unless last rebound
							if i < reboundsCount then
								task.wait(config.Rebounding.Delay)
							end
						end
					end
					elseif reboundType == "a-120" then
					-- A-120 rebounding
					local pathfindNodes = GetPathfindNodesA120(entityTable)
					reboundCon = true
					spawn(function()
						repeat
							wait()
							for i = 1,10 do
								pathfindNodes = GetPathfindNodesA120(entityTable)
							end
						until reboundCon == false
					end)
					for nodeIdx = 1, #pathfindNodes, 1 do
						if not pathfindNodes[nodeIdx] then continue end
						local cframe = pathfindNodes[nodeIdx].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[nodeIdx]) -- OnReachNode
					end

					-- Rebounding handling
					if config.Rebounding.Enabled then
						local reboundsCount = math.random(config.Rebounding.Min, config.Rebounding.Max)
						for i = 1, reboundsCount, 1 do
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding

							-- Run backwards through nodes
							for i = #pathfindNodes, 1, -1 do
								if not pathfindNodes[i] then continue end
								local cframe = pathfindNodes[i].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[i]) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding
							pathfindNodes = GetPathfindNodesA120(entityTable)

							-- Run forwards through nodes
							for nodeIdx = 1, #pathfindNodes, 1 do
								if not pathfindNodes[nodeIdx] then continue end
								local cframe = pathfindNodes[nodeIdx].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[nodeIdx]) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding

							-- Delay unless last rebound
							if i < reboundsCount then
								task.wait(config.Rebounding.Delay)
							end
						end
					end
				else
					-- Ambush rebounding
					local pathfindNodes = GetPathfindNodesAmbush(entityTable)
					reboundCon = true
					spawn(function()
						repeat
							wait()
							for i = 1,10 do
								pathfindNodes = GetPathfindNodesAmbush(entityTable)
							end
						until reboundCon == false
					end)
					for nodeIdx = 1, #pathfindNodes, 1 do
						if not pathfindNodes[nodeIdx] then continue end
						local cframe = pathfindNodes[nodeIdx].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
						EntityMoveTo(model, cframe, config.Movement.Speed)
						task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[nodeIdx]) -- OnReachNode
					end

					-- Rebounding handling
					if config.Rebounding.Enabled then
						local reboundsCount = math.random(config.Rebounding.Min, config.Rebounding.Max)
						for i = 1, reboundsCount, 1 do
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding

							-- Run backwards through nodes
							for i = #pathfindNodes, 1, -1 do
								if not pathfindNodes[i] then continue end
								local cframe = pathfindNodes[i].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[i]) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding
							task.wait(config.Rebounding.Delay)
							model:SetAttribute("Damage", true)
							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", true) -- OnRebounding
							pathfindNodes = GetPathfindNodesAmbush(entityTable)

							-- Run forwards through nodes
							for nodeIdx = 1, #pathfindNodes, 1 do
								if not pathfindNodes[nodeIdx] then continue end
								local cframe = pathfindNodes[nodeIdx].CFrame + Vector3.new(0, 3 + config.Entity.HeightOffset, 0)
								EntityMoveTo(model, cframe, config.Movement.Speed)
								task.spawn(entityTable.RunCallback, entityTable, "OnReachedNode", pathfindNodes[nodeIdx]) -- OnReachNode
							end

							task.spawn(entityTable.RunCallback, entityTable, "OnRebounding", false) -- OnRebounding

							-- Delay unless last rebound
							if i < reboundsCount then
								task.wait(config.Rebounding.Delay)
							end
						end
					end
				end
				
				-- Despawning
				if not model:GetAttribute("Despawning") then
					if config.Rebounding.Max ~= 1 then
						reboundCon = false
						model:SetAttribute("Despawning", true)
						if config.Entity.SmoothSound then
							unloadSound(entityTable, model)
						end
						task.spawn(entityTable.RunCallback, entityTable, "OnDespawning") -- OnDespawning
						EntityMoveTo(model, model:GetPivot() + Vector3.new(0, 300, 0), config.Movement.Speed)
						entityTable:Despawn()
					elseif config.Rebounding.Max <= 1 then
						reboundCon = false
						if config.Entity.SmoothSound then
							unloadSound(entityTable, model)
						end
						task.spawn(entityTable.RunCallback, entityTable, "OnDespawning") -- OnDespawning
						EntityMoveTo(model, model:GetPivot() - Vector3.new(0, 300, 0), config.Movement.Speed)
						entityTable:Despawn()
					end
				end
			end)
		end
	end)
end

-- Main
localPlayer.CharacterAdded:Connect(OnCharacterAdded)

for name, value in defaultPlayerAttributes do
	localPlayer:SetAttribute(name, value)
end
lastRespawn = tick() - localPlayer:GetAttribute("SpawnProtection")

if not vynixu_SpawnerLoaded then
	getgenv().vynixu_SpawnerLoaded = true

	local function getAmbient(room)
		return room:GetAttribute("AmbientOriginal") or room:GetAttribute("Ambient") or Color3.fromRGB(67, 51, 56)
	end
	for _, c in workspace.CurrentRooms:GetChildren() do
		ambientStorage[c] = getAmbient(c)
	end
	workspace.CurrentRooms.ChildAdded:Connect(function(c)
		ambientStorage[c] = getAmbient(c)
	end)
	
	workspace.DescendantRemoving:Connect(function(d)
		if d.Name == "PathfindNodes" then
			d:Clone().Parent = d.Parent
		end
	end)
end

-- Return spawner
getgenv().VynixuEntitySpawnerV2 = spawner
return spawner
