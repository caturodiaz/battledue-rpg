# Battle Due — estado de desarrollo

## Fase 1: auditoría y estabilización

### Estado comprobado

- El proyecto configura Godot 4 con `scenes/main.tscn` como escena principal.
- Hay dos luchadores locales: P1 usa `A/D/W/S/J/K` y P2 las flechas más `U/I`.
- Las barras de vida, la derrota y el reinicio de ronda están conectados en
  `scripts/main.gd`.
- `scripts/fighter.gd` implementa movimiento, salto, orientación frente al rival,
  bloqueo direccional y dos ataques básicos.

### Estabilización aplicada

- El cuerpo de colisión del luchador ahora tiene 105 px de ancho, que coincide con
  la distancia mínima que el prototipo imponía manualmente.
- Se retiró esa corrección manual posterior al movimiento. La separación entre
  luchadores se resuelve mediante las colisiones de `CharacterBody2D`, evitando
  empujes duplicados y vibración al estar muy cerca.
- Se añadieron paredes físicas a ambos extremos de la arena para impedir que los
  luchadores abandonen el escenario.

### Auditoría de recursos de Negotu

- `negotu_idle.png` existe (1281×1227 RGBA) y es la textura actualmente usada por
  `scenes/fighter.tscn`.
- `Six-Frame Anime Ronin Sprite Sheet.png` existe (2172×724 RGBA). Contiene seis
  poses con encuadres desiguales; no debe cortarse como una cuadrícula uniforme.
- Los originales se mantienen intactos. La extracción de poses individuales queda
  para la fase 2.

### Pendiente inmediato

- La lógica actual selecciona y daña al objetivo antes de esperar el `startup` del
  ataque; se corregirá al implementar las fases de ataque en la fase 4.
- No hay ejecutable de Godot disponible en este entorno, por lo que falta ejecutar
  la escena y comprobar las colisiones de forma interactiva en Godot 4.7.2.

## Fase 2: preparación de recursos

### Resultado de la auditoría visual

- La hoja rotulada como seis cuadros representa, de izquierda a derecha, poses de
  idle, desplazamiento, salto, corte bajo, corte alto y bloqueo.
- No es una hoja de sprites convencional: los primeros cinco personajes se
  solapan. El análisis de transparencia encuentra una región conectada desde
  `x=9` hasta `x=1860`; no hay límites de recorte que preserven armas, capas y
  extremidades sin capturar otra pose.
- Por esa razón no se extrajeron imágenes. Los originales permanecen intactos y
  el recurso se clasifica como referencia visual, no como atlas jugable.

### Preparación para animación

- Se añadió `data/characters/negotu_sprites.json`, que registra las fuentes, las
  poses observadas, los cuadros pendientes y el contrato de integración.
- Se creó `assets/characters/negotu/animations/` con una convención de nombres y
  de encuadre para los próximos cuadros aislados.
- La arquitectura seleccionada para cuando existan cuadros válidos es
  `AnimatedSprite2D` + `SpriteFrames`: una sola fuente será responsable del
  encuadre y la orientación visual. El `Sprite2D` actual se mantiene hasta ese
  momento para no introducir una animación falsa.

## Fase 3: animaciones básicas

### Implementado

- Se generó e inspeccionó un recurso temporal derivado visualmente de Negotu. Sus
  cuatro poses aisladas se extrajeron según límites alfa medidos, no según una
  cuadrícula supuesta, y se normalizaron en lienzos PNG transparentes de 768×768
  con la misma línea de apoyo.
- `Fighter/Visual` usa ahora `AnimatedSprite2D` con `SpriteFrames` para `idle`,
  `walk` (dos pasos) y `block`.
- La selección de animación está centralizada en `Fighter`: derrota, ataque,
  bloqueo, salto, caminar e idle se derivan del estado de combate. Solo cambia
  la animación del nodo visual; no altera colisiones ni movimiento físico.
- Las animaciones sin arte válido (`jump`, ataques, `hit`, `defeat` y especial)
  vuelven explícitamente a `idle` como sustitución temporal documentada.

### Corrección posterior: caminata y ataques

- La segunda zancada original se sustituyó por una pose aislada de perfil derecho;
  el ciclo ya no alterna entre orientaciones visualmente contradictorias.
- Se añadió una pose de corte activo visible para `light_attack`. Mientras llega
  arte específico para el golpe pesado, este reutiliza explícitamente esa pose
  temporal en vez de permanecer en idle.
- El objetivo se determina al terminar `startup`, no al pulsar el botón. El daño
  se aplica una sola vez durante la ventana activa y el atacante no puede caminar,
  bloquear ni iniciar otro ataque hasta terminar la recuperación.
- El alcance ligero se ajustó a 145 px porque el anterior (90 px) era inferior a
  los 105 px de separación física mínima entre cuerpos y no podía alcanzar al
  rival. El corte visible aparece ahora al iniciar la ventana activa, sincronizado
  con el daño; el inicio ligero es de 0,12 s y el pesado de 0,24 s.

### Reacción y efectos de impacto

- Los golpes interrumpen el ataque en curso, aplican una pausa breve de impacto y
  un retroceso moderado. Los bloqueos tienen una pausa y un retroceso menores.
- El luchador impactado parpadea en rojo; al bloquear conserva un destello azul.
- Cada impacto crea cuatro destellos lineales pequeños: amarillo para golpe y azul
  para bloqueo. Se atenúan y se liberan a los 0,12 segundos, sin acumular nodos.

## Fase 5: presentación

- Se integró `assets/stages/lunar_dojos_v1.png`: una arena nocturna original de
  ruinas y montañas, preparada a 1280×720. La fuente generada se conserva como
  `lunar_dojos_source_v1.png` para trazabilidad.
- El HUD ahora identifica a Negotu, muestra vida numérica y barras con dirección
  enfrentada, y conserva los controles en un recordatorio discreto inferior.
- El fondo gris temporal del suelo fue retirado; las colisiones de suelo y paredes
  se mantienen sin cambios.

## Fase 6: primera habilidad especial — Círculo Negro

- Activación: `L` (P1) u `O` (P2). Tiene inicio de 0,22 s, alcance de 180 px,
  daño base de 16, recuperación de 0,55 s y enfriamiento de 4,5 s.
- Al activarse, un círculo violeta expansivo aparece sobre el rival si está en
  alcance, o delante del usuario si falla. El golpe pasa por la misma lógica de
  bloqueo, vida, reacción, retroceso y derrota que los ataques físicos.
- Recibir un golpe interrumpe el poder. El HUD comunica si está disponible y el
  tiempo de enfriamiento restante.
