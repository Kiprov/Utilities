--[[
	This script deals with typing and automatic choosing of the right variant.
]]

local IsDeferred: boolean do
	IsDeferred = false

	local bindable = Instance.new("BindableEvent")

	local handlerRun = false
	bindable.Event:Connect(function()
		handlerRun = true
	end)

	bindable:Fire()
	bindable:Destroy()

	if handlerRun == false then
		-- In Deferred mode, things run "later", we can take advantage of this to detect the mode active,
		-- by checking whether a :Fire call manages to change a variable right away, we are able to detect
		-- whether Immediate or Deferred mode is being used.
		
		IsDeferred = true
	end
end

-- These were copied and modified from sleitnick's fork of GoodSignal, thanks sleitnick!
export type ScriptSignal<T...> = {
	IsActive: (self: ScriptSignal<T...>) -> boolean,
	Fire: (self: ScriptSignal<T...>, T...) -> (),
	Connect: (self: ScriptSignal<T...>, callback: (T...) -> ()) -> ScriptConnection,
	Once: (self: ScriptSignal<T...>, callback: (T...) -> ()) -> ScriptConnection,
	DisconnectAll: (self: ScriptSignal<T...>) -> (),
	Destroy: (self: ScriptSignal<T...>) -> (),
	Wait: (self: ScriptSignal<T...>) -> T...,
}
export type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> (),
	Connected: boolean,
}

-- Legacy type. Do not use in newer work.
export type Class = ScriptSignal<...any>

local ChosenSignal: typeof( loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Animator/Signal/docs.lua"))() ) = IsDeferred
	and loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Animator/Signal/deferred.lua"))()
	or loadstring(game:HttpGet("https://raw.githubusercontent.com/Kiprov/Utilities/refs/heads/main/Animator/Signal/immediate.lua"))()

return ChosenSignal
