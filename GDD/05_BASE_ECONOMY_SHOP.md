# 10. BASE DEFENSE & BREACH SYSTEM

## La Base: Anatomía

La base del jugador se compone de 3 capas concéntricas:

```
        ┌─────────────────────────────┐
        │        ZONA EXTERIOR        │  ← Últimas zonas de construcción
        │    ┌───────────────────┐    │
        │    │    BARRERA        │    │  ← Campo de energía (HP pool)
        │    │   ┌───────────┐  │    │
        │    │   │  BÓVEDA   │  │    │  ← Donde están tus Brainrots
        │    │   │  ┌─────┐  │  │    │
        │    │   │  │NÚCLEO│  │  │    │  ← Core vital
        │    │   │  └─────┘  │  │    │
        │    │   └───────────┘  │    │
        │    └───────────────────┘    │
        └─────────────────────────────┘
```

### Capa 1: ZONA EXTERIOR
- Las últimas 4-5 zonas de construcción antes de la base
- Aquí el jugador coloca sus defensas de último recurso
- Zona premium para Reparadores de Barrera y Módulos de Captura

### Capa 2: BARRERA (Campo de Energía)
- **HP Base:** 1000 (Normal) / 750 (Difícil) / 500 (Élite) / 300 (Pesadilla)
- **Visual:** Campo de energía hexagonal semi-transparente que rodea la bóveda
- **Feedback:** Cambia de color según HP: Cyan (100-60%) → Amarillo (60-30%) → Rojo pulsante (30-0%)
- **Regeneración:** 0 natural (solo con Reparadores de Barrera o compra directa)
- **Costo de reparación manual:** 50 Cells por 5% de barrera (escalante: +10 Cells por cada compra)

### Capa 3: BÓVEDA (Vault)
- Espacio visual donde se muestran los Brainrots capturados
- Cada Brainrot ocupa un "containment pod" visible
- Pods organizados por rareza (los más raros en el centro)
- Visual: Cápsulas tech-orgánicas con la criatura dentro, brillando según rareza
- **Capacidad:** 15 Brainrots (ampliable a 20 con mejora de tienda)

### Capa 4: NÚCLEO
- **HP:** 500 (fijo en todas las dificultades)
- **Función:** Si el núcleo es destruido = Game Over total
- **El núcleo solo es atacable si la barrera cayó Y la bóveda fue vaciada**
- **Visual:** Esfera de energía pulsante en el centro de la base

---

## Sistema de Brecha (Breach)

### Flujo de una brecha:

```
Barrera cae a 0%
      │
      ▼
ALERTA: "¡BRECHA EN LA BASE!" (visual + sonora)
      │
      ▼
Brainrots que llegan al final del camino ENTRAN a la base
      │
      ▼
Infiltrados corren hacia la bóveda (5 segundos de travel)
      │
      ▼
Cada infiltrado ROBA 1 Brainrot (el de mayor valor primero)
      │
      ▼
El Brainrot robado desaparece de la bóveda con animación
      │
      ▼
Si bóveda queda vacía → Infiltrados atacan el NÚCLEO
      │
      ▼
Núcleo a 0% = GAME OVER
```

### Mecánicas de infiltración:

| Aspecto | Detalle |
|---------|---------|
| Velocidad infiltrado | ×0.7 de su velocidad original (van cargando) |
| Tiempo de robo | 3 segundos por Brainrot |
| Prioridad de robo | Mayor valor primero (Ancestral → Legendario → ... → Normal) |
| Defensa interna | El jugador NO puede colocar defensas dentro de la base |
| Contramedida | Reparar barrera (los infiltrados dentro son expulsados al restaurar barrera) |
| Costo de reparación de emergencia | 200 Cells = restaura barrera a 10% |

### Feedback visual durante brecha:

1. **Pantalla:** Bordes rojos pulsantes, efecto de alarma
2. **Sonido:** Sirena de brecha, heartbeat sound acelerándose
3. **Bóveda:** Los pods de los Brainrots en peligro parpadean
4. **Minimap:** Iconos rojos mostrando infiltrados dentro de la base
5. **UI:** Counter: "BRAINROTS EN PELIGRO: 8/12"

### Estrategia anti-brecha:

Los jugadores experimentados harán lo siguiente:
- Mantener Reparadores de Barrera en las zonas cercanas a la base
- Guardar Cells de emergencia para reparación express
- No sobre-invertir en capturas si la barrera está baja
- En co-op: designar 1 jugador como "guardián de barrera"

---

# 11. ECONOMY DESIGN

## Monedas del Juego

### Moneda de Partida: CELLS (Células)
- **Obtención:** Kills, capturas, generadores, bonuses de oleada
- **Uso:** Comprar/mejorar defensas, reparar barrera, dentro de una partida
- **Persistencia:** Solo existe DENTRO de una partida. Se resetea al empezar otra
- **Balance:** El jugador debe tomar decisiones sobre cómo gastar

### Moneda Persistente: CORTEX (Córtex)
- **Obtención:** Recompensa al final de partida (basada en rendimiento)
- **Uso:** Comprar items permanentes en la Tienda de Equipamiento
- **Persistencia:** Permanente, se acumula entre partidas
- **Ritmo:** Suficiente para comprar 1 item menor cada 2-3 partidas, 1 item mayor cada 8-10

### Moneda Premium: SYNAPSE (Sinapsis)
- **Obtención:** Compra con Robux, Battle Pass, logros especiales
- **Uso:** Cosméticos, Battle Pass, aceleradores de XP (NO poder directo)
- **Política:** Jamás compra poder directo. Solo cosméticos y conveniencia

---

## Recompensas por Kill (Cells - dentro de partida)

| Rareza del Brainrot | Cells por Kill | Bonus por Kill Eficiente* |
|---------------------|---------------|--------------------------|
| Normal | 10 | +3 |
| Raro | 25 | +8 |
| Élite | 60 | +20 |
| Oro | 150 | +50 |
| Diamante | 350 | +120 |
| Mítico | 800 | +250 |
| Corrupto | 600 | +200 |
| Legendario | 2,000 | +600 |
| Ancestral (Boss) | 5,000 | +1,500 |

*Kill Eficiente = matar antes de que llegue al 50% del camino

## Recompensas por Captura (Cells + Cortex)

| Rareza Capturada | Cells Bonus | Cortex Bonus | Valor Bóveda |
|-----------------|------------|-------------|-------------|
| Normal | +5 | +1 | 5 pts |
| Raro | +15 | +3 | 15 pts |
| Élite | +40 | +8 | 40 pts |
| Oro | +100 | +20 | 100 pts |
| Diamante | +250 | +50 | 250 pts |
| Mítico | +500 | +100 | 600 pts |
| Corrupto | +400 | +80 | 500 pts |
| Legendario | +1,500 | +300 | 1,500 pts |
| Ancestral | +5,000 | +1,000 | 5,000 pts |

## Ingresos Pasivos (Bóveda)

Los Brainrots en la bóveda generan Cells cada 10 segundos:

| Rareza en Bóveda | Cells/10s |
|-----------------|-----------|
| Normal | +1 |
| Raro | +2 |
| Élite | +5 |
| Oro | +10 |
| Diamante | +20 |
| Mítico | +40 |
| Corrupto | +30 |
| Legendario | +80 |
| Ancestral | +200 |

**Set Bonus:** Tener 3+ del mismo tipo de Brainrot da +50% ingreso pasivo para esos.

## Recompensas al Final de Partida (Cortex)

| Condición | Cortex |
|-----------|--------|
| Base: completar partida | 50 |
| Bonus por oleada completada | +5 por oleada |
| Bonus oleada perfecta | +10 por oleada sin daño a barrera |
| Bonus por valor de bóveda | +1 por cada 100 pts en bóveda |
| Bonus victoria perfecta | +100 (sin brecha) |
| Bonus captura de boss | +500 |
| Bonus dificultad | ×1.0 / ×1.5 / ×2.5 / ×4.0 |

**Ejemplo:** Partida Normal, 15 oleadas, 5 perfectas, bóveda 800pts, sin brecha:
- Base: 50 + Oleadas: 75 + Perfectas: 50 + Bóveda: 8 + Victoria Perfecta: 100 = **283 Cortex**

## Costos y Ritmo de Escalado

### Defensas (Cells - en partida):

| Tier | Rango de costo | Disponible desde |
|------|---------------|-----------------|
| Starter | 60-150 Cells | Oleada 1 |
| Mid | 200-400 Cells | Oleada 5 |
| Advanced | 400-800 Cells | Oleada 10 |
| Ultimate | 800+ Cells | Oleada 15 |

### Ingreso estimado por oleada:

| Oleada | Cells ganadas (aprox.) | Cells acumuladas |
|--------|----------------------|-----------------|
| 1 | 100-150 | 600-650 |
| 5 | 200-350 | 1,500-2,000 |
| 10 | 500-800 | 4,000-5,500 |
| 15 | 800-1,500 | 8,000-12,000 |
| 20 | 1,500-3,000 | 15,000-22,000 |
| Boss | 5,000-8,000 | 20,000-30,000 |

### Curva de gasto ideal:
- Oleadas 1-3: Defensas starter, setup básico
- Oleadas 4-7: Primera mejora, primer módulo de captura
- Oleadas 8-12: Defensas mid-tier, segundo módulo de captura, primer generador
- Oleadas 13-17: Defensas avanzadas, mejoras a Nv.3
- Oleadas 18+: Ultimate defenses, reparadores de barrera

---

# 12. EQUIPMENT SHOP PROGRESSION

## Estructura de la Tienda

La tienda usa **Cortex** (moneda persistente) y se organiza en **6 Categorías** con **4 Tiers** cada una.

### Visualización:
La tienda se presenta como un **laboratorio de investigación** donde cada categoría es una estación de trabajo. Los items bloqueados aparecen como hologramas tenues. Los desbloqueados brillan con energía activa.

---

### CATEGORÍA 1: ARSENAL (Defensas de combate)

| Tier | Item | Costo | Req. Nivel | Efecto |
|------|------|-------|-----------|--------|
| I | Cañón de Plasma | 200 Cortex | 3 | Desbloquea defensa en loadout |
| I | Mina de Proximidad | 150 Cortex | 2 | Desbloquea defensa |
| II | Railgun Prismático | 500 Cortex | 12 | Desbloquea defensa |
| II | Torreta de Misiles | 400 Cortex | 9 | Desbloquea defensa |
| III | Orbital Strike Beacon | 1,000 Cortex | 20 | Desbloquea defensa |
| III | Mejora Universal Daño | 800 Cortex | 18 | Todas las DPS hacen +10% |
| IV | Protocolo Overkill | 2,000 Cortex | 30 | Kills en <2s del deploy dan ×2 Cells |
| IV | Arsenal Experimental | 3,000 Cortex | 35 | Acceso a variantes de cada DPS |

### CATEGORÍA 2: CONTROL (Ralentización y CC)

| Tier | Item | Costo | Req. Nivel | Efecto |
|------|------|-------|-----------|--------|
| I | Campo Gravitacional | 250 Cortex | 5 | Desbloquea defensa |
| II | Muro de Distorsión Temporal | 600 Cortex | 8 | Desbloquea defensa |
| II | Trampa de Estasis | 350 Cortex | 7 | Desbloquea defensa |
| III | Campo de Confusión | 900 Cortex | 15 | Desbloquea defensa |
| III | Mejora Control Duration | 700 Cortex | 14 | +15% duración de CC |
| IV | Dominio Temporal | 2,500 Cortex | 32 | Desbloquea Time Stop global |

### CATEGORÍA 3: CAPTURA (Módulos de captura)

| Tier | Item | Costo | Req. Nivel | Efecto |
|------|------|-------|-----------|--------|
| I | Módulo de Captura Básico | 100 Cortex | 1 | Defensa base, siempre disponible pero mejora |
| II | Red de Contención Avanzada | 500 Cortex | 10 | Captura Míticos+ |
| II | Ampliación de Bóveda | 400 Cortex | 8 | +5 slots de bóveda (15→20) |
| III | Bóveda Portátil | 1,200 Cortex | 25 | Captura garantizada ultimate |
| III | Señuelo de Rareza | 800 Cortex | 22 | +10% prob de spawn de raros |
| IV | Maestro Captor | 3,000 Cortex | 38 | +25% probabilidad captura global |

### CATEGORÍA 4: FORTIFICACIÓN (Barrera y base)

| Tier | Item | Costo | Req. Nivel | Efecto |
|------|------|-------|-----------|--------|
| I | Barrera Reforzada | 200 Cortex | 4 | +200 HP base de barrera |
| I | Reparador de Barrera | 150 Cortex | 3 | Desbloquea defensa |
| II | Escudo de Emergencia | 500 Cortex | 11 | Activar = barrera invulnerable 5s (1 uso/partida) |
| III | Barrera Adaptativa | 1,000 Cortex | 20 | Barrera gana resistencia al tipo de daño más recibido |
| III | Núcleo Fortificado | 800 Cortex | 18 | Núcleo tiene +250 HP |
| IV | Fortaleza Suprema | 2,500 Cortex | 35 | Barrera se regenera 0.5%/s natural |

### CATEGORÍA 5: SOPORTE (Utilidades y economía)

| Tier | Item | Costo | Req. Nivel | Efecto |
|------|------|-------|-----------|--------|
| I | Generador de Cells | 150 Cortex | 2 | Desbloquea defensa |
| I | Amplificador de Rango | 200 Cortex | 4 | Desbloquea defensa |
| II | Scout Drone | 400 Cortex | 9 | Revela composición exacta 2 oleadas adelante |
| III | Overdrive Module | 900 Cortex | 17 | Activa: +50% atk speed a todas las defensas por 10s |
| IV | Economía de Guerra | 2,000 Cortex | 28 | +15% Cells de todas las fuentes |

### CATEGORÍA 6: TÁCTICAS (Capacidad y loadout)

| Tier | Item | Costo | Req. Nivel | Efecto |
|------|------|-------|-----------|--------|
| I | Loadout +1 | 300 Cortex | 5 | 8→9 slots de loadout |
| II | Loadout +2 | 600 Cortex | 12 | 9→10 slots de loadout |
| II | Capacidad +3 | 500 Cortex | 10 | 20→23 defensas máx en campo |
| III | Capacidad +5 | 1,000 Cortex | 20 | 23→28 defensas máx |
| III | Quick Deploy | 800 Cortex | 16 | Colocar defensas es 50% más rápido |
| IV | Arquitecto Maestro | 3,000 Cortex | 40 | Desbloquea zonas de construcción bonus en cada mapa |

---

### Sensación de Progresión

```
NIVEL 1-5:    [████░░░░░░░░░░░░]  Starter — aprendiendo mecánicas
NIVEL 5-12:   [████████░░░░░░░░]  Tier II — opciones tácticas reales
NIVEL 12-20:  [████████████░░░░]  Tier III — builds especializados
NIVEL 20-35:  [██████████████░░]  Tier IV — maestría y optimización
NIVEL 35-50:  [████████████████]  Endgame — variantes y experimentación
```

Cada compra se celebra con:
- Animación de desbloqueo (hologram → solid)
- Sonido satisfactorio de "unlock"
- Preview de cómo se usa en partida
- Notificación a amigos: "X desbloqueó Orbital Strike Beacon"
