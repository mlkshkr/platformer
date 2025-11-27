extends Area2D

# Signals
signal player_killed()
signal hit()

# Signal Methods

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		player_killed.emit()
		body.queue_free()

func _on_detonation_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		hit.emit()
