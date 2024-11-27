local RunService = game:GetService("RunService")

local Animators = {}

local Animator = {}
Animator.__index = Animator

local className = RunService:IsServer() and "Server" or "Client"

local AnimationTrack = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Animator/AnimationTrack/main.lua"))()


function Animator:LoadAnimation(keyframeSequence)
	local animations = self._animations
	for _, animation in (animations) do
		if animation._keyframeSequence == keyframeSequence then
			return animation
		end
	end
	local animation = AnimationTrack.new(self, keyframeSequence)
	table.insert(animations, animation)
	return animation
end

function Animator:Destroy()
	self._destroyed = true
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

function Animator.new(humanoid: Humanoid)
	
	local index = Animators[humanoid]
	if index then
		return index
	end

	local self = setmetatable({}, Animator)
	local animations = {}

	self._humanoid = humanoid
	self._destroyed = false
	self._joints = {}
	self._transforms = {}
	self._jointTrackers = {}
	self._animations = animations

	self._descendantAdded = nil
	self._descendantRemoving = nil

	self._stepped = RunService.Stepped:Connect(function(time: number, deltaTime: number)
		debug.profilebegin("animatorProcess")

		local currentTransforms = self._transforms
		local joints = self._joints

		local newTransforms = {}
		local priorities = {}
		for jointName in self._joints do
			priorities[jointName] = 0
		end
		for _, animation in (animations) do
			if not animation._step then
				continue
			end
			local priority = animation.Priority.Value
			local transforms, weight = animation._step()
			if not transforms then
				continue
			end
			for jointName, cf in transforms do
				if not self._joints[jointName] then
					continue
				end
				local override = false
				if priority > priorities[jointName] then
					priorities[jointName] = priority
					override = true
				end
				local other = newTransforms[jointName]
				local startTime = animation._startTime
				if override or not other or startTime > other[1] then
					newTransforms[jointName] = {startTime, cf, weight}
				end
			end
		end
		for jointName, cfData in newTransforms do
			local weight = cfData[3]
			if weight == 1 then
				newTransforms[jointName] = cfData[2]
			else
				newTransforms[jointName] = currentTransforms[jointName]:Lerp(cfData[2], weight)
			end
		end
		for jointName, joint in joints do
			local cf = newTransforms[jointName]
			local transform
			if cf then
				transform = cf
				newTransforms[jointName] = transform
			else
				transform = currentTransforms[jointName]:Lerp(cfIdentity, 1 - 0.1 ^ (deltaTime * 10))
				newTransforms[jointName] = transform
			end
			if className == "Server" then
				joint.joint.C0 = joint.c0 * transform
			else
				joint.joint.Transform = transform
			end
		end
		self._transforms = newTransforms
		debug.profileend()
	end)

	local function newDescendant(joint: Motor6D?)
		if not joint:IsA("Motor6D") then
			return
		end
		local me = {
			joint = joint,
			c0 = joint.C0
		}
		if joint.Part1 then
			self._joints[joint.Part1.Name] = me
			self._transforms[joint.Part1.Name] = cfIdentity
		end
		self._jointTrackers[joint] = JointTracker(joint, function(name)
			self._joints[name] = me
			if not self._transforms[joint.Part1.Name] then
				self._transforms[joint.Part1.Name] = cfIdentity
			end
		end, function(name)
			self._joints[name] = nil
		end)
	end

	self._descendantAdded = humanoid.Parent.DescendantAdded:Connect(newDescendant)
	self._descendantRemoving = humanoid.Parent.DescendantRemoving:Connect(function(joint: Motor6D?)
		if not joint:IsA("Motor6D") then
			return
		end
		if joint.Part1 then
			self._joints[joint.Part1.Name] = nil
		end
		self._jointTrackers[joint]()
		self._jointTrackers[joint] = nil
	end)

	for _, joint in humanoid.Parent:GetDescendants() do
		newDescendant(joint)
	end
	
	Animators[humanoid] = self
	
	return self
	
end

function Animator:GetPlayingAnimationTracks()
	local playingAnimationTracks = {}
	for index, animationTrack: AnimationTrack in self._animations do
		if animationTrack.IsPlaying then
			table.insert(playingAnimationTracks, animationTrack)
		end
	end
	return playingAnimationTracks
end

return Animator
