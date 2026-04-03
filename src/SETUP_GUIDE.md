# PROTEGE TU BASE: BRAINROT SIEGE — Setup Guide

## 7. BUILD ORDER (orden exacto para pegar en Studio)

### Paso 1: Crear lugar nuevo
- Abrir Roblox Studio → New → Baseplate (o vacío)
- Borrar la Baseplate si existe (el mapa se autogenera)

### Paso 2: Crear carpetas

```
ReplicatedStorage/
  └── Modules/                    (Folder)

ServerScriptService/
  ├── Systems/                    (Folder)
  └── AI/                         (Folder)

StarterPlayer/
  └── StarterPlayerScripts/
      └── Controllers/            (Folder)

StarterGui/
  └── GameHUD                     (ScreenGui → ResetOnSpawn = false)
```

### Paso 3: Pegar scripts en este orden

**Config modules (ReplicatedStorage/Modules/):**
1. `GameConfig` — ModuleScript
2. `BrainrotConfig` — ModuleScript
3. `DefenseConfig` — ModuleScript
4. `WaveConfig` — ModuleScript
5. `EconomyConfig` — ModuleScript

**AI (ServerScriptService/AI/):**
6. `PathFollower` — ModuleScript

**Server Systems (ServerScriptService/Systems/):**
7. `BrainrotManager` — ModuleScript
8. `DefenseManager` — ModuleScript
9. `BaseManager` — ModuleScript
10. `CaptureManager` — ModuleScript
11. `EconomyManager` — ModuleScript
12. `WaveManager` — ModuleScript
13. `MatchManager` — ModuleScript

**Server entry points (ServerScriptService/):**
14. `MapSetup` — Script
15. `Main` — Script

**Client controllers (StarterPlayerScripts/Controllers/):**
16. `PlacementController` — ModuleScript
17. `CameraController` — ModuleScript

**Client entry point (StarterPlayerScripts/):**
18. `ClientMain` — LocalScript

**UI (StarterGui/GameHUD/):**
19. `HUDController` — LocalScript (dentro del ScreenGui GameHUD)

### TIPOS DE INSTANCIA
- `.server.lua` → **Script**
- `.client.lua` → **LocalScript**
- `.lua` (sin prefijo) → **ModuleScript**
- Nombres SIN extensión (solo el nombre base)

---

## 8. PLAY SOLO TEST PLAN

1. Click **Play** (F5) o **Play Solo**
2. Verificar en Output (View → Output):
   ```
   === PROTEGE TU BASE: BRAINROT SIEGE ===
   [Main] Remotes creados
   [MapSetup] Mapa generado: 12 wp, 10 zones, base completa
   [PathFollower] 12 waypoints cargados
   [Main] Sistemas inicializados
   [Match] Partida iniciada!
   [Wave] Build phase - Oleada 1
   ```
3. Verás un mapa nocturno con:
   - Camino púrpura en forma de S
   - 10 zonas cyan para construir
   - Barrera azul brillante al final
   - Core blanco brillando
4. Controles:
   - **1** → Torreta Láser ($100)
   - **2** → Trampa de Hielo ($80)
   - **3** → Módulo de Captura ($150)
   - **Click** → Colocar en zona cyan
   - **ESC** → Cancelar colocación
   - **R** → Reparar barrera
   - **F** → Saltar timer de build
   - **WASD** → Mover cámara
   - **Scroll** → Zoom

5. Flujo de prueba:
   - Oleada 1: colocar 2-3 torretas láser, ver Runners morir
   - Oleada 3: aparecen Thiefs, colocar ice trap para frenarlos
   - Oleada 4: aparecen Gold, colocar módulo de captura
   - Dejar que alguno llegue a la barrera → ver daño
   - Si barrera cae → brecha, overlay rojo, robo de capturas
   - Presionar R → reparar barrera
   - Oleada 8: Boss (Tank Diamond x5 HP)
   - Sobrevivir → pantalla VICTORIA

---

## 9. DEBUG CHECKLIST

### "Modules is not a valid member of ReplicatedStorage"
→ Crear carpeta "Modules" en ReplicatedStorage y mover los 5 configs ahí.

### "Infinite yield possible on 'Events'"
→ Main.server.lua crea los Events al inicio. Verificar que Main existe como Script en ServerScriptService.

### Brainrots no se mueven
→ Verificar que MapSetup corrió (ver consola). Waypoints deben estar en Workspace.Map.Path.Waypoints como Parts nombradas 1, 2, 3...

### No puedo colocar defensas
→ Verificar BuildZones existen (Map.BuildZones con Parts).
→ Verificar que tienes suficientes Cells (500 inicial).
→ La zona se ilumina cyan al acercar el mouse.

### Cámara no funciona
→ Verificar que ClientMain es LocalScript en StarterPlayerScripts.
→ Verificar que CameraController existe en Controllers/.

### UI no aparece
→ ScreenGui debe llamarse "GameHUD", tener ResetOnSpawn = false.
→ HUDController debe ser LocalScript DENTRO del ScreenGui.

### "attempt to index nil"
→ Alguna estructura del workspace no existe. Verificar que MapSetup corrió sin errores en la consola Server.

### Beam del láser no aparece
→ Es normal que sea invisible a distancia. Acercar zoom con scroll.

---

## 10. OUT OF SCOPE

| Feature | Cuándo |
|---------|--------|
| Co-op multiplayer | V2 |
| Persistencia (DataStore) | V2 |
| Mejoras de defensa Nv.2 | Vertical Slice |
| Más rarezas (Mythic, Legendary) | Vertical Slice |
| Más defensas | Vertical Slice |
| Boss multi-fase | Alpha |
| Audio/Música | Alpha |
| VFX elaborados | Alpha |
| Modelos 3D estilizados | Alpha |
| Tienda persistente | V2 |
| Battle Pass | V3 |
| Cosméticos | V3 |
| Daily challenges | V2 |
| Ranked/Leaderboards | V3 |
| Anti-exploit | Beta |
| Segundo mapa | Beta |
