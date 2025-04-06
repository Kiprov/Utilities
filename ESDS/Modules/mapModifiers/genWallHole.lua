--!strict

--[[ SERVICES ]]--

local twserv = game:GetService("TweenService")
local geometry = game:GetService("GeometryService")

--[[ IMPORTS ]]--
local util = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/utility/main.lua"))()
local ignore = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/ignoreHandler.lua"))()
local maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/ESDS/Modules/vendor/Maid.lua"))()

--[[ VARIABLES ]]--

local rand = Random.new(DateTime.now().UnixTimestampMillis)
local holeWallIdentifier = "HoleInWallObject"..util.genRandomGUID()

--[[ FUNCTIONS ]]--

local function bindToProperty(prt:Instance,property:string,otherPrt:Instance,forceTo:any?)
	local function upd()
		pcall(function()
			(prt :: any)[property] = (otherPrt :: any)[property]
			if forceTo then
				(otherPrt :: any)[property] = forceTo
			end
		end)
	end
	upd()
	pcall(function()
		otherPrt:GetPropertyChangedSignal(property):Connect(upd)
	end)
end
local function weldTo(part:BasePart,otherPart:BasePart)
	local weld = Instance.new("Weld")
	weld.Part0 = otherPart
	weld.Part1 = part
	weld:AddTag("DoNotInteractWeld")
	weld.C0 = otherPart.CFrame:ToObjectSpace(part.CFrame)
	weld.Parent = part
end
local function createNonInteractableObject()
	local prt = Instance.new("Part")
	prt.CanCollide = false
	prt.CanQuery = false
	prt.CanTouch = false
	prt.Locked = true
	return prt
end

local function childAdded(ch:Instance,cloned:Instance?)
	if not ch:IsA("Decal") and not ch:IsA("Texture") then return end
	local ch:Decal = ch
	local cl:Decal = Instance.fromExisting(ch)
	cl.Parent = cloned;
	

	ch.Transparency = 1

	local didChange = false
	ch.Changed:Connect(function(what)
		if didChange then didChange = false return end
		if what == "Parent" then return end
		pcall(function()
			(cl :: any)[what] = (ch :: any)[what]
		end)
		if what == "Transparency" then
			didChange = true
			(ch :: any).Transparency = 1
		end
	end)

	local maidObj = maid.new()
	maidObj:GiveTask(function()
		cl:Destroy()
	end)
	maidObj:GiveTask(ch.AncestryChanged:Connect(function(c)
		if c == ch then
			maidObj:Destroy()
		end
	end))
	maidObj:GiveTask(ch.Destroying:Once(function()
		maidObj:Destroy()
	end))
end
local function bindChildren(cloned:Instance,base:Instance)
	for _,c in ipairs(base:GetChildren()) do
		childAdded(c,cloned)
	end
	return base.ChildAdded:Connect(function(c)
		childAdded(c,cloned)
	end)
end

local currentPartOperations = {}
local function createHoleModel(intersect:BasePart,baseOffsetCF:CFrame,range:Vector3,size:Vector3,debrisTag:string)
	local holeModel = Instance.new("Model")

	local negativeParts = {}
	local minX,maxX = math.huge,-math.huge

	local scale = math.max(math.min(size.X,size.Y)-3,5)*rand:NextNumber(.3,.8)
	local baseSize = Vector3.new(rand:NextNumber(scale/1.5,scale),rand:NextNumber(scale/1.5,scale))
	baseSize = Vector3.new(math.max(baseSize.Y-5,baseSize.X),math.max(baseSize.X-5,baseSize.Y))

	local zRot = math.rad(rand:NextNumber(-25,25))
	local zRotAng = CFrame.Angles(0,0,zRot)

	local corners = {}
	local exSize = util.getExtentsSize(zRotAng,baseSize,CFrame.new())
	local holePos = baseOffsetCF*CFrame.new(
		rand:NextNumber(-range.X+exSize.X/2,range.X-exSize.X/2),
		rand:NextNumber(-range.Y+exSize.Y/2,range.Y-exSize.Y/2),
		0
	)*CFrame.Angles(0,math.pi,0)

	local sizeMultX,sizeMultY = math.max(1,baseSize.X/5),math.max(1,baseSize.Y/5)
	local sizeMultBase = (sizeMultX+sizeMultY)/2
	for i = 1,10 do
		local dist = i/10
		local isWedge = rand:NextInteger(1,2) == 1
		local prt = Instance.new("Part")
		prt.Size = Vector3.new(
			rand:NextNumber(0.2+(1-dist)/2,1.3)*math.max(scale/10,1.5),
			rand:NextNumber(0.6+(1-dist)*1.5,2)*sizeMultBase,
			rand:NextNumber(.6+(1-dist)*1.5,2)*sizeMultBase
		)
		minX,maxX = math.min(minX,prt.Size.X),math.max(maxX,prt.Size.X)
		local offset = CFrame.new(rand:NextNumber(-2*dist-prt.Size.Z,2*dist+prt.Size.Z),rand:NextNumber(-2*dist-prt.Size.Y,2*dist+prt.Size.Y),prt.Size.X/2)
		local offsetRot = CFrame.Angles(0,0,rand:NextNumber(-7000,7000))*CFrame.Angles(0,math.pi/2,0)
		local exSize = util.getExtentsSize(offset*offsetRot,prt.Size,CFrame.new())

		prt.Shape = isWedge and Enum.PartType.Wedge or Enum.PartType.Block
		prt.Anchored = true
		prt.Transparency = .75

		local bsx = baseSize.X/2
		local bsy = baseSize.Y/2
		if offset.X+exSize.X/2 > bsx then
			offset *= CFrame.new(bsx-(offset.X+exSize.X/2),0,0)
		end
		if offset.X-exSize.X/2 < -bsx then
			offset *= CFrame.new(-bsx-(offset.X-exSize.X/2),0,0)
		end
		if offset.Y+exSize.Y/2 > bsy then
			offset *= CFrame.new(0,bsy-(offset.Y+exSize.Y/2),0)
		end
		if offset.Y-exSize.Y/2 < -bsy then
			offset *= CFrame.new(0,-bsy-(offset.Y-exSize.Y/2),0)
		end
		prt.CFrame = holePos*zRotAng*offset*offsetRot
		--prt.Parent = holeModel
		table.insert(negativeParts,prt)
	end

	local baseZSet = rand:NextNumber(minX,math.max(maxX-.5,minX))
	local baseBaseCF = CFrame.new(0,0,baseZSet)*zRotAng
	local baseCF = holePos*baseBaseCF

	local basePrt = createNonInteractableObject()
	basePrt.CFrame = baseCF
	basePrt.Size = baseSize
	basePrt.Material = Enum.Material.DiamondPlate
	basePrt.Color = Color3.fromRGB(rand:NextInteger(90,120),rand:NextInteger(90,120),rand:NextInteger(90,120))
	basePrt.Parent = holeModel

	local rustOverlay = Instance.fromExisting(basePrt)
	rustOverlay.Color = Color3.fromRGB(rand:NextInteger(90,120),rand:NextInteger(90,120),rand:NextInteger(90,120))
	rustOverlay.Material = Enum.Material.CorrodedMetal
	rustOverlay.Transparency = rand:NextNumber(0.5,0.95) -- always rusty
	rustOverlay.Parent = basePrt
	weldTo(rustOverlay,basePrt)

	for i = 1,7 do
		local r = rand:NextInteger(0,3)
		local osetX = (r%2 == 0 and baseSize.Y or baseSize.X)/2
		local osetZ = (r%2 == 0 and baseSize.X or baseSize.Y)/2
		local startPos = holePos*CFrame.Angles(0,0,r*math.pi/2)*zRotAng*CFrame.new(rand:NextNumber(-osetZ,osetZ),-osetX,baseZSet)
		local uv = rand:NextUnitVector()
		local lastWireEndCF = startPos

		local endI = rand:NextInteger(1,4)
		for i = 1,endI do
			local wirePart = createNonInteractableObject()

			wirePart.Shape = Enum.PartType.Cylinder
			wirePart.Color = Color3.new(math.abs(uv.X),math.abs(uv.Y),math.abs(uv.Z))
			wirePart.Material = Enum.Material.Fabric
			wirePart.Size = Vector3.new(rand:NextNumber(0.3,2),0.2,0.2)*sizeMultBase
			local wireCF = lastWireEndCF*CFrame.new(0,wirePart.Size.X/2,0)
			wirePart.CFrame = wireCF*CFrame.Angles(0,0,math.pi/2)
			wirePart.Parent = holeModel

			local endCF = wireCF*CFrame.new(0,wirePart.Size.X/2,0)*CFrame.Angles(0,0,math.rad(rand:NextNumber(-45,45)))
			local offset = baseCF:ToObjectSpace(endCF)

			local bad = false
			if offset.X > baseSize.X/2 or offset.X < -baseSize.X/2 or offset.Y > baseSize.Y/2 or offset.Y < -baseSize.Y/2 then
				local clampedPos = Vector3.new(
					math.clamp(offset.X,-baseSize.X/2,baseSize.X/2),
					math.clamp(offset.Y,-baseSize.Y/2,baseSize.Y/2)
				)
				local mag = (offset.Position-clampedPos).Magnitude
				wirePart.CFrame *= CFrame.new(-mag/2,0,0)
				wirePart.Size -= Vector3.new((offset.Position-clampedPos).Magnitude)
				bad = true
			end
			weldTo(wirePart,basePrt)

			if i == endI or bad then break end

			local wireBall = Instance.fromExisting(wirePart)
			wireBall.Shape = Enum.PartType.Ball
			wireBall.Size = Vector3.new(.2,.2,.2)*sizeMultBase
			wireBall.CFrame = wireCF*CFrame.new(0,wirePart.Size.X/2,0)
			wireBall.Parent = holeModel
			weldTo(wireBall,wirePart)
			lastWireEndCF = endCF
		end
	end

	local debrisFolder = Instance.new("Folder")
	local baseTransparency = 
		intersect:FindFirstChild(holeWallIdentifier) and (intersect::any)[holeWallIdentifier].Transparency or intersect.Transparency

	local sizeMultActualBase = (baseSize.X/5+baseSize.Y/5)/2
	for i = 1,math.min(sizeMultActualBase*10,30) do
		local prt = Instance.fromExisting(intersect)
		prt.Name = debrisTag
		prt.Transparency = baseTransparency
		prt.Size = Vector3.one*math.max(sizeMultBase/3,1)
		prt.Anchored = false
		prt.CanCollide = true
		prt.CanQuery = false
		prt.CanTouch = true
		prt.CFrame = holePos*zRotAng*CFrame.new(
			rand:NextNumber(-baseSize.X/5,baseSize.X/5),
			rand:NextNumber(-baseSize.Y/5,baseSize.Y/5),
			-2
		)*CFrame.Angles(
			rand:NextNumber(-math.pi*2,math.pi*2),
			rand:NextNumber(-math.pi*2,math.pi*2),
			rand:NextNumber(-math.pi*2,math.pi*2)
		)
		prt.Parent = debrisFolder
		task.defer(function()
			prt:ApplyImpulse((holePos*CFrame.Angles(math.rad(rand:NextNumber(-75,75)),math.rad(rand:NextNumber(-75,75)),0)).LookVector*prt.Mass*100)
			prt:SetNetworkOwner(nil)
		end)
		local tw = twserv:Create(prt,TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,2),{Transparency = 1})
		tw:Play()
		tw.Completed:Once(function()
			prt:Destroy()
			tw:Destroy()
			tw = nil
		end)
	end
	debrisFolder.Parent = workspace
	task.delay(5,function()
		debrisFolder:Destroy()
	end)

	local emitters = {} do -- create particle emitters
		local base = Instance.new("ParticleEmitter")
		base.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		base.Lifetime = NumberRange.new(1.7,2.3)
		base.SpreadAngle = Vector2.new(90, 90)
		base.LightEmission = 1
		base.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.0429234, 5.0625, 1.5441179),
			NumberSequenceKeypoint.new(1, 0)
		})
		base.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.1916667, Color3.fromRGB(255, 241, 1)),
			ColorSequenceKeypoint.new(0.5616667, Color3.fromRGB(255, 152, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
		base.Drag = 10
		base.Speed = NumberRange.new(50, 50)
		base.Brightness = 3
		base.Enabled = false
		base.Acceleration = Vector3.new(0, 0.25, 0)
		base.Texture = "rbxasset://textures/particles/explosion01_core_main.dds"
		base.EmissionDirection = Enum.NormalId.Front
		base.RotSpeed = NumberRange.new(-30, 30)
		base.Rotation = NumberRange.new(-180, 180)
		base.Parent = basePrt
		table.insert(emitters,base)

		local debris = Instance.new("ParticleEmitter")
		debris.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		debris.LightInfluence = 1
		debris.Lifetime = NumberRange.new(0.5, 1)
		debris.SpreadAngle = Vector2.new(70, 70)
		debris.LightEmission = 0.5
		debris.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 181, 187)),
			ColorSequenceKeypoint.new(0.1466667, Color3.fromRGB(255, 174, 2)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
		debris.Drag = 1
		debris.Speed = NumberRange.new(50, 90)
		debris.Size = NumberSequence.new(3.3749998, 0)
		debris.Enabled = false
		debris.Acceleration = Vector3.new(0, -50, 0)
		debris.EmissionDirection = Enum.NormalId.Front
		debris.RotSpeed = NumberRange.new(-20, 20)
		debris.Rotation = NumberRange.new(-360, 360)
		debris.Parent = basePrt
		table.insert(emitters,debris)

		local shock = Instance.new("ParticleEmitter")
		shock.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		shock.Lifetime = NumberRange.new(0.25, 0.5)
		shock.Transparency = NumberSequence.new(0, 1)
		shock.LightEmission = 1
		shock.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 161, 154)),
			ColorSequenceKeypoint.new(0.1916667, Color3.fromRGB(255, 243, 0)),
			ColorSequenceKeypoint.new(0.395, Color3.fromRGB(198, 144, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
		shock.Speed = NumberRange.new(0, 0)
		shock.Size = NumberSequence.new(0, 50)
		shock.Enabled = false
		shock.ZOffset = 1
		shock.Texture = "rbxasset://textures/particles/explosion01_shockwave_main.dds"
		shock.EmissionDirection = Enum.NormalId.Front
		shock.Parent = basePrt
		table.insert(emitters,shock)

		local smoke = Instance.new("ParticleEmitter")
		smoke.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
		smoke.LightInfluence = 1
		smoke.SpreadAngle = Vector2.new(90, 90)
		smoke.Transparency = NumberSequence.new(0, 1)
		smoke.LightEmission = 1
		smoke.Color = ColorSequence.new(Color3.fromRGB(164, 166, 166), Color3.fromRGB(0, 0, 0))
		smoke.Size = NumberSequence.new(7, 0)
		smoke.Enabled = false
		smoke.Acceleration = Vector3.new(0, 5, 0)
		smoke.Texture = "rbxasset://textures/particles/explosion01_smoke_main.dds"
		smoke.EmissionDirection = Enum.NormalId.Front
		smoke.RotSpeed = NumberRange.new(-200, 200)
		smoke.Rotation = NumberRange.new(-360, 360)
		smoke.Parent = basePrt
		table.insert(emitters,smoke)

		local debris2 = Instance.fromExisting(debris)
		debris2.Orientation = Enum.ParticleOrientation.VelocityParallel
		debris2.Parent = basePrt
		table.insert(emitters,debris2)

		local baseFire = Instance.fromExisting(base)
		baseFire.Enabled = true
		baseFire.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.0278, 2.69, 2.69),
			NumberSequenceKeypoint.new(1, 0)
		})
		baseFire.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.1916667, Color3.fromRGB(255, 241, 1)),
			ColorSequenceKeypoint.new(0.5616667, Color3.fromRGB(255, 152, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
		})
		baseFire.Speed = NumberRange.new(10, 10)
		baseFire.Rate = scale*15
		baseFire.Parent = basePrt
		table.insert(emitters,baseFire)

		local fireSmoke = Instance.fromExisting(smoke)
		fireSmoke.Enabled = true
		fireSmoke.Lifetime = NumberRange.new(2, 5)
		fireSmoke.Size = NumberSequence.new(2.375, 0)
		fireSmoke.Parent = basePrt
		table.insert(emitters,fireSmoke)
	end

	weldTo(basePrt,intersect)
	holeModel.Parent = intersect
	for i,v in ipairs(emitters) do
		if not v.Enabled then
			v:Emit(20)
			task.delay(v.Lifetime.Max+3,v.Destroy,v)
		end
	end

	intersect:AddTag("UnionedObjectIntersect")
	task.spawn(function()
		if currentPartOperations[intersect] then
			repeat task.wait() until not currentPartOperations[intersect]
		end
		currentPartOperations[intersect] = true
		local int = intersect:FindFirstChild(holeWallIdentifier) or intersect
		local union:PartOperation = geometry:SubtractAsync(int,negativeParts,{
			CollisionFidelity = Enum.CollisionFidelity.Default,
			RenderFidelity = Enum.RenderFidelity.Precise,
			SplitApart = false,
		})[1]
		for i,v in ipairs(negativeParts) do
			v:Destroy()
		end
		if int ~= intersect then -- this is already a union
			(int::UnionOperation):SubstituteGeometry(union)
			currentPartOperations[intersect] = nil
			return
		end

		union.Name = holeWallIdentifier
		union.UsePartColor = true
		union.CanCollide = false
		union.CanTouch = false
		union.CanQuery = false
		union.Anchored = false
		union.Massless = true
		union.Locked = true
		union.CustomPhysicalProperties = PhysicalProperties.new(0.0001,0,0,0,0)
		local weld = Instance.new("Weld")
		weld:AddTag("DoNotInteractWeld")
		weld.Part0 = intersect
		weld.Part1 = union
		weld.Parent = union
		bindToProperty(union,"Color",intersect)
		bindToProperty(union,"Material",intersect)
		bindToProperty(union,"Reflectance",intersect)
		bindToProperty(union,"Transparency",intersect,1)
		bindToProperty(union,"CastShadow",intersect)

		bindChildren(union,intersect)
		union.Parent = intersect
		currentPartOperations[intersect] = nil
	end)
	return holeModel,basePrt
end

--[[ RETURN ]]--
return createHoleModel
