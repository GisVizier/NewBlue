# VastBlue Architecture Document

## Overview

VastBlue is a Roblox anime RPG featuring character customization, race gacha, realm (private server) management, inventory, and cinematic scenes. This document describes the refactored architecture.

## Directory Structure

```
src/
  Shared/                          -- ReplicatedStorage.Shared (both server & client)
    Modules/
      Types.luau                   -- All type definitions
      Net.luau                     -- Centralized networking (remotes, rate limiting)
      DataTemplate.luau            -- Player data shape (pure table)
      DataMigrations.luau          -- Versioned migration scaffold
      Enums.luau                   -- Game enumerations
      Constants.luau               -- Magic numbers, authorized users, config
    Config/
      AnimationIds.luau            -- All animation asset IDs
      PlaceIds.luau                -- Universe place IDs
      RaceConfig.luau              -- Race probabilities, spin config
      CustomizationConfig.luau     -- Body scale tables, clothing defaults, SmartBone
      PhysicsConfig.luau           -- Wind direction/speed/power
    Util/
      WeldAndScale.luau            -- Canonical weld+scale module (merged from 2 copies)
      Cleanup.luau                 -- Connection/instance cleanup tracker
      HMSConvert.luau              -- Seconds to HH:MM:SS

  Server/                          -- ServerScriptService
    Init.server.luau               -- Bootstrap: Init() then Start() all services
    Services/
      DataService.luau             -- ProfileService wrapper, pure-table storage
      NotificationService.luau     -- Send notifications via Net module
      AuthService.luau             -- Authorization checks (group rank, user ID)
      FilterService.luau           -- TextService filtering with pcall
      PurchaseService.luau         -- MarketplaceService.ProcessReceipt handler
      RealmService.luau            -- Private server management (generate/join/ban)
      CustomizationService/
        init.luau                  -- Orchestrator: listens to events, dispatches
        ClothingHandler.luau       -- Pants/shirt/shoes/accessory refresh & unlock
        AppearanceHandler.luau     -- Hair, facial, face decals, skin, build
        RaceHandler.luau           -- Race additions, gacha roll (per-player debounce)
        ColorHandler.luau          -- Hair/beard/clothing color tweening
        ProportionHandler.luau     -- Body width/height/depth scaling

  Client/                          -- StarterPlayerScripts
    Init.client.luau               -- Bootstrap: Init() then Start() all controllers
    Controllers/
      CameraController.luau        -- Camera orbit + player positioning (moved from server)
      SoundController.luau         -- Local sound playback via Net
      MovementController.luau      -- Character leaning (fixed 0.__5 -> 0.5)
      SceneController.luau         -- Cinematic camera + tween helpers
      WindController.luau          -- Wind effects initialization from PhysicsConfig
      WindLines.luau               -- (third-party) wind particle lines
      WindShake/                   -- (third-party) tree/object wind shaking

  StarterCharacterScripts/         -- Per-character scripts
    Animate.client.luau            -- Animation system (fixed deprecated APIs)
    TripFix.client.luau            -- Disable FallingDown/Ragdoll states

  ServerStorage/                   -- Server-only assets
    Modules/Data/ProfileService.luau    -- (vendored third-party)
    Modules/UtilityModules/LootPlan/    -- (vendored third-party)

  ReplicatedStorage/               -- Mapped as ReplicatedStorage.Assets
    CustomizeMeshes/               -- Character mesh assets
    ClothingShopData/              -- Shop pricing data
    SmartBone/                     -- (vendored third-party)
    ReplicatedModules/
      Utilities/
        BoatTween/                 -- (vendored third-party)
        spr.luau                   -- (vendored third-party)
        RainUtil.luau              -- Rain effects (fixed :connect -> :Connect)
      Scenes/                      -- Scene data (Dojo)
      StoredScenes/                -- Scene data (Bleach, Itachi, Mist) (fixed typo)
    ReplicatedAnims/               -- Animation assets
    Packs/                         -- Pack assets
    RealmData/                     -- Realm UI data (ReservedID, BannedPlayers, etc.)
```

## Service/Controller Pattern

### Server Services
Each service module exports:
- `Init()` — Register state, create resources (no connections)
- `Start()` — Connect events, begin logic

Bootstrap order in `Init.server.luau`:
1. DataService
2. NotificationService
3. AuthService
4. FilterService
5. PurchaseService
6. CustomizationService
7. RealmService

### Client Controllers
Same `Init()`/`Start()` pattern. Controllers in `StarterPlayerScripts` persist across respawns. Character-specific scripts remain in `StarterCharacterScripts`.

## Networking (Net Module)

All remotes are created and managed by `Shared/Modules/Net.luau`:

**Events:** `CustomizeEvent`, `UpdateColorEvent`, `RaceRoll`, `RealmRequest`, `Purchase`, `Notify`, `LocalSoundEvent`

**Functions:** `FilterRequest`

Server API:
- `Net.listen(remoteName, handler)` — auto rate-limited
- `Net.fireClient(remoteName, player, ...)`
- `Net.fireAllClients(remoteName, ...)`

Client API:
- `Net.fire(remoteName, ...)`
- `Net.invoke(remoteName, ...)`
- `Net.connect(remoteName, handler)`

Built-in per-remote rate limiting (10 requests/second per player).

## Data Layer

**Storage:** ProfileService stores `DataTemplate` table directly — no Value-tree conversion.

**Key:** `PlayerDataVer1` (fresh start, no migration from v7)

**Flow:**
1. `DataService._loadProfile()` → `ProfileStore:LoadProfileAsync()` → `profile:Reconcile()` → `DataMigrations.Run()`
2. `DataService.GetData(player)` → returns typed table reference
3. `DataService.SetData(player, "Data.Currency.Money", 100)` → dot-path setter
4. Auto-save every 120 seconds via `profile:Save()`
5. `PlayerRemoving` → `profile:Release()`

**Future migrations:** Increment `_version` in DataTemplate, add migration function to `DataMigrations.Migrations[version]`.

## Critical Bug Fixes

1. **Per-player debounces** — Race spin, realm generate, realm ban all use per-player tables instead of global booleans
2. **pcall on ALL external calls** — DataStore, MarketplaceService, MessagingService, TextService, TeleportService
3. **Camera moved to client** — Was running on server (did nothing useful)
4. **Input validation** — All remote handlers validate types and ranges
5. **No _G globals** — All 5 global functions replaced by proper module requires
6. **No print statements** — All debug prints removed from production code
7. **Fixed deprecated APIs** — `:connect()` → `:Connect()`, `spawn()` → `task.spawn()`, `wait()` → `task.wait()`
8. **Fixed typos** — `SToredScenes`, `NewAtmoshpere`, `Flter`, `ProcessRecept`, `Sucess`, `FoundFealm`, `Elimating`
9. **Merged duplicate WeldAndScale** — Single canonical copy in `Shared/Util/`

## Tooling

| Tool | Config File | Purpose |
|------|------------|---------|
| Rojo | `default.project.json` | File sync to Roblox Studio |
| Selene | `selene.toml` | Linter (`std = "roblox"`) |
| StyLua | `stylua.toml` | Formatter (tabs, 120 col) |
| Luau LSP | `.luaurc` | Type checker (`strict` mode) |
| Aftman | `aftman.toml` | Tool version management |

## Conventions

- **Strict typing:** `--!strict` at top of all new files
- **Services use `:` methods**, handlers use `.` functions
- **Config over magic numbers:** All constants in `Constants.luau` or domain-specific config files
- **No `_G`:** Module requires only
- **Error handling:** `pcall` on all external service calls, `warn()` for errors
- **Cleanup:** `Cleanup.new()` for managing connections per-character
