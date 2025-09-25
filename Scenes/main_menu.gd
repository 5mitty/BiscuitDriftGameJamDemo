extends Control

#@onready var play_button = %PlayButton
var save_path = "user://player_data.save"
var package_score = 0
var package_scores = []
var finished_time = 0.0
var finished_times = []
var player_money_total = 0
@onready var play_map_1_button = %PlayMap1Button
@onready var play_map_2_button = %PlayMap2Button
@onready var play_map_3_button = %PlayMap3Button
@onready var quit_button = %QuitButton
@onready var money_label = %MoneyLabel
@export var main_game_scene: PackedScene = preload("res://Scenes/gameLarge.tscn")
@export var main_starting_screen_scene: PackedScene = preload("res://Scenes/start_screen.tscn")

func _ready():
	_load_data()
	if player_money_total:
		money_label.text = "MONEY: " + str(player_money_total)
	else:
		money_label.text = "MONEY: " + str(0)
	#play_button.pressed.connect(_on_play_button_pressed)
	#play_map_1_button.pressed.connect(_on_play_map_1_button_pressed)
	#play_map_2_button.pressed.connect(_on_play_map_2_button_pressed)
	#play_map_3_button.pressed.connect(_on_play_map_3_button_pressed)
	#quit_button.pressed.connect(_on_quit_button_pressed)


#func _on_play_button_pressed():
	#get_tree().change_scene_to_packed(main_game_scene)
	
func _load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		package_scores = file.get_var()
		finished_times = file.get_var()
		player_money_total = file.get_var()
		
func _delete_save_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		if file:
			file.close()
			print("Save file cleared by overwriting.")
		else:
			print("Error clearing save file.")


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")
	#get_tree().quit()


func _on_play_map_1_button_pressed():
	get_tree().change_scene_to_packed(main_game_scene)
	#get_tree().change_scene_to_file("res://Scenes/gameLarge.tscn")


func _on_play_map_2_button_pressed():
	print("No Map 2 Yet")


func _on_play_map_3_button_pressed():
	print("No Map 3 Yet")


func _on_load_button_pressed():
	_load_data()
	if player_money_total:
		money_label.text = "MONEY: " + str(player_money_total)
	else:
		money_label.text = "MONEY: " + str(0)
	print("LOADED DATA: \nPACKAGES SCORES: " + str(package_scores) + "\nFINISH TIMES: " + str(finished_times))
