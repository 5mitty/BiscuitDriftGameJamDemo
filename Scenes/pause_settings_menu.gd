extends Control

@onready var player = $".."
@onready var canvas_layer = %CanvasLayer
@onready var settings_canvas_layer = %SettingsCanvasLayer
#@onready var resume = %Resume
#@onready var settings = %Settings
#@onready var quit = %Quit
@onready var back = $MarginContainer/MarginContainer/CanvasLayer/VBoxContainer/Back

func _ready():
	# Connect button signals if you haven't already in the editor
	#resume.pressed.connect(_on_resume_pressed)
	#settings.pressed.connect(_on_settings_pressed)
	#quit.pressed.connect(_on_quit_pressed)
	pass
	


#func grab_initial_focus():
	## This function will be called by your player script
	## to tell the menu to set the gamepad focus
	#if resume:
		#resume.grab_focus()
		#print("Pause Menu: Grabbed initial focus on Resume Button.")
	#else:
		#push_warning("Pause Menu: Resume Button not found for initial focus!")

#func _on_resume_pressed():
	##UIPauseMenu()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#player.is_paused = false
	#get_tree().paused = false
	#canvas_layer.hide()
	##canvas_layer.hide()
	#print("pressed Resume")
#
#func _on_settings_pressed():
	#pass # Replace with function body.
#
#
#func _on_quit_pressed():
	#print("pressed Quit")
	#get_tree().quit()

#func UIPauseMenu():
	#print("UI_CANCEL pressed.")
	#is_game_paused = not is_game_paused
	#print("is_game_paused toggled to: ", is_game_paused)


func _on_back_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.is_paused = false
	get_tree().paused = false
	settings_canvas_layer.hide()
	#canvas_layer.hide()
	print("pressed Resume")
