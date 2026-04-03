# 20. DEVELOPMENT ROADMAP

## Fase 1: PROTOTIPO (Semanas 1-3)

**Objetivo:** Validar el core loop — ¿es divertido colocar defensas, matar brainrots y capturarlos?

| Semana | Entregables |
|--------|------------|
| 1 | Mapa graybox con camino + waypoints. Brainrot cápsula que sigue el path. Sistema de oleadas básico (5 oleadas, 1 clase). |
| 2 | Colocación de 2 defensas (torreta láser + trampa hielo). Sistema de daño. Cells básico. UI placeholder. |
| 3 | Módulo de captura básico. Bóveda visual simple. Barrera con HP. Sistema de brecha. Boss placeholder (mucho HP). |

**Criterio de éxito:** Una partida de 5 oleadas donde puedes colocar defensas, matar brainrots, capturar algunos, y experimentar una brecha si fallas.

---

## Fase 2: VERTICAL SLICE (Semanas 4-6)

**Objetivo:** Una partida completa de 10 oleadas que representa la experiencia final.

| Semana | Entregables |
|--------|------------|
| 4 | 4 clases de Brainrot con comportamiento diferenciado. 5 rarezas funcionando (Normal→Diamante). Balance de oleadas. |
| 5 | 6 defensas (1 por familia) con 2 niveles de mejora. Sistema de venta. Economía balanceada. |
| 6 | UI funcional (HUD, hotbar, preview oleada, resultados). Boss con mecánica simple. Feedback visual (VFX básicos, sonido placeholder). |

**Criterio de éxito:** 10 oleadas jugables de principio a fin con variedad, decisiones significativas, y un resultado satisfactorio.

---

## Fase 3: ALPHA (Semanas 7-10)

**Objetivo:** Juego publicable internamente, con arte dirigido y gameplay pulido.

| Semana | Entregables |
|--------|------------|
| 7 | Arte del mapa (terreno, decoración, iluminación). Modelos de Brainrots estilizados. |
| 8 | Modelos de defensas. VFX de combate (láser, hielo, plasma). Partículas de rareza. |
| 9 | UI skinned (no placeholder). Sonido implementado (música + SFX). Animaciones básicas. |
| 10 | Balance pass. Bug fixing. Performance optimization. Playtest interno. |

**Criterio de éxito:** Build que se puede mostrar a otros. Se ve y se siente como un juego real, no un prototipo.

---

## Fase 4: BETA (Semanas 11-14)

**Objetivo:** Publicación inicial en Roblox para early players.

| Semana | Entregables |
|--------|------------|
| 11 | Co-op (2-4 jugadores). Sync de estado. Balanceo multiplayer. |
| 12 | Persistencia (DataStore): Nivel de Guardián, Cortex, Brainrotdex. Tienda permanente Tier I-II. |
| 13 | Daily challenges. Segundo mapa. Defensas adicionales (2-3). |
| 14 | QA pass. Performance en dispositivos bajos. Anti-exploit básico. Publicación beta. |

**Criterio de éxito:** Juego publicado en Roblox, jugable por el público, con retención medible.

---

## Fase 5: POLISH & LIVE (Semanas 15-20+)

**Objetivo:** Pulir basado en feedback real, expandir contenido.

| Semana | Entregables |
|--------|------------|
| 15-16 | Feedback integration. Balance adjustments. Bug fixes from live. |
| 17-18 | Battle Pass V1. Cosmetic shop. Rarezas Mítico-Legendario. |
| 19-20 | Tercer mapa. Dificultades Élite/Pesadilla. Ranked system. |
| 20+ | Seasonal content pipeline. Community events. Prestige. |

---

# 21. MVP TASK BREAKDOWN

## Epic 1: MAPA & INFRAESTRUCTURA

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 1.1 | Crear mapa graybox con terrain básico | 4h | P0 |
| 1.2 | Diseñar y colocar waypoints del camino (20-25 puntos) | 2h | P0 |
| 1.3 | Crear y marcar 15 zonas de construcción (parts transparentes) | 2h | P0 |
| 1.4 | Construir base placeholder (barrera + bóveda + núcleo) | 3h | P0 |
| 1.5 | Configurar iluminación básica | 1h | P1 |
| 1.6 | Setup de folder structure en Roblox Studio | 1h | P0 |

## Epic 2: SISTEMA DE OLEADAS

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 2.1 | WaveManager: state machine (build→spawn→combat→complete) | 4h | P0 |
| 2.2 | WaveConfig: definir composición de 10 oleadas + boss | 2h | P0 |
| 2.3 | Sistema de spawn: instanciar brainrots con intervalo | 3h | P0 |
| 2.4 | Timer de build phase con UI | 2h | P0 |
| 2.5 | Preview de oleada (UI + datos) | 2h | P1 |
| 2.6 | Boss wave con HP escalado | 2h | P1 |

## Epic 3: BRAINROT AI & PATHFINDING

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 3.1 | PathFollower: movimiento por waypoints con velocidad variable | 3h | P0 |
| 3.2 | Modelo placeholder de Brainrot (cápsula con color de rareza) | 1h | P0 |
| 3.3 | Sistema de HP y muerte | 2h | P0 |
| 3.4 | 4 comportamientos de clase (Swarmer, Tank, Speedster, Shielder) | 4h | P0 |
| 3.5 | 5 rarezas con multiplicadores (Normal→Diamante) | 2h | P0 |
| 3.6 | Habilidad pasiva: escudo del Shielder | 2h | P1 |
| 3.7 | Object pooling para Brainrots | 3h | P1 |

## Epic 4: SISTEMA DE DEFENSAS

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 4.1 | PlacementController: preview fantasma + snap a zonas | 4h | P0 |
| 4.2 | DefenseManager: validation + instanciar en servidor | 3h | P0 |
| 4.3 | Sistema de targeting (closest, highest HP, highest rarity) | 3h | P0 |
| 4.4 | Torreta Láser: beam continuo + daño | 3h | P0 |
| 4.5 | Trampa de Hielo: aura de ralentización | 2h | P0 |
| 4.6 | Trampa de Estasis: freeze single target | 2h | P0 |
| 4.7 | Mina de Proximidad: damage burst on contact | 2h | P1 |
| 4.8 | Amplificador de Rango: buff a defensas cercanas | 2h | P1 |
| 4.9 | Módulo de Captura: lógica de captura (ver Epic 6) | — | — |
| 4.10 | Sistema de mejoras (2 niveles) | 3h | P0 |
| 4.11 | Sistema de venta (50% refund) | 1h | P1 |
| 4.12 | Modelos placeholder de defensas | 2h | P0 |

## Epic 5: SISTEMA DE BASE

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 5.1 | BaseManager: HP de barrera, damage handling | 2h | P0 |
| 5.2 | Visual de barrera (color basado en HP%) | 2h | P0 |
| 5.3 | Sistema de brecha: detección + alarma | 2h | P0 |
| 5.4 | Infiltración: brainrots entran a base y roban | 3h | P0 |
| 5.5 | Robo de bóveda: priorizar por valor | 2h | P0 |
| 5.6 | Reparación de barrera (compra con Cells) | 1h | P0 |
| 5.7 | Núcleo HP + game over si destruido | 1h | P0 |
| 5.8 | Visual de bóveda con pods | 2h | P1 |

## Epic 6: SISTEMA DE CAPTURA

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 6.1 | CaptureManager: detección de brainrots en rango con HP bajo | 3h | P0 |
| 6.2 | Probabilidad de captura por rareza × módulo | 2h | P0 |
| 6.3 | Añadir a bóveda + feedback visual | 2h | P0 |
| 6.4 | Cooldown de módulo de captura | 1h | P0 |

## Epic 7: ECONOMÍA

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 7.1 | EconomyManager: tracking de Cells por jugador | 2h | P0 |
| 7.2 | Recompensas por kill (basada en rareza) | 1h | P0 |
| 7.3 | Recompensas por captura (bonus Cells) | 1h | P0 |
| 7.4 | Ingreso pasivo de bóveda | 2h | P1 |
| 7.5 | Costos de defensas y mejoras (validación server) | 1h | P0 |
| 7.6 | Costo de reparación de barrera | 1h | P0 |

## Epic 8: UI

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 8.1 | HUD: barra superior (oleada, timer, cells) | 3h | P0 |
| 8.2 | Hotbar de defensas (1-6) | 3h | P0 |
| 8.3 | Status bar (barrera HP%, bóveda count) | 2h | P0 |
| 8.4 | Preview de oleada (banner con composición) | 2h | P1 |
| 8.5 | Pantalla de resultados (victoria/derrota) | 3h | P0 |
| 8.6 | Notificación de captura (pop-up con rareza) | 2h | P1 |
| 8.7 | Alerta de brecha (overlay rojo) | 1h | P0 |
| 8.8 | Menú de upgrade/sell al seleccionar defensa | 2h | P0 |
| 8.9 | Tienda in-game (defensas disponibles con costos) | 2h | P1 |

## Epic 9: AUDIO

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 9.1 | Música: build phase, combat phase, boss | 2h | P2 |
| 9.2 | SFX: disparo, muerte, captura, brecha | 2h | P1 |
| 9.3 | AudioManager: crossfade entre estados | 2h | P2 |

## Epic 10: MATCH FLOW

| # | Tarea | Estimación | Prioridad |
|---|-------|-----------|----------|
| 10.1 | MatchManager: orquestar todo el flujo de partida | 4h | P0 |
| 10.2 | Condiciones de victoria/derrota | 1h | P0 |
| 10.3 | Pantalla de inicio / selección de dificultad (simplificada) | 2h | P1 |
| 10.4 | Restart / Volver a jugar | 1h | P1 |

### Resumen de estimación MVP:

| Prioridad | Horas estimadas |
|-----------|----------------|
| P0 (imprescindible) | ~75h |
| P1 (importante) | ~30h |
| P2 (nice to have) | ~6h |
| **Total MVP** | **~111h** |

---

# 22. FIRST PLAYABLE BUILD PLAN

## ¿Qué es el "First Playable"?

El First Playable es la primera build donde alguien puede sentarse, jugar, y experimentar el core loop completo. No tiene arte final, no tiene todas las features, pero **es divertido o al menos informativo sobre si la dirección es correcta.**

## Alcance exacto del First Playable:

### Lo que ESTÁ:
1. **1 mapa graybox** con camino de 20 waypoints y 12 zonas de construcción
2. **5 oleadas** de Brainrots (solo Swarmers y Tanks, solo Normal y Raro)
3. **2 defensas colocables**: Torreta Láser y Trampa de Hielo
4. **Sistema de daño funcional**: defensas dañan/ralentizan brainrots
5. **Barrera con HP**: brainrots que llegan al final la golpean
6. **Brecha básica**: si barrera cae, game over (sin infiltración aún)
7. **Cells**: ganar por kills, gastar en defensas
8. **1 Módulo de Captura**: captura brainrots con HP bajo
9. **Bóveda**: lista visual de brainrots capturados (texto, no 3D)
10. **HUD mínimo**: cells, oleada actual, HP barrera, botones de defensa
11. **Win/Lose**: sobrevivir 5 oleadas = win, barrera destruida = lose

### Lo que NO ESTÁ:
- Arte (todo es cápsulas/cubos con colores)
- Sonido
- Mejoras de defensa
- Rarezas superiores a Raro
- Boss
- Infiltración con robo
- Persistencia
- Co-op
- Tienda permanente
- Cualquier polish

## Orden de implementación:

```
DÍA 1: Setup + Mapa
├── Crear folder structure
├── Mapa graybox (terrain plano + camino con parts)
├── Colocar waypoints (parts numeradas)
└── Crear zonas de construcción (parts transparentes)

DÍA 2: Brainrot Movement
├── BrainrotConfig (stats de Swarmer y Tank)
├── PathFollower module
├── Brainrot spawn básico (instanciar cápsula en waypoint 1)
└── Brainrot se mueve por waypoints hasta el final

DÍA 3: Damage + Barrera
├── Sistema de HP para Brainrots
├── BaseManager con barrera HP
├── Brainrots que llegan al final dañan barrera
├── Muerte de brainrot (desaparece)
└── Game over si barrera = 0

DÍA 4: Defensas
├── PlacementController (preview + click to place)
├── DefenseManager (validación server)
├── Torreta Láser (beam damage continuo)
├── Trampa de Hielo (slow aura)
└── Targeting: enemigo más cercano

DÍA 5: Oleadas + Economía
├── WaveManager (state machine)
├── 5 oleadas con composición definida
├── Build phase timer (15s)
├── EconomyManager (Cells)
├── Gain Cells on kill
└── Spend Cells to place defense

DÍA 6: Captura + Bóveda
├── CaptureManager
├── Módulo de Captura (defensa)
├── Captura de brainrots con HP < 25%
├── Bóveda (tabla de datos + UI simple)
└── Ingreso pasivo básico de bóveda

DÍA 7: UI + Polish Mínimo + Playtest
├── HUD: cells, oleada, barrera HP
├── Hotbar de defensas (2 botones)
├── Pantalla de victoria/derrota
├── Bug fixing
└── PLAYTEST INTERNO
```

## Preguntas que el First Playable debe responder:

1. ¿Es satisfactorio colocar defensas y ver cómo matan brainrots?
2. ¿La tensión de "llegarán a la barrera" funciona?
3. ¿La captura se siente como una decisión interesante vs. solo matar?
4. ¿El ritmo build→combat→reward se siente bien?
5. ¿El loop genera "quiero jugar otra vez"?
6. ¿Las 2 defensas se sienten suficientemente distintas?
7. ¿Los controles de colocación son intuitivos?

Si las respuestas son mayoritariamente SÍ → proceder a Vertical Slice.
Si hay NOs → iterar sobre el core loop antes de añadir contenido.
