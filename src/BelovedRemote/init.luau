--!strict

-- Beloved Remote


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Types ----------

type BelovedPrefix = "RE" | "UE" | "RF"
type BelovedAction = string
type Beloved = string


---------- Constants ----------

local Constants = {}

do
	local assets = {}
	assets.folder = script:WaitForChild("Assets")
	assets.remoteEvent = assets.folder:WaitForChild("RemoteEvent")
	assets.remoteFunction = assets.folder:WaitForChild("RemoteFunction")
	assets.unreliableRemoteEvent = assets.folder:WaitForChild("UnreliableRemoteEvent")
	Constants.assets = assets
end

Constants.environment = {
	isClient = RunService:IsClient(),
	isServer = RunService:IsServer(),
	isStudio = RunService:IsStudio(),
}

Constants.defaultWaitTimeout = 10

Constants.connectPlayerString = "__Connect_Beloved_Player__"

local function deepFreeze(t: {any}?)
    if type(t) == "table" then
        table.freeze(t)
        for _, v in t do
            deepFreeze(v :: {any}?)
        end
    end
end
deepFreeze(Constants)


---------- Globals ----------

local Globals = {}

Globals.player_beloved_isConnected = {} :: {[Player]: {[Beloved]: true?}}
Globals.beloved_receiverBindableEvent = {} :: {[Beloved]: BindableEvent?}
Globals.beloved_receiverBindableFunction = {} :: {[Beloved]: BindableFunction?}


---------- Local functions ----------

local getIsEnvironment

local getBeloved
local setPlayerIsConnected
local isPlayerConnected
local waitForPlayerToConnect

local getReceiverEvent
local getReceiverFunction
local createReceiverEvent
local createReceiverFunction

local connectRemotes


----- Environment -----

getIsEnvironment = function(environment: "Server" | "Client")
	if environment == "Server" then
		return Constants.environment.isServer
	elseif environment == "Client" then
		return Constants.environment.isClient
	end
	return false
end


----- Beloved -----

getBeloved = function(prefix: BelovedPrefix, name: BelovedAction): Beloved
	return `{prefix}/{name}`
end

setPlayerIsConnected = function(beloved: Beloved, player: Player, isConnected: boolean)
	-- Get player's isConnected dictionary
	local beloved_isConnected
	do
		local beloved_isConnected_raw = Globals.player_beloved_isConnected[player]
		if beloved_isConnected_raw then
			beloved_isConnected = beloved_isConnected_raw
		else
			beloved_isConnected = {}
			Globals.player_beloved_isConnected[player] = beloved_isConnected
		end
	end

	-- Set value
	beloved_isConnected[beloved] = if isConnected then true else nil
end

isPlayerConnected = function(beloved: Beloved, player: Player)
	local beloved_isConnected = Globals.player_beloved_isConnected[player] or {}
	local isConnected = beloved_isConnected[beloved] == true
	return isConnected
end

waitForPlayerToConnect = function(beloved: Beloved, player: Player, timeout: number?)
	-- Wait
	local startTime = time()
	local passedTime = 0
	local targetTimeout = timeout or Constants.defaultWaitTimeout
	while not isPlayerConnected(beloved, player) do
		if passedTime > targetTimeout then
			break
		end
		task.wait()
		passedTime = time() - startTime
	end
end


----- Receiver instances -----

getReceiverEvent = function(beloved: Beloved)
	return Globals.beloved_receiverBindableEvent[beloved]
end

getReceiverFunction = function(beloved: Beloved)
	return Globals.beloved_receiverBindableFunction[beloved]
end

createReceiverEvent = function(beloved: Beloved)
	local bindableEvent_raw = Globals.beloved_receiverBindableEvent[beloved]
	if not bindableEvent_raw then
		local bindableEvent = Instance.new("BindableEvent")
		Globals.beloved_receiverBindableEvent[beloved] = bindableEvent
	end
end

createReceiverFunction = function(beloved: Beloved)
	local bindableFunction_raw = Globals.beloved_receiverBindableFunction[beloved]
	if not bindableFunction_raw then
		local bindableFunction = Instance.new("BindableFunction")
		Globals.beloved_receiverBindableFunction[beloved] = bindableFunction
	end
end


----- Connect -----

connectRemotes = function()
	if getIsEnvironment("Server") then
		Constants.assets.remoteEvent.OnServerEvent:Connect(function(player: Player, beloved: Beloved, ...)
			-- Check connection
			if table.pack(...)[1] == Constants.connectPlayerString then
				setPlayerIsConnected(beloved, player, true)
				return
			end

			-- Fire event
			local event = getReceiverEvent(beloved)
			if event then
				event:Fire(player, ...)
			end
		end)
		Constants.assets.unreliableRemoteEvent.OnServerEvent:Connect(function(player: Player, beloved: Beloved, ...)
			local event = getReceiverEvent(beloved)
			if event then
				event:Fire(player, ...)
			end
		end)
		Constants.assets.remoteFunction.OnServerInvoke = function(player: Player, beloved: Beloved, ...: any): ...any
			local fn = getReceiverFunction(beloved)
			if fn then
				return fn:Invoke(player, ...)
			end
			return nil
		end
	elseif getIsEnvironment("Client") then
		Constants.assets.remoteEvent.OnClientEvent:Connect(function(beloved: Beloved, ...)
			local event = getReceiverEvent(beloved)
			if event then
				event:Fire(...)
			end
		end)
		Constants.assets.unreliableRemoteEvent.OnClientEvent:Connect(function(beloved: Beloved, ...)
			local event = getReceiverEvent(beloved)
			if event then
				event:Fire(...)
			end
		end)
		Constants.assets.remoteFunction.OnClientInvoke = function(beloved: Beloved, ...: any): ...any
			local fn = getReceiverFunction(beloved)
			if fn then
				return fn:Invoke(...)
			end
			return nil
		end
	end
end


----- Main -----

local function main()
	-- Listen to remote event
	task.defer(connectRemotes)
	
	-- Clean up player data
	Players.PlayerRemoving:Connect(function(player: Player)
		Globals.player_beloved_isConnected[player] = nil
	end)
end


---------- Calling function ----------

task.defer(main)


---------- Module ----------

local Module = {}


----- Environment -----

function Module.getEnvironmentInfo()
	return Constants.environment
end


----- Caller to server -----

-- Assume that the server is already connected.

function Module.fire_toServer(name: BelovedAction, ...)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: fire_toServer should be called from the Client!")
	local beloved = getBeloved("RE", name)
	Constants.assets.remoteEvent:FireServer(beloved, ...)
end

function Module.fireUnreliable_toServer(name: BelovedAction, ...)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: fireUnreliable_toServer should be called from the Client!")
	local beloved = getBeloved("UE", name)
	Constants.assets.unreliableRemoteEvent:FireServer(beloved, ...)
end

function Module.invoke_toServer(name: BelovedAction, ...)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: invoke_toServer should be called from the Client!")
	local beloved = getBeloved("RF", name)
	return Constants.assets.remoteFunction:InvokeServer(beloved, ...)
end


----- Caller to client -----

-- Make sure that the client is connected.

function Module.fire_toClient(name: BelovedAction, player: Player, ...)
	assert(getIsEnvironment("Server"), "[Beloved Remote]: fire_toClient should be called from the Server!")
	local beloved = getBeloved("RE", name)
	task.spawn(function(...: any)
		waitForPlayerToConnect(beloved, player)
		if isPlayerConnected(beloved, player) then
			Constants.assets.remoteEvent:FireClient(player, beloved, ...)
		else
			warn(`[Beloved Remote]: {player} isn't connected yet!`)
			warn(`	Make sure to call belovePlayer_RE_toServer({name}) from the Client!`)
		end
	end, ...)
end

function Module.fireUnreliable_toClient(name: BelovedAction, player: Player, ...)
	assert(getIsEnvironment("Server"), "[Beloved Remote]: fireUnreliable_toClient should be called from the Server!")
	local beloved = getBeloved("UE", name)
	task.spawn(function(...: any)
		waitForPlayerToConnect(beloved, player)
		if isPlayerConnected(beloved, player) then
			Constants.assets.unreliableRemoteEvent:FireClient(player, beloved, ...)
		else
			warn(`[Beloved Remote]: {player} isn't connected yet!`)
			warn(`	Make sure to call belovePlayer_UE_toServer({name}) from the Client!`)
		end
	end, ...)
end

function Module.invoke_toClient(name: BelovedAction, player: Player, ...)
	assert(getIsEnvironment("Server"), "[Beloved Remote]: invoke_toClient should be called from the Server!")
	local beloved = getBeloved("RF", name)
	waitForPlayerToConnect(beloved, player)
	if isPlayerConnected(beloved, player) then
		return Constants.assets.remoteFunction:InvokeClient(player, beloved, ...)
	else
		warn(`[Beloved Remote]: {player} isn't connected yet!`)
		warn(`	Make sure to call belovePlayer_RF_toServer({name}) from the Client!`)
		return nil
	end
end


----- To server receiver -----

-- Connect to onServerEvent and onServerInvoke.

function Module.connect_toServer(name: BelovedAction, callback: (player: Player, ...any) -> ())
	assert(getIsEnvironment("Server"), "[Beloved Remote]: connect_toServer should be called from the Server!")
	local beloved = getBeloved("RE", name)
	createReceiverEvent(beloved)
	local event = getReceiverEvent(beloved)
	if event then
		event.Event:Connect(callback)
	end
end

function Module.connectUnreliable_toServer(name: BelovedAction, callback: (player: Player, ...any) -> ())
	assert(getIsEnvironment("Server"), "[Beloved Remote]: connectUnreliable_toServer should be called from the Server!")
	local beloved = getBeloved("UE", name)
	createReceiverEvent(beloved)
	local event = getReceiverEvent(beloved)
	if event then
		event.Event:Connect(callback)
	end
end

function Module.setOnInvoke_toServer(name: BelovedAction, callback: (player: Player, ...any) -> ...any)
	assert(getIsEnvironment("Server"), "[Beloved Remote]: setOnInvoke_toServer should be called from the Server!")
	local beloved = getBeloved("RF", name)
	createReceiverFunction(beloved)
	local fn = getReceiverFunction(beloved)
	if fn then
		fn.OnInvoke = callback
	end
end


----- To client receiver -----

-- Connect to onClientEvent and onClientInvoke.

function Module.connect_toClient(name: BelovedAction, callback: (...any) -> ())
	assert(getIsEnvironment("Client"), "[Beloved Remote]: connect_toClient should be called from the Client!")
	local beloved = getBeloved("RE", name)
	createReceiverEvent(beloved)
	local event = getReceiverEvent(beloved)
	if event then
		event.Event:Connect(callback)
	end
end

function Module.connectUnreliable_toClient(name: BelovedAction, callback: (...any) -> ())
	assert(getIsEnvironment("Client"), "[Beloved Remote]: connectUnreliable_toClient should be called from the Client!")
	local beloved = getBeloved("UE", name)
	createReceiverEvent(beloved)
	local event = getReceiverEvent(beloved)
	if event then
		event.Event:Connect(callback)
	end
end

function Module.setOnInvoke_toClient(name: BelovedAction, callback: (...any) -> ...any)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: setOnInvoke_toClient should be called from the Client!")
	local beloved = getBeloved("RF", name)
	createReceiverFunction(beloved)
	local fn = getReceiverFunction(beloved)
	if fn then
		fn.OnInvoke = callback
	end
end


----- Connect player to server -----

function Module._belovePlayer_toServer(beloved: Beloved)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: _belovePlayer_toServer should be called from the Client!")
	Constants.assets.remoteEvent:FireServer(beloved, Constants.connectPlayerString)
end

function Module.belovePlayer_RE_toServer(name: BelovedAction)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: belovePlayer_RE_toServer should be called from the Client!")
	Module._belovePlayer_toServer(getBeloved("RE", name))
end

function Module.belovePlayer_UE_toServer(name: BelovedAction)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: belovePlayer_RE_toServer should be called from the Client!")
	Module._belovePlayer_toServer(getBeloved("UE", name))
end

function Module.belovePlayer_RF_toServer(name: BelovedAction)
	assert(getIsEnvironment("Client"), "[Beloved Remote]: belovePlayer_RF_toServer should be called from the Client!")
	Module._belovePlayer_toServer(getBeloved("RF", name))
end


----- Debug purpose -----

function Module._printGlobals()
	print(Globals)
end


---------- Return module ----------

table.freeze(Module)
return Module
