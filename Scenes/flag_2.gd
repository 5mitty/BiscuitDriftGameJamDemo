extends Node3D

@onready var flag_area = $FlagArea

func _on_flag_area_body_entered(_body):
	hide()
	flag_area.set_deferred("monitoring", false)
	flag_area.set_deferred("monitorable", false)
