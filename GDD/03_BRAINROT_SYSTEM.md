# 8. BRAINROT CLASSES & RARITY SYSTEM

## Filosofía de Diseño

Los Brainrots no son enemigos genéricos. Cada uno tiene personalidad visual, comportamiento diferenciado y valor estratégico. El sistema de clases define **cómo se comportan**, y el sistema de rarezas define **qué tan poderosos y valiosos son**.

---

## CLASES DE BRAINROT (Arquetipos de Comportamiento)

### Clase 1: SWARMER (Enjambre)
- **Rol:** Cantidad sobre calidad
- **Comportamiento:** Viajan en grupos grandes, son rápidos pero frágiles
- **Amenaza:** Saturan las defensas por volumen
- **Visual:** Pequeños, deformes, movimiento errático, brillan en grupo
- **Ejemplo:** *Skibidi Mite* — insecto mutante que corre en zigzag

### Clase 2: TANK (Tanque)
- **Rol:** Absorber daño
- **Comportamiento:** Lentos pero con HP masivo y armadura
- **Amenaza:** Difíciles de matar, llegan a la barrera con HP alto
- **Visual:** Grandes, pesados, placas de armadura orgánica, pasos que tiemblan
- **Ejemplo:** *Brainrot Golem* — masa de materia corrupta compactada

### Clase 3: SPEEDSTER (Veloz)
- **Rol:** Evasión y velocidad
- **Comportamiento:** Extremadamente rápidos, bajo HP
- **Amenaza:** Pasan las defensas antes de que reaccionen
- **Visual:** Aerodinámicos, efecto de estela, deformación por velocidad
- **Ejemplo:** *Sigma Dasher* — criatura felina corrupta con rayas de energía

### Clase 4: SHIELDER (Protector)
- **Rol:** Proteger a otros Brainrots
- **Comportamiento:** Genera campo de escudo que protege aliados cercanos
- **Amenaza:** Hace que las hordas sean mucho más resistentes
- **Visual:** Aura brillante, geometría hexagonal flotante
- **Ejemplo:** *Gyatt Guardian* — esfera flotante con campo hexagonal

### Clase 5: HEALER (Sanador)
- **Rol:** Regenerar HP de aliados
- **Comportamiento:** Se posiciona detrás del grupo, cura en área
- **Amenaza:** Invalida el daño sostenido si no se elimina primero
- **Visual:** Tentáculos de energía verde que conectan con aliados
- **Ejemplo:** *Rizz Medic* — criatura tentacular con pulso regenerativo

### Clase 6: SABOTEUR (Saboteador)
- **Rol:** Dañar o deshabilitar defensas
- **Comportamiento:** Ataca las defensas del jugador en lugar del camino
- **Amenaza:** Destruye tu infraestructura, abre huecos
- **Visual:** Garras afiladas, energía disruptiva, chispas
- **Ejemplo:** *Ohio Wrecker* — criatura bípeda con brazos de demolición

### Clase 7: STEALTH (Sigiloso)
- **Rol:** Invisibilidad parcial
- **Comportamiento:** Invisible hasta estar cerca de defensas o barrera
- **Amenaza:** Bypasea defensas que no detectan invisibles
- **Visual:** Translúcido, efecto de distorsión óptica, aparece con flash
- **Ejemplo:** *Phantom Skibidi* — silueta distorsionada semi-visible

### Clase 8: BOSS (Jefe)
- **Rol:** Amenaza suprema de oleada
- **Comportamiento:** Múltiples fases, mecánicas únicas, spawna adds
- **Amenaza:** Puede destruir la barrera solo si no se maneja
- **Visual:** Enorme, diseño elaborado, efectos de partículas masivos
- **Ejemplo:** *El Corruptor Ancestral* — amalgama de todos los tipos

---

## SISTEMA DE RAREZAS

### Tabla de Rarezas Completa

| Rareza | Color | HP Mult. | Velocidad | Daño Barrera | Resistencia | Recompensa $ | Prob. Captura | Valor Bóveda | Habilidad |
|--------|-------|----------|-----------|-------------|-------------|-------------|--------------|-------------|-----------|
| Normal | Gris | ×1.0 | ×1.0 | ×1.0 | Ninguna | 10 Cells | 40% | 5 pts | Ninguna |
| Raro | Verde | ×1.5 | ×1.1 | ×1.3 | — | 25 Cells | 30% | 15 pts | Ninguna |
| Élite | Azul | ×2.5 | ×1.2 | ×1.8 | 15% resist | 60 Cells | 20% | 40 pts | 1 pasiva |
| Oro | Dorado | ×4.0 | ×1.0 | ×2.5 | 25% resist | 150 Cells | 12% | 100 pts | 1 pasiva |
| Diamante | Cyan brillante | ×6.0 | ×1.3 | ×3.0 | 30% resist + escudo | 350 Cells | 7% | 250 pts | 1 pasiva + 1 activa |
| Mítico | Púrpura | ×10.0 | ×1.4 | ×4.0 | 40% resist + regen | 800 Cells | 3% | 600 pts | 2 pasivas + 1 activa |
| Corrupto | Rojo oscuro | ×8.0 | ×1.6 | ×5.0 | 35% + anti-slow | 600 Cells | 4% | 500 pts | 2 pasivas especiales |
| Legendario | Naranja brillante | ×15.0 | ×1.2 | ×6.0 | 50% + inmune a CC | 2000 Cells | 1.5% | 1500 pts | 2 pasivas + 2 activas |
| Ancestral | Blanco-dorado | ×25.0 | ×1.0 | ×10.0 | 60% + multi-fase | 5000 Cells | 0.3% | 5000 pts | Set completo |

### Detalle de Resistencias por Rareza

**Normal:** Sin resistencias. Vulnerable a todo.

**Raro:** Sin resistencias especiales, pero HP incrementado hace que requiera más DPS.

**Élite:** 15% de reducción de daño general. Las torretas básicas necesitan estar mejoradas.

**Oro:** 25% de reducción + immunidad al primer efecto de control recibido (cooldown 8s). Brillan con partículas doradas que señalan su valor.

**Diamante:** 30% reducción + escudo regenerativo que absorbe los primeros 200 puntos de daño (se regenera si no recibe daño por 5s). Requiere burst damage para romper el escudo.

**Mítico:** 40% reducción + regenera 2% HP/s. Requiere DPS sostenido alto o debuffs anti-heal. Aura púrpura visible.

**Corrupto:** 35% reducción + inmune a ralentización. Más rápido que su clase base. Deja un rastro de corrupción que daña defensas cercanas al camino (2% HP/s a defensas en rango de 5 studs).

**Legendario:** 50% reducción + inmune a efectos de control (stun, freeze, knockback). Solo vulnerable a daño puro. Aura flamígera naranja, partículas épicas.

**Ancestral:** 60% reducción + sistema de fases (3 barras de HP). Al perder cada barra, cambia de comportamiento y gana nuevas habilidades. Solo 1 por partida, siempre es el Boss.

---

## HABILIDADES ESPECIALES POR RAREZA

### Habilidades Pasivas (siempre activas)

| Habilidad | Rareza mín. | Efecto |
|-----------|------------|--------|
| Piel Gruesa | Élite | Reduce daño de torretas básicas en 20% |
| Aura Tóxica | Élite | Daña defensas cercanas al pasar (1% HP/s) |
| Regeneración | Oro | Recupera 1% HP/s |
| Escudo de Energía | Diamante | Absorbe primeros 200 de daño, se regenera |
| Campo Anti-Slow | Corrupto | Inmune a efectos de ralentización |
| Inspiración | Mítico | Brainrots cercanos ganan +20% velocidad |
| Fortaleza | Legendario | Inmune a CC, 50% reducción |
| Multi-Fase | Ancestral | 3 barras de HP con transiciones |

### Habilidades Activas (se activan bajo condiciones)

| Habilidad | Rareza mín. | Trigger | Efecto |
|-----------|------------|---------|--------|
| Sprint | Diamante | HP < 50% | Velocidad ×2 por 3 segundos |
| Destello EMP | Diamante | Al pasar por defensa | Desactiva 1 defensa por 2s |
| Llamada de Horda | Mítico | HP < 30% | Spawna 3 Swarmers Normales |
| Pulso de Corrupción | Corrupto | Cada 10s | Daño en área a defensas (50 dmg) |
| Teleport | Legendario | HP < 40% | Se teletransporta 30 studs adelante |
| Escudo Masivo | Legendario | Al entrar al último tercio del camino | Gana escudo = 50% de HP max |
| Nova Ancestral | Ancestral | Transición de fase | Destruye todas las defensas en 15 studs |
| Invocación | Ancestral | Fase 2 | Spawna 5 Élites de su clase |

---

## SPAWNING & COMPOSICIÓN DE OLEADAS

### Reglas de composición:

1. **Oleadas 1-3:** Solo Normales, 1-2 clases
2. **Oleada 4+:** Se introducen Raros, combinaciones de 2-3 clases
3. **Oleada 7+:** Élites garantizados, posible Oro
4. **Oleada 10+:** Oro garantizado, posible Diamante
5. **Oleada 13+:** Diamante garantizado, posible Mítico
6. **Oleada 16+:** Mítico garantizado, posible Corrupto
7. **Oleada 19+:** Corrupto + Legendario posible
8. **Boss Wave:** 1 Ancestral + horda mixta

### Composición tipo de oleada:

```lua
-- Ejemplo: Oleada 10 en dificultad Normal
{
    total = 35,
    composition = {
        {class = "Swarmer", rarity = "Normal", count = 15},
        {class = "Tank", rarity = "Normal", count = 5},
        {class = "Speedster", rarity = "Raro", count = 6},
        {class = "Shielder", rarity = "Raro", count = 3},
        {class = "Tank", rarity = "Elite", count = 2},
        {class = "Swarmer", rarity = "Oro", count = 1},  -- Target de captura
    },
    spawnInterval = 1.2,  -- segundos entre spawns
    spawnPattern = "mixed",  -- alternado, no todos de golpe
}
```

---

## BRAINROTS NOMBRADOS (Ejemplos de Diseño)

### Tier Normal
| Nombre | Clase | Visual |
|--------|-------|--------|
| Skibidi Mite | Swarmer | Insecto pequeño gris con antenas pulsantes |
| Brainrot Slug | Tank | Babosa grande gris con placas |
| Fanum Runner | Speedster | Criatura cuadrúpeda gris, estela de humo |

### Tier Raro
| Nombre | Clase | Visual |
|--------|-------|--------|
| Ohio Crawler | Swarmer | Insecto verde con mandíbulas brillantes |
| Sigma Shield | Shielder | Esfera verde con hexágonos flotantes |
| Gyatt Sprinter | Speedster | Felino verde neón, estela luminosa |

### Tier Élite
| Nombre | Clase | Visual |
|--------|-------|--------|
| Rizz Commander | Healer | Tentacular azul con pulsos curativos |
| Skibidi Breaker | Saboteur | Bípedo azul con brazos mecánicos |
| Fanum Fortress | Tank | Golem azul con cristales incrustados |

### Tier Oro
| Nombre | Clase | Visual |
|--------|-------|--------|
| Golden Sigma | Tank | Golem dorado con venas de energía |
| Auric Dasher | Speedster | Felino dorado con corona de partículas |
| Gilded Guardian | Shielder | Esfera dorada, escudo masivo radiante |

### Tier Diamante
| Nombre | Clase | Visual |
|--------|-------|--------|
| Crystal Phantom | Stealth | Criatura cristalina semitransparente |
| Diamond Swarm Queen | Swarmer | Reina de enjambre, spawna mites al morir |
| Prismatic Tank | Tank | Tanque con escudo de diamante refractante |

### Tier Mítico
| Nombre | Clase | Visual |
|--------|-------|--------|
| Void Walker | Stealth | Criatura de vacío púrpura, distorsiona espacio |
| Mythic Hydra | Healer+Tank | Híbrido multicabeza, se cura y absorbe |
| Arcane Disruptor | Saboteur | Destructor de defensas con energía arcana |

### Tier Corrupto
| Nombre | Clase | Visual |
|--------|-------|--------|
| Corruption Engine | Tank | Motor orgánico rojo que corrompe el terreno |
| Plague Runner | Speedster | Dejá rastro de corrupción, inmune a slow |
| Chaos Invoker | Healer | Cura mediante corrupción, debuffea defensas |

### Tier Legendario
| Nombre | Clase | Visual |
|--------|-------|--------|
| Omega Skibidi | Boss-lite | Enorme, aura de fuego, inmune a CC |
| The Sigma Prime | Tank+Shielder | Tanque supremo con escudo que refleja |
| Eternal Phantom | Stealth | Permanentemente invisible salvo al atacar |

### Tier Ancestral (Bosses de Mapa)
| Nombre | Mapa | Mecánica Única |
|--------|------|---------------|
| El Corruptor | Sendero Corrupto | 3 fases, spawna corrupción permanente en el mapa |
| Madre de Enjambre | Colmena Profunda | Spawna infinitos swarmers, hay que destruir huevos |
| El Arquitecto | Ruinas Techno | Reconstruye el camino, crea atajos para otros brainrots |
