extends Node2D

var round_over: bool = false
var health_bars: Dictionary = {}
var special_labels: Dictionary = {}
var result_label: Label
var restart_button: Button

func _ready() -> void:
    var player1: Fighter = $Player1
    var player2: Fighter = $Player2

    player1.health_changed.connect(_on_health_changed.bind(1))
    player2.health_changed.connect(_on_health_changed.bind(2))
    player1.special_cooldown_changed.connect(_on_special_cooldown_changed.bind(1))
    player2.special_cooldown_changed.connect(_on_special_cooldown_changed.bind(2))
    player1.defeated.connect(_on_player_defeated)
    player2.defeated.connect(_on_player_defeated)

    _create_hud()

    _on_health_changed(player1.health, player1.max_health, 1)
    _on_health_changed(player2.health, player2.max_health, 2)
    _on_special_cooldown_changed(0.0, player1.circle_black_cooldown, 1)
    _on_special_cooldown_changed(0.0, player2.circle_black_cooldown, 2)

func _create_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)

    var title := Label.new()
    title.text = "BATTLE DUE"
    title.position = Vector2(0, 10)
    title.size = Vector2(1280, 42)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0, 1.0))
    title.add_theme_color_override("font_shadow_color", Color(0.08, 0.02, 0.14, 1.0))
    title.add_theme_constant_override("shadow_offset_x", 2)
    title.add_theme_constant_override("shadow_offset_y", 3)
    title.add_theme_font_size_override("font_size", 30)
    layer.add_child(title)

    for player_number in [1, 2]:
        var label := Label.new()
        label.text = "NEGOTU  ·  JUGADOR %d" % player_number
        label.position = Vector2(40 if player_number == 1 else 900, 55)
        label.size = Vector2(340, 26)
        label.horizontal_alignment = (
            HORIZONTAL_ALIGNMENT_LEFT
            if player_number == 1
            else HORIZONTAL_ALIGNMENT_RIGHT
        )
        label.add_theme_color_override("font_color", Color(0.95, 0.9, 1.0, 1.0))
        label.add_theme_color_override("font_shadow_color", Color(0.04, 0.02, 0.08, 1.0))
        label.add_theme_constant_override("shadow_offset_x", 1)
        label.add_theme_constant_override("shadow_offset_y", 2)
        label.add_theme_font_size_override("font_size", 20)
        layer.add_child(label)

        var bar := ProgressBar.new()
        bar.position = Vector2(40 if player_number == 1 else 900, 85)
        bar.size = Vector2(340, 28)
        bar.min_value = 0
        bar.max_value = 100
        bar.value = 100
        bar.show_percentage = true
        bar.fill_mode = (
            ProgressBar.FILL_BEGIN_TO_END
            if player_number == 1
            else ProgressBar.FILL_END_TO_BEGIN
        )
        bar.add_theme_font_size_override("font_size", 16)
        bar.add_theme_color_override("font_color", Color.WHITE)
        bar.add_theme_color_override("font_outline_color", Color(0.06, 0.02, 0.1, 1.0))
        bar.add_theme_constant_override("outline_size", 3)
        bar.add_theme_stylebox_override(
            "background",
            _create_bar_style(Color(0.06, 0.04, 0.12, 0.9), Color(0.56, 0.32, 0.9, 1.0))
        )
        bar.add_theme_stylebox_override(
            "fill",
            _create_bar_style(
                Color(0.48, 0.12, 0.72, 1.0)
                if player_number == 1
                else Color(0.18, 0.52, 0.92, 1.0),
                Color(0.88, 0.72, 1.0, 1.0)
            )
        )
        layer.add_child(bar)
        health_bars[player_number] = bar

        var special_label := Label.new()
        special_label.position = Vector2(40 if player_number == 1 else 900, 116)
        special_label.size = Vector2(340, 22)
        special_label.horizontal_alignment = (
            HORIZONTAL_ALIGNMENT_LEFT
            if player_number == 1
            else HORIZONTAL_ALIGNMENT_RIGHT
        )
        special_label.add_theme_font_size_override("font_size", 14)
        layer.add_child(special_label)
        special_labels[player_number] = special_label

    var controls := Label.new()
    controls.text = "P1  A/D mover · W saltar · S bloquear · J/K atacar · L especial       P2  Flechas mover · ↓ bloquear · U/I atacar · O especial"
    controls.position = Vector2(40, 675)
    controls.size = Vector2(1200, 24)
    controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    controls.add_theme_color_override("font_color", Color(0.79, 0.73, 0.92, 0.9))
    controls.add_theme_font_size_override("font_size", 14)
    layer.add_child(controls)

    result_label = Label.new()
    result_label.position = Vector2(400, 210)
    result_label.size = Vector2(480, 70)
    result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    result_label.add_theme_font_size_override("font_size", 32)
    result_label.visible = false
    layer.add_child(result_label)

    restart_button = Button.new()
    restart_button.text = "REINICIAR RONDA"
    restart_button.position = Vector2(530, 285)
    restart_button.size = Vector2(220, 45)
    restart_button.visible = false
    restart_button.pressed.connect(_restart_round)
    layer.add_child(restart_button)

func _on_health_changed(
    current_health: int,
    maximum_health: int,
    player_number: int
) -> void:
    if health_bars.has(player_number):
        var bar: ProgressBar = health_bars[player_number]
        bar.max_value = maximum_health
        bar.value = current_health

func _on_player_defeated(loser_number: int) -> void:
    if round_over:
        return

    round_over = true
    result_label.text = "¡JUGADOR %d GANA!" % (3 - loser_number)
    result_label.visible = true
    restart_button.visible = true

func _on_special_cooldown_changed(
    remaining_seconds: float,
    _total_seconds: float,
    player_number: int
) -> void:
    if not special_labels.has(player_number):
        return

    var label: Label = special_labels[player_number]
    if remaining_seconds <= 0.0:
        label.text = "CÍRCULO NEGRO  ·  LISTO"
        label.add_theme_color_override("font_color", Color(0.78, 0.5, 1.0, 1.0))
    else:
        label.text = "CÍRCULO NEGRO  ·  %0.1f s" % remaining_seconds
        label.add_theme_color_override("font_color", Color(0.58, 0.42, 0.7, 1.0))

func _restart_round() -> void:
    get_tree().reload_current_scene()

func _create_bar_style(background: Color, border: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = background
    style.border_color = border
    style.set_border_width_all(2)
    style.corner_radius_top_left = 7
    style.corner_radius_top_right = 7
    style.corner_radius_bottom_left = 7
    style.corner_radius_bottom_right = 7
    return style
