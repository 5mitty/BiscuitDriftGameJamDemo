extends RayCast3D

@onready var force_steering_label = %ForceSteeringLabel
@onready var collider_label = %ColliderLabel

#@onready var prompt = %Prompt
@onready var player_vehicle = $".." # Assumes player is the parent node
var player_on_road = false

# The `collision_layer_3_value` is 4, because Godot's layers are powers of 2 (Layer 1=1, Layer 2=2, Layer 3=4)
const COLLISION_LAYER_3_VALUE = 4

func _physics_process(delta):
	player_on_road = false # Reset this every frame

	if is_colliding():
		var collider = get_collider()
		
		# First, check if the collider's layer includes layer 3.
		# The bitwise AND operator '&' checks if the bit for layer 3 is set.
		if collider.collision_layer & COLLISION_LAYER_3_VALUE:
			collider_label.text = "On the Road"
			#print("WOAHHH")
			player_on_road = true
		else:
			collider_label.text = "Not On the Road"
		
		#if collider.collision_layer & 2:
			#collider_label.text = "On the Ground"
			#player_on_road = false
			#print("NOOOO")
			
			# You can still use your other logic here.
			#if collider is Interactable:
				# ... your existing logic for Interactable objects on layer 3
			#raycast_text.text += collider.get_prompt()
			#if Input.is_action_pressed(collider.prompt_input):
				#collider.interact(owner)
	else:
		collider_label.text = "Not On the Road"

# You can add a function to print the status if you want to.
func _on_player_on_road_status_change(is_on_road):
	if is_on_road:
		print("Player is now on the road!")
	else:
		print("Player is no longer on the road.")
