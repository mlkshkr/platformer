extends Node2D

# =============================================================================
# 1) CONFIG / RESOURCES
# =============================================================================

var bullet_scene: PackedScene = preload("res://scenes/props/bullet.tscn")

# =============================================================================
# 2) ENGINE CALLBACKS
# =============================================================================

func _process(delta: float) -> void:
	manage_drone_detection()

# =============================================================================
# 3) AI / DRONE LOGIC
# =============================================================================

func manage_drone_detection() -> void:
	"""
	Indica la direzione verso il giocatore che l'oggetto ottiene una volta
	che viene triggerato
	"""
	var drone := $Entities/Drone
	var player := $Entities/Player

	if drone and player:
		if drone.active:
			drone.direction = (player.position - drone.position).normalized()

# =============================================================================
# 4) SIGNAL HANDLERS
# =============================================================================

func _on_player_shoot(pos: Vector2, dir: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	$Bullets.add_child(bullet)
	bullet.setup(pos, dir)
