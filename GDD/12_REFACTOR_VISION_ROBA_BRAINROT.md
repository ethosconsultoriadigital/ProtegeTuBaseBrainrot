# Rediseño técnico: visión “Roba brainrots” + 8 bases + Lucky Blocks

Documento de **Lead Designer + arquitectura Luau** para refactorizar el MVP actual **sin reescribir desde cero**. Referencia de assets del Creator Store ya acordados en el proyecto:

| Uso | Asset (Creator Store) |
|-----|------------------------|
| Mapa principal (flat / estilo referencia) | [Steal-A-Brainrot-Map](https://create.roblox.com/store/asset/101491434169003/Steal-A-Brainrot-Map) (`GameConfig.IMPORTED_MAP_ASSET_ID`) |
| Pool brainrots / contenido | [67-Brainrot-working](https://create.roblox.com/store/asset/112586636995159/67-Brainrot-working), [BRAINROT-PACK-3](https://create.roblox.com/store/asset/72466520546640/BRAINROT-PACK-3), [Brainrot-pack-1](https://create.roblox.com/store/asset/98891498207178/Brainrot-pack-1) |
| Referencia tienda / props | [Steal-A-Brainrot-Shop](https://create.roblox.com/store/asset/95566802299515/Steal-A-Brainrot-Shop) |
| Referencia base | [Steal-A-Brainrot-Base](https://create.roblox.com/store/asset/107398504693015/Steal-A-Brainrot-Base) |

**Seguridad:** cualquier asset de Store/Toolbox puede traer **scripts** de terceros. Antes de mergear a producción: abrir modelo en **place de prueba**, revisar `Script`/`LocalScript`/`ModuleScript`, quitar `require` externos, `loadstring`, `HttpService` no deseado, y **clonar solo meshes** si hace falta.

---

## 1. Resumen del nuevo diseño

El juego pasa de un **TD de una sola base y una polilínea** a un **servidor con mapa tipo “roba brainrots”**: una **ruta principal** compartida por donde circulan **Lucky Blocks** (flujo de recursos, no atacan) y **brainrots enemigos** (amenaza). Los enemigos **eligen aleatoriamente una de 8 bases** y, en un nodo de ramificación, **abandonan el troncal** para seguir un **camino secundario** hasta esa base, donde intentan **romper defensa / robar** brainrots que el jugador **guardó** tras abrir Lucky Blocks. La economía principal deja de ser “farmear kills” y pasa a ser **obtener brainrots por rareza → almacenar → generar valor → arriesgar robo**.

---

## 2. Diferencias clave contra el diseño anterior

| Área | MVP actual (repo) | Nueva visión |
|------|-------------------|--------------|
| **Mapa** | Graybox procedural o import simple; **un** `Map.Path.Waypoints` lineal; `Map.Base` único | Mapa Store [Steal-A-Brainrot-Map](https://create.roblox.com/store/asset/101491434169003/Steal-A-Brainrot-Map); **troncal + 8 ramas** a bases; terreno **flat** (ajustar Y / quitar montañas en place o por script de cámara) |
| **Flujo enemigos** | `BrainrotManager` + `PathFollower`: una lista de `Vector3` hasta un fin único → `BaseManager.HandleBrainrotArrival` | Misma entidad puede usar **dos segmentos de path**: troncal hasta **nodo de split**, luego **subpath por `baseId`** elegido con **RNG ponderado** |
| **Economía** | `EconomyManager`: kills, capturas, oleadas, bóveda pasiva; `WaveManager` motor | Lucky Blocks como **fuente principal**; kills secundarios; **ingreso por brainrots almacenados** por rareza (Normal / Gold / Diamond + extensible) |
| **Defensa** | `DefenseManager` + `BuildZones` globales alrededor de un único recorrido | **Defensa por base** (zonas hijas de cada `Base_i` o tags `BaseId`); mismas torretas/trampas **reubicadas** por base |
| **Progresión** | Oleadas 1..N, victoria “acabaste oleadas”, derrota núcleo | Progresión por **valor acumulado en base**, **riesgo de robo**, upgrades de defensa/tienda; victoria/derrota a **redefinir** (ej. temporadas, objetivos de valor, o boss que prioriza una base) |

---

## 3. Diseño del mapa y flujo

**Ruta principal (troncal)**  
- Conjunto de waypoints `T1..Tn` en `Workspace.Map.Path.Main` (o `Path.Trunk` — nombre a fijar en convención).
- Spawn conjunto de: **enemigos** y **Lucky Blocks** (colas distintas).

**Desvíos a bases**  
- Por cada `baseIndex` 1..8: carpeta `Workspace.Map.Path.Branches.Base_01` … `Base_08` con waypoints `B_i_1..B_i_m` donde `B_i_1` coincide (o se snap) al **nodo de unión** `J_i` sobre el troncal.

**Nodo de decisión**  
- Cada enemigo lleva `state = TRUNK | BRANCH`.
- En el waypoint `J` (config por índice o por `Attribute "IsJunction"`), el servidor elige `targetBaseId` (ya decidido al spawn o al llegar a J — ver sección 5).

**Lucky Blocks**  
- Spawnean en el inicio del troncal (o cola de spawn); **solo** `PathFollower` sobre **solo** `Main`; al llegar al final: **despawn** o loop al inicio; **sin** `targetBaseId`.

**Flujo general**  
1. Lucky Block recorre troncal → interacción → drop → inventario/base del jugador.  
2. Enemigo spawna en troncal → avanza → en `J` toma rama `Base_k` → ataca barrera de esa base → robo si aplica.

---

## 4. Sistema de 8 bases

**Representación técnica**  
- `Workspace.Map.Bases` con **8** `Folder` o `Model` hijos: `Base_01` … `Base_08`, cada uno con:
  - `Barrier`, `Vault` (almacenamiento), opcional `Core`, `BuildZones` (hijo o tag).
  - `Attribute "BaseId" = number` y `Attribute "OwnerUserId"` (0 si libre).

**Asignación a jugadores**  
- Al `PlayerAdded`: asignar el **primer `Base_i` libre**; persistir en `EconomyManager` / nuevo `BaseAssignmentService` tabla `UserId → baseId`.
- **Solo / <8 jugadores:** bases sin dueño quedan `OwnerUserId = 0`, **inactivas** para economía de jugador (no generan Cells al “dueño fantasma”) o modo “IA dummy” según diseño; **no** deben recibir defensas de jugadores reales salvo regla explícita.

**Qué almacena cada base**  
- Lista de `{ rarity, templateId, value, stealValue }` por brainrot guardado (similar a hoy `BaseManager` vault pero **por base**).

**Robo**  
- Enemigo que llega a `Base_k` con barrera caída / brecha: reduce almacén de **esa** base (solo del `OwnerUserId` de `k`).

**Defensa**  
- `DefenseManager` filtra colocación por `baseId` del jugador local o del dueño de la zona clicada.

---

## 5. Sistema de brainrots enemigos

| Etapa | Comportamiento |
|-------|----------------|
| **Spawn** | Cola desde `WaveManager` / nuevo `ThreatSpawnScheduler`; posición = `Main[1]` |
| **Elección de base** | Al **spawn** (recomendado, reproducible): `targetBaseId = WeightedRandom(BaseAttackConfig)`; excluir bases sin dueño si regla así lo pide |
| **Navegación** | `PathFollower` extendido o **encadenar** dos instancias: primero array `trunkVectors`, al completar, `branchVectors[targetBaseId]` |
| **Ataque** | Al llegar al final de rama: `BaseRegistry.Get(baseId):ApplyDamage` / mismo contrato que hoy `BaseManager.HandleBrainrotArrival` pero **parametrizado por base** |
| **Llegada / robo** | Si barrera activa: daño a barrera de **esa** base; si brecha: robar de **vault de esa base** |
| **Jefe** | `BrainrotConfig` o spawn metadata `forcedBaseId` opcional |

---

## 6. Sistema de Lucky Blocks

| Aspecto | Diseño |
|---------|--------|
| **Spawn** | Scheduler independiente del de enemigos; límite concurrente en troncal |
| **Movimiento** | Solo waypoints `Main`; tag `EntityType = LuckyBlock` |
| **Interacción** | `ProximityPrompt` en servidor o hitbox + `RemoteEvent` “OpenLuckyBlock”; **cooldown** por jugador |
| **Drop** | Tabla `LuckyBlockLootTable`: rareza → peso → referencia a asset visual / stats en `BrainrotConfig` |
| **Integración** | Drop añade entrada al **vault de la base del jugador** + notificación `CellsUpdate` / nuevo evento `VaultContentsChanged` |

---

## 7. Nueva economía del juego

- **Fuente principal:** apertura Lucky Blocks (y tick pasivo por brainrots **almacenados** por rareza).  
- **Valor por rareza:** tabla en `EconomyConfig` o `BrainrotConfig`: `passiveIncomePerSec`, `sellValue`, `stealValueMultiplier`.  
- **Riesgo/recompensa:** más rareza → más ingreso y **más valor robable**; caps diarios o soft-cap por slot.  
- **Anti-abuso:** cooldown de apertura, límite de Lucky Blocks simultáneos, **no** stacking infinito de income sin slots; validación servidor en **todo** gasto/compra.

---

## 8. Cambios técnicos al proyecto actual (concretos)

**Modificar**  
- `src/ReplicatedStorage/Modules/GameConfig.lua` — bases, rutas, pesos RNG, IDs de assets, flags flat map.  
- `src/ReplicatedStorage/Modules/EconomyConfig.lua` / `BrainrotConfig.lua` — rarezas Normal/Gold/Diamond, loot, valores de robo.  
- `src/ServerScriptService/MapSetup.server.lua` — convención de carpetas `Path.Main`, `Path.Branches.Base_XX`; opción “solo flat” (o documentar place sin Terrain).  
- `src/ServerScriptService/Main.server.lua` — nuevos `RemoteEvent`, init orden de managers, carpetas `Workspace.ActiveLuckyBlocks`.  
- `src/ServerScriptService/Systems/BrainrotManager.lua` — spawn con `targetBaseId`, dos fases de path, tipos enemigo vs lucky block.  
- `src/ServerScriptService/Systems/BaseManager.lua` → **refactor a instancia por base** o delegar en `BaseRegistry` + `BaseInstance.lua`.  
- `src/ServerScriptService/Systems/MatchManager.lua` — orquestar 8 bases, win/lose nuevos, wiring robo.  
- `src/ServerScriptService/Systems/DefenseManager.lua` — colocación scoped por `baseId` / zonas por base.  
- `src/ServerScriptService/Systems/WaveManager.lua` — convivir con spawn de amenazas o **reemplazar** por `ThreatScheduler` (ver fases).  
- `src/ServerScriptService/Systems/EconomyManager.lua` — income por vault por base, Lucky Block payouts.  
- `src/ServerScriptService/Systems/CaptureManager.lua` — relevo hacia “almacenar en mi base” si aún aplica; o fusionar con vault por base.  
- `src/ServerScriptService/AI/PathFollower.lua` — API `AppendWaypoints` / `SetRoute` / segunda fase sin duplicar lógica.  
- `src/StarterGui/HUDController.client.lua` — UI multi-base, indicador de base propia, Lucky Block feedback.  
- `src/StarterPlayer/Controllers/PlacementController.lua` — raycast + `baseId` de zona.  
- `src/StarterPlayer/Controllers/CameraController.lua` — bounds del mapa importado o config por `Map` bounding box.

**Crear (nuevos)**  
- `src/ReplicatedStorage/Modules/BaseLayoutConfig.lua` — IDs de ramas, índices de junction.  
- `src/ReplicatedStorage/Modules/LuckyBlockConfig.lua` — tablas de loot, cooldowns.  
- `src/ReplicatedStorage/Modules/TargetBaseConfig.lua` — pesos por base, exclusiones.  
- `src/ServerScriptService/Systems/BaseRegistry.lua` — 8 instancias lógicas.  
- `src/ServerScriptService/Systems/LuckyBlockManager.lua` — spawn, movimiento, apertura.  
- `src/ServerScriptService/Systems/RouteService.lua` (opcional) — resolver `Vector3[]` por trunk+branch.

**Reemplazar / deprecar**  
- Modelo mental “una sola `Map.Base`”: **deprecar** asunción única en `BaseManager`; mantener API temporal `GetDefaultBase()` que redirija a `BaseRegistry` durante migración.  
- `WaveManager` como **único** motor de progresión: puede quedar **deprecated** frente a `SessionDirector` si las oleadas dejan de ser el eje; en Fase 1–2 puede coexistir.  
- `MatchManager` stats centrados en una partida TD: extender o versionar `stats` por base.

**Mantener**  
- `PathFollower` (núcleo matemático), `DefenseConfig` (familias de defensa), `Main.server.lua` patrón de Events, `InsertService` + `IMPORTED_MAP_ASSET_ID`, estructura `Systems/` + `Modules/`.

---

## 9. Nueva arquitectura recomendada

```
ReplicatedStorage/Modules/
  GameConfig, EconomyConfig, BrainrotConfig, DefenseConfig
  BaseLayoutConfig, LuckyBlockConfig, TargetBaseConfig, RarityConfig

ServerScriptService/
  Main.server.lua
  MapSetup.server.lua
  Systems/
    BaseRegistry.lua          -- 8 bases, asignación jugador
    BaseInstance.lua          -- HP barrera, vault, breach por base (opcional módulo)
    BrainrotManager.lua       -- entidades enemigas + tipos
    LuckyBlockManager.lua
    RouteService.lua          -- trunk + branch → array Vector3
    ThreatSpawnScheduler.lua  -- (reemplazo gradual de WaveManager)
    DefenseManager.lua
    EconomyManager.lua
    CaptureManager.lua          -- o fusionado con vault
    MatchManager.lua            -- orquestación + fin de partida
  AI/
    PathFollower.lua

Workspace/
  Map/... (import + convención Path)
  ActiveBrainrots, ActiveDefenses, ActiveLuckyBlocks
```

**Cliente:** `HUDController`, `PlacementController`, eventos nuevos (`LuckyBlockOpened`, `BaseAssigned`, `BranchEnemySpawned`, etc.).

**Multiplayer:** toda mutación de vault / economía **solo servidor**; cliente solo UI y requests.

---

## 10. Plan de refactor por fases

### Fase 1 — Mapa, rutas y 8 bases (objetivo)

- **Objetivo:** Mapa Store flat; convención `Main` + `Branches.Base_01..08`; `BaseRegistry` + asignación jugador; barrera/vault **por base** (aunque economía aún global temporalmente).
- **Archivos:** `MapSetup.server.lua`, `GameConfig.lua`, nuevo `BaseRegistry.lua`, refactor `BaseManager` o split, `Main.server.lua`, `MatchManager.lua` (init).
- **Riesgos:** jerarquía del asset ≠ convención; hace falta **documento de naming** en Studio una vez importado.
- **Éxito:** 8 bases visibles, jugador asignado a una, defensas se colocan solo en su base (o fallback documentado).

### Fase 2 — Enemigos con base aleatoria

- **Objetivo:** En spawn, `targetBaseId`; en junction, cambio a rama; llegada llama API de la base correcta.
- **Archivos:** `BrainrotManager.lua`, `PathFollower.lua` o `RouteService.lua`, `TargetBaseConfig.lua`, `MatchManager.lua`.
- **Riesgos:** desalineación de nodos `J_i`; enemigos atascados.
- **Éxito:** 100 enemigos consecutivos sin stuck; distribución de destinos cercana a pesos configurados.

### Fase 3 — Lucky Blocks + economía por drops

- **Objetivo:** Spawner + movimiento troncal; apertura → loot rareza → vault del jugador; ingreso pasivo por rareza.
- **Archivos:** `LuckyBlockManager.lua`, `LuckyBlockConfig.lua`, `EconomyManager.lua`, `Main.server.lua` (remotes), `HUDController.client.lua`.
- **Riesgos:** scripts maliciosos en meshes de packs — **auditar** [packs enlazados](https://create.roblox.com/store/asset/112586636995159/67-Brainrot-working) etc.
- **Éxito:** bucle: abrir LB → ver rareza → sube ingreso / valor en vault.

### Fase 4 — Robo de almacenados

- **Objetivo:** Enemigo en brecha de base `k` roba del vault de `k` solo.
- **Archivos:** `BaseInstance`/`BaseRegistry`, `BrainrotManager`, `MatchManager`, eventos cliente.
- **Éxito:** robo reduce slots correctos; dueño ve UI actualizada.

### Fase 5 — UI, polish, balance

- **Objetivo:** Indicadores de ruta/base, VFX, sonidos, tuning números, victoria/derrota claras.
- **Archivos:** `HUDController`, configs, opcional `SoundService` en `default.project.json`.
- **Riesgos:** saturación visual 8 bases.
- **Éxito:** sesión 15 min comprensible sin leer código.

---

## 11. Lista exacta de managers / módulos recomendados

| Módulo | Responsabilidad |
|--------|-------------------|
| `GameConfig` | Constantes globales, asset IDs, número de bases |
| `BaseLayoutConfig` | Rutas: nombres de folders, índices junction, offsets |
| `TargetBaseConfig` | Pesos RNG, boss overrides, bases excluidas |
| `RarityConfig` | Normal / Gold / Diamond + extensión |
| `LuckyBlockConfig` | Tablas de loot, cooldowns, límites |
| `BrainrotConfig` | Stats enemigo + metadatos visuales / asset refs |
| `DefenseConfig` | Defensas (mantener) |
| `EconomyConfig` | Precios, multiplicadores por rareza |
| `BaseRegistry` | Crear/obtener las 8 bases, asignación jugador |
| `BaseInstance` | HP barrera, vault, breach, robos **de una base** |
| `RouteService` | Construir `Vector3[]` trunk→branch |
| `PathFollower` | Movimiento sobre polyline |
| `BrainrotManager` | Ciclo de vida enemigos + hooks daño/muerte |
| `LuckyBlockManager` | Spawn, movimiento, interacción, loot |
| `ThreatSpawnScheduler` | Cuándo spawnear amenazas (reemplazo gradual de olas) |
| `WaveManager` | **Deprecated** gradualmente o redefinido como “oleadas de amenaza” |
| `DefenseManager` | Colocación y combate de defensas **por base** |
| `EconomyManager` | Cells, ingresos, pagos, por jugador |
| `CaptureManager` | Fusionar o redirigir a “guardar en base” |
| `MatchManager` | Orquestación, remotes, fin de sesión |
| `MapSetup` | Import + validación de jerarquía + stubs |
| `HUDController` | UI sesión, bases, Lucky Blocks |
| `PlacementController` | Input colocación con `baseId` |

---

## 12. Riesgos técnicos y de diseño

- **Navegación:** ramas mal alineadas → enemigos orbitando; mitigar con **tolerancia** en `PathFollower` y waypoints de prueba en Studio.  
- **Balance:** RNG duro → una base focoada; usar **pesos** + **ventana sin repetir** misma base.  
- **Saturación visual:** 8 bases + UI; minimap o resaltar **solo tu base**.  
- **Abuso económico:** macros en LB; **cooldown servidor** + rate limit.  
- **Race conditions:** dos jugadores abriendo mismo bloque; **mutex** por entidad.  
- **Multiplayer:** asignación de base y vault **solo servidor**; replicar con atributos o eventos puntuales.  
- **Bases vacías:** no generar amenaza infinita a base sin dueño o marcar **no elegible**.  
- **Performance:** muchos followers; **pooling**, tick a 10 Hz para lejanos, LOD.

---

## 13. MVP refactorizado (mínimo jugable, scope acotado)

1. Mapa [Steal-A-Brainrot-Map](https://create.roblox.com/store/asset/101491434169003/Steal-A-Brainrot-Map) + **troncal + 2 ramas de prueba** (no hace falta pulir las 8 el primer día si la convención está lista).  
2. **4 bases** asignables (subir a 8 en siguiente iteración) para reducir QA.  
3. Enemigos con **RNG de base** y **path de dos tramos**.  
4. **Un** tipo de Lucky Block, **3 rarezas** de drop, almacenamiento en vault de la base del jugador.  
5. **Una** defensa por tipo en tu base; sin tienda compleja del asset [Shop](https://create.roblox.com/store/asset/95566802299515/Steal-A-Brainrot-Shop) al inicio (solo referencia visual).  
6. Robo **mínimo:** quitar 1 ítem del vault al completar infiltración.

---

## 14. Sugerencias adicionales de assets (categorías)

Prioridad: reutilizar meshes de los packs ya enlazados; complementar solo donde falte.

- **Señales de ruta:** decals / beams en troncal (no necesariamente nuevo asset).  
- **Indicador de base objetivo:** billboard en enemigo con color por `baseId`.  
- **VFX de robo:** partículas genéricas Creator Store “loot burst”.  
- **Feedback Lucky Block:** sonido + flash UI (sin asset obligatorio).  
- **Props de base:** piezas de [Steal-A-Brainrot-Base](https://create.roblox.com/store/asset/107398504693015/Steal-A-Brainrot-Base) clonadas por base.  
- **Iconos UI:** pack genérico “game icons” en Store si hace falta.  
- **Barreras / puertas:** mismo pack base o Part + tween hasta abrir brecha.

---

## 15. Siguiente paso exacto para empezar en el repo

1. **En Roblox Studio** (con mapa importado): documentar con capturas la jerarquía real bajo `Workspace.Map` (nombres de carpetas del asset [Steal-A-Brainrot-Map](https://create.roblox.com/store/asset/101491434169003/Steal-A-Brainrot-Map)).  
2. **Definir convención fija** en un markdown corto (o `BaseLayoutConfig` esqueleto): rutas `Path/Main`, `Path/Branches/Base_XX`, atributos en nodos junction.  
3. **Implementar Fase 1** en código: crear `BaseRegistry.lua`, migrar `BaseManager` a **multi-instancia** o wrapper, ajustar `MapSetup` para validar/crear stubs de las 8 bases si el asset no las trae completas.  
4. **Congelar** cambios de diseño de oleadas hasta tener Fase 2 lista (evitar doble motor).

---

*Documento generado para alinear implementación por fases con el código en `src/` actual. Para aplicar cambios de código, usar modo Agent por fase.*
