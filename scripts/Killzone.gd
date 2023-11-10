extends Area2D

signal on_player_killed_by_zone

func _on_body_entered(body):
	on_player_killed_by_zone.emit()
