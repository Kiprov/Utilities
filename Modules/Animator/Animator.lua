--!optimize 2
--!native
-- ceat_ceat

-- all files with my name near the top are written by me and me only
-- users and editers, please leave my name and the url where they are,
-- esp if you release your own version
-- (i would advise you also put your name near the top)

--[[
	ceat's KeyframeSequence Animator - https://roblox.com/library/15329902944
	
	Custom Animator class that tries to perfectly emulate the roblox animator
	(+ some additional features). Solves issues that other animators have such
	as lack of fading when a new animation plays, animation conflicts, and lack
	of weighting by containing all animations on a particular
	Humanoid/AnimationController into one Animator object instead of many
	
	Animators are self-contained. An Animator will not respect the state of
	another, which will cause animating conflicts. Please only use create one
	Animator per each given Humanoid/AnimationController
	
	It is recommended to use this module on the client, as changes to the
	Transform property on the server are overwritten by the client's animating
	processes and large amounts of replication packets. It has been made possible
	for a server-side usage of the module to replicate animations fully to the
	client, which is outlined below
	
	Additional stuff added on top of emulating Roblox animation APIs  ------------
	
		enum AnimationMode:
			Transform - uses the Transform property to animate
			C0 - uses the C0 property to animate, causing C0 to become immutable
				(only use C0 when you absolutely must use this module on the server)
				
		property AnimationMode:
			Value of enum AnimationMode defined above
			default: AnimationMode.Transform
			
		RBXScriptSignal Stepped ({ [string]: CFrame }):
			Event that fires every Stepped that passes the new transforms for
			each Motor6D
			
	Usage example ----------------------------------------------------------------
	
		local Animator = require(module)
		
		local animator = Animator.new(model)
		animator.AnimationMode = Animator.AnimationMode.C0
		
		local track = animator:LoadAnimation(keyframeSequence)
		track:Play()
		
		animator.Stepped:Connect(function(cframes)
			for jointName, transform in cframes do
				print("transform of", jointName, "is now", transform)
			end
		end)
		
]]

local RunService = game:GetService("RunService")

local AnimationMode = {
	Transform = 0,
	C0 = 1
}

local Animator = {}
Animator.__index = Animator
Animator.AnimationMode = AnimationMode

local AnimationTrack = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/Animator/AnimationTrack/Source.lua"))()
local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/Animator/Signal.lua"))()
local assertClass = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/Animator/assertType.lua"))().assertClass

local function assertIsObject(self)
	assert(self ~= Animator, "cannot call object method on static class")
end

function Animator:LoadAnimation(keyframeSequence)
	assertIsObject(self)
	assertClass("LoadAnimation", keyframeSequence, {"AnimationTrack", "KeyframeSequence"}, 2)
	local animations = self._animations
	for _, animation in animations do
		if animation._keyframeSequence == keyframeSequence then
			return animation
		end
	end
	local animation = AnimationTrack.new(self, keyframeSequence)
	table.insert(animations, animation)
	return animation
end

function Animator:GetPlayingAnimationTracks()
	local tracks = {}
	for _, animationTrack in self._animations do
		if animationTrack.IsPlaying then
			table.insert(tracks, animationTrack)
		end
	end
	return tracks
end

function Animator:Destroy()
	assertIsObject(self)
	assert(not self._destroyed, "cannot destroy already destroyed Animator")
	self._destroyed = true
	for _, animation in self._animations do
		animation:Destroy()
	end
	for _, stopTracker in self._jointTrackers do
		stopTracker()
	end
	table.clear(self._animations)
	table.clear(self._jointTrackers)
	self._stepped:Disconnect()
	self._descendantAdded:Disconnect()
	self._descendantRemoving:Disconnect()
	self._stepped = nil
	self._descendantAdded = nil
	self._descendantRemoving = nil
end

local clock = os.clock
local cfIdentity = CFrame.identity

-- for mimicking naming behavior of poses

local function Part1Tracker(part, onSet)
	local connection = part:GetPropertyChangedSignal("Name"):Connect(function()
		onSet(part.Name)
	end)
	return function()
		connection:Disconnect()
	end
end

local function JointTracker(joint, onSet, onUnset)
	local current
	local currentTracker
	local function onPartNameChanged(name)
		onUnset(current)
		current = name
		onSet(current)
	end
	if joint.Part1 then
		current = joint.Part1.Name
		currentTracker = Part1Tracker(joint.Part1, onPartNameChanged)
	end
	local connection = joint:GetPropertyChangedSignal("Part1"):Connect(function()
		onUnset(current)
		if currentTracker then
			currentTracker()
			currentTracker = nil
		end
		if joint.Part1 then
			current = joint.Part1.Name
			onSet(current)
			currentTracker = Part1Tracker(joint.Part1, onPartNameChanged)
		end
	end)
	return function()
		connection:Disconnect()
		if currentTracker then
			currentTracker()
		end
	end
end

function Animator.new(humanoid)
	assertClass("Animator.new", humanoid, {"Humanoid", "AnimationController"}, 1)

	local self = setmetatable({}, Animator)
	
	-- localizing these fields to this scope so it doesnt have to index self so much
	-- every frame
	-- self._transforms is not localized because it is overwritten on each frame
	local animations = {}
	local joints = {}
	local jointTrackers = {}
	local steppedEvent = Signal.new("Stepped")

	self.AnimationMode = AnimationMode.Transform
	self.Stepped = steppedEvent

	self._humanoid = humanoid
	self._destroyed = false
	self._joints = joints
	self._transforms = {} -- not localized because this table changes
	self._jointTrackers = jointTrackers
	self._animations = animations

	self._descendantAdded = nil
	self._descendantRemoving = nil

	local last = clock()
	self._stepped = RunService.Stepped:Connect(function()
		debug.profilebegin("animatorProcess")
		local now = clock()
		local delta = now - last -- stepped delta is throttled
		last = now

		local currentTransforms = self._transforms

		local newTransforms = {}
		local priorities = {}
		for jointName in joints do
			priorities[jointName] = 0
		end
		for _, animation in animations do
			if not animation._step then
				continue
			end
			local priority = animation.Priority.Value
			local transforms, weight = animation._step(delta)
			if not transforms then
				continue
			end
			for jointName, cf in transforms do
				if not joints[jointName] then
					continue
				end
				local override = false
				if priority >= priorities[jointName] then
					priorities[jointName] = priority
					override = true
				end
				local other = newTransforms[jointName]
				if override then
					local startTime = animation._startTime
					if other then
						-- hope this works!
						local a = priority == other[3] and weight/(weight + other[4]) or weight
						local cfFinal = other[2]:Lerp(cf, a) 
						newTransforms[jointName] = {startTime, cfFinal, priority, weight}
					else
						newTransforms[jointName] = {startTime, cf, priority, weight}
					end
				end
			end
		end
		-- finalize
		for jointName, cfData in newTransforms do
			newTransforms[jointName] = cfData[2]
		end
		for jointName, joint in joints do
			local cf = newTransforms[jointName]
			local transform
			if cf then
				transform = cf
				newTransforms[jointName] = transform
			else
				transform = currentTransforms[jointName]:Lerp(cfIdentity, 1 - (1/10)^(delta*10))
				newTransforms[jointName] = transform
			end
			if self.AnimationMode == AnimationMode.Transform then
				joint.joint.Transform = transform
			else
				joint.joint.C0 = joint.c0 * transform
			end
		end
		self._transforms = newTransforms
		steppedEvent:Fire(newTransforms)
		debug.profileend()
	end)

	local function newDescendant(joint)
		if joint.ClassName ~= "Motor6D" then
			return
		end
		local me = {
			joint = joint,
			c0 = joint.C0
		}
		if joint.Part1 then
			joints[joint.Part1.Name] = me
			self._transforms[joint.Part1.Name] = cfIdentity
		end
		self._jointTrackers[joint] = JointTracker(joint, function(name)
			joints[name] = me
			if not self._transforms[joint.Part1.Name] then
				self._transforms[joint.Part1.Name] = cfIdentity
			end
		end, function(name)
			joints[name] = nil
		end)
	end
	
	for _, joint in humanoid.Parent:GetDescendants() do
		newDescendant(joint)
	end

	self._descendantAdded = humanoid.Parent.DescendantAdded:Connect(newDescendant)
	self._descendantRemoving = humanoid.Parent.DescendantRemoving:Connect(function(joint)
		if joint.ClassName ~= "Motor6D" then
			return
		end
		if joint.Part1 then
			steppedEvent[joint.Part1.Name] = nil
		end
		jointTrackers[joint]() -- stop tracker
		jointTrackers[joint] = nil
	end)

	return self
end

return Animator