extends CharacterBody2D
class_name Fighter

signal health_changed(current_health: int, maximum_health: int)
signal defeated(player_number: int)
signal special_cooldown_changed(remaining_seconds: float, total_seconds: float)

@export var player_number: int = 1
@export var move_speed: float = 320.0
@export var jump_velocity: float = -600.0
@export var max_health: int = 100
@export var circle_black_damage: int = 16
@export var circle_black_range: float = 180.0
@export var circle_black_startup: float = 0.22
@export var circle_black_recovery: float = 0.55
@export var circle_black_cooldown: float = 4.5

var health: int = 100
var facing: int = 1
var is_attacking: bool = false
var is_blocking: bool = false
var attack_cooldown: float = 0.0
var attack_animation: StringName = &""
var attack_sequence: int = 0
var attack_is_active: bool = false
var special_cooldown_remaining: float = 0.0
var hit_stun_remaining: float = 0.0
var hit_flash_remaining: float = 0.0
var last_hit_was_blocked: bool = false
var is_defeated: bool = false
var fighter_visual: AnimatedSprite2D
var normal_color: Color
var jump_takeoff_remaining: float = 0.0
var jump_landing_remaining: float = 0.0
var was_on_floor: bool = true


func _ready() -> void:
	fighter_visual = get_node_or_null("Visual") as AnimatedSprite2D
	if fighter_visual != null:
		normal_color = Color.WHITE

	health = max_health
	add_to_group("fighters")
	health_changed.emit(health, max_health)
	special_cooldown_changed.emit(special_cooldown_remaining, circle_black_cooldown)

func _physics_process(delta: float) -> void:
	if is_defeated:
		velocity = Vector2.ZERO
		_update_visual_animation()
		return

	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if special_cooldown_remaining > 0.0:
		special_cooldown_remaining = maxf(0.0, special_cooldown_remaining - delta)
		special_cooldown_changed.emit(
			special_cooldown_remaining,
			circle_black_cooldown
		)
	if hit_flash_remaining > 0.0:
		hit_flash_remaining = maxf(0.0, hit_flash_remaining - delta)

	if hit_stun_remaining > 0.0:
		hit_stun_remaining = maxf(0.0, hit_stun_remaining - delta)
		is_blocking = false
		if not is_on_floor():
			velocity += get_gravity() * delta
		_update_visual_tint()
		move_and_slide()

		if is_on_floor() and not was_on_floor:
			jump_landing_remaining = 0.12
			jump_takeoff_remaining = 0.0

		was_on_floor = is_on_floor()
		jump_takeoff_remaining = maxf(0.0, jump_takeoff_remaining - delta)
		jump_landing_remaining = maxf(0.0, jump_landing_remaining - delta)

		_update_visual_animation()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis(
		"p%d_left" % player_number,
		"p%d_right" % player_number
	)

	var wants_to_block := Input.is_action_pressed(
		"p%d_down" % player_number
	)
	velocity.x = 0.0 if wants_to_block or is_attacking else direction * move_speed

	is_blocking = wants_to_block and not is_attacking

	_update_visual_tint()

	# Mirar hacia el rival más cercano.
	var nearest_opponent: Fighter = null
	var nearest_distance: float = INF

	for fighter in get_tree().get_nodes_in_group("fighters"):
		if not (fighter is Fighter) or fighter == self:
			continue
		if fighter.is_defeated:
			continue

		var distance: float = absf(
			fighter.global_position.x - global_position.x
		)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_opponent = fighter

	if nearest_opponent != null:
		facing = 1 if nearest_opponent.global_position.x > global_position.x else -1

	if fighter_visual != null:
		fighter_visual.flip_h = facing < 0

	if not is_blocking and Input.is_action_just_pressed("p%d_jump" % player_number):
		if is_on_floor():
			velocity.y = jump_velocity
			jump_takeoff_remaining = 0.12
			jump_landing_remaining = 0.0

	if not is_blocking and Input.is_action_just_pressed("p%d_light" % player_number):
		try_attack(10, 145.0, 0.12, 0.35, &"light_attack")

	if not is_blocking and Input.is_action_just_pressed("p%d_heavy" % player_number):
		try_attack(20, 150.0, 0.24, 0.70, &"heavy_attack")

	if not is_blocking and Input.is_action_just_pressed("p%d_special" % player_number):
		try_circle_black()

	move_and_slide()

	if is_on_floor() and not was_on_floor:
		jump_landing_remaining = 0.12
		jump_takeoff_remaining = 0.0

	was_on_floor = is_on_floor()
	jump_takeoff_remaining = maxf(0.0, jump_takeoff_remaining - delta)
	jump_landing_remaining = maxf(0.0, jump_landing_remaining - delta)

	_update_visual_animation()


func _update_visual_animation() -> void:
	if fighter_visual == null or fighter_visual.sprite_frames == null:
		return

	var requested_animation: StringName = &"idle"
	if is_defeated:
		requested_animation = &"defeat"
	elif hit_stun_remaining > 0.0:
		requested_animation = &"hit"
	elif is_attacking:
		requested_animation = attack_animation
	elif is_blocking:
		requested_animation = &"block"
	elif jump_landing_remaining > 0.0:
		requested_animation = &"jump_land"
	elif not is_on_floor():
		if jump_takeoff_remaining > 0.0:
			requested_animation = &"jump_takeoff"
		elif velocity.y < -120.0:
			requested_animation = &"jump_rise"
		elif velocity.y > 120.0:
			requested_animation = &"jump_fall"
		else:
			requested_animation = &"jump_apex"
	elif absf(velocity.x) > 10.0:
		requested_animation = &"walk"

	# Missing action art intentionally falls back to idle rather than pretending it
	# exists. The current temporary set includes visible light and heavy strikes.
	if not fighter_visual.sprite_frames.has_animation(requested_animation):
		requested_animation = &"idle"

	if fighter_visual.animation != requested_animation:
		fighter_visual.play(requested_animation)


func _update_visual_tint() -> void:
	if fighter_visual == null:
		return

	if hit_flash_remaining > 0.0:
		fighter_visual.modulate = (
			Color(0.3, 0.85, 1.0, 1.0)
			if last_hit_was_blocked
			else Color(1.0, 0.42, 0.42, 1.0)
		)
	elif is_blocking:
		fighter_visual.modulate = Color(0.25, 0.75, 1.0, 1.0)
	else:
		fighter_visual.modulate = normal_color

func try_attack(
	damage: int,
	reach: float,
	startup: float,
	recovery: float,
	animation_name: StringName
) -> void:
	if is_defeated or is_attacking or attack_cooldown > 0.0:
		return

	attack_cooldown = startup + recovery
	is_attacking = true
	attack_animation = animation_name
	attack_sequence += 1
	attack_is_active = false
	var sequence_id: int = attack_sequence

	await get_tree().create_timer(startup).timeout
	if is_defeated or sequence_id != attack_sequence:
		is_attacking = false
		attack_animation = &""
		attack_is_active = false
		return

	attack_is_active = true
	var target := _find_attack_target(reach)
	if target != null:
		target.take_damage(damage, global_position.x)

	await get_tree().create_timer(recovery).timeout
	if sequence_id != attack_sequence:
		return
	is_attacking = false
	attack_animation = &""
	attack_is_active = false


func _find_attack_target(reach: float) -> Fighter:

	var target: Fighter = null
	var nearest_distance := reach + 1.0

	for fighter in get_tree().get_nodes_in_group("fighters"):
		if fighter == self or not fighter is Fighter:
			continue
		if fighter.is_defeated:
			continue

		var distance: float = fighter.global_position.x - global_position.x
		var in_front: bool = sign(distance) == facing

		if (
			in_front
			and absf(distance) <= reach
			and absf(fighter.global_position.y - global_position.y) < 90.0
		):
			if absf(distance) < nearest_distance:
				nearest_distance = absf(distance)
				target = fighter

	return target


func try_circle_black() -> void:
	if (
		is_defeated
		or is_attacking
		or attack_cooldown > 0.0
		or special_cooldown_remaining > 0.0
	):
		return

	is_attacking = true
	attack_is_active = false
	attack_animation = &"circle_black"
	attack_cooldown = circle_black_startup + circle_black_recovery
	attack_sequence += 1
	var sequence_id: int = attack_sequence
	special_cooldown_remaining = circle_black_cooldown
	special_cooldown_changed.emit(
		special_cooldown_remaining,
		circle_black_cooldown
	)

	await get_tree().create_timer(circle_black_startup).timeout
	if is_defeated or sequence_id != attack_sequence:
		is_attacking = false
		attack_animation = &""
		attack_is_active = false
		return

	attack_is_active = true
	var target := _find_attack_target(circle_black_range)
	var effect_position := global_position + Vector2(facing * 120.0, -65.0)
	if target != null:
		effect_position = target.global_position + Vector2(0.0, -65.0)
		target.take_damage(circle_black_damage, global_position.x)
	_spawn_circle_black_effect(effect_position)

	await get_tree().create_timer(circle_black_recovery).timeout
	if sequence_id != attack_sequence:
		return
	is_attacking = false
	attack_animation = &""
	attack_is_active = false

func take_damage(amount: int, attacker_x: float) -> void:
	if is_defeated:
		return

	var final_damage: int = amount
	var attacker_direction: float = signf(attacker_x - global_position.x)
	var attacker_in_front: bool = attacker_direction == float(facing)
	var was_blocked: bool = is_blocking and attacker_in_front

	if was_blocked:
		final_damage = maxi(1, int(ceil(amount * 0.25)))
		print("¡Jugador %d bloqueó el golpe!" % player_number)

	health = maxi(0, health - final_damage)
	health_changed.emit(health, max_health)

	print(
        "Jugador %d recibió %d de daño. Vida: %d / %d"
		% [player_number, final_damage, health, max_health]
	)

	attack_sequence += 1
	is_attacking = false
	attack_animation = &""
	attack_is_active = false
	is_blocking = false
	hit_stun_remaining = 0.08 if was_blocked else 0.16
	hit_flash_remaining = 0.08
	last_hit_was_blocked = was_blocked
	var knockback_direction: float = -attacker_direction
	if is_zero_approx(knockback_direction):
		knockback_direction = -float(facing)
	velocity.x = knockback_direction * (105.0 if was_blocked else 245.0)
	_spawn_impact_effect(attacker_x, was_blocked)

	if health == 0:
		is_defeated = true
		velocity = Vector2.ZERO
		defeated.emit(player_number)


func _spawn_impact_effect(attacker_x: float, was_blocked: bool) -> void:
	var arena := get_parent()
	if arena == null:
		return

	var effect := Node2D.new()
	effect.global_position = Vector2(
		(attacker_x + global_position.x) * 0.5,
		global_position.y - 65.0
	)
	effect.z_index = 10
	arena.add_child(effect)

	var effect_color := (
		Color(0.3, 0.85, 1.0, 1.0)
		if was_blocked
		else Color(1.0, 0.82, 0.25, 1.0)
	)
	var spark_angles: PackedFloat32Array = PackedFloat32Array([
		-2.35, -1.55, -0.75, 0.05
	])
	for angle in spark_angles:
		var spark := Line2D.new()
		spark.default_color = effect_color
		spark.width = 4.0
		spark.points = PackedVector2Array([
			Vector2.ZERO,
			Vector2.from_angle(angle) * 28.0
		])
		effect.add_child(spark)

	var tween := effect.create_tween()
	tween.parallel().tween_property(effect, "scale", Vector2(1.65, 1.65), 0.12)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.12)
	tween.tween_callback(effect.queue_free)


func _spawn_circle_black_effect(effect_position: Vector2) -> void:
	var arena := get_parent()
	if arena == null:
		return

	var effect := Node2D.new()
	effect.global_position = effect_position
	effect.z_index = 9
	arena.add_child(effect)

	for radius in [20.0, 34.0, 50.0]:
		var ring := Line2D.new()
		ring.default_color = Color(0.4, 0.04, 0.75, 0.92)
		ring.width = 4.0 if radius < 50.0 else 2.0
		ring.points = _create_circle_points(radius, 24)
		effect.add_child(ring)

	var core := Polygon2D.new()
	core.polygon = _create_circle_points(13.0, 20)
	core.color = Color(0.12, 0.01, 0.22, 0.9)
	effect.add_child(core)

	var tween := effect.create_tween()
	tween.parallel().tween_property(effect, "scale", Vector2(2.4, 2.4), 0.32)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.32)
	tween.tween_callback(effect.queue_free)


func _create_circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments + 1):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector2.from_angle(angle) * radius)
	return points
