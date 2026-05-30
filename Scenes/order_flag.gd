extends Node3D

@onready var order_flag_area = get_node_or_null("OrderFlagArea")
@onready var flag_area = get_node_or_null("FlagArea")

func _on_order_flag_area_body_entered(_body):
	hide()
	if order_flag_area:
		order_flag_area.set_deferred("monitoring", false)
		order_flag_area.set_deferred("monitorable", false)

func _on_flag_area_body_entered(_body):
	hide()
	if flag_area:
		flag_area.set_deferred("monitoring", false)
		flag_area.set_deferred("monitorable", false)
