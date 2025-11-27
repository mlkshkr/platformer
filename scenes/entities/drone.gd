extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 100
var active: bool = false
var life: int = 3

# Base Methods

func _physics_process(delta: float) -> void:
	if active:
		position += direction * speed * delta
	
# Signals
	
func _on_body_entered(body: Node2D) -> void:
	active = true

func _on_detonation_area_hit() -> void:
	life -= 1
	if life == 0:
		queue_free()
