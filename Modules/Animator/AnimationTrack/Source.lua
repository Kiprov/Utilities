--!optimize 2
--!native
-- ceat_ceat

--[[
	AnimationTrack - the main thing
]]

local TweenService = game:GetService("TweenService")

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/Animator/Signal.lua"))()
local getLerpAlpha = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/Animator/AnimationTrack/easing.lua"))()
local assertType = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Modules/Animator/assertType.lua"))().assertType

local AnimationTrack = {}
AnimationTrack.__index = AnimationTrack

function AnimationTrack:AdjustSpeed(speed)
	assertType("AdjustSpeed", speed, {"number"}, 2)
	self.Speed = speed
end

function AnimationTrack:AdjustWeight(weight, fadeTime)
	assertType("AdjustWeight", weight, {"number"}, 2)
	assertType("AdjustWeight", fadeTime, {"number", "nil"}, 3)
	self.Weight = weight
	if self._setWeight then
		self._setWeight(weight, fadeTime)
	end
end

function AnimationTrack:GetMarkerReachedSignal(name)
	assertType("GetMarkerReachedSignal", name, {"string"}, 2)
	local event = self._markerReachedSignals[name]
	if not event then
		event = Signal.new("MarkerReached")
		self._markerReachedSignals[name] = event
	end
	return event
end

function AnimationTrack:GetTimeOfKeyframe(keyframeName)
	assertType("GetTimeOfKeyframe", keyframeName, {"string"}, 2)
	return self._keyframeTimes[keyframeName] or error("Could not find a keyframe by that name!")
end

-- localize stuff for better reach
local clock = os.clock
local min = math.min
local tclear = table.clear
local cframeIdentity = CFrame.identity

function AnimationTrack:Play(fadeTime, weight, speed)
	assertType("Play", fadeTime, {"number", "nil"}, 2)
	assertType("Play", weight, {"number", "nil"}, 3)
	assertType("Play", speed, {"number", "nil"}, 4)

	fadeTime = fadeTime or 0.1
	weight = weight or self.Weight
	speed = speed or 1
	self.Speed = speed
	self.Weight = weight

	local keyframes = self._keyframes
	local keyframeTimes = self._keyframeTimes
	local keyframeNames = self._keyframeNamesOrdered -- sorted array
	local markerTimes = self._markerTimes
	local markerNames = self._markerNamesOrdered -- sorted array
	local markerReachedSignals = self._markerReachedSignals
	local transforms = table.clone(self._parent._transforms)
	local jointNames = self._jointNames

	local hasNamedKeyframes = #keyframeNames > 0
	local hasNamedMarkers = #markerNames > 0
	local nextPassKeyframeIdx = 1
	local nextPassMarkerIdx = 1

	local didLoopEvent = self.DidLoop
	local keyframeReachedEvent = self.KeyframeReached

	self._transforms = transforms -- get joints at current state to ease in

	local startTime = clock()
	local length = self.Length
	local timePosition = 0

	local poseIndexes = {}
	local nextPoseIndexes = {}
	local lastPoses = {}
	local nextPoses = {}
	local jointNames = self._jointNames

	-- for fading between weights
	local weightInitial = 0
	local weightFadeStart = startTime

	local function reset()
		for _, jointName in jointNames do
			lastPoses[jointName] = keyframes[jointName][1]
			nextPoses[jointName] = keyframes[jointName][2]
			poseIndexes[jointName] = 1
			nextPoseIndexes[jointName] = 2
		end
	end

	local function getCurrentTotalWeight()
		return weightInitial + (weight - weightInitial)*min((clock() - weightFadeStart)/fadeTime, 1)
	end

	self._startTime = startTime
	reset()
	local function step(delta)
		debug.profilebegin("animationProcess")

		local now = clock()
		local netWeight = getCurrentTotalWeight()
		if length == 0 then
			for _, jointName in jointNames do
				local pose = keyframes[jointName][1]
				transforms[jointName] = pose and pose.CFrame or cframeIdentity
			end
			return transforms, netWeight
		end

		local inc = delta*self.Speed
		timePosition += inc

		local trueTimePosition = self.TimePosition + inc

		if trueTimePosition ~= timePosition then -- timeposition has been changed
			timePosition = self.TimePosition
			-- reset indexes to allow the loops below to go back up to the proper index
			reset()
			-- place incrementing indexes at appropriate spots
			for i, time in keyframeTimes do
				if time > timePosition then
					nextPassKeyframeIdx = i
					break
				end
			end
			for i, time in markerTimes do
				if time > timePosition then
					nextPassMarkerIdx = i
					break
				end
			end
			timePosition = trueTimePosition
		else
			self.TimePosition = timePosition
		end

		if timePosition > length then
			if self.Looped then
				timePosition %= length
				nextPassKeyframeIdx = 1
				nextPassMarkerIdx = 1
				reset()
				didLoopEvent:Fire()
			else
				self.TimePosition = 0
				self:Stop(0.5)
				return
			end
		end
		self.TimePosition = timePosition

		-- incrementing indexes instead of linear search so that it doesnt have
		-- to linear search on potentially massive arrays every frame

		if hasNamedKeyframes then
			local nextKeyframeTime = keyframeTimes[nextPassKeyframeIdx]
			if nextKeyframeTime then
				if timePosition >= nextKeyframeTime then
					repeat
						keyframeReachedEvent:Fire(keyframeNames[nextPassKeyframeIdx])
						nextPassKeyframeIdx += 1
					until not keyframeTimes[nextPassKeyframeIdx] or keyframeTimes[nextPassKeyframeIdx] > timePosition
				end
			end
		end

		if hasNamedMarkers then
			local nextMarkerTime = markerTimes[nextPassMarkerIdx]
			if nextMarkerTime then
				if timePosition >= nextMarkerTime then
					repeat
						local event = markerReachedSignals[markerNames[nextPassMarkerIdx]]
						if event then
							event:Fire()
						end
						nextPassMarkerIdx += 1
					until not markerTimes[nextPassMarkerIdx] or markerTimes[nextPassMarkerIdx] > timePosition
				end
			end
		end

		for _, jointName in jointNames do
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

			-- same incrementing index logic as the keyframereached and marker logic
			-- above, just with a lot more values involved

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
		return transforms, netWeight
	end

	local function setWeight(newWeight, newFadeTime)
		weightInitial = getCurrentTotalWeight()
		weight = newWeight
		weightFadeStart = clock()
		fadeTime = newFadeTime or 0.1
		self.Weight = newWeight
	end

	self.IsPlaying = true
	self._step = step
	self._setWeight = setWeight
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
			if self._step == step then
				self._step = nil
				self._setWeight = nil
			end
			return
		end
		for jointName, initCF in initCFrames do
			newTransforms[jointName] = initCF:Lerp(cframeIdentity, a)
		end
		self._transforms = newTransforms
		return {}, self.Weight*(1 - a)
	end
	self._step = step
end

function AnimationTrack:Stop(fadeTime)
	assertType("Stop", fadeTime, {"number", "nil"}, 2)

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
end

function AnimationTrack:Destroy()
	assert(not self._destroyed, "cannot destroy already destroyed AnimationTrack")
	self._destroyed = true
	self:Stop()
	self.DidLoop:Destroy()
	self.Stopped:Destroy()
	self.Ended:Destroy()
	self.KeyframeReached:Destroy()
	self.Stopped:Destroy()
	for _, signal in self._markerReachedSignals do
		signal:Destroy()
	end
	table.remove(self._parent._animations, table.find(self._parent._animations, self))
end

function AnimationTrack.new(parent, keyframeSequence)
	local self = setmetatable({}, AnimationTrack)

	self.IsPlaying = false
	self.Length = 0
	self.Looped = keyframeSequence.Loop
	self.Speed = 1
	self.TimePosition = 0
	self.Weight = 1
	self.Priority = keyframeSequence.Priority

	self.Name = keyframeSequence.Name

	self.DidLoop = Signal.new("DidLoop")
	self.Ended = Signal.new("Ended")
	self.KeyframeReached = Signal.new("KeyframeReached")
	self.Stopped = Signal.new("Stopped")

	self._parent = parent
	self._destroyed = false
	self._keyframes = {}
	self._keyframeTimes = {}
	self._keyframeNamesOrdered = {}
	self._markerTimes = {}
	self._markerNamesOrdered = {}
	self._jointNames = {}
	self._transforms = {} -- processed transforms via _step
	self._step = nil -- function that the Play() method creates so that much is localized, minizming index calls that would otherwise be needed in an object private methods approach
	self._setWeight = nil -- function that the Play() method creats that AdjustWeight() interfaces to be able to manipulate data only accessible to _step

	self._markerReachedSignals = {}

	-- reference lists for final sorting
	local keyframeTimes = {}
	local markerTimes = {}

	for _, keyframe in keyframeSequence:GetChildren() do
		self.Length = math.max(self.Length, keyframe.time)
		if keyframe.Name ~= "Keyframe" then
			keyframeTimes[keyframe.Name] = keyframe.time
			table.insert(self._keyframeTimes, keyframe.time)
			table.insert(self._keyframeNamesOrdered, keyframe.Name)
		end
		for _, marker in keyframe:GetMarkers() do
			markerTimes[marker.Name] = keyframe.time
			table.insert(self._markerTimes, keyframe.time)
			table.insert(self._markerNamesOrdered, marker.Name)
		end
		local rootPose = keyframe:GetChildren()[1]
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

	-- not confident that the above will have it sort it so im gonna sort it lol

	table.sort(self._keyframeTimes, function(a, b) return a < b end)
	table.sort(self._markerTimes, function(a, b) return a < b end)
	table.sort(self._keyframeNamesOrdered, function(a, b)
		return keyframeTimes[a] < keyframeTimes[b]
	end)
	table.sort(self._markerNamesOrdered, function(a, b)
		return markerTimes[a] < markerTimes[b]
	end)

	for _, jointKeyframes in self._keyframes do
		table.sort(jointKeyframes, function(a, b)
			return a.time < b.time
		end)
		if self.Looped and #jointKeyframes > 1 then
			-- pad the start with the last keyframe and the end with the first key frame to seemlessly loop it
			local first = table.clone(jointKeyframes[1])
			local last = table.clone(jointKeyframes[#jointKeyframes])
			first.time = self.Length + first.time
			last.time = last.time - self.Length
			table.insert(jointKeyframes, first)
			table.insert(jointKeyframes, 1, last)
		end
	end

	return self
end

return AnimationTrack
