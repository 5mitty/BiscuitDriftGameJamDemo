extends Node3D

#signal mob_spawned(mob)

 #= preload("")
@export var mob_to_spawn: PackedScene = preload("res://Scenes/flag_2.tscn")
#@onready var spawn_manager_timer = get_parent().%Spawn_Manager_Timer

@onready var marker_3d = %Marker3D
#@onready var spawn_timer = %SpawnTimer


func _ready():
	# Connect the timer's timeout signal to the internal spawning function.
	# This allows the spawner to spawn mobs independently if its timer is active.
	#if spawn_timer:
		#spawn_timer.timeout.connect(_on_timer_timeout)
	pass

# --- Internal Spawning Logic ---
# This private function encapsulates the actual mob spawning process.
func _spawn_single_mob():
	var i = 3
	while i > 0:
		i -= 1
		# Instantiate the mob scene.
		var new_flag = mob_to_spawn.instantiate()
		# Add the new mob as a child of this spawner.
		add_child(new_flag)
		# Set the mob's global position to the Marker3D's global position.
		new_flag.global_position = marker_3d.global_position
		# Emit the signal, notifying any listeners that a mob has been spawned.
		#GameScore.mob_spawned.emit(new_mob)
		print("Flag Respawn " + i + ": Spawned a mob at ", new_flag.global_position)

# --- Timer Callback (for self-spawning) ---
# This function is called when the internal spawn_timer times out.
#func _on_timer_timeout():
	##_spawn_single_mob()
	#pass

# --- Public Function for Manager to Call ---
# This function is exposed so that the MobSpawnerManager3D can
# explicitly tell this spawner to spawn a mob.
func spawn_mob_from_manager():
	_spawn_single_mob()
	print("MobSpawner3D: Triggered to spawn by manager.")
#

	
