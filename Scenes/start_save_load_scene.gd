extends Control

signal navigate(to: String)

var save_path = "user://player_data.save"
var package_scores = []
var finished_times = []
var player_money_total = 0

@onready var load_button = %LoadButton
@onready var new_save_button = %NewSaveButton
@onready var back_button = %BackButton

func _ready():
	load_button.grab_focus()

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

var garage_scene = preload("res://Scenes/garage_selection_scene.tscn")

func _on_load_button_pressed():
	_load_data()
	get_tree().change_scene_to_packed(garage_scene)

func _on_new_save_button_pressed():
	navigate.emit("save_warning")

func _on_back_button_pressed():
	navigate.emit("start")
