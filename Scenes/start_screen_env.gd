extends Node3D

var save_path = "user://player_data.save"
var vehicle_selected = 1

@onready var van = %van
@onready var taxi = %taxi
@onready var suv = %suv
@onready var suv_luxury = %"suv-luxury"
@onready var sedan = %sedan
@onready var canvas_layer = $CanvasLayer

const SCREEN_SCENES = {
	"start": preload("res://Scenes/start_screen.tscn"),
	"load_save": preload("res://Scenes/start_save_load_scene.tscn"),
	"save_warning": preload("res://Scenes/start_save_load_scene_new_save_warning.tscn"),
	"tutorial": preload("res://Scenes/tutorial_screen.tscn"),
}

var _screens = {}
var _current = ""

func _ready():
	_load_data()
	_show_selected_car()
	_setup_screens()

func _setup_screens():
	for child in canvas_layer.get_children():
		child.queue_free()
	await get_tree().process_frame

	for key in SCREEN_SCENES:
		var screen = SCREEN_SCENES[key].instantiate()
		screen.hide()
		canvas_layer.add_child(screen)
		_screens[key] = screen
		screen.navigate.connect(show_screen)

	show_screen("start")

func show_screen(name: String):
	if _current in _screens:
		_screens[_current].hide()
	if name in _screens:
		_screens[name].show()
		_current = name

func _show_selected_car():
	van.hide()
	taxi.hide()
	suv.hide()
	suv_luxury.hide()
	sedan.hide()
	match vehicle_selected:
		1: van.show()
		2: taxi.show()
		3: suv.show()
		4: suv_luxury.show()
		5: sedan.show()

func _load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		file.get_var() #package_scores
		file.get_var() #finished_times
		file.get_var() #player_money_total 
		file.get_var() #van_purchased
		file.get_var() #taxi_purchased
		file.get_var() #suv_purchased
		file.get_var() #lux_purchased
		file.get_var() #sedan_purchased
		vehicle_selected = file.get_var()
