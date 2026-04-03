# SEGUNDA PARTE: TECHNICAL PRODUCTION

## Modo: Roblox Senior Technical Producer + Luau Engineer

---

## A. MVP TÉCNICO EXACTO

### Definición del MVP técnico más inteligente

El MVP técnico más eficiente no construye "todo un poquito" — construye **el core loop completo con profundidad mínima**. Esto significa:

**El MVP técnico es una partida de 10 oleadas solo-player en 1 mapa donde:**

1. Brainrots de 4 clases y 5 rarezas siguen un camino por waypoints
2. El jugador coloca 6 tipos de defensas en zonas predefinidas
3. Las defensas atacan/ralentizan/capturan automáticamente
4. La barrera recibe daño de brainrots que llegan al final
5. Si la barrera cae, hay infiltración y robo de bóveda
6. El jugador gana Cells por kills/capturas y gasta en defensas/mejoras
7. Hay un boss en la oleada final
8. Victoria/derrota con pantalla de resultados
9. Toda la lógica es server-authoritative
10. UI funcional (no bonita, funcional)

### Lo que NO entra en el MVP técnico:
- Co-op (requiere networking complejo)
- Persistencia/DataStore (agrega complejidad sin validar fun)
- Battle Pass / Shop permanente
- Más de 1 mapa
- Cosmetic system
- Daily challenges
- Ranked / Leaderboards

### Razón: El MVP técnico valida **diversión** y **viabilidad de performance** antes de invertir en sistemas meta.

---

## B. LISTA DE SISTEMAS A PROGRAMAR (Ordenados por prioridad)

### Prioridad 1: FUNDACIÓN (Sin estos no hay juego)

| # | Sistema | Dependencias | Complejidad |
|---|---------|-------------|-------------|
| 1 | **Path System** | Waypoints en mapa | Baja |
| 2 | **Brainrot Spawning & Movement** | Path System | Media |
| 3 | **Defense Placement** | Build zones en mapa | Media-Alta |
| 4 | **Defense Targeting & Damage** | Brainrots, Defensas | Media |
| 5 | **Barrier & Game Over** | Brainrot arrival | Baja |
| 6 | **Economy (Cells)** | Kill tracking | Baja |
| 7 | **Wave State Machine** | Spawn, Economy | Media |

### Prioridad 2: DIFERENCIACIÓN (Lo que hace este juego único)

| # | Sistema | Dependencias | Complejidad |
|---|---------|-------------|-------------|
| 8 | **Capture System** | Brainrot HP, módulo de captura | Media |
| 9 | **Vault Management** | Capture System | Baja |
| 10 | **Breach & Infiltration** | Barrier, Vault | Media |
| 11 | **Rarity System** | Brainrot configs | Baja |
| 12 | **Class Behaviors** | Brainrot AI | Media |

### Prioridad 3: COMPLETITUD (Para que sea una partida completa)

| # | Sistema | Dependencias | Complejidad |
|---|---------|-------------|-------------|
| 13 | **Defense Upgrades** | Defense System | Baja |
| 14 | **Boss AI** | Brainrot System | Media |
| 15 | **Match Manager** | Wave System, Win/Lose | Media |
| 16 | **UI - HUD** | Economy, Waves, Barrier | Media |
| 17 | **UI - Placement** | Defense System | Media |
| 18 | **UI - Results** | Match Manager | Baja |

### Prioridad 4: POLISH

| # | Sistema | Dependencias | Complejidad |
|---|---------|-------------|-------------|
| 19 | **VFX Manager** | All combat systems | Media |
| 20 | **Audio Manager** | Wave states | Baja |
| 21 | **Object Pooling** | Brainrot System | Media |
| 22 | **Performance Optimization** | Todo | Variable |

---

## C. SCRIPTS Y MÓDULOS NECESARIOS

### Módulos de Configuración (ReplicatedStorage/Modules/Config/)

| Archivo | Responsabilidad |
|---------|----------------|
| `GameConfig.lua` | Constantes globales: cells iniciales, HP barrera por dificultad, max defensas, max bóveda, timers de build phase |
| `BrainrotConfig.lua` | Tabla de stats por clase × rareza: HP, velocidad, daño a barrera, resistencia, reward, capture rate |
| `DefenseConfig.lua` | Tabla de stats por defensa × nivel: costo, daño, rango, cooldown, efectos especiales |
| `WaveConfig.lua` | Composición de cada oleada: cantidad, clases, rarezas, intervalo de spawn, eventos especiales |
| `RarityConfig.lua` | Colores, multiplicadores, nombres, efectos visuales por rareza |
| `EconomyConfig.lua` | Rewards por kill/captura, costos de reparación, rates de ingreso pasivo |

### Scripts de Servidor (ServerScriptService/)

| Archivo | Responsabilidad |
|---------|----------------|
| `Main.server.lua` | Entry point. Inicializa todos los managers en orden. Conecta RemoteEvents. |
| `Systems/MatchManager.lua` | Orquesta el flujo completo: lobby→prep→oleadas→boss→resultado. State machine principal. |
| `Systems/WaveManager.lua` | Genera oleadas según config. Controla spawning. Detecta oleada completada. Escala dificultad. |
| `Systems/BrainrotManager.lua` | Pool de brainrots. Spawn/despawn. Update de posición (Heartbeat). Tracking de todos los brainrots activos. |
| `Systems/DefenseManager.lua` | Validación de placement. Creación de instancias. Targeting loop. Cálculo de daño. Mejoras y venta. |
| `Systems/BaseManager.lua` | HP de barrera. Detección de brecha. Lógica de infiltración. HP de núcleo. Reparación. |
| `Systems/CaptureManager.lua` | Detección de brainrots en rango de captura. Roll de probabilidad. Transferencia a bóveda. |
| `Systems/EconomyManager.lua` | Tracking de Cells per player. Reward on kill. Reward on capture. Passive income. Cost validation. |
| `Systems/PlayerManager.lua` | Gestión de jugadores conectados. Loadout. Estado por jugador. |
| `AI/PathFollower.lua` | Módulo que mueve un brainrot por waypoints. Maneja velocidad, slow effects, dirección. |
| `AI/BrainrotBehaviors.lua` | Comportamientos específicos por clase: Shielder genera escudo, Speedster sprint, etc. |
| `AI/BossAI.lua` | IA del boss: fases, spawning de adds, habilidades. |

### Scripts de Cliente (StarterPlayerScripts/)

| Archivo | Responsabilidad |
|---------|----------------|
| `ClientMain.client.lua` | Entry point cliente. Conecta eventos. Inicializa controllers. |
| `Controllers/InputController.lua` | Detecta clicks, hotkeys (1-6 para defensas, Q-R para habilidades). |
| `Controllers/PlacementController.lua` | Muestra preview fantasma de defensa al seleccionar. Highlight de zonas válidas. Snap. Envía request al server. |
| `Controllers/CameraController.lua` | Cámara top-down/isométrica con zoom y pan. |
| `Controllers/SelectionController.lua` | Al clickear defensa existente: muestra opciones upgrade/sell. |
| `Visual/BrainrotVisual.lua` | Escucha eventos de spawn/move/die y actualiza visuales. Partículas de rareza. |
| `Visual/DefenseVisual.lua` | Animaciones de disparo, beam, etc. |
| `Visual/VFXManager.lua` | Pool de partículas. Explosiones, capturas, impactos. |
| `Audio/AudioManager.lua` | Reproduce música por estado. SFX por evento. |

### Scripts de UI (StarterGui/)

| Archivo | Responsabilidad |
|---------|----------------|
| `UIControllers/HUDController.client.lua` | Actualiza top bar (oleada, timer, cells), status bar (barrera, bóveda). |
| `UIControllers/ShopController.client.lua` | Tienda in-game: lista de defensas comprables con costos. |
| `UIControllers/VaultController.client.lua` | Vista de bóveda: lista de brainrots capturados con rareza. |
| `UIControllers/NotifController.client.lua` | Pop-ups: captura, brecha, robo, oleada completada. |

### Total de archivos: ~30 archivos Luau

---

## D. RIESGOS TÉCNICOS

### Riesgo 1: PERFORMANCE DE BRAINROTS
- **Problema:** 60+ brainrots moviéndose simultáneamente en oleadas altas puede causar lag
- **Probabilidad:** Alta
- **Impacto:** Alto (el juego se vuelve injugable)
- **Mitigación:**
  1. Object pooling obligatorio — nunca Instance.new() durante combat
  2. Mover brainrots con CFrame en Heartbeat, NO con TweenService (más control)
  3. Reducir propiedades replicadas: solo Position y HP se replican
  4. Client-side interpolation: el server envía posiciones cada 0.1s, el client interpola suavemente
  5. LOD: brainrots lejanos a la cámara usan mesh más simple
  6. Limitar partículas activas simultáneas (pool de 50 max)

### Riesgo 2: REPLICACIÓN EN CO-OP
- **Problema:** Sincronizar estado de 60 brainrots + 30 defensas + base para 4 jugadores
- **Probabilidad:** Alta (cuando se implemente co-op)
- **Impacto:** Alto
- **Mitigación:**
  1. Server-authoritative: clientes solo ven, no deciden
  2. Batch updates: enviar estado cada 0.2s en lote, no por cada cambio
  3. Delta compression: solo enviar lo que cambió
  4. Prioritized replication: brainrots cerca de la cámara del jugador se actualizan más frecuentemente
  5. Postponer co-op hasta que el single-player sea sólido

### Riesgo 3: EXPLOITS / CHEAT
- **Problema:** Jugadores modificando Cells, colocando defensas gratis, capturando sin módulo
- **Probabilidad:** Certeza (Roblox tiene muchos exploiters)
- **Impacto:** Medio (single player no importa tanto, co-op sí)
- **Mitigación:**
  1. TODA lógica de gameplay en servidor — el cliente NUNCA modifica estado
  2. Validar CADA RemoteEvent: ¿tiene cells? ¿la zona es válida? ¿no está ocupada?
  3. Rate limiting en RemoteEvents (máx 10 requests/segundo por jugador)
  4. Sanity checks: si un jugador tiene más Cells de lo posible, flag
  5. No confiar en NADA que venga del cliente excepto intención (qué quiere hacer, no resultado)

### Riesgo 4: DATASTORE LIMITS
- **Problema:** Roblox DataStore tiene límites de requests (60 + 10×players por minuto)
- **Probabilidad:** Media (cuando se implemente persistencia)
- **Impacto:** Medio (pérdida de progreso)
- **Mitigación:**
  1. Save solo al final de partida, no durante
  2. Cache en memoria, flush periodically
  3. Usar UpdateAsync, no SetAsync (atomic)
  4. Retry con backoff exponencial
  5. Session locking para evitar duplication

### Riesgo 5: SCOPE CREEP
- **Problema:** Agregar features antes de validar el core loop
- **Probabilidad:** Muy alta
- **Impacto:** Muy alto (nunca se lanza)
- **Mitigación:**
  1. First Playable en 7 días con scope fijo
  2. No empezar co-op hasta que single-player funcione
  3. No empezar persistencia hasta que el gameplay sea divertido
  4. Playtest cada semana — si no es divertido, iterar antes de agregar

---

## E. ESTRATEGIA DE IMPLEMENTACIÓN CON IA (Claude)

### Cómo construiría este juego paso a paso:

#### Paso 1: Configuración base
> "Claude, crea los archivos de configuración (GameConfig, BrainrotConfig, DefenseConfig, WaveConfig, RarityConfig, EconomyConfig) con todos los valores numéricos del GDD. Solo datos, sin lógica."

**Output:** 6 módulos Luau con tablas de datos listas para consumir.

#### Paso 2: Path System
> "Claude, crea el módulo PathFollower.lua que lea waypoints de Workspace.Map.Path.Waypoints (parts numeradas) y mueva un modelo por ellos a velocidad configurable. Incluye soporte para efectos de slow."

**Output:** PathFollower module funcional y testeado.

#### Paso 3: Brainrot System
> "Claude, crea BrainrotManager.lua que use object pooling para spawnar brainrots. Cada brainrot usa PathFollower para moverse. Al llegar al último waypoint, llama un callback. Soporta HP, daño, y muerte."

**Output:** BrainrotManager con spawn, move, damage, die.

#### Paso 4: Defense System
> "Claude, crea DefenseManager.lua con sistema de placement validado por servidor. Crea la Torreta Láser (beam damage continuo al enemigo más cercano) y la Trampa de Hielo (aura slow). Incluye PlacementController.lua para el cliente con preview fantasma."

**Output:** 2 defensas funcionales con placement.

#### Paso 5: Wave System
> "Claude, crea WaveManager.lua con state machine (BUILD→SPAWN→COMBAT→COMPLETE). Lee composiciones de WaveConfig. Spawn brainrots con intervalos. Detecta oleada completada cuando todos los brainrots mueren o escapan."

**Output:** Oleadas jugables con transiciones.

#### Paso 6: Base System
> "Claude, crea BaseManager.lua. La barrera tiene HP y recibe daño de brainrots que llegan al final. Visual: cambia color. Si llega a 0: activa brecha. Implementa infiltración básica y robo de bóveda."

**Output:** Barrera funcional con brecha.

#### Paso 7: Capture System
> "Claude, crea CaptureManager.lua. El módulo de captura (defensa) detecta brainrots en rango con HP bajo. Hace roll de probabilidad basado en rareza. Si captura: remueve brainrot del campo y añade a la bóveda."

**Output:** Captura funcional.

#### Paso 8: Economy
> "Claude, crea EconomyManager.lua. Tracking de Cells por jugador. Rewards on kill. Rewards on capture. Costos de defensas validados server-side. Ingreso pasivo de bóveda."

**Output:** Economía funcional.

#### Paso 9: Match Manager
> "Claude, crea MatchManager.lua que orqueste todo: inicia partida → prep → loop de oleadas → boss → resultado. Condiciones de victoria/derrota. Pantalla de resultados con stats."

**Output:** Partida jugable de principio a fin.

#### Paso 10: UI
> "Claude, crea el HUD con: barra superior (oleada, timer, cells), barra inferior (hotbar de defensas), status (barrera, bóveda). Crea pantalla de resultados y notificaciones de captura/brecha."

**Output:** UI funcional completa.

#### Paso 11: Remaining defenses
> "Claude, implementa las 4 defensas restantes: Trampa de Estasis (freeze), Mina de Proximidad (burst), Amplificador de Rango (buff), Módulo de Captura. Con sus niveles de mejora."

**Output:** 6/6 defensas funcionales.

#### Paso 12: Polish & VFX
> "Claude, implementa VFXManager con partículas para: disparo láser, impacto plasma, freeze, muerte por rareza, captura. Implementa AudioManager básico."

**Output:** Feedback visual y sonoro.

### Filosofía de implementación:

1. **Cada paso es testeado antes de avanzar** — no construir sobre código roto
2. **Server-first** — toda lógica va al servidor primero, visuals después
3. **Configs separados de lógica** — cambiar un número no requiere tocar código
4. **Módulos pequeños y desacoplados** — cada sistema es independiente
5. **RemoteEvents tipados** — documentar qué datos envía cada evento
6. **No optimizar prematuramente** — hacer funcionar, luego hacer rápido
