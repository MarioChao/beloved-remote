--!strict


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local _Modules = script.Parent.Parent:WaitForChild("Modules")
local BelovedRemote = require(_Modules:WaitForChild("BelovedRemote"))


---------- Local functions ----------

local connectEvents
local onPlayerAdded


----- Connect & fire -----

connectEvents = function()
    BelovedRemote.connect_toServer("Test", function(player: Player, ...)
        print(player, ...)
    end)
    BelovedRemote.connectUnreliable_toServer("Test", function(player: Player, ...)
        print(player, ...)
    end)
    BelovedRemote.setOnInvoke_toServer("Test", function(player: Player, ...)
        print(player, ...)
        return {message = "Response", data = "OK"}
    end)
end

onPlayerAdded = function(player: Player)
    -- Fire remote event
    local firstParam = "server to client"
    BelovedRemote.fire_toClient("Test", player, firstParam, {message = "Message1", data = "Data1"})
    BelovedRemote.fire_toClient("Test", player, firstParam, {message = "Message1", data = "Data2"})
    BelovedRemote.fire_toClient("Test", player, firstParam, {message = "Message2", data = "Data1"})
    BelovedRemote.fire_toClient("Test", player, firstParam, {message = "Message2", data = "Data2"})

    -- Fire unreliable remote event
    task.wait(1)
    firstParam = "u server to client"
    BelovedRemote.fireUnreliable_toClient("Test", player, firstParam, {message = "UMessage1", data = "UData1"})
    BelovedRemote.fireUnreliable_toClient("Test", player, firstParam, {message = "UMessage1", data = "UData2"})
    BelovedRemote.fireUnreliable_toClient("Test", player, firstParam, {message = "UMessage2", data = "UData1"})
    BelovedRemote.fireUnreliable_toClient("Test", player, firstParam, {message = "UMessage2", data = "UData2"})

    -- Fire remote function
    task.wait(1)
    firstParam = "f server to client"
    print(BelovedRemote.invoke_toClient("Test", player, firstParam, {message = "FMessage1", data = "FData1"}))
    print(BelovedRemote.invoke_toClient("Test", player, firstParam, {message = "FMessage1", data = "FData2"}))
    print(BelovedRemote.invoke_toClient("Test", player, firstParam, {message = "FMessage2", data = "FData1"}))
    print(BelovedRemote.invoke_toClient("Test", player, firstParam, {message = "FMessage2", data = "FData2"}))

    task.wait(4)
    BelovedRemote._printGlobals()
end


----- Main -----

local function main()
    -- C->S Connect
    connectEvents()

    -- S->C Fire
    local initialPlayers = Players:GetPlayers()
    task.defer(function()
        for _, player in initialPlayers do
            task.defer(onPlayerAdded, player)
        end
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
end


---------- Calling function ----------

main()
