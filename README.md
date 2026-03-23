# beloved-remote

Experimental manager for (unreliable) remote events and remote functions.

This module simplifies remote communications by eliminating any use of `Instance`s.

The module also mitigates the `Remote event invocation discarded` error in Server to Client communications.

> [!IMPORTANT]
> If you did forget to implement `OnClientEvent()`, a warning message will be generated after 10 seconds.
> If you forgot to implement `OnServerEvent()`, neither errors nor warnings will show.

## Usage

For it to work, the module should be placed in a shared container like `ReplicatedStorage`.

### Client → Server

Event Connection - Server script
```luau
BelovedRemote.connect_toServer(eventName, function(player: Player, ...)
    -- insert code here
end)
```

> [!NOTE]
> The method for UnreliableRemoteEvent is `.connectUnreliable_toServer()`.
> The method for RemoteFunction is `.setOnInvoke_toServer()`.

Event Firing - Client script
```luau
BelovedRemote.fire_toServer(eventName, {data})
```

> [!NOTE]
> The method for UnreliableRemoteEvent is `.fireUnreliable_toServer()`.
> The method for RemoteFunction is `.invoke_toServer()`.

### Server → Client

Event Connection - Client script
```luau
-- Connect
BelovedRemote.connect_toClient(eventName, function(...)
    -- insert code here
end)

-- Belove (establish connection)
BelovedRemote.belovePlayer_RE_toServer(eventName)
```

> [!NOTE]
> The methods for UnreliableRemoteEvent are `.connectUnreliable_toClient()` and `.belovePlayer_UE_toServer()`.
> The methods for RemoteFunction are `.setOnInvoke_toClient()` and `.belovePlayer_RF_toServer()`.

Event Firing - Server script
```luau
BelovedRemote.fire_toClient(eventName, player, {data})
```

> [!NOTE]
> The method for UnreliableRemoteEvent is `.fireUnreliable_toClient()`.
> The method for RemoteFunction is `.invoke_toClient()`.

## Credits

Inspirations:
- sleitnick's [Net](https://sleitnick.github.io/RbxUtil/api/Net) - similar interface.
