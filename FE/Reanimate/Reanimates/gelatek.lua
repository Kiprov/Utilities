local Global = (getgenv and getgenv()) or shared
Global.GelatekReanimateConfig = {
    -- [[ Rig Settings ]] --
    ["AnimationsDisabled"] = false,
    ["R15ToR6"] = true,
    ["DontBreakHairWelds"] = false,
    ["PermanentDeath"] = true,
    ["Headless"] = false,
    ["TeleportBackWhenVoided"] = true,
    
    -- [[ Reanimation Settings ]] --
    ["AlignReanimate"] = true,
    ["FullForceAlign"] = true,
    ["FasterHeartbeat"] = true,
    ["DynamicalVelocity"] = true,
    ["DisableTweaks"] = false,
    
    -- [[ Optimization ]] --
    ["OptimizeGame"] = false,

    -- [[ Miscellacious ]] --
    ["LoadLibrary"] = false,
    ["DetailedCredits"] = false,
    
    -- [[ Flinging Methods ]] --
    ["TorsoFling"] = false,
    ["BulletEnabled"] = false,
    ["BulletConfig"] = {
        ["RunAfterReanimate"] = false,
        ["LockBulletOnTorso"] = false
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gelatekussy/GelatekReanimate/main/Main.lua"))()
