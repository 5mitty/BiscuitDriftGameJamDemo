extends Node3D

@onready var dropoff_flag_area = $DropoffFlagArea
@onready var player = $"../Player"

func _on_dropoff_flag_area_body_entered(_body):
	if player.isInDropoff:
		hide()
		dropoff_flag_area.set_deferred("monitoring", false)
		dropoff_flag_area.set_deferred("monitorable", false)
