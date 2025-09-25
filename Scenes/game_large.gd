extends Node3D

#@export var mob_to_spawn: PackedScene

@onready var flag_respawn_1 = %FlagRespawn1
@onready var flag_respawn_2 = %FlagRespawn2
@onready var flag_respawn_3 = %FlagRespawn3
@onready var dropoff_flag_2 = $DropoffFlag2
@onready var dropoff_flag_3 = $DropoffFlag3
@onready var dropoff_flag_4 = $DropoffFlag4


var flag_respawn_points = []
var dropoff_flags = []

func _ready():
	flag_respawn_points = [flag_respawn_1, flag_respawn_2, flag_respawn_3]
	dropoff_flags = [dropoff_flag_2, dropoff_flag_3, dropoff_flag_4]
	
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
