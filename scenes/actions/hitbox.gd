extends Area2D


func _ready() -> void:
	get_tree().create_timer(0.3).timeout.connect(queue_free)
