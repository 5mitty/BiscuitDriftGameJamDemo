extends Control

@onready var player = $".."
@onready var canvas_layer = %CanvasLayer
@onready var settings_canvas_layer = %SettingsCanvasLayer
@onready var resume = %Resume
@onready var settings = %Settings
@onready var quit = %Quit

func _ready():
	pass

func grab_initial_focus():
	resume.grab_focus()
	


#func grab_initial_focus():
	## This function will be called by your player script
	## to tell the menu to set the gamepad focus
	#if resume:
		#resume.grab_focus()
		#print("Pause Menu: Grabbed initial focus on Resume Button.")
	#else:
		#push_warning("Pause Menu: Resume Button not found for initial focus!")

func _on_resume_pressed():
	canvas_layer.hide()
	hide()
	player.is_paused = false
	if OS.get_name() == "Web":
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Engine.time_scale = 1.0
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false

func _on_settings_pressed():
	canvas_layer.hide()
	settings_canvas_layer.show()


func _on_quit_pressed():
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/garage_selection_scene.tscn")

#func UIPauseMenu():
	#print("UI_CANCEL pressed.")
	#is_game_paused = not is_game_paused
	#print("is_game_paused toggled to: ", is_game_paused)
