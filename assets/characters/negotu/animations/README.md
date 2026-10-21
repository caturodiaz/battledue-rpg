# Negotu animation sources

This directory is reserved for **new, isolated** animation frames. Do not place
crops from `Six-Frame Anime Ronin Sprite Sheet.png` here: its poses overlap and
cannot be split without retaining parts of neighbouring poses.

Use one transparent 768×768 PNG per frame. Keep Negotu's feet on the same
bottom-centre baseline in every frame; do not resize the drawing to force it
into the canvas.

Expected filenames:

- `idle_01.png`, `idle_02.png`, ...
- `walk_01.png`, `walk_02.png`, ...
- `jump_takeoff.png`, `jump_rise.png`, `jump_fall.png`
- `light_attack_startup.png`, `light_attack_active.png`, `light_attack_recovery.png`
- `heavy_attack_startup.png`, `heavy_attack_active.png`, `heavy_attack_recovery.png`
- `block_01.png`, `hit_01.png`, `defeat_01.png`
- `circle_black_startup.png`, `circle_black_active.png`, `circle_black_recovery.png`

The Godot integration uses an `AnimatedSprite2D` and a `SpriteFrames` resource.
The temporary v1 set includes only `idle_01`, `walk_01`, `walk_02`, and
`block_01`; jump, attacks, hit, defeat, and special animation art are still
pending and deliberately fall back to idle.
