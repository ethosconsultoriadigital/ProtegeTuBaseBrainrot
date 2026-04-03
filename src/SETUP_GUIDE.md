# PROTEGE TU BASE: BRAINROT SIEGE — Guía de Setup del Prototipo

## 6. DÓNDE VA CADA ARCHIVO EN ROBLOX STUDIO

### ReplicatedStorage/Modules/ (ModuleScripts)
```
GameConfig.lua      → ReplicatedStorage > Modules > GameConfig       (ModuleScript)
BrainrotConfig.lua  → ReplicatedStorage > Modules > BrainrotConfig   (ModuleScript)
DefenseConfig.lua   → ReplicatedStorage > Modules > DefenseConfig    (ModuleScript)
WaveConfig.lua      → ReplicatedStorage > Modules > WaveConfig       (ModuleScript)
EconomyConfig.lua   → ReplicatedStorage > Modules > EconomyConfig    (ModuleScript)
```

### ServerScriptService/ (Scripts y ModuleScripts)
```
Main.server.lua        → ServerScriptService > Main                  (Script)
MapSetup.server.lua    → ServerScriptService > MapSetup              (Script)

Systems/MatchManager.lua   → ServerScriptService > Systems > MatchManager    (ModuleScript)
Systems/WaveManager.lua    → ServerScriptService > Systems > WaveManager     (ModuleScript)
Systems/BrainrotManager.lua → ServerScriptService > Systems > BrainrotManager (ModuleScript)
Systems/DefenseManager.lua → ServerScriptService > Systems > DefenseManager  (ModuleScript)
Systems/BaseManager.lua    → ServerScriptService > Systems > BaseManager     (ModuleScript)
Systems/CaptureManager.lua → ServerScriptService > Systems > CaptureManager  (ModuleScript)
Systems/EconomyManager.lua → ServerScriptService > Systems > EconomyManager  (ModuleScript)

AI/PathFollower.lua        → ServerScriptService > AI > PathFollower         (ModuleScript)
```

### StarterPlayerScripts/ (LocalScripts y ModuleScripts)
```
ClientMain.client.lua → StarterPlayer > StarterPlayerScripts > ClientMain    (LocalScript)

Controllers/PlacementController.lua → StarterPlayerScripts > Controllers > PlacementController (ModuleScript)
Controllers/CameraController.lua    → StarterPlayerScripts > Controllers > CameraController    (ModuleScript)
```

### StarterGui/ (ScreenGui + LocalScript)
```
1. Crear un ScreenGui llamado "GameHUD" dentro de StarterGui
2. Meter HUDController.client.lua dentro de ese ScreenGui como LocalScript

StarterGui > GameHUD (ScreenGui) > HUDController (LocalScript)
```

### IMPORTANTE: Tipos de instancia
- Archivos `.server.lua` → **Script** (server-side)
- Archivos `.client.lua` → **LocalScript** (client-side)
- Archivos `.lua` (sin prefijo) → **ModuleScript**
- Los nombres NO deben incluir la extensión (.lua). Solo el nombre base.

---

## 7. ORDEN EXACTO DE IMPLEMENTACIÓN EN ROBLOX STUDIO

### Paso 1: Crear estructura de carpetas

En Roblox Studio, crea estas carpetas manualmente:

```
ReplicatedStorage/
  └── Modules/              (Folder)

ServerScriptService/
  ├── Systems/              (Folder)
  └── AI/                   (Folder)

StarterPlayer/
  └── StarterPlayerScripts/
      └── Controllers/      (Folder)

StarterGui/
  └── GameHUD               (ScreenGui, ResetOnSpawn = false)
```

### Paso 2: Crear los ModuleScripts de configuración (ReplicatedStorage/Modules/)

Copiar en este orden:
1. `GameConfig` (ModuleScript)
2. `BrainrotConfig` (ModuleScript)
3. `DefenseConfig` (ModuleScript)
4. `WaveConfig` (ModuleScript)
5. `EconomyConfig` (ModuleScript)

### Paso 3: Crear el sistema de IA (ServerScriptService/AI/)

6. `PathFollower` (ModuleScript)

### Paso 4: Crear los sistemas del servidor (ServerScriptService/Systems/)

7. `BrainrotManager` (ModuleScript)
8. `BaseManager` (ModuleScript)
9. `EconomyManager` (ModuleScript)
10. `CaptureManager` (ModuleScript)
11. `DefenseManager` (ModuleScript)
12. `WaveManager` (ModuleScript)
13. `MatchManager` (ModuleScript)

### Paso 5: Crear scripts del servidor

14. `MapSetup` (Script) — en ServerScriptService directamente
15. `Main` (Script) — en ServerScriptService directamente

### Paso 6: Crear controllers del cliente

16. `PlacementController` (ModuleScript) — en StarterPlayerScripts/Controllers/
17. `CameraController` (ModuleScript) — en StarterPlayerScripts/Controllers/

### Paso 7: Crear entry point del cliente

18. `ClientMain` (LocalScript) — en StarterPlayerScripts directamente

### Paso 8: Crear UI

19. `HUDController` (LocalScript) — dentro de StarterGui/GameHUD (ScreenGui)

---

## 8. PASOS EXACTOS PARA PROBARLO EN PLAY SOLO

1. Abrir Roblox Studio
2. Crear un nuevo lugar (Baseplate o vacío)
3. Seguir el orden de implementación arriba (crear carpetas, luego scripts)
4. **IMPORTANTE**: Configurar el ScreenGui "GameHUD":
   - Click derecho en StarterGui → Insert Object → ScreenGui
   - Renombrar a "GameHUD"
   - En propiedades: ResetOnSpawn = **false**
   - Meter el LocalScript "HUDController" dentro
5. Click en **Play** (F5) o **Play Solo** en la pestaña Test
6. El MapSetup generará el mapa automáticamente
7. Después de ~3 segundos, la partida inicia automáticamente
8. Verás en la consola (Output):
   ```
   === PROTEGE TU BASE: BRAINROT SIEGE ===
   [Main] Events creados
   [PathFollower] Cargados 12 waypoints
   [Main] Todos los sistemas inicializados
   [MatchManager] ¡Partida iniciada!
   [WaveManager] Fase de construcción — Oleada 1 en 18s
   ```
9. Usa los controles:
   - **1, 2, 3** — Seleccionar defensa
   - **Click** — Colocar en zona cyan
   - **ESC** — Cancelar colocación
   - **R** — Reparar barrera
   - **F** — Saltar timer de build
   - **WASD** — Mover cámara
   - **Scroll** — Zoom

---

## 9. ERRORES COMUNES Y CÓMO DEPURARLOS

### "Modules is not a valid member of ReplicatedStorage"
**Causa:** Los ModuleScripts no están dentro de una carpeta llamada "Modules" en ReplicatedStorage.
**Fix:** Crear la carpeta "Modules" en ReplicatedStorage y mover los configs ahí.

### "Infinite yield possible on 'Events'"
**Causa:** Los RemoteEvents no se crearon todavía. Main.server.lua los crea al inicio.
**Fix:** Verificar que Main (Script) existe en ServerScriptService y que tiene RunContext = Server (default).

### Los brainrots no se mueven
**Causa:** Los waypoints no están nombrados numéricamente (1, 2, 3...) o no están en Workspace.Map.Path.Waypoints.
**Fix:** Si usas MapSetup.server.lua, esto se genera automáticamente. Si creaste el mapa a mano, verificar nombres.

### No puedo colocar defensas
**Causa 1:** No hay zonas de construcción o están lejos del mouse.
**Fix:** Verificar que Workspace.Map.BuildZones tiene Parts.
**Causa 2:** No tienes suficientes Cells.
**Fix:** Verificar en consola que el Economy se inicializó.

### La cámara no se mueve
**Causa:** El CameraController puede no haber iniciado si falta alguna dependencia.
**Fix:** Verificar en la consola del cliente (View → Output, filtrar Client) que dice "[ClientMain] Cliente listo".

### "attempt to index nil with 'FindFirstChild'"
**Causa:** Alguna estructura del workspace no existe.
**Fix:** Verificar que MapSetup corrió exitosamente (ver consola Server).

### La UI no aparece
**Causa:** El ScreenGui no se llama "GameHUD" o no tiene el HUDController dentro.
**Fix:** Verificar estructura: StarterGui > GameHUD (ScreenGui) > HUDController (LocalScript).
**Causa 2:** ResetOnSpawn está en true y el personaje murió/respawneó.
**Fix:** Poner ResetOnSpawn = false en el ScreenGui.

### Performance baja
**Causa:** Muchos brainrots simultáneos.
**Fix:** En MVP esto no debería pasar con 15-20 brainrots. Si hay lag, verificar que no hay loops infinitos en Output.

---

## 10. QUÉ DEJAR FUERA DEL PROTOTIPO POR AHORA

| Feature | Razón | Cuándo añadirlo |
|---------|-------|----------------|
| Co-op multiplayer | Requiere sync complejo | V2 (Beta) |
| Persistencia (DataStore) | No valida diversión | V2 |
| Mejoras de defensa Nv.2 | Scope del MVP es Nv.1 | Vertical Slice |
| Rarezas Oro+ | 3 rarezas son suficientes para validar | Vertical Slice |
| Más de 3 defensas | 3 cubren DPS/Slow/Capture | Vertical Slice |
| Boss multi-fase | MVP tiene boss simplificado (mucho HP) | Alpha |
| Tienda persistente | No hay persistencia aún | V2 |
| Battle Pass | Post-launch | V3 |
| Cosméticos | Post-launch | V3 |
| Audio/Música | No afecta gameplay core | Alpha |
| VFX elaborados | Parts con color bastan para MVP | Alpha |
| Daily challenges | Post-persistencia | V2 |
| Ranked/Leaderboards | Post-persistencia | V3 |
| Segundo mapa | 1 mapa basta para validar | Beta |
| Habilidades activas | Complejidad innecesaria en MVP | Vertical Slice |
| Anti-exploit | No hay multijugador aún | Beta |
| Modelos 3D detallados | Parts geométricas bastan | Alpha |
| Animaciones de brainrots | Movimiento por CFrame basta | Alpha |
| Ingreso pasivo de bóveda | Incluido pero puede simplificarse | Ya incluido |
| Sistema de venta de defensas | Ya incluido básicamente | Ya incluido |
