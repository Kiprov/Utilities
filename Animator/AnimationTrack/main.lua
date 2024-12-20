-- ceat_ceat

local TweenService = game:GetService("TweenService")

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Animator/Signal/main.lua"))()
local getLerpAlpha = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Animator/AnimationTrack/easing.lua"))()
local AnimationTrack = {}
AnimationTrack.__index = AnimationTrack

function AnimationTrack:AdjustSpeed(speed)
	self.Speed = speed
end

function AnimationTrack:AdjustWeight(weight, fadeTime)
	self.Weight = weight
end

function AnimationTrack:GetMarkerReachedSignal(name)
	local event = self._markerReachedSignals[name]
	if not event then
		event = Signal.new("MarkerReached")
		self._markerReachedSignals[name] = event
	end
	return event
end
function AnimationTrack:GetTimeOfKeyframe(keyframeName)
	return self._keyframeTimes[keyframeName] or error("ХЗ")
end

local DEFAULT_POSE = {
	Time = 0,
	CFrame = CFrame.identity,
	EasingDirection = Enum.PoseEasingDirection.In.Value,
	EasingStyle = Enum.PoseEasingStyle.Linear.Value,
	Weight = 0
}

-- localize stuff for better reach
local clock = os.clock
local min = math.min
local ipairs = ipairs
local tclear = table.clear
local cframeIdentity = CFrame.identity

local animationPlayed: RBXScriptConnection? = nil;

function AnimationTrack:Play(fadeTime, weight, speed)
	
	local animator: Animator? = self._parent._humanoid:FindFirstChildOfClass("Animator")
	if animator then
		if animationPlayed then
			animationPlayed:Disconnect()
			animationPlayed = nil
		end
		animationPlayed = animator.AnimationPlayed:Connect(function(animationTrack: AnimationTrack) 
			animationTrack:Stop()
		end)
		for index, animationTrack in animator:GetPlayingAnimationTracks() :: {AnimationTrack} do 
			animationTrack:Stop()
		end
	end
	
	fadeTime = fadeTime or 0.1
	speed = speed or 1
	self.Speed = speed
	
	local keyframes = self._keyframes
	local keyframeTimes = self._keyframeTimes
	local markerTimes = self._markerTimes
	local markerReachedSignals = self._markerReachedSignals
	local transforms = table.clone(self._parent._transforms)
	local jointNames = self._jointNames
	local passedKeyframes = {}
	local passedMarkers = {}

	local didLoopEvent = self.DidLoop
	local keyframeReachedEvent = self.KeyframeReached
	
	self._transforms = transforms

	local startTime = clock()
	local last = clock()
	local length = self.Length
	local timePosition = 0
	local lerpAlpha = 0
	
	local poseIndexes = {}
	local nextPoseIndexes = {}
	local lastPoses = {}
	local nextPoses = {}
	local jointNames = self._jointNames
	
	local function reset()
		for _, jointName in ipairs(jointNames) do
			lastPoses[jointName] = keyframes[jointName][1]
			nextPoses[jointName] = keyframes[jointName][2]
			poseIndexes[jointName] = 1
			nextPoseIndexes[jointName] = 2
		end
		tclear(passedKeyframes)
		tclear(passedMarkers)
	end
	
	self._startTime = startTime
	reset()
	local function step()
		debug.profilebegin("animationProcess")
		
		local now = clock()
		local weight = min((now - startTime)/fadeTime, 1)
		if length == 0 then
			for _, jointName in ipairs(jointNames) do
				local pose = keyframes[jointName][1]
				transforms[jointName] = pose and pose.CFrame or cframeIdentity
			end
			return transforms, weight
		end
		
		local delta = now - last -- stepped has throttling
		last = now
		timePosition += delta*self.Speed
		lerpAlpha = min(lerpAlpha + delta, 1)
		
		if timePosition > length then
			if self.Looped then
				timePosition %= length
				tclear(passedKeyframes)
				tclear(passedMarkers)
				reset()
				didLoopEvent:Fire()
			else
				self.TimePosition = 0
				self:Stop(0.5)
				return
			end
		end
		self.TimePosition = timePosition

		for name, time in keyframeTimes do
			if passedKeyframes[name] then
				continue
			end
			if timePosition >= time then
				passedKeyframes[name] = true
				keyframeReachedEvent:Fire(name)
			end
		end
		for name, time in markerTimes do
			if passedMarkers[name] then
				continue
			end
			if timePosition >= time then
				passedMarkers[name] = true
				local event = markerReachedSignals[name]
				if event then
					event:Fire()
				end
			end
		end
		
		--[[
		
		the idea
		
		if there is a joint that has keyframes that start after 0 and end before the length
		the lastpose should be the last pose and the nextpos should be the first pose
		and the time between those poses should wrap around
		so something like (length - lastpose.time + nextpose.time)
		
		if the current pose index is 1 but timeposition is before the first pose and the animation
		loops, then it is clear that it should loop around from the beginning to the end too
		and it should do something similar to the above
		
		that way the animator can pretend that first pose is the last pose but its out of range
		so that it will still lerp to it
		
		]]
		
		for _, jointName in ipairs(jointNames) do
			local poses = keyframes[jointName]
			if #poses == 0 then
				transforms[jointName] = cframeIdentity
				continue
			end
			
			local lastPose = lastPoses[jointName]
			local nextPose = nextPoses[jointName]
			local poseIdx = poseIndexes[jointName]
			local nextPoseIdx = nextPoseIndexes[jointName]
			local numPoses = #poses
			
			if nextPose and timePosition > nextPose.time then
				repeat
					poseIdx = nextPoseIdx
					nextPoseIdx += 1
				until not poses[nextPoseIdx] or poses[nextPoseIdx].time >= timePosition
				lastPose = poses[poseIdx]
				nextPose = poses[nextPoseIdx]
				lastPoses[jointName] = lastPose
				nextPoses[jointName] = nextPose
				poseIndexes[jointName] = poseIdx
				nextPoseIndexes[jointName] = nextPoseIdx
			end
			if not nextPose or lastPose == nextPose then
				transforms[jointName] = lastPose.cframe
			else
				local dt = (timePosition - lastPose.time)/(nextPose.time - lastPose.time)
				transforms[jointName] = lastPose.cframe:Lerp(nextPose.cframe, getLerpAlpha(dt, nextPose.easingStyle, nextPose.easingDirection))
			end
		end
		debug.profileend()
		return transforms, weight
	end
	self.IsPlaying = true
	self._step = step
end

function AnimationTrack:_fadeOut(fadeTime)
	local initCFrames = table.clone(self._transforms)
	local startTime = clock()
	local function step()
		local elapsed = clock() - startTime
		local newTransforms = {}
		local a = min(elapsed/fadeTime, 1)
		if a == 1 then
			self.Ended:Fire()
			self._step = nil
			return
		end
		for jointName, initCF in initCFrames do
			newTransforms[jointName] = initCF:Lerp(cframeIdentity, a)
		end
		self._transforms = newTransforms
		return {}, 1
	end
	self._step = step
end

function AnimationTrack:Stop(fadeTime)
	if not self.IsPlaying then
		return
	end
	fadeTime = fadeTime or 0.5
	self.IsPlaying = false
	self.Stopped:Fire()
	self._step = nil
	self._startTime = nil
	if fadeTime > 0 then
		self:_fadeOut(fadeTime)
	else
		self.Ended:Fire()
	end
	if animationPlayed then
		animationPlayed:Disconnect()
		animationPlayed = nil
	end
end

function AnimationTrack.new(parent, keyframeSequence)
	local self = setmetatable({}, AnimationTrack)

	self.IsPlaying = false
	self.Length = 0
	self.Looped = keyframeSequence.Loop
	self.Speed = 1
	self.TimePosition = 0
	self.Priority = keyframeSequence.Priority
	
	self.Name = keyframeSequence.Name

	self.DidLoop = Signal.new("DidLoop")
	self.Ended = Signal.new("Ended")
	self.KeyframeReached = Signal.new("KeyframeReached")
	self.Stopped = Signal.new("Stopped")
	
	self._parent = parent
	self._keyframeSequence = keyframeSequence
	self._destroyed = false
	self._keyframes = {}
	self._keyframeTimes = {}
	self._markerTimes = {}
	self._jointNames = {} -- for use with ipairs to speed up iteration
	self._transforms = {} -- processed transforms via _step
	self._step = nil -- function that the Play() method creates so that much is localized
	-- and the main animator does not hav to do as much indexing work

	self._markerReachedSignals = {}

	for _, keyframe in ipairs(keyframeSequence:GetChildren()) do
		self.Length = math.max(self.Length, keyframe.time)
		if keyframe.Name ~= "Keyframe" then
			self._keyframeTimes[keyframe.Name] = keyframe.time
		end
		for _, marker in keyframe:GetMarkers() do
			self._markerTimes[marker.Name] = keyframe.time
		end
		local rootPose = keyframe:FindFirstChild("HumanoidRootPart")
		if not rootPose then
			continue
		end
		for _, pose in rootPose:GetDescendants() do
			if not pose:IsA("Pose") or pose.Weight == 0 then
				continue
			end
			local keyframes = self._keyframes[pose.Name]
			if not keyframes then
				keyframes = {}
				self._keyframes[pose.Name] = keyframes
				self._transforms[pose.Name] = CFrame.identity
				table.insert(self._jointNames, pose.Name)
			end
			table.insert(keyframes, {
				time = keyframe.Time,
				cframe = pose.CFrame,
				easingDirection = pose.EasingDirection.Value,
				easingStyle = pose.EasingStyle.Value,
				weight = pose.Weight
			})
		end
	end
	
	-- not confident in the above so im gonna sort it lol
	for _, jointKeyframes in self._keyframes do
		table.sort(jointKeyframes, function(a, b)
			return a.time < b.time
		end)
		if self.Looped and #jointKeyframes > 1 then
			-- pad the start with the last keyframe and the end with the first key frame to loop it
			local first = table.clone(jointKeyframes[1])
			local last = table.clone(jointKeyframes[#jointKeyframes])
			first.time = self.Length + first.time
			last.time = last.time - self.Length
			table.insert(jointKeyframes, first)
			table.insert(jointKeyframes, 1, last)
		end
	end
	
	--print(self)
	return self
end

return AnimationTrack
