--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- destroys the sound after it ends
local function decaySound(snd:Sound)
	assert(snd and snd:IsA("Sound"),"not a sound")

	snd.Ended:Once(function()
		task.wait(3)
		snd:Destroy()
	end)
	return snd
end

-- creates a sound that automatically plays
local function createSound(sndid:string,props:({[string]: any})?)
	local props:{[string]: any} = props or {}
	local snd:Sound = Instance.new("Sound")
	snd.SoundId = sndid
	for propName,prop in pairs(props) do
		if propName == "Parent" then continue end
		(snd::any)[propName] = prop ~= "BAD" and prop or nil
	end
	snd:Play()
	snd.Parent = props.Parent or ReplicatedStorage
	return snd
end

-- creates a sound that automatically plays and is automatically destroyed
local function createTemporarySound(sndid:string,props:({[string]: any})?)
	decaySound(createSound(sndid,props))
end

-- creates a sound from a sound, automatically plays
local function createSoundFromSound(inst:Sound,props:({[string]: any})?):Sound
	assert(inst and inst:IsA("Sound"),"not a sound")
	
	local props:{[string]: any} = props or {}
	local snd:Sound = inst and inst:Clone()
	for propName,prop in pairs(props) do
		if propName == "Parent" then continue end
		(snd::any)[propName] = prop ~= "BAD" and prop or nil
	end
	snd:Play()
	snd.Parent = props.Parent or ReplicatedStorage
	return snd
end

-- creates a temporary sound, read createTemporarySound for more info
local function createTemporarySoundFromSound(inst:Sound,props:({[string]: any})?)
	decaySound(createSoundFromSound(inst,props))
end

-- creates a sound at a location
local function createSoundAtPos(location:Vector3,sndid:string,props:({[string]: any})?)
	local att = Instance.new("Attachment")
	att.Position = location
	att.Parent = workspace.Terrain
	
	local propsList:{[string]: any} = props or {}
	propsList.Parent = att	
	
	local snd = createSound(sndid,propsList)
	snd.Destroying:Once(function()
		task.wait() -- roblox doesnt like immediately destroying right after a child is destroyed
		att:Destroy()
	end)
	return snd
end

local function createTemporarySoundAtPos(location:Vector3,sndid:string,props:({[string]: any})?)
	decaySound(createSoundAtPos(location,sndid,props))
end

return {
	createSound = createSound,
	createTemporarySound = createTemporarySound,
	
	createSoundFromSound = createSoundFromSound,
	createTemporarySoundFromSound = createTemporarySoundFromSound,
	
	createSoundAtPos = createSoundAtPos,
	createTemporarySoundAtPos = createTemporarySoundAtPos,
	
	decaySound = decaySound
}
