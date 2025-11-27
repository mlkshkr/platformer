extends Node2D

var bullet_scene: PackedScene = preload("res://bullet.tscn")

# Base Methods

func _process(delta: float) -> void:
	manage_drone_detection()

# Other Methods

func manage_drone_detection():
	if $Entities/Drone and $Entities/Player:
		if $Entities/Drone.active:
			$Entities/Drone.direction = (
				$Entities/Player.position - $Entities/Drone.position
			).normalized()

# Signals

func _on_player_shoot(pos: Vector2, dir: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	$Bullets.add_child(bullet)
	bullet.setup(pos, dir)
