# 13. MULTIPLAYER DESIGN

## Modos de Juego

### Solo (1 jugador)
- Experiencia completa, balanceada para 1 persona
- El jugador controla todos los recursos y decisiones
- Oleadas calibradas para manejar con ~20 defensas
- Ideal para práctica, exploración y ranked personal

### Co-op (2–4 jugadores)
- **Mismo mapa, misma base, misma bóveda**
- Los jugadores comparten la base pero tienen **economía separada**
- Cada jugador tiene su propio pool de Cells
- Las capturas van a la bóveda compartida
- Las oleadas escalan: ×1.4 por cada jugador adicional

### Cómo funciona la cooperación:

| Aspecto | Detalle |
|---------|---------|
| Zonas de construcción | Compartidas, primer jugador en colocar ocupa el slot |
| Economía | Cells individuales (kills dan Cells al jugador que hizo más daño) |
| Bóveda | Compartida — todos contribuyen y se benefician |
| Barrera | Compartida — cualquiera puede repararla |
| Loadout | Individual — cada jugador trae sus defensas |
| Recompensas finales | Individuales basadas en contribución + bonus grupal |

### Roles emergentes en co-op:

No hay roles forzados, pero el diseño fomenta especialización natural:

**El DPS Dealer:**
- Trae loadout ofensivo (Railgun, Misiles, Orbital)
- Se posiciona en tramos tempranos del camino
- Maximiza kills y dinero

**El Controller:**
- Trae loadout de control (Hielo, Estasis, Confusión)
- Se posiciona en tramos medios
- Ralentiza y debilita para que otros rematen

**El Captor:**
- Trae módulos de captura y soporte
- Se posiciona en tramos finales (antes de la base)
- Maximiza capturas de Brainrots debilitados

**El Guardian:**
- Trae defensas de barrera y fortificación
- Se posiciona en la zona exterior de la base
- Mantiene la barrera y protege la bóveda

### Comunicación:

| Sistema | Función |
|---------|---------|
| Ping system | Click en mapa = "¡Defiendan aquí!" / "¡Captura disponible!" |
| Quick chat | Mensajes presets: "Necesito ayuda", "Barrera baja", "Boss viene" |
| Emotes | Expresiones visuales sobre el personaje |
| Wave preview share | Todos ven la preview de oleada simultáneamente |

### Incentivos co-op:

- **Bonus grupal:** +25% Cortex si todos sobreviven
- **Bonus sinergia:** Defensas de diferentes jugadores cerca = +10% efectividad
- **Bonus MVP:** El jugador con mayor contribución recibe título y bonus
- **Logros co-op exclusivos:** Solo desbloqueables en grupo

---

# 14. VISUAL DIRECTION

## Estilo Artístico: TECHNO-ORGANIC FORTRESS

### Mood General
> Una fusión entre tecnología alienígena avanzada y biología mutante. La base es una fortaleza de otro mundo donde la ciencia y lo orgánico coexisten. El camino es tierra corrupta por energía brainrot. Las defensas son dispositivos tech-clean. Los Brainrots son criaturas bio-mecánicas grotescamente adorables.

### Referencia de Estilo
- **Warframe** (arquitectura orgánica Orokin)
- **Fortnite Save the World** (estilización colorida y legible)
- **Subnautica** (bio-luminiscencia y tech alienígena)
- **Splatoon** (claridad visual y saturación)

---

## Paleta de Colores

### Entorno - Base del Jugador
| Elemento | Color | Hex | Uso |
|----------|-------|-----|-----|
| Estructura principal | Blanco titanio | #E8E8EC | Paredes, plataformas |
| Detalles tech | Cyan energético | #00E5FF | Líneas de energía, UI activa |
| Iluminación ambiental | Azul profundo | #1A237E | Luz de fondo, shadows |
| Energía de bóveda | Turquesa brillante | #00BFA5 | Pods de captura, bóveda |
| Acentos | Blanco puro | #FFFFFF | Highlights, bordes |

### Entorno - Camino / Battlefield
| Elemento | Color | Hex | Uso |
|----------|-------|-----|-----|
| Terreno corrupto | Púrpura oscuro | #311B92 | Camino principal |
| Energía corrupta | Magenta | #D500F9 | Flujo de corrupción, trail |
| Vegetación mutante | Verde tóxico | #76FF03 | Plantas del entorno |
| Cielo / Fondo | Negro azulado | #0D1B2A | Skybox |
| Particulas | Púrpura claro | #EA80FC | Ambiente del camino |

### Colores de Rareza (IDENTIDAD VISUAL CRÍTICA)
| Rareza | Color principal | Color secundario | Efecto visual |
|--------|---------------|-----------------|--------------|
| Normal | #9E9E9E (Gris) | #757575 | Sin efecto |
| Raro | #4CAF50 (Verde) | #81C784 | Brillo suave |
| Élite | #2196F3 (Azul) | #64B5F6 | Brillo + partículas |
| Oro | #FFC107 (Dorado) | #FFD54F | Brillo intenso + destellos |
| Diamante | #00BCD4 (Cyan) | #80DEEA | Cristalino + refracción |
| Mítico | #9C27B0 (Púrpura) | #CE93D8 | Aura + distorsión |
| Corrupto | #F44336 (Rojo) | #EF5350 | Aura oscura + estela corrupta |
| Legendario | #FF9800 (Naranja) | #FFB74D | Flamígero + partículas épicas |
| Ancestral | #FFFFFF / #FFD700 | Gradiente | Celestial + multi-efecto |

---

## Materiales Sugeridos (Roblox)

| Superficie | Material | Propiedades |
|-----------|----------|-------------|
| Base - Paredes | SmoothPlastic | Reflectance 0.1, clean |
| Base - Pisos | Neon (detalles) + SmoothPlastic | Líneas de energía cyan |
| Camino | Slate / Cobblestone | Textura orgánica corrupta |
| Defensas | Metal + Neon | Tech limpio con acentos de energía |
| Brainrots | SmoothPlastic + ForceField (raros+) | Bio-orgánico estilizado |
| Barrera | ForceField | Semi-transparente, hexagonal |
| Bóveda pods | Glass + Neon | Cápsulas de contención |

---

## VFX Sugeridos

### Defensas
| VFX | Defensa | Descripción |
|-----|---------|-------------|
| Beam continuo | Torreta Láser | Rayo cyan que conecta torreta con target |
| Explosión de plasma | Cañón de Plasma | Impacto con expansión de onda y chispas |
| Ondas concéntricas | Campo Gravitacional | Ondas púrpura que se contraen al centro |
| Cristales de hielo | Trampa de Hielo | Cristales que se forman bajo enemigos |
| Rayo descendente | Orbital Strike | Columna de luz desde el cielo |
| Campos hexagonales | Módulo Captura | Red de hexágonos cyan que envuelve al target |

### Brainrots
| VFX | Trigger | Descripción |
|-----|---------|-------------|
| Trail de rareza | Movimiento | Estela del color de rareza tras el brainrot |
| Escudo hexagonal | Shielder activo | Domo de hexágonos semitransparentes |
| Pulso de curación | Healer activa | Ondas verdes expandiéndose |
| Distorsión óptica | Stealth | Efecto de camuflaje tipo Predator |
| Partículas de muerte | Al morir | Explosión de partículas del color de rareza |
| Aura de boss | Boss/Ancestral | Aura masiva con partículas orbitantes |

### Base
| VFX | Trigger | Descripción |
|-----|---------|-------------|
| Pulso de barrera | Impacto | Onda desde punto de impacto por la barrera |
| Alarma roja | Brecha | Pantalla con overlay rojo pulsante |
| Captura exitosa | Captura | Flash de luz + partículas hacia la bóveda |
| Robo | Infiltración | Energía roja saliendo de la bóveda |

---

## Iluminación

| Zona | Tipo | Mood |
|------|------|------|
| Base | Luz volumétrica cyan, clean | Seguridad, tecnología, hogar |
| Camino inicio | Luz tenue púrpura, niebla | Misterio, amenaza lejana |
| Camino medio | Luz más intensa, mezcla | Combate, acción |
| Camino final (cerca de base) | Contraste cyan vs púrpura | Tensión, frontera |
| Bóveda interior | Luz cálida turquesa, pods brillando | Valor, tesoro, premio |
| Durante brecha | Rojo pulsante, sombras duras | Emergencia, pánico |

**Ciclo de luz:** No hay ciclo día/noche. La iluminación es constante estilizada para mantener legibilidad en gameplay. Cambios de luz solo por eventos (brecha, boss, etc.).

---

## UI / UX Direction

### Filosofía UI
> Minimalista pero informativa. Cada pixel tiene propósito. No cluttered. La información importante está siempre visible, la secundaria aparece contextualmente.

### Layout de pantalla durante gameplay:

```
┌─────────────────────────────────────────────────────────┐
│ [Oleada 7/15]         [⏱ 00:32]         [Cells: 1,240] │  ← Top bar
│                                                         │
│                                                         │
│                    ÁREA DE JUEGO 3D                      │
│                                                         │
│                                                         │
│                                                         │
│                                                         │
│ [🛡 Barrera: 78%]                   [📦 Bóveda: 5/15]  │  ← Status bar
│                                                         │
│ [Q][W][E][R]  ← Habilidades activas                    │
│                                                         │
│ [1][2][3][4][5][6][7][8] ← Defensas disponibles         │  ← Hotbar
└─────────────────────────────────────────────────────────┘
```

### Tipografía
- **Headers:** Geométrica, bold, en mayúsculas (estilo: Rajdhani, Exo 2)
- **Body:** Sans-serif limpia (estilo: Inter, Nunito)
- **Números:** Monospace para contadores (estilo: JetBrains Mono)

### Animaciones UI
- Números de Cells suben/bajan con interpolación suave
- Barra de barrera pulsa cuando está baja
- Iconos de oleada entran con slide + bounce
- Capturas tienen pop-up con efecto de brillo y shake
- La rareza del pop-up refleja el color: una captura Oro tiene pop-up dorado

### Sensación Premium
- Bordes redondeados con glow sutil
- Backgrounds con gradient semi-transparente (glassmorphism light)
- Micro-animaciones en hover/click
- Sonidos de feedback en cada acción de UI
- Transiciones suaves entre estados (build → combat → reward)

---

# 15. RETENTION & REPLAYABILITY

## Hooks de Retención

### Corto plazo (sesión a sesión)
| Hook | Mecanismo |
|------|----------|
| Daily Challenges | 3 desafíos diarios: "Captura 5 Élites", "Sin brecha en Difícil" |
| Login Bonus | Reward track de 7 días, reset semanal |
| "One More Game" Loop | Partidas de 15-25 min, perfectas para "una más" |
| Near-Miss Memory | "Casi capturo un Legendario... la próxima" |

### Mediano plazo (semana a semana)
| Hook | Mecanismo |
|------|----------|
| Weekly Boss | Boss especial semanal con recompensas únicas |
| Brainrotdex Progress | Avance visible en la colección global |
| Shop Unlocks | Cada nivel nuevo trae algo que desbloquear |
| Ranked Season | Tabla de clasificación semanal con rewards |

### Largo plazo (mes a mes)
| Hook | Mecanismo |
|------|----------|
| Battle Pass | 30 niveles, rewards cosméticos + Cortex |
| Seasonal Content | Nuevos Brainrots, mapas, defensas cada season |
| Prestige System | Resetear progreso por recompensas exclusivas |
| Community Events | Retos globales: "Comunidad captura 1M de Brainrots" |

## Rejugabilidad Estructural

| Factor | Cómo varía cada partida |
|--------|------------------------|
| Composición de oleadas | Semi-aleatoria, nunca 2 partidas iguales |
| Spawns de rareza | Basado en probabilidad, sorpresa constante |
| Mapa | Múltiples mapas con layouts diferentes |
| Build path | Diferentes loadouts = diferentes estrategias |
| Dificultad | 4 niveles con recompensas escaladas |
| Co-op composition | Diferentes combinaciones de jugadores |
| Risk/reward choices | ¿Cuánto arriesgo por capturas? |

## Progresión Visible

El jugador siempre debe ver:
1. Su Nivel de Guardián y cuánto falta para el siguiente
2. Su Brainrotdex y qué le falta
3. La siguiente compra alcanzable en la tienda
4. Su ranking actual y cuánto falta para subir
5. Su record personal en cada mapa/dificultad

---

# 16. MONETIZATION (Fair)

## Principio Fundamental
> **Nada que se compre con dinero real da ventaja directa en gameplay.** Todo lo premium es cosmético, social o conveniencia de tiempo.

## Streams de Monetización

### 1. Battle Pass (Synapse / Robux)
- **Costo:** 499 Robux por season (3 meses)
- **Contenido:** 30 niveles con rewards
  - Skins de defensas (visual only)
  - Skins de bóveda (visual only)
  - Emotes y títulos
  - Cortex bonus (acelerador, no exclusivo)
  - Skin de personaje
  - Trail cosmético para Brainrots capturados
- **Free track:** 15 niveles con rewards menores para no-compradores

### 2. Cosmetic Shop (Synapse)
- **Skins de defensa:** Cambian el visual de las torretas/trampas. No stats.
- **Temas de bóveda:** Cambian cómo se ve tu bóveda (Tech, Naturaleza, Neón, Infernal)
- **Skins de personaje:** Outfits para tu guardián
- **Efectos de captura:** Animaciones especiales al capturar (fuegos artificiales, confetti, rayo)
- **Efectos de kill:** Animaciones especiales al matar (explosión de estrellas, vaporización)
- **Marcos de perfil:** Bordes para tu card de jugador

### 3. Convenience (Synapse)
- **XP Boost:** +50% XP por 24 horas (no da más poder, solo sube nivel más rápido)
- **Extra loadout slot:** 1 slot adicional de loadout save (máx 3 compras)
- **Nombre coloreado:** Color de nombre en chat según preferencia
- **Private server:** Servidores privados para jugar con amigos

### 4. Lo que NUNCA se vende
- Defensas exclusivas premium
- Stats boost directos
- Brainrots exclusivos con poder
- Probabilidad de captura mejorada por pago
- Cells o Cortex por dinero real (en cantidades significativas)
- Skips de oleada o dificultad
- Nada que haga la partida más fácil para quien paga

### Modelo de ingreso estimado:
- 70% Battle Pass
- 20% Cosmetic Shop
- 10% Convenience

Este modelo respeta al jugador F2P y da razones aspiracionales para gastar sin crear frustración.
