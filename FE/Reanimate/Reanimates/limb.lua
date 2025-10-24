--// BY MrY7zz
if not game:IsLoaded() then
	game.Loaded:Wait()
end

--// Check configdoc.md for settings documentation

--// Below are the settings
-- SETTINGS --
local settings = _G
local fpdh = workspace.FallenPartsDestroyHeight + 5

settings["Use default animations"] = true
settings["Fake character transparency level"] = 1
settings["Disable character scripts"] = true
settings["Fake character should collide"] = true
settings["Parent real character to fake character"] = true
settings["Respawn character"] = true
settings["Instant respawn"] = true
settings["Hide HumanoidRootPart"] = true
settings["PermaDeath fake character"] = true
settings["R15 Reanimate"] = false
settings["Click Fling"] = false
settings["Anti-Fling"] = true
settings["Hide RootPart Distance"] = CFrame.new(fpdh, fpdh, 0)

settings["Names to exclude from transparency"] = {}
--// Settings end

loadstring(game:HttpGet("https://raw.githubusercontent.com/somethingsimade/CurrentAngleV4/refs/heads/main/currentanglev2.5.lua"))()
