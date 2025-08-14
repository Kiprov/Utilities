# Entity Spawner
This module allows u to create ur custom entities.
Module forked from RegularVynixu, port for "ENDLESS DOORS" made by Kip.
If you wish to skip the tutorial, use this example:[Example](https://github.com/Kiprov/Utilities/blob/main/ENDLESS%20DOORS/Entity%20Spawner/Example.lua)
# Setup of the Entity Spawner.
Firstly you want to copy the raw link of the "Source.lua" file.
Then you want to make a new blank txt or lua file.
Now paste this code into your file.
```lua
---====== Load spawner ======---
local spawner = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/main/ENDLESS%20DOORS/Entity%20Spawner/Source.lua"))()
```
After you `pasted` the code the next thing you want to do is get a template of your entity. Here is a template provided below!
```lua
---====== Create entity ======---

local entity = spawner.Create({
	Entity = {
		Name = "Template Entity",
		Asset = "", --This can be a raw roblox rbxm file on github or a "rbxassetid://" model from the marketplace.
		HeightOffset = 0,
        SmoothTransition = true,
	},
	Lights = {
		Flicker = {
			Enabled = true,
			Duration = 1
		},
		Shatter = true,
		Repair = false
	},
	CameraShake = {
		Enabled = true,
		Range = 100,
		Values = {1.5, 20, 0.1, 1} -- Magnitude, Roughness, FadeIn, FadeOut
	},
	Movement = {
		Speed = 100,
		Delay = 2,
		Reversed = false
	},
	Rebounding = {
		Enabled = true,
		Type = "Ambush", -- "Blitz"
		Min = 1,
		Max = 1,
		Delay = 2
	},
	Damage = {
		Enabled = true,
		Range = 40,
		Amount = 125
	},
	Crucifixion = {
		Enabled = true,
		Range = 40,
		Resist = false,
		Break = true
	},
	Death = {
		Type = "Guiding", -- "Curious"
		Hints = {"Death", "Hints", "Go", "Here"},
		Cause = ""
	}
})

---====== Debug entity ======---

entity:SetCallback("OnSpawned", function()
    print("Entity has spawned")
end)

entity:SetCallback("OnStartMoving", function()
    print("Entity has started moving")
end)

entity:SetCallback("OnReachNode", function(node)
	print("Entity has reached node:", node)
end)

entity:SetCallback("OnEnterRoom", function(room, firstTime)
    if firstTime == true then
        print("Entity has entered room: ".. room.Name.. " for the first time")
    else
        print("Entity has entered room: ".. room.Name.. " again")
    end
end)

entity:SetCallback("OnLookAt", function(lineOfSight)
	if lineOfSight == true then
		print("Player is looking at entity")
	else
		print("Player view is obstructed by something")
	end
end)

entity:SetCallback("OnRebounding", function(startOfRebound)
    if startOfRebound == true then
        print("Entity has started rebounding")
	else
        print("Entity has finished rebounding")
	end
end)

entity:SetCallback("OnDespawning", function()
    print("Entity is despawning")
end)

entity:SetCallback("OnDespawned", function()
    print("Entity has despawned")
end)

entity:SetCallback("OnDamagePlayer", function(newHealth)
	if newHealth == 0 then
		print("Entity has killed the player")
	else
		print("Entity has damaged the player")
	end
end)

--[[

DEVELOPER NOTE:
By overwriting 'CrucifixionOverwrite' the default crucifixion callback will be replaced with your custom callback.

entity:SetCallback("CrucifixionOverwrite", function()
    print("Custom crucifixion callback")
end)

]]--

---====== Run entity ======---

entity:Run()
-- entity:Pause()
-- entity:IsPaused()
-- entity:Despawn()
```
Now you may have noticed there are some functions associated with the entity u created("entity:Run()","entity:Pause()","entity:Resume()","entity:IsPaused" and "entity:Despawn")
Let's go over what each function does!
# Entity Functions
# entity:Run()
This function spawns the entity into the game.
# entity:Pause(bool)
This function pauses or resumes the entity by providing a boolean value.
# entity:IsPaused()
This function returns the state of the entity(paused or resumed).
# entity:Despawn()
This function completely removes the entity from the game.
# End of the setup
Now that you know what each function does it's time for you to create awesome custom entities out there and use them for anything(ex:a mode, an entity spawner hub, etc.).
