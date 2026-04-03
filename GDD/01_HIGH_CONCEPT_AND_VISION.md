# PROTEGE TU BASE: BRAINROT SIEGE

## Game Design Document v1.0

**Estudio:** Ethos Consultoría Digital
**Plataforma:** Roblox (Luau / Roblox Studio)
**Género:** Tower Defense + Creature Collection + Base Siege
**Jugadores:** 1–4 (Solo / Co-op)
**Target:** Roblox audience 9–18, secondary 18–25
**Monetización:** F2P con Battle Pass, cosméticos y convenience (NO pay-to-win)

---

## 1. HIGH CONCEPT

**PROTEGE TU BASE: BRAINROT SIEGE** es un Tower Defense premium para Roblox donde oleadas de criaturas mutantes llamadas "Brainrots" avanzan por senderos corrompidos hacia tu fortaleza. Tu misión: desplegar trampas y defensas letales a lo largo del camino, derrotar y **capturar** a los Brainrots más valiosos, y almacenarlos en tu **Bóveda Viva** — un núcleo orgánico-tecnológico que genera recursos y prestigio según la rareza de las criaturas que resguardas.

Pero hay un giro: si la barrera de tu base cae, los enemigos **infiltran** tu bóveda y **roban** tus Brainrots capturados, empezando por los más raros. Cada partida es una tensión constante entre la avaricia de capturar criaturas de alto valor y la necesidad de invertir en defensas sólidas.

**Elevator Pitch:**
> "Tower Defense meets Pokémon Vault. Defiende, captura, acumula... pero si tu base cae, te roban todo."

**Comparable Experiences:**
- Tower Defense Simulator (Roblox) × Pet Simulator × Dungeon Defenders
- Con la profundidad de Bloons TD 6 y la colección de Palworld
- Con una identidad visual techno-orgánica única tipo Warframe × Fortnite

**Diferenciadores clave:**
1. **Captura activa**: No solo matas enemigos; los capturas para obtener valor permanente
2. **Robo a la base**: Perder defensas tiene consecuencias reales — pierdes tus criaturas
3. **Bóveda Viva**: Tu colección genera ingresos pasivos y afecta tu gameplay
4. **Progresión dual**: Mejoras tus defensas Y tu colección de criaturas
5. **Tensión estratégica**: ¿Inviertes en captura o en defensa? Cada decisión importa

---

## 2. CORE FANTASY

### La fantasía del jugador

> "Soy el guardián de una fortaleza secreta donde almaceno las criaturas más raras y peligrosas del mundo. Cada oleada es una oportunidad de capturar algo increíble, pero también un riesgo de perderlo todo."

### Por qué es adictivo

**Ciclo de Tensión-Recompensa:**
El jugador experimenta un loop emocional constante:
1. **Anticipación** → "Viene una oleada con un Brainrot Mítico... necesito capturarlo"
2. **Tensión táctica** → "¿Gasto en una trampa de captura o refuerzo la barrera?"
3. **Euforia de captura** → "¡Lo tengo! Un Brainrot Diamante en mi bóveda"
4. **Ansiedad de pérdida** → "La barrera está al 30%... si cae, pierdo mi colección"
5. **Orgullo de colección** → "Tengo 3 Ancestrales, mi bóveda genera más que nadie"

**Hooks psicológicos:**
- **Loss aversion**: Proteger lo que ya tienes es más motivador que ganar algo nuevo
- **Collection drive**: La compulsión de completar sets de rarezas
- **Near-miss excitement**: "Casi capturo un Legendario... la próxima oleada"
- **Social comparison**: "Mi bóveda vale más que la tuya"
- **Escalating stakes**: Cada oleada sube la apuesta porque tienes más que perder

---

## 3. CORE GAMEPLAY LOOP (Moment-to-Moment)

```
┌─────────────────────────────────────────────────────────┐
│                    CORE LOOP (30-60s)                    │
│                                                         │
│  SCOUT ──→ BUILD/UPGRADE ──→ DEFEND ──→ CAPTURE ──→    │
│    ↑                                              │     │
│    └──────────── COLLECT REWARDS ←────────────────┘     │
│                       │                                 │
│              STORE IN VAULT ──→ VAULT GENERATES VALUE   │
│                       │                                 │
│              NEXT WAVE (higher stakes)                  │
└─────────────────────────────────────────────────────────┘
```

### Desglose del loop:

**1. SCOUT (5s)**
- Preview de la próxima oleada: tipos, cantidades, rarezas
- El jugador evalúa amenazas y oportunidades de captura

**2. BUILD / UPGRADE (15-20s entre oleadas)**
- Colocar nuevas defensas en zonas válidas del camino
- Mejorar defensas existentes
- Posicionar módulos de captura estratégicamente
- Reforzar la barrera de la base

**3. DEFEND (20-40s durante oleada)**
- Las defensas atacan automáticamente
- El jugador puede activar habilidades activas de defensas
- Gestión de prioridades: ¿Enfoco fuego en el boss o en la horda?

**4. CAPTURE (durante oleada)**
- Brainrots debilitados pasan por módulos de captura
- Probabilidad basada en: HP restante × rareza × nivel de módulo
- El jugador puede usar "Capture Pulse" (habilidad activa con cooldown)

**5. COLLECT REWARDS (5s post-oleada)**
- Dinero por kills
- Bonus por capturas
- Bonus por oleada perfecta (barrera intacta)
- Brainrots capturados van a la bóveda

**6. VAULT MANAGEMENT (opcional entre oleadas)**
- Ver colección actual
- Los Brainrots en bóveda generan ingresos pasivos
- Reorganizar prioridad de protección

---

## 4. META LOOP (Progresión a mediano y largo plazo)

```
PARTIDA ──→ EXPERIENCIA + MONEDAS ──→ NIVEL DE GUARDIAN
                                            │
                    ┌───────────────────────┼───────────────────────┐
                    ▼                       ▼                       ▼
            TIENDA DE EQUIPO         COLECCIÓN GLOBAL        RANGOS/TÍTULOS
            (nuevas defensas,        (Brainrotdex con        (prestigio social,
             mejoras, módulos)        todas las rarezas)      recompensas)
                    │                       │                       │
                    ▼                       ▼                       ▼
            BUILDS MÁS FUERTES      SETS COMPLETOS =        MODOS AVANZADOS
            OLEADAS MÁS ALTAS       BONUSES PASIVOS         DIFICULTAD ÉLITE
                    │                       │                       │
                    └───────────────────────┼───────────────────────┘
                                            ▼
                                    SEASONS / EVENTS
                                    (nuevos brainrots,
                                     mapas, defensas)
```

### Sistemas de meta-progresión:

**A. Nivel de Guardián (XP global)**
- Sube con cada partida completada
- Desbloquea tiers de la tienda
- Da acceso a mapas más difíciles
- Otorga títulos y cosméticos

**B. Brainrotdex (Colección permanente)**
- Registro de todos los Brainrots capturados alguna vez
- Completar sets de rareza da bonuses permanentes
- Los Brainrots de partida son temporales, pero registran en el Dex
- Incentiva rejugabilidad: "Me falta el Ancestral tipo Tanque"

**C. Tienda de Equipamiento (Progresión de poder)**
- Defensas nuevas, mejoras de módulos, habilidades
- Se desbloquea por nivel + moneda ganada en partidas
- Estructura aspiracional por tiers

**D. Rankings & Seasons**
- Tabla de clasificación por valor de bóveda más alto alcanzado
- Seasons trimestrales con nuevos Brainrots, mapas y Battle Pass
- Eventos limitados con Brainrots exclusivos

---

## 5. GAME PILLARS

### Pilar 1: TENSIÓN ESTRATÉGICA
> Cada decisión tiene un costo de oportunidad real.

- ¿Invierto en daño o en captura?
- ¿Protejo la barrera o maximizo kills para dinero?
- ¿Guardo un Brainrot raro arriesgando que me lo roben, o juego conservador?
- La dificultad escala con tu éxito: cuanto más tienes, más pierdes si fallas

### Pilar 2: CAPTURA & COLECCIÓN
> La captura de Brainrots es tan importante como matarlos.

- Cada criatura capturada tiene valor real en gameplay
- La bóveda es un sistema vivo que genera beneficios
- Completar colecciones da recompensas tangibles
- La rareza importa: un Ancestral vale más que 50 Normales

### Pilar 3: RIESGO & RECOMPENSA
> Perder no es solo "Game Over", es perder cosas que valoras.

- La brecha de la base tiene consecuencias reales
- Los Brainrots robados se pierden de la partida
- El jugador debe balancear avaricia vs. seguridad
- Las oleadas finales son las más lucrativas pero las más peligrosas

### Pilar 4: IDENTIDAD VISUAL PREMIUM
> Este juego debe verse y sentirse como un producto AAA de Roblox.

- Estilo techno-orgánico único
- Cada rareza tiene identidad visual clara e impactante
- UI limpia, moderna, con animaciones satisfactorias
- VFX que comunican información y generan emoción

### Pilar 5: COOPERACIÓN SIGNIFICATIVA
> Jugar con amigos debe ser mejor que jugar solo, no solo más fácil.

- Roles emergentes: uno captura, otro defiende, otro mejora
- Recursos compartidos con decisiones de grupo
- Bóveda compartida = motivación compartida
- Oleadas escaladas para multijugador

### Pilar 6: REJUGABILIDAD INFINITA
> Cada partida debe sentirse diferente.

- Composición aleatoria de oleadas
- Diferentes mapas con layouts únicos
- Builds variados según defensas elegidas
- Sistema de temporadas con contenido nuevo

---

## 6. PLAYER GOALS

### Objetivos Primarios (por partida)
| Objetivo | Descripción |
|----------|-------------|
| Sobrevivir todas las oleadas | Llegar a la oleada final sin perder el núcleo |
| Proteger la bóveda | Mantener la barrera intacta para no perder capturas |
| Capturar Brainrots valiosos | Obtener al menos 1 criatura de alta rareza |
| Maximizar valor de bóveda | Terminar con el mayor valor acumulado posible |

### Objetivos Secundarios (por partida)
| Objetivo | Descripción |
|----------|-------------|
| Oleada perfecta | Completar una oleada sin daño a la barrera |
| Captura perfecta | Capturar todos los Brainrots élite+ de una oleada |
| Eficiencia económica | Terminar con ratio kill/gasto óptimo |
| Sin pérdidas | Terminar sin que ningún Brainrot sea robado |

### Objetivos Meta (largo plazo)
| Objetivo | Descripción |
|----------|-------------|
| Completar Brainrotdex | Capturar al menos 1 de cada tipo y rareza |
| Max Nivel de Guardián | Alcanzar el nivel máximo |
| Desbloquear toda la tienda | Obtener todas las defensas y mejoras |
| Ranking Season | Estar en top 100 de la season |

### Condiciones de Victoria / Fracaso

**Victoria:**
- Sobrevivir la oleada final = Victoria básica
- Sobrevivir con bóveda intacta = Victoria perfecta
- Sobrevivir + capturar boss final = Victoria suprema

**Fracaso:**
- Núcleo de la base destruido = Derrota total (pierdes todo)
- Bóveda vaciada = Derrota parcial (sobrevives pero sin capturas)
- Abandono = Sin recompensas

**Nota:** Incluso en derrota parcial, el jugador conserva XP y moneda ganada por kills. Esto evita frustración total pero mantiene las stakes altas por la pérdida de capturas.
