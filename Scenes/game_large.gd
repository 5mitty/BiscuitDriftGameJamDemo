extends Node3D

#@export var mob_to_spawn: PackedScene

var save_path = "user://player_data.save"
var package_score = 0
var package_scores = []
var finished_time = 0.0
var finished_times = []
var player_money_total = 0
var van_purchased = true
var taxi_purchased = false
var suv_purchased = false
var lux_purchased = false
var sedan_purchased = true
var van_price = 0
var taxi_price = 300
var suv_price = 500
var lux_price = 1000
var sedan_price = 2500
var vehicles_id = [1, 2, 3, 4, 5]
var vehicle_selected = 1
@onready var flag_respawn_1 = %FlagRespawn1
@onready var flag_respawn_2 = %FlagRespawn2
@onready var flag_respawn_3 = %FlagRespawn3
@onready var dropoff_flag_2 = $DropoffFlag2
@onready var dropoff_flag_3 = $DropoffFlag3
@onready var dropoff_flag_4 = $DropoffFlag4
@onready var player = %Player
@onready var player_2 = %Player2


var flag_respawn_points = []
var dropoff_flags = []

func _ready():
	flag_respawn_points = [flag_respawn_1, flag_respawn_2, flag_respawn_3]
	dropoff_flags = [dropoff_flag_2, dropoff_flag_3, dropoff_flag_4]
	_load_data()
	#if vehicle_selected == 1 || vehicle_selected == 2 || vehicle_selected == 4:
		##player_2.queue_free()
	#else:
		#player.queue_free()
	
func _save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(package_scores)
	file.store_var(finished_times)
	file.store_var(player_money_total)
	file.store_var(van_purchased)
	file.store_var(taxi_purchased)
	file.store_var(suv_purchased)
	file.store_var(lux_purchased)
	file.store_var(sedan_purchased)
	file.store_var(vehicle_selected)
	
func _load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		package_scores = file.get_var()
		finished_times = file.get_var()
		player_money_total = file.get_var()
		van_purchased = file.get_var()
		taxi_purchased = file.get_var()
		suv_purchased = file.get_var()
		lux_purchased = file.get_var()
		sedan_purchased = file.get_var()
		vehicle_selected = file.get_var()
	
func _spawn_flags():
	var i = 3
	while i > 0:
		i -= 1
		## Instantiate the mob scene.
		#var new_flag = mob_to_spawn.instantiate()
		## Add the new mob as a child of this spawner.
		#add_child(new_flag)
		# Set the mob's global position to the Marker3D's global position.
		dropoff_flags[i].global_position = flag_respawn_points[i].global_position
		# Emit the signal, notifying any listeners that a mob has been spawned.
		#GameScore.mob_spawned.emit(new_mob)
		print("Flag Respawn " + str(i) + ": Spawned a mob at ", dropoff_flags[i].global_position)
	
func _physics_process(delta):
	pass
	
func _process(delta):
	pass
