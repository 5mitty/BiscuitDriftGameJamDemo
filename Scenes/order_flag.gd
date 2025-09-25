extends Node3D

#var is_collected = false
#if not is_collected:
			#is_collected = true

#@onready var dropoff_flag_area = %DropoffFlagArea
@onready var order_flag_area = %OrderFlagArea
@onready var flag_area = %FlagArea
@onready var player = $"../Player"

var isGrabbingPackages = false

#
func _ready():
	order_flag_area.area_entered.connect(_on_order_flag_area_body_entered)
	flag_area.area_entered.connect(_on_flag_area_body_entered)
	#dropoff_flag_area.area_entered.connect(_on_dropoff_flag_area_body_entered)


#func _on_flag_area_area_entered(area):
	#pass


#func _on_flag_area_body_entered(body):
	#print("Deleting: " + str(body))
	#
	#if body.name == "Player":
		#print("ENTERED FLAG AREA DELETING FLAG BCUZ: " + str(body))
		##get_parent()._flag_collected()
		#queue_free()


#func _on_order_flag_area_body_entered(body):
	#print("Deleting: " + str(body))
	#
	#if body.name == "Player":
		#print("ENTERED FLAG AREA DELETING FLAG BCUZ: " + str(body))
		##get_parent()._flag_collected()
		#queue_free()

func _on_order_flag_area_body_entered(body):
	queue_free()

func _on_flag_area_body_entered(body):
	if player.orders_placed >= 3 || player.isInPickup == true:
		queue_free()
	else:
		print("NOT PICKING UP PACKAGE")

#func _on_dropoff_flag_area_body_entered(body):
	#queue_free()
	#print(str(body))
