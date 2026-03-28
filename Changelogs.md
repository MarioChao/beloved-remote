# Changelogs

## [v0.0.2] Doc-strings + Additional method | 2026/03/27

Added doc-strings to each public methods (those not prefixed with `_`).

New method `getIsPlayerConnected()`:
- Checks if a `Player` has started listening to a remote action.
- Can only be called from the Server.

## [v0.0.1] Fixed wally description | 2026/03/23

Fixed description not showing up on Wally.

## [v0.0.0] Beloved remote | 2026/03/22

Created the `BelovedRemote` module:
- 1x remote event.
- 1x unreliable remote event.
- 1x remote function.
- Connect & fire multiple different events.

Added MIT License to `BelovedRemote` and this repository.
