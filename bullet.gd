extends Area2D

@export var speed: float = 150
@export var direction: Vector2

# Base Methods

func _ready() -> void:
	add_to_group("bullets")
	var shoot_tween = get_tree().create_tween()
	shoot_tween.tween_property($Sprite2D, "scale", Vector2.ONE, 0.5).from(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	position += direction * speed

# Other Methods

func setup(pos: Vector2, dir: Vector2):
	position = pos + dir * 16
	direction = dir
