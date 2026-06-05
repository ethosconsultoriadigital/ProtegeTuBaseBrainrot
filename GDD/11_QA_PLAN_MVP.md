# Plan de prueba inicial — MVP (Roblox Studio)

Checklist manual para validar el MVP en **Play** (solo). Roblox Studio no se puede ejecutar desde el agente; este documento es la fuente de verdad para quien pruebe en local con Rojo sync.

**Prerrequisitos:** `rojo serve` + plugin conectado y sync aplicado, o place guardada con el mismo código.

---

## 1. Smoke test de carga

| Qué hacer | Pulsa **Play**. Abre **View → Output** (filtro **Server** si aplica). |
| Qué debería pasar | Logs tipo `=== PROTEGE TU BASE`, `[Main]`, `[MapSetup]`, `[BrainrotManager] Init OK`, `[Match] === PARTIDA INICIADA ===` sin errores rojos al inicio. Tras ~2 s inicia la partida. |
| Señal de problema | `require` nil, stack al cargar `Systems/*`, o `[Main] Mapa no encontrado tras 10s`. |
| Archivos probables | `src/ServerScriptService/Main.server.lua`, `MapSetup.server.lua`, `src/ServerScriptService/Systems/*`, `src/ReplicatedStorage/Modules/*.lua` |

---

## 2. Validación de mapa

| Qué hacer | Explorer: `Workspace → Map` → Ground, Path (Waypoints + Seg_*), BuildZones, Base (Barrier, Vault, Core). |
| Qué debería pasar | Estructura graybox coherente (suelo, camino, zonas cian, barrera, bóveda, núcleo). |
| Señal de problema | Falta `Map`, `Path` o `Base`; `[MapSetup]` ausente o solo warnings de mapa vacío. |
| Archivos probables | `src/ServerScriptService/MapSetup.server.lua`, `Main.server.lua` (`WaitForMap`) |

---

## 3. Validación de waypoints

| Qué hacer | `Map → Path → Waypoints`: Parts **1** … **12**. Observar movimiento de brainrots por el camino. |
| Qué debería pasar | 12 waypoints; log `Init OK — 12 waypoints`; enemigos avanzan hacia la barrera. |
| Señal de problema | `waypoints insuficientes`, enemigos quietos o errores en PathFollower. |
| Archivos probables | `src/ServerScriptService/Systems/BrainrotManager.lua`, `src/ServerScriptService/AI/PathFollower.lua`, `MapSetup.server.lua` |

---

## 4. Validación de build zones

| Qué hacer | `Map → BuildZones`: `Zone_01` … `Zone_10`. Revisar Output al inicio. |
| Qué debería pasar | 10 zonas; colocación hace snap cerca de zona (`GameConfig.BUILD_ZONE_SNAP_RADIUS`). |
| Señal de problema | Warning `BuildZones no encontrado o vacío`; colocación siempre rechazada por zona. |
| Archivos probables | `MapSetup.server.lua`, `src/ServerScriptService/Systems/DefenseManager.lua`, `src/ReplicatedStorage/Modules/GameConfig.lua` |

---

## 5. Validación de UI

| Qué hacer | En Play, comprobar **PlayerGui → GameHUD** (oleada, timer, cells, barrera, hotbar 1/2/3). |
| Qué debería pasar | HUD visible; cells iniciales acordes a `STARTING_CELLS` (500); sin waits infinitos. |
| Señal de problema | HUD vacío; `[HUD]` / Events nil; `No se pudo cargar PlacementController`. |
| Archivos probables | `src/StarterGui/HUDController.client.lua`, `src/StarterPlayer/ClientMain.client.lua`, `Main.server.lua`, `src/StarterPlayer/Controllers/PlacementController.lua` |

---

## 6. Validación de oleadas

| Qué hacer | Jugar varias oleadas; opcional **F** (`RequestSkipTimer`) para acortar fase build. |
| Qué debería pasar | Ciclo build → combate → oleada limpia; hasta **8** oleadas (`TOTAL_WAVES`); logs `[Match]`. |
| Señal de problema | Estado atascado, sin spawn, oleada que no termina. |
| Archivos probables | `src/ServerScriptService/Systems/WaveManager.lua`, `src/ReplicatedStorage/Modules/WaveConfig.lua`, `MatchManager.lua`, `BrainrotManager.lua` |

---

## 7. Validación de placement

| Qué hacer | **1** torreta → mover mouse sobre zona → **clic** confirmar. **ESC** cancelar. Probar 2/3 si hay cells. |
| Qué debería pasar | Defensa bajo `Workspace.ActiveDefenses`; cells bajan según `DefenseConfig`. |
| Señal de problema | Sin ghost/clic; `[Match] Placement rechazado` (revisar mensaje; falta de cells no es bug). |
| Archivos probables | `PlacementController.lua`, `ClientMain.client.lua`, `MatchManager.lua`, `DefenseManager.lua`, `DefenseConfig.lua`, `EconomyManager.lua` |

---

## 8. Validación de daño y kills

| Qué hacer | **LaserTurret** en rango del camino; observar brainrots en rango. |
| Qué debería pasar | HP baja, muerte por daño; rewards vía `MatchManager` / economía según diseño. |
| Señal de problema | Torreta inactiva; solo muerte por llegar al final del path. |
| Archivos probables | `DefenseManager.lua`, `BrainrotManager.lua`, `BrainrotConfig.lua`, `MatchManager.lua` |

---

## 9. Validación de economía

| Qué hacer | Observar cells en HUD tras kills, capturas, clear de oleada / perfecta; esperar ingreso pasivo de bóveda (`VAULT_INCOME_INTERVAL`). Probar gasto (colocación) y **R** (reparar barrera). |
| Qué debería pasar | Valores coherentes con `EconomyConfig` / `GameConfig`; sin errores en `EconomyManager`. |
| Señal de problema | Cells nil/0 incorrecto; gastos duplicados o sin efecto. |
| Archivos probables | `EconomyManager.lua`, `EconomyConfig.lua`, `GameConfig.lua`, `HUDController.client.lua`, `MatchManager.lua` |

---

## 10. Validación de captura y vault

| Qué hacer | **CaptureModule** tras bajar HP del enemigo; o **sin defensas** para probar auto-captura al matar. Llenar hasta **6** slots (`VAULT_MAX_SLOTS`). |
| Qué debería pasar | Entradas en bóveda; mensaje de lleno al 6/6; eventos/notificaciones si aplican. |
| Señal de problema | Nunca captura; bóveda vacía en servidor tras captura aparente. |
| Archivos probables | `CaptureManager.lua`, `DefenseManager.lua`, `BaseManager.lua`, `MatchManager.lua`, `BrainrotConfig.lua` |

---

## 11. Validación de barrera, breach e infiltración

| Qué hacer | Dejar enemigos golpear barrera hasta 0; observar brecha, infiltración (viaje + robo o daño a núcleo si bóveda vacía). Probar **R** con cells. |
| Qué debería pasar | HP barrera baja; `BRECHA`; `BreachStarted`/`Ended`; tiempos ~`INFILTRATOR_*` en `GameConfig`; repair cierra brecha. |
| Señal de problema | Barrera no recibe daño; breach no arranca; infiltración no ocurre. |
| Archivos probables | `BaseManager.lua`, `BrainrotManager.lua`, `PathFollower.lua`, `GameConfig.lua`, `HUDController.client.lua`, `MatchManager.lua` |

---

## 12. Validación de victoria / derrota

| Qué hacer | **Victoria:** completar las 8 oleadas. **Derrota:** brecha + bóveda vacía hasta destruir núcleo. |
| Qué debería pasar | Logs `[Match] VICTORY` / `[Match] DEFEAT`; `GameOver` al cliente; UI de resultados si está cableada. |
| Señal de problema | Partida infinita; sin `GameOver`; fin incorrecto. |
| Archivos probables | `MatchManager.lua`, `WaveManager.lua`, `BaseManager.lua`, `HUDController.client.lua` |

---

## Cómo interpretar fallos

- **Al abrir Play / primer frame:** suele ser sync, `require`, orden de `Init`, o mapa no listo → revisar `Main`, `MapSetup`, módulos.
- **Durante partida:** suele ser lógica de managers o remotes → revisar el manager del apartado que falla.
- **Solo cliente / HUD:** priorizar `HUDController`, `ClientMain`, `PlacementController`.
