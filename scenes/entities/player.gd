extends CharacterBody2D

# LIFE
var is_gameover: bool

# FIGHT
var is_melee_attacking: bool
var hitbox_scene: PackedScene = preload("res://scenes/actions/hitbox.tscn")
var shieldbox_scene: PackedScene = preload("res://scenes/actions/shieldbox.tscn")
var combo_1_scene: PackedScene = preload("res://scenes/actions/combo_1.tscn")
var combo_index = ""

func detect_combo_1():
	if Input.is_key_pressed(KEY_I):
		combo_index = "I"
		get_tree().create_timer(0.5).timeout.connect(reset_combo)
	if Input.is_key_pressed(KEY_J) and combo_index == "I":
		combo_index = "J"
		get_tree().create_timer(0.5).timeout.connect(reset_combo)
	if Input.is_key_pressed(KEY_K) and combo_index == "J":
		var combo_1_instance = combo_1_scene.instantiate()
		combo_1_instance.position = get_melee_range()
		owner.add_child(combo_1_instance)

func get_melee_range():
	return position + 10 * get_local_mouse_position().normalized()

func reset_combo():
	combo_index = ""
# Movement

# animation
var animation_state: String = 'idle'
var gun_directions = {
	Vector2i(1,0): 0,
	Vector2i(1,1): 1,
	Vector2i(0,1): 2,
	Vector2i(-1,1): 3,
	Vector2i(-1,0): 4,
	Vector2i(-1,-1): 5,
	Vector2i(0,-1): 6,
	Vector2i(1,-1): 7,
}

# base movement
@export var speed = 300.0
@export var direction_x: float
# jump
@export var jump_strength := 200
@export var gravity = 10

# SIGNALS
signal shoot(pos: Vector2, dir: Vector2)

# Base Methods

func _physics_process(delta: float) -> void:
	manage_input(delta)
	melee_attack()
	parry()
	move_and_slide()
	detect_combo_1()

# Other Methods

# INPUT
func manage_input(delta):
	animation()
	check_shoot()
	set_direction_x()
	check_jump()
	apply_gravity(delta)

# Movement methods
func check_jump():
	if Input.is_action_just_pressed('jump'):
		velocity.y = -jump_strength

func check_shoot():
	if Input.is_action_just_pressed('shoot') and $ReloadTimer.time_left == 0:
		shoot.emit(position, get_local_mouse_position().normalized()) # Normalize to get only the direction -1,1
		$ReloadTimer.start()
		var tween = get_tree().create_tween()
		tween.tween_property($Marker, "scale", Vector2(0.1,0.1), 0.2)
		tween.tween_property($Marker, "scale", Vector2(0.2,0.2), 0.4)

func set_direction_x():
	direction_x = Input.get_axis("left", "right")
	velocity.x = direction_x * speed;

func apply_gravity(delta):
	velocity.y += gravity * delta

# ANIMATION

func animation():
	movement_animation()

func movement_animation():
	move_legs()
	move_torso()
	move_marker()

func move_legs():
	$Legs.flip_h = direction_x < 0
	if is_on_floor():
		if direction_x:
			animation_state = 'run'
		else:
			animation_state = 'idle'
	else:
		if velocity.y < 0:
			animation_state = 'jump'
	$AnimationPlayer.current_animation = animation_state

func move_torso():
	var mouse_pos = get_local_mouse_position().normalized()
	var adjusted_dir = Vector2i(round(mouse_pos.x), round(mouse_pos.y))
	$Torso.frame = gun_directions[adjusted_dir]

func move_marker():
	$Marker.position = get_local_mouse_position().normalized() * 40

# Fight Methods

func melee_attack():
	if Input.is_action_just_pressed("melee_attack") and not Input.is_action_just_pressed("parry"):
		var hitbox = hitbox_scene.instantiate()
		owner.add_child(hitbox)
		hitbox.position = get_melee_range()

func parry():
	if Input.is_action_just_pressed("parry") and not Input.is_action_just_pressed("melee"):
		var shieldbox = shieldbox_scene.instantiate()
		owner.add_child(shieldbox)
		shieldbox.position = get_melee_range()
