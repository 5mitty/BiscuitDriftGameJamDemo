extends Node3D

#var is_collected = false
#if not is_collected:
			#is_collected = true

@onready var flag_area = %FlagArea
#
func _ready():
	flag_area.area_entered.connect(_on_flag_area_body_entered)



#func _on_flag_area_area_entered(area):
	#pass

#
#func _on_flag_area_body_entered(body):
	#print("Deleting: " + str(body))
	#
	#if body.name == "Player":
		#print("ENTERED FLAG AREA DELETING FLAG BCUZ: " + str(body))
		##get_parent()._flag_collected()
		#queue_free()


func _on_flag_area_body_entered(body):
	print("Deleting: " + str(body))
	queue_free()
	#
