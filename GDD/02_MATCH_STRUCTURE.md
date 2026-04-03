# 7. MATCH STRUCTURE

## Estructura de una Partida Completa

**Duración objetivo:** 15–25 minutos (casual) / 30–45 minutos (modo élite)
**Oleadas:** 15 oleadas estándar + 1 Boss Final + 1 Fase de Infiltración posible

---

## FASE 0: LOBBY & LOADOUT (60s)

**Qué ocurre:**
- El jugador (o grupo) selecciona mapa y dificultad
- Elige su loadout de defensas disponibles (máx. 8 slots de tipos de defensa)
- Ve preview del mapa: camino, zonas de construcción, posición de la base
- En co-op: los jugadores ven los loadouts de los demás para coordinar

**Dificultades disponibles:**
| Dificultad | Oleadas | Multiplicador Enemigos | Recompensa | Desbloqueo |
|-----------|---------|----------------------|-----------|------------|
| Normal | 15 + Boss | ×1.0 | ×1.0 | Nivel 1 |
| Difícil | 18 + Boss | ×1.5 | ×1.8 | Nivel 10 |
| Élite | 20 + Boss + Infiltración | ×2.2 | ×3.0 | Nivel 20 |
| Pesadilla | 25 + Boss + Infiltración × 2 | ×3.5 | ×5.0 | Nivel 35 |

---

## FASE 1: PREPARACIÓN INICIAL (45s)

**Qué ocurre:**
- Se revela el mapa completo con el camino iluminado
- El jugador recibe **500 Células** (moneda de partida) iniciales
- Puede colocar defensas iniciales en las zonas válidas
- Se muestra preview de la Oleada 1: tipos y cantidad de enemigos
- La Bóveda aparece vacía, con slots visibles para capturar

**UI activa:**
- Barra de Células (moneda)
- Inventario de defensas (loadout)
- Minimapa con camino
- Preview de oleada
- Indicador de estado de barrera: 100%

**Feedback visual:**
- Las zonas válidas de construcción brillan con un pulso suave cyan
- El camino tiene una energía corrupta oscura fluyendo (anticipación)
- La bóveda pulsa con luz tenue, esperando ser llenada

---

## FASE 2: OLEADAS DE COMBATE (Oleadas 1–15/25)

### Estructura por oleada:

```
PREVIEW (5s) ──→ BUILD PHASE (15-20s) ──→ COMBAT PHASE (20-40s) ──→ REWARDS (5s)
                                                                         │
                                                                    NEXT WAVE
```

### Sub-fase: PREVIEW (5s)
- Banner animado: "OLEADA 3 — 12 Brainrots — Contiene: 1 Élite"
- Iconos de los tipos de enemigos que vienen
- Indicador de rareza máxima en la oleada
- Si viene un Brainrot raro+, destello especial con sonido

### Sub-fase: BUILD PHASE (15-20s entre oleadas)
- Timer visible contando hacia la próxima oleada
- El jugador puede:
  - Colocar nuevas defensas (si tiene Células)
  - Mejorar defensas existentes (3 niveles por defensa)
  - Vender defensas (50% de reembolso)
  - Posicionar/reposicionar módulos de captura
  - Reforzar barrera (costo escalante)
  - Activar skip timer (bonificación de velocidad si está listo antes)
- En co-op: todos construyen simultáneamente, se ven las colocaciones en real-time

### Sub-fase: COMBAT PHASE (20-40s)
- Los Brainrots spawnan al inicio del camino y siguen la ruta
- Las defensas disparan/activan automáticamente
- El jugador puede:
  - Activar habilidades activas de defensas (cooldown)
  - Usar "Capture Pulse" en Brainrots debilitados
  - Reposicionar defensas móviles (si tiene)
  - Activar Barrier Surge (refuerzo temporal de emergencia)
- Los Brainrots que llegan al final del camino **golpean la barrera**
- Brainrots que pasan por módulos de captura con HP bajo = probabilidad de captura

### Sub-fase: REWARDS (5s post-oleada)
- Resumen rápido: kills, dinero ganado, capturas
- Pop-up especial si se capturó algo raro
- Cells ganadas se añaden al total
- Brainrots capturados aparecen en la bóveda con animación

### Escalado por oleada:

| Oleada | Enemigos | Rarezas posibles | Velocidad | Eventos especiales |
|--------|----------|-----------------|-----------|-------------------|
| 1–3 | 8–15 | Normal | Lenta | Tutorial implícito |
| 4–6 | 15–25 | Normal, Raro | Normal | Primera élite posible |
| 7–9 | 20–35 | Normal, Raro, Élite | Normal+ | Mini-boss oleada 9 |
| 10–12 | 30–45 | +Oro, Diamante | Rápida | Oleadas rush, doble camino |
| 13–15 | 40–60 | +Mítico | Muy rápida | Oleadas mixtas, habilidades especiales |
| 16–18 | 50–70 | +Corrupto | Variable | Caminos secretos, sabotaje |
| 19–20 | 60–80 | +Legendario | Extrema | Pre-boss, todo tipo |
| BOSS | 1 + horda | Ancestral (boss) | Variable | Mecánicas de boss |

---

## FASE 3: BOSS WAVE

**Estructura del Boss:**

El boss es un Brainrot Ancestral único por mapa con:
- **3 fases de HP** (cada fase cambia comportamiento)
- **Horda de escolta** (Brainrots menores que lo acompañan)
- **Habilidades de área** (daño a múltiples defensas, debuffs)
- **Resistencia a captura** (solo capturable en fase final con HP < 5%)

**Mecánicas de Boss:**

| Fase | HP% | Comportamiento |
|------|-----|---------------|
| Fase 1 | 100–60% | Avance normal, escudo regenerativo, spawna escoltas |
| Fase 2 | 60–25% | Velocidad aumentada, ataque a defensas cercanas, pulsos de daño |
| Fase 3 | 25–0% | Enrage: velocidad máxima, daño doble a barrera, vulnerable a captura |

**Recompensa de Boss:**
- Kill: ×10 moneda base + item especial
- Captura (extremadamente difícil): Brainrot Ancestral para la bóveda — vale más que toda la colección junta

---

## FASE 4: INFILTRACIÓN (Solo en Élite+ y si la barrera cayó)

**Trigger:** Si en cualquier momento durante la partida la barrera cae a 0%, se activa la Fase de Infiltración.

**Qué ocurre:**
1. **Alarma visual y sonora** — la pantalla se tiñe de rojo, sirenas
2. Los Brainrots que lleguen al final del camino ahora **entran a la base**
3. Dentro de la base, los infiltrados van directo a la bóveda
4. **Roban Brainrots** empezando por los de MAYOR rareza
5. Cada Brainrot robado tiene animación y sonido de pérdida
6. El jugador puede gastar Células para **reparar la barrera** (costo alto)
7. Mientras repara, debe seguir defendiendo el camino

**Mecánica de robo:**
- Cada Brainrot infiltrado tarda 3 segundos en robar 1 criatura
- Priorizan las de mayor valor
- El jugador ve en la bóveda los Brainrots siendo atacados
- Si repara la barrera antes de perder todo, los infiltrados son expulsados

**Tensión máxima:** El jugador está dividido entre gastar en reparar la barrera o en más defensas para la oleada actual.

---

## FASE 5: EXTRACCIÓN / CIERRE

**Si sobrevivió todas las oleadas:**

1. **Pantalla de Victoria** — Animación épica de la bóveda brillando
2. **Resumen de partida:**
   - Oleadas completadas
   - Total de kills
   - Brainrots capturados (con rareza)
   - Valor total de bóveda
   - Dinero ganado
   - XP ganada
   - Bonuses (oleada perfecta, sin daño a barrera, etc.)
3. **Brainrotdex update** — Nuevas entradas registradas
4. **Nivel de Guardián** — Barra de XP sube con animación
5. **Recompensas especiales** si aplica (first clear, achievements)

**Si perdió (núcleo destruido):**
1. Pantalla de derrota con la base colapsando
2. Resumen parcial: conserva XP y moneda por kills
3. Pierde TODOS los Brainrots capturados en esa partida
4. Motivación: "Llegaste a oleada 12. ¿Puedes superar tu récord?"

**Multiplayer adicional:**
- Tabla comparativa entre jugadores co-op
- MVP de la partida (más kills, más capturas, más defensa)
- Bonus co-op por completar juntos

---

## Ritmo Emocional de una Partida

```
EMOCIÓN
  ▲
  │              ╱╲         ╱╲         ╱╲ BOSS
  │    ╱╲      ╱  ╲  ╱╲  ╱  ╲  ╱╲  ╱  ╲╱╲
  │  ╱  ╲    ╱    ╲╱  ╲╱    ╲╱  ╲╱      ╲
  │╱    ╲  ╱                                ╲ INFILTRACIÓN
  │      ╲╱                                  ╲___
  │ PREP                                      RESULTADO
  └──────────────────────────────────────────────────→ TIEMPO
      Oleada 1   Oleada 5   Oleada 10  Oleada 15  Boss  Fin
```

El ritmo alterna entre momentos de calma (build phases) y tensión (combat), con picos crecientes que culminan en el boss y la posible infiltración.
