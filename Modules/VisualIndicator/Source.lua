--[[
Visual Indicator Module

A module that allows you to show visual cues to entities.
Obtained from Pressure.
Ported by Kip.
]]--
if getgenv().VisualIndicator then
return getgenv().VisualIndicator
end
local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local CoreGui: CoreGui = cloneref(game:GetService('CoreGui'))
local Players: Players = cloneref(game:GetService('Players'))
local RunService: RunService = cloneref(game:GetService('RunService'))
local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local HttpService: HttpService = cloneref(game:GetService('HttpService'))
local Debris: Debris = cloneref(game:GetService('Debris'))
local RenderStepped = RunService.RenderStepped
local LocalPlayer = Players.LocalPlayer

local ProtectGui = protectgui or (function() end)
local GetHUI = gethui or (function() return CoreGui end)
local assert = function(condition, errorMessage) 
    if (not condition) then
        error(if errorMessage then errorMessage else "assert failed", 3)
    end
end
local plr = LocalPlayer
local ui = Instance.new("ScreenGui")
ui.Name = "Visuals"
ui.IgnoreGuiInset = true
ui.ResetOnSpawn = false
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.ClipToDeviceSafeArea = false
ui.DisplayOrder = 999
pcall(ProtectGui, ui)
ui.Parent = GetHUI()
local preloadService = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/PreloadService/Source.lua"))()
preloadService:SetDirectory("VisualIndicator")
function preload(assetType,assetURL,assetName,format)
return preloadService:Preload(assetType,assetURL,assetName,nil,format)
end
local vIF,static = preload("Model","https://github.com/Kiprov/Utilities/blob/main/Pressure/Assets/VisualIndicatorFrame.rbxlx?raw=true","VisualIndicatorFrame",".rbxlx"),preload("Model","https://github.com/Kiprov/Utilities/blob/main/Pressure/Assets/Static.rbxlx?raw=true","Static",".rbxlx")
vIF.Parent,static.Parent = ui,ui
local module = {
	["UI"] = vIF
}
module.CircleUI = module.UI.CircleIndicator
module.CircleTween = nil
function module.ActivateCircle(part, range, length, color)
		local circleUI = module.CircleUI:Clone()
		circleUI.Parent = module.CircleUI.Parent
		circleUI.Visible = true
		circleUI.ImageTransparency = 1
		circleUI.ImageColor3 = color or Color3.fromRGB(0, 213, 255)
		local circleTween = TweenService:Create(circleUI, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {
			["ImageTransparency"] = 0.75
		})
		circleTween:Play()
		local circleName = "CircleIndicator" .. HttpService:GenerateGUID()
		RunService:BindToRenderStep(circleName, 205, function()
			local char = plr.Character or plr.CharacterAdded:Wait()
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			local root = hum.RootPart
			if not hum or not root then return end
			if hum.Health <= 0 then
				return
			elseif root.Parent then
				if range >= (root.Position - part.Position).Magnitude then
					local look_x = root.CFrame.LookVector.X
					local look_z = root.CFrame.LookVector.Z
					local unit = Vector3.new(look_x, 0, look_z).Unit
					local partPos = part.Position
					local x = root.Position.X
					local z = root.Position.Z
					local vector = Vector3.new(x, 0, z)
					local part_x = partPos.X
					local part_z = partPos.Z
					local partUnit = (Vector3.new(part_x, 0, part_z) - vector).unit
					local dot = unit:Dot(partUnit)
					local multiple = unit.X * partUnit.Z - unit.Z * partUnit.X
					local tan = math.atan2(multiple, dot)
					circleUI.Rotation = math.deg(tan)
				end
			else
				return
			end
		end)
		if length then
			task.delay(length, function()
				RunService:UnbindFromRenderStep(circleName)
				if circleTween then
					circleTween:Pause()
					circleTween = nil
					circleUI:Destroy()
				end
			end)
		end
end
module.Time = 1
module.Enableds = {}
module.EntityIndicatorUIS = {}
function module.EntityEnable(name,color)
	module.Enableds[name] = true
	local ei = module.EntityIndicatorUIS[name]
	ei.ImageColor3 = color
	ei.Visible = true
end
function module.EntityDisable(name)
	module.Enableds[name] = false
	local ei = module.EntityIndicatorUIS[name]
	game.TweenService:Create(ei, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		["Size"] = UDim2.new(1.25, 0, 1.25, 0),
		["ImageTransparency"] = 1
	}):Play()
end
function mapValue(p45, p46, p47, p48, p49)
	return p46 <= p45 and 1 or (p45 <= p47 and 0.75 or p48 + (p45 - p47) * p49 / (p46 - p47))
end
function module.TrackEntity(part, distance, color, length)
		local actualTime = length or 0.75
		local calcTime = 1 - actualTime
		local actualColor = color or Color3.fromRGB(51, 34, 61)
		local renderName = "EntityIndicator"..part.Parent.Name
		local entityUI = module.UI.GeneralIndicator:Clone()
		entityUI.Name = part.Parent.Name
		entityUI.Parent = module.UI
		entityUI.ZIndex = #module.EntityIndicatorUIS
		module.EntityIndicatorUIS[part.Parent.Name] = entityUI
		module.Enableds[part.Parent.Name] = false
		RunService:UnbindFromRenderStep(renderName)
		RunService:BindToRenderStep(renderName, 205, function()
		local char = plr.Character or plr.CharacterAdded:Wait()
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			local root = hum.RootPart
			if not hum or not root then return end
			if hum.Health > 0 then
				if part and part.Parent then
					local magni = (part.Position - root.Position).Magnitude
					if distance < magni then
						if module.Enableds[part.Parent.Name] then
							module.EntityDisable(part.Parent.Name)
						end
					else
						if not module.Enableds[part.Parent.Name] then
							module.EntityEnable(part.Parent.Name,actualColor)
						end
						local mapTime = mapValue(magni, distance, 50, actualTime, calcTime)
						game.TweenService:Create(entityUI, TweenInfo.new(mapTime, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
							["Size"] = UDim2.new(calcTime + mapTime, 0, calcTime + mapTime, 0),
							["ImageTransparency"] = mapTime
						}):Play()
					end
				else
					RunService:UnbindFromRenderStep(renderName)
					if module.Enableds[part.Parent.Name] then
						module.EntityDisable(part.Parent.Name)
						Debris:AddItem(entityUI,0.4)
					end
					return
				end
			else
				if module.Enableds[part.Parent.Name] then
					module.EntityDisable(part.Parent.Name)
					Debris:AddItem(entityUI,0.4)
				end
				return
			end
		end)
end
local staticInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0)
module.StaticTween1 = TweenService:Create(module.UI.Static.s1, staticInfo, {
	["Position"] = UDim2.new(0.49, 0, 0.5, 0)
})
module.StaticTween2 = TweenService:Create(module.UI.Static.s2, staticInfo, {
	["Position"] = UDim2.new(0.51, 0, 0.5, 0)
})
function module.StaticToggle(bool)
	-- upvalues: (copy) module
	if bool then
		module.UI.Static.s1.Position = UDim2.new(0.51, 0, 0.5, 0)
		module.StaticTween1:Play()
		module.UI.Static.s2.Position = UDim2.new(0.49, 0, 0.5, 0)
		module.StaticTween2:Play()
		module.UI.Static.Visible = true
	else
		module.StaticTween1:Pause()
		module.StaticTween2:Pause()
		module.UI.Static.Visible = false
		return
	end
end
getgenv().VisualIndicator = module
return module
