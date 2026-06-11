extends Control

func _ready():
	var canvas    = find_child("CanvasLayer", true, false)
	canvas.visible = false
	var forward   = find_child("Forward", true, false)
	var back      = find_child("Back",    true, false)
	var left      = find_child("Left",    true, false)
	var right     = find_child("Right",   true, false)

	forward.button_down.connect(func(): Input.action_press("ui_up"))
	forward.button_up.connect(func():   Input.action_release("ui_up"))
	back.button_down.connect(func():    Input.action_press("ui_down"))
	back.button_up.connect(func():      Input.action_release("ui_down"))
	left.button_down.connect(func():    Input.action_press("ui_left"))
	left.button_up.connect(func():      Input.action_release("ui_left"))
	right.button_down.connect(func():   Input.action_press("ui_right"))
	right.button_up.connect(func():     Input.action_release("ui_right"))

	canvas.visibility_changed.connect(_release_all)

func _release_all() -> void:
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")
