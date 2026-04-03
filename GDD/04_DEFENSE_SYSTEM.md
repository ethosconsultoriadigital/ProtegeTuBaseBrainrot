# 9. DEFENSE SYSTEM

## Filosofía de Diseño

Las defensas son la expresión de la estrategia del jugador. No hay "mejor defensa" universal — cada configuración responde a diferentes composiciones de oleadas y estilos de juego. El sistema premia la sinergia, el posicionamiento y la adaptación.

**Reglas de colocación:**
- Las defensas SOLO se colocan en **zonas válidas** marcadas a lo largo del camino
- Cada zona tiene 1 slot de defensa (algunas zonas premium tienen 2)
- Las defensas tienen rango de acción visualizado al colocar
- Se pueden vender por 50% de su costo total (incluye mejoras)
- Máximo 20 defensas simultáneas (30 en co-op, 7-8 por jugador)

---

## FAMILIAS DE DEFENSAS

### FAMILIA 1: DAÑO DIRECTO (DPS)
> *Propósito: Eliminar enemigos con daño consistente*

#### Torreta Láser (Starter)
- **Costo:** 100 Cells
- **Daño:** 15/s
- **Rango:** 12 studs
- **Velocidad de ataque:** Continuo (beam)
- **Target:** Enemigo más cercano
- **Mejoras:**
  - Nv.2 (75 Cells): Daño 25/s, rango 14
  - Nv.3 (150 Cells): Daño 40/s, rango 16, penetra escudos 20%

#### Cañón de Plasma
- **Costo:** 250 Cells
- **Daño:** 80 por disparo
- **Rango:** 18 studs
- **Velocidad de ataque:** 1 disparo cada 2s
- **Target:** Enemigo con más HP
- **Especial:** Daño splash (5 studs, 40% daño a adyacentes)
- **Mejoras:**
  - Nv.2 (175 Cells): Daño 130, splash 6 studs
  - Nv.3 (350 Cells): Daño 200, splash 8 studs, quema (10 dmg/s por 3s)

#### Railgun Prismático
- **Costo:** 500 Cells
- **Daño:** 250 por disparo
- **Rango:** 30 studs (línea recta, atraviesa enemigos)
- **Velocidad de ataque:** 1 cada 4s
- **Target:** Línea con más enemigos
- **Especial:** Penetra todos los enemigos en línea, daño reducido 10% por penetración
- **Desbloqueo:** Nivel de Guardián 12
- **Mejoras:**
  - Nv.2 (350 Cells): Daño 400, sin reducción por penetración
  - Nv.3 (700 Cells): Daño 600, marca enemigos (reciben +15% daño por 3s)

---

### FAMILIA 2: RALENTIZACIÓN (SLOW)
> *Propósito: Reducir velocidad de enemigos para dar más tiempo a las defensas*

#### Trampa de Hielo
- **Costo:** 80 Cells
- **Efecto:** -30% velocidad por 3s
- **Rango:** 8 studs (área circular en el camino)
- **Cooldown:** Siempre activa (aura)
- **Nota:** No afecta Corruptos (inmunes a slow)
- **Mejoras:**
  - Nv.2 (60 Cells): -45% velocidad, rango 10
  - Nv.3 (120 Cells): -60% velocidad, rango 12, congela por 0.5s al entrar

#### Campo Gravitacional
- **Costo:** 200 Cells
- **Efecto:** -50% velocidad en área + atrae enemigos al centro
- **Rango:** 10 studs
- **Duración:** 5s activo, 5s cooldown
- **Especial:** Agrupa enemigos para combos con splash damage
- **Mejoras:**
  - Nv.2 (150 Cells): -60%, atracción más fuerte
  - Nv.3 (300 Cells): -70%, daño pasivo 5/s a enemigos en el campo

#### Muro de Distorsión Temporal
- **Costo:** 400 Cells
- **Efecto:** Los enemigos que cruzan se mueven a 20% de su velocidad por 2s
- **Rango:** Barrera de 15 studs de ancho
- **Cooldown:** 8s después de activarse
- **Desbloqueo:** Nivel de Guardián 8
- **Mejoras:**
  - Nv.2 (280 Cells): 15% velocidad, 3s duración
  - Nv.3 (560 Cells): 10% velocidad, 3s, envejece enemigos (-10% HP max)

---

### FAMILIA 3: CONTROL (CC)
> *Propósito: Detener, desviar o incapacitar enemigos*

#### Trampa de Estasis
- **Costo:** 150 Cells
- **Efecto:** Congela 1 enemigo por 2s
- **Rango:** 10 studs
- **Cooldown:** 6s
- **Target:** Enemigo más peligroso en rango (por HP × velocidad)
- **Nota:** Legendarios+ son inmunes
- **Mejoras:**
  - Nv.2 (110 Cells): 2.5s freeze, cooldown 5s
  - Nv.3 (220 Cells): 3s freeze, afecta 2 enemigos simultáneos

#### Torre de Empuje
- **Costo:** 120 Cells
- **Efecto:** Knockback que empuja enemigos 8 studs hacia atrás
- **Rango:** 12 studs
- **Cooldown:** 4s
- **Especial:** Funciona contra Corruptos (no es slow, es físico)
- **Mejoras:**
  - Nv.2 (90 Cells): 12 studs knockback, cooldown 3s
  - Nv.3 (180 Cells): 15 studs knockback, stun 0.5s tras impacto

#### Campo de Confusión
- **Costo:** 350 Cells
- **Efecto:** Enemigos en el área caminan en dirección contraria por 3s
- **Rango:** 10 studs
- **Cooldown:** 12s
- **Desbloqueo:** Nivel de Guardián 15
- **Mejoras:**
  - Nv.2 (250 Cells): 4s duración, cooldown 10s
  - Nv.3 (500 Cells): 5s duración, enemigos confundidos atacan a otros Brainrots

---

### FAMILIA 4: BURST (Daño Explosivo)
> *Propósito: Daño masivo en momentos clave, ideal para romper escudos y matar élites*

#### Mina de Proximidad
- **Costo:** 60 Cells (consumible, se re-compra)
- **Daño:** 200 en área de 6 studs
- **Trigger:** Primer enemigo que pise
- **Especial:** Ignora 50% de armadura. Se destruye al activarse.
- **Mejoras:** No mejorables, pero se pueden comprar en lote (5× por 250 Cells)

#### Torreta de Misiles
- **Costo:** 300 Cells
- **Daño:** 150 por misil, dispara ráfaga de 3
- **Rango:** 20 studs
- **Cooldown:** 8s entre ráfagas
- **Target:** Enemigo con mayor rareza en rango
- **Mejoras:**
  - Nv.2 (210 Cells): 200 por misil, ráfaga de 4
  - Nv.3 (420 Cells): 300 por misil, ráfaga de 5, misiles buscan objetivos distintos

#### Orbital Strike Beacon
- **Costo:** 600 Cells
- **Daño:** 1000 en área de 12 studs
- **Cooldown:** 30s
- **Especial:** Habilidad activa — el jugador elige dónde cae el strike
- **Desbloqueo:** Nivel de Guardián 20
- **Mejoras:**
  - Nv.2 (420 Cells): 1500 daño, 15 studs
  - Nv.3 (840 Cells): 2000 daño, 18 studs, deja zona de fuego (100 dmg/s por 5s)

---

### FAMILIA 5: SOPORTE
> *Propósito: Mejorar otras defensas, curar barrera, dar buffs*

#### Amplificador de Rango
- **Costo:** 150 Cells
- **Efecto:** +25% rango a defensas adyacentes (15 studs)
- **Stacking:** No se acumula con otro amplificador
- **Mejoras:**
  - Nv.2 (110 Cells): +35% rango
  - Nv.3 (220 Cells): +50% rango + 10% velocidad de ataque

#### Generador de Cells
- **Costo:** 200 Cells
- **Efecto:** Genera 5 Cells por segundo pasivamente
- **Especial:** ROI en 40 segundos. Crítico para economía mid-game
- **Límite:** Máximo 3 por jugador
- **Mejoras:**
  - Nv.2 (150 Cells): 8 Cells/s
  - Nv.3 (300 Cells): 12 Cells/s + bonus de 50 Cells por oleada completada

#### Reparador de Barrera
- **Costo:** 250 Cells
- **Efecto:** Repara 1% de barrera por segundo
- **Rango:** Debe estar en zona cercana a la base (últimas 3 zonas)
- **Límite:** 2 máximo
- **Mejoras:**
  - Nv.2 (175 Cells): 2% por segundo
  - Nv.3 (350 Cells): 3% por segundo + escudo temporal en emergencia

---

### FAMILIA 6: CAPTURA
> *Propósito: Capturar Brainrots debilitados para la bóveda*

#### Módulo de Captura Básico
- **Costo:** 150 Cells
- **Efecto:** Intenta capturar Brainrots con <25% HP que pasen por el rango
- **Rango:** 8 studs
- **Probabilidad base:** ×1.0 (multiplicador sobre prob. de rareza)
- **Cooldown:** 5s entre intentos
- **Visual:** Campo de contención azul que atrapa momentáneamente al target
- **Mejoras:**
  - Nv.2 (110 Cells): <30% HP threshold, ×1.3 probabilidad
  - Nv.3 (220 Cells): <35% HP threshold, ×1.6 probabilidad, cooldown 3s

#### Red de Contención Avanzada
- **Costo:** 350 Cells
- **Efecto:** Captura con <40% HP, puede capturar 2 simultáneamente
- **Rango:** 12 studs
- **Probabilidad base:** ×1.5
- **Especial:** Puede capturar Míticos+ (el básico no puede)
- **Desbloqueo:** Nivel de Guardián 10
- **Mejoras:**
  - Nv.2 (250 Cells): <45% HP, ×1.8 prob, captura 3 simultáneos
  - Nv.3 (500 Cells): <50% HP, ×2.2 prob, bonus: Brainrots capturados valen +20%

#### Bóveda Portátil (Ultimate)
- **Costo:** 800 Cells
- **Efecto:** Captura instantánea de 1 Brainrot con <20% HP, cualquier rareza
- **Rango:** 15 studs
- **Cooldown:** 45s
- **Especial:** Garantiza captura si el target cumple condición de HP. Único por partida.
- **Desbloqueo:** Nivel de Guardián 25
- **Mejoras:**
  - Nv.2 (560 Cells): <25% HP, cooldown 35s
  - Nv.3 (1120 Cells): <30% HP, cooldown 25s, Brainrot capturado vale ×2

---

## SINERGIAS DE DEFENSA

El posicionamiento estratégico crea sinergias naturales:

### Combos de ejemplo:

| Combo | Defensas | Efecto |
|-------|----------|--------|
| Kill Zone | Campo Gravitacional + Cañón de Plasma | Agrupa enemigos + splash devastador |
| Capture Lane | Trampa de Hielo + Torreta Láser + Módulo Captura | Ralentiza, debilita, captura |
| Fortress | Reparador + Amplificador + Torreta Misiles | Defensa sostenida del último tramo |
| Glass Cannon | Railgun + Amplificador + Orbital Strike | Daño máximo, sin control |
| Control Corridor | Estasis + Confusión + Empuje | Los enemigos nunca avanzan |
| Economy Engine | Generador ×3 + Minas (baratas) | Máximo ingreso, mínima inversión |

### Regla de sinergia de proximidad:
- Defensas del mismo tipo dentro de 10 studs: -10% eficiencia (anti-stack)
- Defensas de diferente tipo dentro de 10 studs: +5% eficiencia (sinergia)
- Esto fomenta diversidad y no spam de una sola defensa

---

## SISTEMA DE HABILIDADES ACTIVAS

Algunas defensas Nv.3 desbloquean habilidades activas que el jugador activa manualmente:

| Defensa | Habilidad Activa | Cooldown | Efecto |
|---------|-----------------|----------|--------|
| Cañón de Plasma Nv.3 | Plasma Overcharge | 20s | Siguiente disparo hace ×3 daño |
| Muro Temporal Nv.3 | Time Stop | 45s | Congela TODOS los enemigos en mapa por 2s |
| Orbital Strike Nv.3 | Coordinate Strike | 30s | Elige ubicación del golpe orbital |
| Campo Confusión Nv.3 | Mass Hysteria | 60s | Todos los enemigos en mapa se atacan entre sí por 3s |
| Bóveda Portátil Nv.3 | Emergency Extract | 45s | Captura instantánea garantizada |

El jugador puede tener máximo 4 habilidades activas a la vez (por límite de interfaz), incentivando decisiones de build.
