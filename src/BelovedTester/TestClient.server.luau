--!strict


---------- Imports ----------

local _Modules = script.Parent.Parent:WaitForChild("Modules")
local BelovedRemote = require(_Modules:WaitForChild("BelovedRemote"))


---------- Local functions ----------

local connectEvents
local fireEvents


----- Connect & fire -----

connectEvents = function()
    BelovedRemote.connect_toClient("Test", function(...)
        print(...)
    end)
    BelovedRemote.connectUnreliable_toClient("Test", function(...)
        print(...)
    end)
    BelovedRemote.setOnInvoke_toClient("Test", function(...)
        print(...)
        return {message = "Response", data = "OK"}
    end)
end

fireEvents = function()
    -- Fire remote event
    task.wait(3)
    local firstParam = "client to server"
    BelovedRemote.fire_toServer("Test", firstParam, {message = "Message1", data = "Data1"})
    BelovedRemote.fire_toServer("Test", firstParam, {message = "Message1", data = "Data2"})
    BelovedRemote.fire_toServer("Test", firstParam, {message = "Message2", data = "Data1"})
    BelovedRemote.fire_toServer("Test", firstParam, {message = "Message2", data = "Data2"})

    -- Fire unreliable remote event
    task.wait(1)
    firstParam = "u client to server"
    BelovedRemote.fireUnreliable_toServer("Test", firstParam, {message = "UMessage1", data = "UData1"})
    BelovedRemote.fireUnreliable_toServer("Test", firstParam, {message = "UMessage1", data = "UData2"})
    BelovedRemote.fireUnreliable_toServer("Test", firstParam, {message = "UMessage2", data = "UData1"})
    BelovedRemote.fireUnreliable_toServer("Test", firstParam, {message = "UMessage2", data = "UData2"})

    -- Fire remote function
    task.wait(1)
    firstParam = "f client to server"
    print(BelovedRemote.invoke_toServer("Test", firstParam, {message = "FMessage1", data = "FData1"}))
    print(BelovedRemote.invoke_toServer("Test", firstParam, {message = "FMessage1", data = "FData2"}))
    print(BelovedRemote.invoke_toServer("Test", firstParam, {message = "FMessage2", data = "FData1"}))
    print(BelovedRemote.invoke_toServer("Test", firstParam, {message = "FMessage2", data = "FData2"}))
end


----- Main -----

local function main()
    -- S->C Connect
    connectEvents()

    -- S->C Belove
    BelovedRemote.belovePlayer_RE_toServer("Test")
    BelovedRemote.belovePlayer_UE_toServer("Test")
    BelovedRemote.belovePlayer_RF_toServer("Test")

    -- C->S Fire
    fireEvents()
end


---------- Calling function ----------

main()
