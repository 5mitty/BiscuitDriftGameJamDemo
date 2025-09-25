extends VehicleBody3D

@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 400
@onready var force_steering_label = %ForceSteeringLabel
var steer_display = 0.0
var steer_text_from_int = ""
var force_display = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER
	
	steer_display = snapped(steering, 0.1)
	if steer_display > 0.2:
		steer_text_from_int = "Left"
	elif steer_display <= -0.2:
		steer_text_from_int = "Right"
	else:
		steer_text_from_int = "Centered"
	
	#str(steer_display)
	%ForceSteeringLabel.text = "Force: " + str(engine_force) + " Steering: " + steer_text_from_int
