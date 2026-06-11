extends Control

func _ready():
	var canvas    = find_child("CanvasLayer", true, false)
	canvas.visible = false
	var gas       = find_child("Gas",       true, false)
	var brake     = find_child("Brake",     true, false)
	var handbrake = find_child("Handbrake", true, false)

	gas.button_down.connect(func():       Input.action_press("ui_up"))
	gas.button_up.connect(func():         Input.action_release("ui_up"))
	brake.button_down.connect(func():     Input.action_press("ui_down"))
	brake.button_up.connect(func():       Input.action_release("ui_down"))
	handbrake.button_down.connect(func(): Input.action_press("handbrake"))
	handbrake.button_up.connect(func():   Input.action_release("handbrake"))

	canvas.visibility_changed.connect(_release_all)

func _release_all() -> void:
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("handbrake")
