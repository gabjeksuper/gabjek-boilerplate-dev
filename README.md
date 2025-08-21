# Gabjek Boilerplate Dev - FiveM

Secure, minimal boilerplate to teach devs how to build FiveM scripts. Everything that changes state lives server-side, behind ACE permissions, rate limits, and validation. Use this as a base for dev menus, admin tools, mini-games, shops, etc., and spin out new resources following the same pattern.

## Why
- Server-first: single server router, no sensitive logic on client. Lots of current scripts have tons of exploit-filled scripts that let cheaters use various triggers. 
- Compatible: standalone; auto-bridges ESX, QBCore, Qbox.
- Optional stack: ox_lib, ox_target, ox_inventory, oxmysql.
- Production-ready: rate limiting, input sanitization, optional DB migrations, CI (Luacheck + Busted), tagged releases.

## Quick start
1. Put the folder in `resources/[local]/gabjek-boilerplate-dev`.
2. `server.cfg`:
   ```cfg
   ensure gabjek-boilerplate-dev
   add_ace group.admin gbd.announce allow
   add_ace group.admin gbd.diag allow
   add_ace group.admin gbd.admin allow
   ```
3. Optional: start `ox_lib`, `ox_target`, `ox_inventory`, `oxmysql`, `es_extended`, `qb-core`, or `qbx-core`.
4. DB demo: set `Config.UseOxMySQL = true` in `shared/config.lua`.

## How it works
- F6 or `/panel` opens NUI.
- Client requests a session token (`gbd:requestToken`).
- Client sends actions only via `gbd:route(action, payload, token)`.
- Server checks token, rate limit, ACE (if required), validates input, executes, responds.

## Included examples
- Dev menu (ox_lib): self notify, progress, player list, teleports, give item, give money, admin announce.
- Announce command: `/announce <msg>` (ACE `gbd.announce`).
- Player list: server builds the list; client only displays.
- Teleports: server uses named presets from config; no raw coords from client.
- Give item/money: validated, capped; ox_inventory or framework bridge.

## Add your own scripts
Add a route in `server/main.lua` inside `ROUTES` with optional `perm` and a `fn(src, data)` that validates input and uses framework/ox APIs. Trigger it from client with `TriggerServerEvent('gbd:route', 'your_action', data, TOKEN)`. Keep state-changing logic strictly server-side.

## Exports
Server:
```lua
exports['gabjek-boilerplate-dev']:Notify(source, 'Message')
exports['gabjek-boilerplate-dev']:HasFramework() -- 'ESX' | 'QBCORE' | 'QBOX' | 'STANDALONE'
```
Client:
```lua
exports['gabjek-boilerplate-dev']:OpenPanel()
```

## Config
See `shared/config.lua`. Toggle features (ox_*) and adjust limits/teleports/locales.
