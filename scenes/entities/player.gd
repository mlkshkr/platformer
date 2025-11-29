extends CharacterBody2D

# =============================================================================
# 1) CONFIG / EXPORT VARIABLES
# =============================================================================

# --- Movement ---
@export var speed: float = 300.0
@export var jump_strength: float = 400
@export var gravity: float = 1000.0

# --- Jump System ---
@export var coyote_time_max: float = 0.15
@export var jump_buffer_time: float = 0.15

# --- Animation ---
var gun_directions := {
	Vector2i(1,0): 0, Vector2i(1,1): 1, Vector2i(0,1): 2, Vector2i(-1,1): 3,
	Vector2i(-1,0): 4, Vector2i(-1,-1): 5, Vector2i(0,-1): 6, Vector2i(1,-1): 7,
}

# --- Combat Scenes ---
var hitbox_scene: PackedScene = preload("res://scenes/actions/hitbox.tscn")
var shieldbox_scene: PackedScene = preload("res://scenes/actions/shieldbox.tscn")
var combo_1_scene: PackedScene = preload("res://scenes/actions/combo_1.tscn")

# =============================================================================
# 2) STATE VARIABLES
# =============================================================================

# Movement
var direction_x: float = 0.0

# Jump system
var coyote_time: float = 0.0
var jump_buffer: float = 0.0

# Combat
var is_melee_attacking: bool = false
var combo_index: String = ""

# Animation
var animation_state: String = "idle"

# Life
var is_gameover: bool = false

# Signals
signal shoot(pos: Vector2, dir: Vector2)

# =============================================================================
# 3) ENGINE CALLBACKS
# =============================================================================

func _ready() -> void:
	pass # no longer using timers

func _physics_process(delta: float) -> void:

	# --- Movement Core ---
	apply_gravity(delta)
	set_direction_x()

	# --- Jump System ---
	update_coyote_time(delta)
	update_jump_buffer(delta)
	try_jump()

	# --- Combat / Input ---
	check_shoot()
	melee_attack()
	parry()
	detect_combo_1()

	# --- Engine Move ---
	move_and_slide()

	# --- Animation ---
	animations()

# =============================================================================
# 4) MOVEMENT SYSTEM
# =============================================================================

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func set_direction_x() -> void:
	direction_x = Input.get_axis("left", "right")
	velocity.x = direction_x * speed

# =============================================================================
# 5) JUMP SYSTEM (Coyote + Buffer)
# =============================================================================

func update_coyote_time(delta: float) -> void:
	if is_on_floor():
		coyote_time = coyote_time_max
	else:
		coyote_time = max(coyote_time - delta, 0.0)

func update_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_time
	if jump_buffer > 0.0:
		jump_buffer = max(jump_buffer - delta, 0.0)

func try_jump() -> void:
	if jump_buffer > 0.0 and (is_on_floor() or coyote_time > 0.0):
		velocity.y = -jump_strength
		jump_buffer = 0.0
		coyote_time = 0.0

# =============================================================================
# 6) SHOOT SYSTEM
# =============================================================================

func check_shoot() -> void:
	if Input.is_action_just_pressed("shoot") and $ReloadTimer.time_left == 0:
		shoot.emit(position, get_local_mouse_position().normalized())
		$ReloadTimer.start()

		var tween = get_tree().create_tween()
		tween.tween_property($Marker, "scale", Vector2(0.1,0.1), 0.2)
		tween.tween_property($Marker, "scale", Vector2(0.2,0.2), 0.4)

# =============================================================================
# 7) COMBAT SYSTEM (Melee + Parry)
# =============================================================================

func melee_attack() -> void:
	if Input.is_action_just_pressed("melee_attack") \
	and not Input.is_action_just_pressed("parry"):
		var hitbox = hitbox_scene.instantiate()
		owner.add_child(hitbox)
		hitbox.position = get_melee_range()

func parry() -> void:
	if Input.is_action_just_pressed("parry") \
	and not Input.is_action_just_pressed("melee"):
		var shieldbox = shieldbox_scene.instantiate()
		owner.add_child(shieldbox)
		shieldbox.position = get_melee_range()

# =============================================================================
# 8) COMBO SYSTEM
# =============================================================================

func detect_combo_1() -> void:
	if Input.is_key_pressed(KEY_I):
		combo_index = "I"
		get_tree().create_timer(0.5).timeout.connect(reset_combo)

	if Input.is_key_pressed(KEY_J) and combo_index == "I":
		combo_index = "J"
		get_tree().create_timer(0.5).timeout.connect(reset_combo)

	if Input.is_key_pressed(KEY_K) and combo_index == "J":
		var instance = combo_1_scene.instantiate()
		instance.position = get_melee_range()
		owner.add_child(instance)

func reset_combo() -> void:
	combo_index = ""

# =============================================================================
# 9) ANIMATION SYSTEM
# =============================================================================

func animations() -> void:
	movement_animation()

func movement_animation() -> void:
	move_legs()
	move_torso()
	move_marker()

func move_legs() -> void:
	$Legs.flip_h = direction_x < 0

	if is_on_floor():
		if direction_x != 0:
			animation_state = "run"
		else:
			animation_state = "idle"
	else:
		if velocity.y < 0:
			animation_state = "jump"

	$AnimationPlayer.current_animation = animation_state

func move_torso() -> void:
	var mouse_pos := get_local_mouse_position().normalized()
	var adjusted := Vector2i(round(mouse_pos.x), round(mouse_pos.y))
	$Torso.frame = gun_directions[adjusted]

func move_marker() -> void:
	$Marker.position = get_local_mouse_position().normalized() * 40

# =============================================================================
# 10) UTILITY METHODS
# =============================================================================

func get_melee_range() -> Vector2:
	return position + 10 * get_local_mouse_position().normalized()
