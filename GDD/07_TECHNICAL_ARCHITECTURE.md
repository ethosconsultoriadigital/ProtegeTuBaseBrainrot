# 17. MVP SCOPE FOR ROBLOX

## V1 (MVP) — Lo que DEBE estar

| Sistema | Alcance MVP | Notas |
|---------|------------|-------|
| Mapa | 1 mapa con 1 camino, 15 zonas de construcción | Simple pero completo |
| Oleadas | 10 oleadas + 1 boss | Suficiente para sesión de 15 min |
| Brainrots | 4 clases (Swarmer, Tank, Speedster, Shielder) | Las más icónicas |
| Rarezas | 5 rarezas (Normal → Diamante) | Suficiente para sentir progresión |
| Defensas | 6 defensas (1 DPS, 1 Slow, 1 CC, 1 Burst, 1 Soporte, 1 Captura) | 1 por familia |
| Mejoras | 2 niveles de mejora por defensa | Simplificado |
| Base | Barrera + Bóveda (8 slots) + Núcleo | Core completo |
| Brecha | Sistema de infiltración básico | Funcional |
| Economía | Cells (in-game) solo | Sin persistencia aún |
| Modo | Solo solamente | Co-op en V2 |
| UI | HUD funcional, tienda in-game, preview oleada | Clean pero básica |
| Guardado | Nada persistente en V1 | Cada partida es standalone |

## V2 — Segunda Iteración

| Sistema | Alcance |
|---------|---------|
| Co-op | 2-4 jugadores |
| Persistencia | Cortex + Nivel de Guardián + Brainrotdex |
| Tienda permanente | Tier I y II |
| Rarezas | Añadir Mítico, Corrupto, Legendario |
| Clases | Añadir Healer, Saboteur, Stealth |
| Defensas | 2-3 defensas adicionales por familia |
| Mapas | 2 mapas adicionales |
| Oleadas | 15 oleadas + boss |
| Battle Pass | V1 del Battle Pass |
| Daily Challenges | Sistema básico |

## V3+ — Expansión

- Ancestrales y bosses únicos por mapa
- Dificultades Élite y Pesadilla
- Tienda Tier III y IV
- Ranked system
- Seasonal content
- Cosmetic shop completa
- Prestige system
- Community events

## Lo que se puede simplificar sin matar la fantasía:

1. **Habilidades activas de Brainrots:** En MVP, solo pasivas simples (más HP, más velocidad)
2. **Sinergias de defensa:** En MVP, sin bonus de proximidad — solo funcionalidad individual
3. **Set bonuses de bóveda:** En MVP, sin sets — solo valor individual
4. **Roles co-op:** No aplica en MVP (solo mode)
5. **Animaciones elaboradas:** En MVP, partículas simples en vez de VFX complejos
6. **Boss multi-fase:** En MVP, boss con 1 fase y mucho HP

---

# 18. ROBLOX TECHNICAL ARCHITECTURE

## Principios Técnicos

1. **Server Authority:** El servidor controla toda lógica de gameplay (oleadas, daño, economía, captura). El cliente solo envía inputs y recibe estado.
2. **Minimal RemoteEvents:** Solo los necesarios. Batch updates cuando sea posible.
3. **Object Pooling:** Reusar instancias de Brainrots y proyectiles para performance.
4. **Client-Side Prediction:** VFX y animaciones corren en cliente. Estado real en servidor.
5. **DataStore Seguro:** Toda escritura de datos validada en servidor.

---

## Servicios de Roblox Utilizados

| Servicio | Uso |
|----------|-----|
| Players | Gestión de jugadores, conexión/desconexión |
| ReplicatedStorage | Módulos compartidos, RemoteEvents, configuración |
| ServerScriptService | Toda lógica server (oleadas, IA, economía, daño) |
| ServerStorage | Templates de Brainrots, defensas, datos de configuración |
| StarterPlayerScripts | Scripts de cliente (input, cámara, placement preview) |
| StarterGui | Toda la UI |
| Workspace | Mapa, entidades en juego, efectos visuales |
| SoundService | Audio |
| DataStoreService | Guardado persistente (V2+) |
| RunService | Game loops (Heartbeat para server, RenderStepped para client) |
| CollectionService | Tags para identificar tipos de entidades |
| TweenService | Animaciones suaves client-side |

---

## RemoteEvents & RemoteFunctions

### RemoteEvents (Server → Client)

| Nombre | Datos | Propósito |
|--------|-------|----------|
| WaveStarted | {waveNumber, composition, duration} | Notificar inicio de oleada |
| WaveEnded | {kills, cellsEarned, captures} | Resumen post-oleada |
| BrainrotSpawned | {id, class, rarity, pathIndex} | Crear visual de Brainrot en cliente |
| BrainrotDied | {id, killerDefenseId} | Reproducir VFX de muerte |
| BrainrotCaptured | {id, rarity, vaultSlot} | Animación de captura |
| BarrierUpdate | {currentHP, maxHP, lastDamageSource} | Actualizar UI de barrera |
| BreachStarted | {} | Activar alarma de brecha |
| BreachEnded | {} | Desactivar alarma |
| BrainrotStolen | {rarity, remainingInVault} | Notificar robo |
| CellsUpdate | {amount} | Actualizar dinero del jugador |
| GameOver | {victory, stats} | Pantalla de resultado |
| DefensePlaced | {defenseId, type, position} | Confirmar colocación (otros clientes) |
| DefenseUpgraded | {defenseId, newLevel} | Actualizar visual de mejora |

### RemoteEvents (Client → Server)

| Nombre | Datos | Propósito |
|--------|-------|----------|
| RequestPlaceDefense | {defenseType, position, rotation} | Solicitar colocación |
| RequestUpgradeDefense | {defenseId} | Solicitar mejora |
| RequestSellDefense | {defenseId} | Solicitar venta |
| RequestRepairBarrier | {} | Solicitar reparación |
| RequestSkipTimer | {} | Solicitar saltar timer de build |
| ActivateAbility | {abilityId, targetPosition?} | Usar habilidad activa |
| RequestCapturePulse | {targetBrainrotId} | Usar captura manual |

### RemoteFunctions (Client → Server, con respuesta)

| Nombre | Request | Response | Propósito |
|--------|---------|----------|----------|
| GetGameState | {} | {wave, cells, barrier, vault, defenses} | Sync inicial o reconexión |
| GetDefenseCost | {type, level} | {cost, canAfford} | Verificar precio antes de comprar |
| GetWavePreview | {waveNumber} | {composition, rarities} | Preview de oleada |
| GetVaultContents | {} | {brainrots[]} | Listar bóveda actual |

---

## Responsabilidades Server / Client

### SERVER (Autoridad total)

```
┌─ Game Manager ──────────────────────────┐
│  ├─ Wave System                          │
│  │   ├─ Wave composition generator       │
│  │   ├─ Spawn scheduler                  │
│  │   └─ Wave state machine               │
│  ├─ Brainrot System                      │
│  │   ├─ AI / Pathfinding                 │
│  │   ├─ HP / Damage management           │
│  │   ├─ Abilities (server-authoritative) │
│  │   └─ Death / Capture resolution       │
│  ├─ Defense System                       │
│  │   ├─ Placement validation             │
│  │   ├─ Targeting logic                  │
│  │   ├─ Damage calculation               │
│  │   ├─ Effect application               │
│  │   └─ Upgrade management               │
│  ├─ Base System                          │
│  │   ├─ Barrier HP management            │
│  │   ├─ Breach detection                 │
│  │   ├─ Vault management                 │
│  │   └─ Core HP management               │
│  ├─ Economy System                       │
│  │   ├─ Cells tracking per player        │
│  │   ├─ Kill rewards                     │
│  │   ├─ Capture rewards                  │
│  │   └─ Passive income from vault        │
│  └─ Match System                         │
│      ├─ Match state (prep/combat/boss)   │
│      ├─ Win/lose conditions              │
│      └─ Scoring & rewards                │
└──────────────────────────────────────────┘
```

### CLIENT (Presentación + Input)

```
┌─ Client Systems ────────────────────────┐
│  ├─ Input Handler                        │
│  │   ├─ Defense placement (preview)      │
│  │   ├─ Click to place/upgrade/sell      │
│  │   ├─ Ability activation               │
│  │   └─ Camera controls                  │
│  ├─ Visual Manager                       │
│  │   ├─ Brainrot visual sync             │
│  │   ├─ Defense animations               │
│  │   ├─ VFX / Particles                  │
│  │   └─ UI updates                       │
│  ├─ UI Controller                        │
│  │   ├─ HUD (cells, barrier, wave)       │
│  │   ├─ Defense hotbar                   │
│  │   ├─ Vault display                    │
│  │   ├─ Shop (in-game)                   │
│  │   ├─ Wave preview                     │
│  │   └─ Results screen                   │
│  └─ Audio Manager                        │
│      ├─ Music state management           │
│      ├─ SFX triggers                     │
│      └─ Ambience                         │
└──────────────────────────────────────────┘
```

---

## Sistema de Oleadas (Server)

```lua
-- Pseudocódigo de la state machine de oleadas
WaveStates = {
    IDLE,           -- Esperando inicio de partida
    BUILD_PHASE,    -- Jugador construyendo (timer)
    SPAWNING,       -- Spawneando Brainrots
    COMBAT,         -- Brainrots en camino, defensas atacando
    WAVE_COMPLETE,  -- Todos muertos/capturados, rewards
    BOSS_INTRO,     -- Cinemática/intro de boss
    BOSS_COMBAT,    -- Pelea de boss
    VICTORY,        -- Jugador ganó
    DEFEAT          -- Jugador perdió
}

-- Transiciones:
-- IDLE → BUILD_PHASE (al iniciar partida)
-- BUILD_PHASE → SPAWNING (timer termina o jugador skip)
-- SPAWNING → COMBAT (todos spawneados)
-- COMBAT → WAVE_COMPLETE (todos los brainrots eliminados/capturados/escapados)
-- WAVE_COMPLETE → BUILD_PHASE (siguiente oleada)
-- WAVE_COMPLETE → BOSS_INTRO (si es oleada de boss)
-- BOSS_INTRO → BOSS_COMBAT
-- BOSS_COMBAT → VICTORY (boss muerto/capturado)
-- Cualquiera → DEFEAT (núcleo destruido)
```

## Colocación de Defensas (Server + Client)

```
CLIENT:                              SERVER:
1. Jugador entra a modo "colocar"    
2. Preview fantasma sigue cursor     
3. Snap a zonas válidas (highlight)  
4. Click para confirmar              
5. RemoteEvent: RequestPlaceDefense  →  6. Validar: zona válida? tiene cells? no ocupada?
                                     ←  7a. Si OK: crear defensa, restar cells, confirmar
                                         7b. Si NO: rechazar con razón
8. Recibir confirmación o rechazo
9. Si OK: spawnar visual + sonido
```

## IA de Pathfinding (Server)

**Método:** Pre-computed path con waypoints (NO navmesh dinámico — demasiado costoso)

```lua
-- El camino se define como serie de waypoints en el mapa
-- Cada Brainrot tiene un pathIndex que indica su waypoint actual
-- Cada Heartbeat, los Brainrots se mueven hacia su siguiente waypoint
-- Velocidad basada en: baseSpeed × rarityMultiplier × slowEffects

-- Pseudo:
function UpdateBrainrot(brainrot, dt)
    local target = path[brainrot.pathIndex + 1]
    if not target then
        -- Llegó al final: atacar barrera
        DamageBarrier(brainrot)
        return
    end
    
    local direction = (target.Position - brainrot.Position).Unit
    local speed = brainrot.baseSpeed * brainrot.raritySpeedMult * brainrot.slowFactor
    brainrot.Position = brainrot.Position + direction * speed * dt
    
    if (brainrot.Position - target.Position).Magnitude < 1 then
        brainrot.pathIndex += 1
    end
end
```

## Captura de Brainrots (Server)

```lua
-- Cada módulo de captura chequea Brainrots en rango cada 0.5s
-- Si un Brainrot tiene HP < threshold:
--   1. Calcular probabilidad: baseCaptureRate × rarityModifier × moduleLevel
--   2. Roll aleatorio
--   3. Si éxito: remover Brainrot del camino, añadir a bóveda
--   4. Fire BrainrotCaptured event
--   5. Añadir rewards

function TryCapture(module, brainrot)
    if brainrot.hp / brainrot.maxHp > module.hpThreshold then return false end
    if module.cooldownRemaining > 0 then return false end
    
    local prob = RARITY_CAPTURE_RATES[brainrot.rarity] * module.captureMultiplier
    local roll = math.random()
    
    if roll <= prob then
        -- Captura exitosa
        AddToVault(brainrot)
        RemoveBrainrot(brainrot)
        module.cooldownRemaining = module.cooldown
        return true
    end
    return false
end
```

## Robo a la Base (Server)

```lua
-- Cuando barrera llega a 0:
-- 1. Flag: breached = true
-- 2. Brainrots que llegan al final ahora entran a infiltración
-- 3. Cada infiltrado tiene timer de 3s, luego roba el Brainrot más valioso
-- 4. Si bóveda vacía, atacan el núcleo

function OnBarrierBreached()
    breached = true
    FireAllClients("BreachStarted")
end

function HandleInfiltrator(brainrot)
    -- Espera 5s de travel al vault
    wait(5)
    if not breached then return end -- Barrera reparada mientras viajaba
    
    -- Roba el más valioso
    local target = GetMostValuableBrainrotInVault()
    if target then
        wait(3) -- Tiempo de robo
        if not breached then return end
        RemoveFromVault(target)
        FireAllClients("BrainrotStolen", {rarity = target.rarity})
    else
        -- Bóveda vacía, atacar núcleo
        DamageCore(brainrot.barrierDamage)
    end
end
```

---

# 19. RECOMMENDED FOLDER STRUCTURE IN ROBLOX STUDIO

```
game/
├── ReplicatedStorage/
│   ├── Modules/                          -- Módulos compartidos client/server
│   │   ├── Config/
│   │   │   ├── GameConfig.lua            -- Constantes del juego (HP barrera, cells iniciales, etc.)
│   │   │   ├── BrainrotConfig.lua        -- Stats de cada clase × rareza
│   │   │   ├── DefenseConfig.lua         -- Stats de cada defensa × nivel
│   │   │   ├── WaveConfig.lua            -- Composición de oleadas por mapa/dificultad
│   │   │   ├── EconomyConfig.lua         -- Costos, recompensas, rates
│   │   │   └── RarityConfig.lua          -- Colores, multiplicadores, probabilidades
│   │   ├── Utils/
│   │   │   ├── MathUtils.lua             -- Funciones matemáticas comunes
│   │   │   ├── TableUtils.lua            -- Utilidades de tablas
│   │   │   └── FormatUtils.lua           -- Formateo de números, texto
│   │   └── Types/
│   │       └── GameTypes.lua             -- Type definitions compartidos
│   ├── Events/
│   │   ├── GameEvents/                   -- RemoteEvents de gameplay
│   │   │   ├── WaveStarted.RemoteEvent
│   │   │   ├── WaveEnded.RemoteEvent
│   │   │   ├── BrainrotSpawned.RemoteEvent
│   │   │   ├── BrainrotDied.RemoteEvent
│   │   │   ├── BrainrotCaptured.RemoteEvent
│   │   │   ├── BarrierUpdate.RemoteEvent
│   │   │   ├── BreachStarted.RemoteEvent
│   │   │   ├── BreachEnded.RemoteEvent
│   │   │   ├── BrainrotStolen.RemoteEvent
│   │   │   ├── CellsUpdate.RemoteEvent
│   │   │   └── GameOver.RemoteEvent
│   │   ├── DefenseEvents/                -- RemoteEvents de defensas
│   │   │   ├── RequestPlaceDefense.RemoteEvent
│   │   │   ├── RequestUpgradeDefense.RemoteEvent
│   │   │   ├── RequestSellDefense.RemoteEvent
│   │   │   ├── DefensePlaced.RemoteEvent
│   │   │   └── DefenseUpgraded.RemoteEvent
│   │   ├── BaseEvents/                   -- RemoteEvents de base
│   │   │   └── RequestRepairBarrier.RemoteEvent
│   │   ├── AbilityEvents/
│   │   │   ├── ActivateAbility.RemoteEvent
│   │   │   └── RequestCapturePulse.RemoteEvent
│   │   └── Functions/                    -- RemoteFunctions
│   │       ├── GetGameState.RemoteFunction
│   │       ├── GetDefenseCost.RemoteFunction
│   │       ├── GetWavePreview.RemoteFunction
│   │       └── GetVaultContents.RemoteFunction
│   └── Assets/
│       ├── UI/                           -- Assets de UI compartidos
│       │   ├── Icons/
│       │   └── Frames/
│       └── Particles/                    -- Templates de partículas
│           ├── CaptureEffect.ParticleEmitter
│           ├── DeathEffect.ParticleEmitter
│           └── RarityAuras/
│
├── ServerScriptService/
│   ├── Main.server.lua                   -- Entry point del servidor, inicializa todo
│   ├── Systems/
│   │   ├── MatchManager.lua              -- State machine de la partida
│   │   ├── WaveManager.lua               -- Generación y ejecución de oleadas
│   │   ├── BrainrotManager.lua           -- Spawning, AI, pathfinding, death
│   │   ├── DefenseManager.lua            -- Placement, targeting, damage, upgrades
│   │   ├── BaseManager.lua               -- Barrera, bóveda, núcleo, brecha
│   │   ├── EconomyManager.lua            -- Cells, rewards, costos
│   │   ├── CaptureManager.lua            -- Lógica de captura
│   │   └── PlayerManager.lua             -- Gestión de jugadores, loadouts
│   ├── AI/
│   │   ├── PathFollower.lua              -- Movimiento por waypoints
│   │   ├── BrainrotBehaviors.lua         -- Comportamientos por clase
│   │   └── BossAI.lua                    -- IA específica de bosses
│   └── Data/
│       └── DataManager.lua               -- DataStore (V2+)
│
├── ServerStorage/
│   ├── Templates/
│   │   ├── Brainrots/                    -- Modelos 3D de cada Brainrot
│   │   │   ├── Swarmer.Model
│   │   │   ├── Tank.Model
│   │   │   ├── Speedster.Model
│   │   │   └── Shielder.Model
│   │   ├── Defenses/                     -- Modelos 3D de cada defensa
│   │   │   ├── LaserTurret.Model
│   │   │   ├── IceTrap.Model
│   │   │   ├── StasisTrap.Model
│   │   │   ├── ProximityMine.Model
│   │   │   ├── RangeAmplifier.Model
│   │   │   └── CaptureModule.Model
│   │   └── Effects/                      -- VFX server-side
│   └── MapData/
│       └── Map1_Waypoints.lua            -- Datos de waypoints del mapa
│
├── StarterPlayerScripts/
│   ├── ClientMain.client.lua             -- Entry point del cliente
│   ├── Controllers/
│   │   ├── InputController.lua           -- Manejo de input del jugador
│   │   ├── PlacementController.lua       -- Preview y placement de defensas
│   │   ├── CameraController.lua          -- Control de cámara top-down/orbital
│   │   ├── SelectionController.lua       -- Selección de defensas para upgrade/sell
│   │   └── AbilityController.lua         -- Activación de habilidades
│   ├── Visual/
│   │   ├── BrainrotVisual.lua            -- Sync visual de Brainrots con server
│   │   ├── DefenseVisual.lua             -- Animaciones de defensas
│   │   ├── VFXManager.lua                -- Gestión de efectos visuales
│   │   └── EnvironmentEffects.lua        -- Efectos ambientales (brecha, etc.)
│   └── Audio/
│       └── AudioManager.lua              -- Música y SFX
│
├── StarterGui/
│   ├── HUD/
│   │   ├── TopBar.ScreenGui              -- Oleada, timer, cells
│   │   ├── BottomBar.ScreenGui           -- Hotbar de defensas
│   │   ├── StatusBar.ScreenGui           -- Barrera, bóveda
│   │   └── AbilityBar.ScreenGui          -- Habilidades activas
│   ├── Screens/
│   │   ├── WavePreview.ScreenGui         -- Preview de oleada
│   │   ├── VaultScreen.ScreenGui         -- Vista de bóveda
│   │   ├── ShopScreen.ScreenGui          -- Tienda in-game
│   │   ├── ResultsScreen.ScreenGui       -- Pantalla de resultados
│   │   └── PauseMenu.ScreenGui           -- Menú de pausa
│   ├── Notifications/
│   │   ├── CaptureNotif.ScreenGui        -- Pop-up de captura
│   │   ├── BreachNotif.ScreenGui         -- Alerta de brecha
│   │   └── WaveNotif.ScreenGui           -- Banner de oleada
│   └── UIControllers/
│       ├── HUDController.client.lua      -- Lógica de HUD
│       ├── ShopController.client.lua     -- Lógica de tienda
│       ├── VaultController.client.lua    -- Lógica de bóveda UI
│       └── NotifController.client.lua    -- Lógica de notificaciones
│
├── Workspace/
│   ├── Map/
│   │   ├── Terrain/                      -- Terreno del mapa
│   │   ├── Path/                         -- Camino con waypoints
│   │   │   └── Waypoints/                -- Folder con parts numeradas
│   │   ├── BuildZones/                   -- Zonas válidas de construcción
│   │   │   └── Zone_01..Zone_20.Part     -- Parts transparentes marcando zonas
│   │   ├── Base/                         -- Modelo de la base
│   │   │   ├── Barrier.Model             -- Barrera visual
│   │   │   ├── Vault.Model               -- Bóveda con pods
│   │   │   └── Core.Model                -- Núcleo
│   │   ├── Environment/                  -- Decoración
│   │   └── Lighting/                     -- Luces del mapa
│   ├── ActiveBrainrots/                  -- Folder para Brainrots en juego (server managed)
│   └── ActiveDefenses/                   -- Folder para defensas colocadas
│
└── SoundService/
    ├── Music/
    │   ├── BuildPhase.Sound
    │   ├── CombatPhase.Sound
    │   ├── BossPhase.Sound
    │   ├── BreachAlarm.Sound
    │   └── Victory.Sound
    ├── SFX/
    │   ├── Defenses/
    │   │   ├── LaserShoot.Sound
    │   │   ├── PlasmaExplode.Sound
    │   │   ├── IceFreeze.Sound
    │   │   └── CaptureSuccess.Sound
    │   ├── Brainrots/
    │   │   ├── SwarmerDeath.Sound
    │   │   ├── TankStep.Sound
    │   │   └── BossRoar.Sound
    │   ├── UI/
    │   │   ├── ButtonClick.Sound
    │   │   ├── Purchase.Sound
    │   │   ├── Error.Sound
    │   │   └── Notification.Sound
    │   └── Base/
    │       ├── BarrierHit.Sound
    │       ├── BreachSiren.Sound
    │       └── BrainrotStolen.Sound
    └── Ambience/
        └── CorruptedPath.Sound
```
