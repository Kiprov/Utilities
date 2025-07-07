--!optimize 2
--!native
-- ceat_ceat

--[[
	Signal - custom minimal signal implementation
]]

local Signal = {}
local Connection = {}
Signal.__index = Signal
Connection.__index = Connection

Signal.__tostring = function(self)
	if self._name then
		return `Signal {self._name}`
	end
	return "Signal"
end

Connection.__tostring = function()
	return "RBXScriptConnection"
end

function Connection:Disconnect()
	self.Connected = false
	table.remove(self._parent._connections, table.find(self._parent._connections, self))
end

Connection.disconnect = Connection.Disconnect

function Connection.new(parent, callback)
	local self = setmetatable({}, Connection)
	self.Connected = true
	self._callback = callback
	self._parent = parent
	self._once = false
	table.insert(parent._connections, self)
	return self
end

function Signal:Connect(callback)
	assert(type(callback) == "function", "callback must be a function")
	return Connection.new(self, callback)
end

function Signal:Once(callback)
	assert(type(callback) == "function", "callback must be a function")
	local connection = Connection.new(self, callback)
	connection._once = true
	return callback
end

function Signal:Wait()
	local thread = coroutine.running()
	table.insert(self._waitingThreads, thread)
	return coroutine.yield()
end

function Signal:Fire(...)
	for _, connection in self._connections do
		task.spawn(connection._callback, ...)
		if connection._once then
			connection:Disconnect()
		end
	end
	for _, thread in self._waitingThreads do
		task.spawn(thread, ...)
	end
	table.clear(self._waitingThreads)
end

function Signal:Destroy()
	for _, connection in self._connections do
		connection:Disconnect()
	end
	for _, thread in self._waitingThreads do
		coroutine.resume(thread)
	end
	table.clear(self._waitingThreads)
end

Signal.connect = Signal.Connect
Signal.wait = Signal.Wait
Signal.fire = Signal.Fire
Signal.destroy = Signal.Destroy

function Signal.new(name)
	local self = setmetatable({}, Signal)
	self._waitingThreads = {}
	self._connections = {}
	self._name = name
	return self
end

return Signal