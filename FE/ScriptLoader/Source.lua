getgenv().MultiReanimate = {
	ScriptName = "None",
	Framework = "None"
}
local scripts = {
["Cleetus"] = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/Cleetus/Source.lua"))()
end,
["SuTart"] = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/SuTart/Source.lua"))()
end,
["VoidBoss"] = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/VoidBoss/Source.lua"))()
end,
["KrystalDance"] = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/KrystalDance/Source.lua"))()
end,
["BillieEilish"] = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/BillieEilish/Source.lua"))()
end,
}
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local PlaceId,JobId = game.PlaceId,game.JobId
local TeleportCheck = false
Players.LocalPlayer.OnTeleport:Connect(function(State)
	if (not TeleportCheck) and queue_on_teleport then
		TeleportCheck = true
		queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/FE/ScriptLoader/Source.lua"))()]])
	end
end)    
local names = {}
local reanimnames = {"Hatless","Krypton","Empyrean","MW","Limb","Gelatek"}
for i,v in next, scripts do
names[#names + 1] = i
end
local alertSound = "rbxassetid://4590662766"
local ranscript = false
local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)
Library.ShowCustomCursor = true -- Toggles the Linoria cursor globaly (Default value = true)
Library.NotifySide = "Right" -- Changes the side of the notifications globaly (Left, Right) (Default value = Left)

local Window = Library:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Set Resizable to true if you want to have in-game resizable Window
	-- Set ShowCustomCursor to false if you don't want to use the Linoria cursor
	-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
	-- Position and Size are also valid options here
	-- but you do not need to define them unless you are changing them :)

	Title = 'KIP SCRIPT LOADER',
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	NotifySide = "Right",
	TabPadding = 8,
	MenuFadeTime = 0.2
})
local function Notify(title,msg)
local data = {
Title = title or "",
Description = msg or "Lorem Ipsum",
Time = 5,
SoundId = alertSound
}
Library:Notify(data)
end
function rj()
	Notify("SCRIPT LOADER","Rejoining...")
    if #Players:GetPlayers() <= 1 then
		Players.LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(PlaceId, Players.LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
	end
end
-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
	-- Creates a new tab titled Main
	Main = Window:AddTab('Main'),
	['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local Main = Tabs.Main:AddLeftGroupbox('Scripts')
local Sub = Tabs.Main:AddRightGroupbox('Reanimates')

Main:AddDropdown('Script', {
	Values = names,
	Default = "None", -- number index of the value / string
	Multi = false, -- true / false, allows multiple choices to be selected

	Text = 'Scripts',
	Tooltip = 'A dropdown that allows u to select which script to execute(select reanimate first).', -- Information shown when you hover over the dropdown
	DisabledTooltip = 'I am disabled!', -- Information shown when you hover over the dropdown while it's disabled

	Searchable = true, -- true / false, makes the dropdown searchable (great for a long list of values)

	Callback = function(Value)
		print('[cb] Dropdown got changed. New value:', Value)
		MultiReanimate.ScriptName = Value
	end,

	Disabled = false, -- Will disable the dropdown (true / false)
	Visible = true, -- Will make the dropdown invisible (true / false)
})

local ExecuteScript = Main:AddButton({
	Text = 'Execute',
	Func = function()
		print('You clicked a button!')
		if table.find(names,Options.Script.Value) then
		if MultiReanimate.Framework == "None" then
		Notify("SCRIPT LOADER","Missing reanimate.")
		return
		end
		if ranscript then
		rj()
		return
		end
		ranscript = true
		spawn(function()
		scripts[Options.Script.Value]()
		end)
		end
	end,
	DoubleClick = false,

	Tooltip = 'Executes the selected script from the dropdown above.',
	DisabledTooltip = 'I am disabled!', -- Information shown when you hover over the button while it's disabled

	Disabled = false, -- Will disable the button (true / false)
	Visible = true -- Will make the button invisible (true / false)
})
Sub:AddDropdown('Reanimate', {
	Values = reanimnames,
	Default = "None", -- number index of the value / string
	Multi = false, -- true / false, allows multiple choices to be selected

	Text = 'Reanimates',
	Tooltip = 'A dropdown that allows u to select which reanimate to execute on a script.', -- Information shown when you hover over the dropdown
	DisabledTooltip = 'I am disabled!', -- Information shown when you hover over the dropdown while it's disabled

	Searchable = true, -- true / false, makes the dropdown searchable (great for a long list of values)

	Callback = function(Value)
		print('[cb] Dropdown got changed. New value:', Value)
		MultiReanimate.Framework = Value
	end,

	Disabled = false, -- Will disable the dropdown (true / false)
	Visible = true, -- Will make the dropdown invisible (true / false)
})

Library:SetWatermarkVisibility(false)

Library:OnUnload(function()
	WatermarkConnection:Disconnect()

	print('Unloaded!')
	Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu", Callback = function(value) Library.KeybindFrame.Visible = value end})
MenuGroup:AddToggle("ShowCustomCursor", {Text = "Custom Cursor", Default = true, Callback = function(Value) Library.ShowCustomCursor = Value end})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('KIPSCRIPTLOADER')
SaveManager:SetFolder('KIPSCRIPTLOADER')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
