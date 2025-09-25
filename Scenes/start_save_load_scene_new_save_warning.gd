extends Control

var save_path = "user://player_data.save"
#@onready var play_button = %PlayButton
#@onready var tutorial_button = %TutorialButton
#@onready var quit_button = %QuitButton
var package_scores = []
var finished_times = []
var player_money_total = 0
@export var main_menu_scene: PackedScene = preload("res://Scenes/main_menu.tscn")
@export var tutorial_scene: PackedScene = preload("res://Scenes/tutorial_screen.tscn")
@export var start_screen_scene: PackedScene = preload("res://Scenes/start_screen.tscn")
@onready var load_button = %LoadButton
@onready var new_save_button = %NewSaveButton
@onready var back_button = %BackButton

#func _ready():
	#load_button.pressed.connect(_on_load_button_pressed)
	#new_save_button.pressed.connect(_on_new_save_button_pressed)
	#back_button.pressed.connect(_on_back_button_pressed)

func _load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		package_scores = file.get_var()
		finished_times = file.get_var()
		player_money_total = file.get_var()
		
func _save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(package_scores)
	file.store_var(finished_times)
	file.store_var(player_money_total)
		
func _delete_save_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		if file:
			file.close()
			print("Save file cleared by overwriting.")
		else:
			print("Error clearing save file.")

#func _on_quit_button_pressed():
	#get_tree().quit()

func _on_load_button_pressed():
	_load_data()
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_new_save_button_pressed():
	_delete_save_data()
	_save_data()
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")
