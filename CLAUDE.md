# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VastBlue is a Roblox Luau game project synced to Roblox Studio via **Rojo**. The game features character customization (body proportions, clothing, hair, race, colors), private realms, and a gacha-style race spin system.

## Toolchain

Managed via [Aftman](https://github.com/LPGhatguy/aftman) (`aftman.toml`):
- **Rojo 7.7.0** — File sync to Roblox Studio (`rojo serve` / `rojo build`)
- **Selene 0.27.1** — Luau linter (`selene`)
- **StyLua 2.0.1** — Luau formatter (`stylua .`)

Selene config: `std = "roblox"`, unused variables allowed, empty-if warned.
StyLua config: tabs, 120 column width, Unix line endings, double quotes preferred.

## Rojo Mapping (`default.project.json`)

| Filesystem path | Roblox location |
|---|---|
| `src/Server/` | `ServerScriptService` |
| `src/Client/` | `StarterPlayer.StarterPlayerScripts` |
| `src/StarterCharacterScripts/` | `StarterPlayer.StarterCharacterScripts` |
| `src/Shared/` | `ReplicatedStorage.Shared` |
| `src/ReplicatedStorage/` | `ReplicatedStorage.Assets` |
| `src/ServerStorage/` | `ServerStorage` |

## Architecture

### Bootstrap & Lifecycle

Server and client each have a single entry point that requires all services/controllers into an array, then calls `Init()` on all, then `Start()` on all (two-phase initialization):

- **Server**: `src/Server/Bootstrap.server.luau` — boots 7 services in order
- **Client**: `src/Client/Bootstrap.client.luau` — boots controllers (CameraController, WindController)

Services/controllers are plain tables with `Init()` and `Start()` methods (not a framework — no DI container).

### Server Services (`src/Server/Services/`)

- **DataService** — ProfileService wrapper. Loads/saves per-player profiles. Other services access data via `DataService.GetData(player)` / `DataService.WaitForData(player)` / `DataService.SetData(player, "dot.path", value)`. DataStore key: `PlayerDataVer1`.
- **CustomizationService** — Orchestrates character appearance. Delegates to handler modules in its subfolder (ClothingHandler, AppearanceHandler, RaceHandler, ColorHandler, ProportionHandler).
- **RealmService** — Private server generation, teleportation, and ban lists via DataStoreService + MessagingService.
- **PurchaseService** — MarketplaceService.ProcessReceipt handler with a registration pattern for product handlers.
- **AuthService** — Group rank / whitelist checks (currently always grants access).
- **NotificationService** — Thin wrapper that fires the `Notify` remote to clients.
- **FilterService** — TextService.FilterStringAsync wrapper via `FilterRequest` RemoteFunction.

### Shared Layer (`src/Shared/`)

Accessible by both server and client at `ReplicatedStorage.Shared`:

- `Modules/Net.luau` — Centralized networking. Creates all RemoteEvents/RemoteFunctions in `ReplicatedStorage.GameRemotes` on the server. Includes per-player rate limiting (10 calls/sec per remote). Server uses `Net.listen()` / `Net.fireClient()` / `Net.fireAllClients()`. Client uses `Net.fire()` / `Net.invoke()` / `Net.connect()`.
- `Modules/DataTemplate.luau` — Canonical player data shape. ProfileService reconciles against this.
- `Modules/DataMigrations.luau` — Versioned migration scaffold. Runs sequentially from `data._version` to `CURRENT_VERSION`.
- `Modules/Types.luau` — Shared Luau type definitions for all data structures.
- `Modules/Enums.luau` — String enum tables (NotificationType, CustomizeAction, ClothingCategory, RealmAction).
- `Modules/Constants.luau` — Game-wide constants (data store version, group ID, authorized users, auto-save period).
- `Config/` — Configuration tables: RaceConfig (probabilities), CustomizationConfig (body scale tables, wrap orders, defaults), AnimationIds, PhysicsConfig, PlaceIds.
- `Util/` — Cleanup (maid-like), WeldAndScale (mesh welding + SmartBone setup), HMSConvert.

### Client Controllers (`src/Client/Controllers/`)

CameraController, WindController run as StarterPlayerScripts (persist across respawns). StarterCharacterScripts contains Animate and TripFix (reset each spawn).

### Networking Pattern

All remote names are declared in the `REMOTES` table in `Net.luau`. To add a new remote:
1. Add the name to `REMOTES.Events` or `REMOTES.Functions` in `Net.luau`
2. Call `Net.listen("RemoteName", handler)` on the server
3. Call `Net.fire("RemoteName", ...)` or `Net.connect("RemoteName", handler)` on the client

### Data Flow

ProfileService stores the `DataTemplate` table directly (no Value-tree wrapper). Data flows:
1. Player joins → DataService loads profile, reconciles with DataTemplate, runs migrations, sets `DataReady` BoolValue on the Player instance
2. Other services call `DataService.WaitForData(player)` to get the profile data table
3. Services mutate the data table directly (or via `DataService.SetData` for path-based access)
4. Auto-save every 120 seconds; profile released on player leave

## Vendored Dependencies (DO NOT MODIFY)

Located in `src/ServerStorage/Modules/` and `src/ReplicatedStorage/`:
ProfileService, SmartBone, BoatTween, spr, LootPlan, Octree, WindShake

## Code Conventions

- All files use `--!strict` type checking mode
- No `_G` globals — all state is module-scoped
- Use `task.spawn`/`task.wait`/`task.delay` (not deprecated `spawn`/`wait`/`delay`)
- Use `:Connect` not `:connect`
- Wrap all external Roblox service calls (DataStoreService, MarketplaceService, TeleportService, etc.) in `pcall`
- Per-player debounces (keyed by UserId), never global booleans
- No `print()` statements in non-vendored code (use `warn()` only for errors)
