extends Control

@onready var play_button = %PlayButton
@onready var tutorial_button = %TutorialButton
@onready var quit_button = %QuitButton
@export var main_menu_scene: PackedScene = preload("res://Scenes/main_menu.tscn")
@export var tutorial_scene: PackedScene = preload("res://Scenes/tutorial_screen.tscn")
@export var start_save_load_scene = preload("res://Scenes/start_save_load_scene.tscn")

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(start_save_load_scene)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_tutorial_button_pressed():
	get_tree().change_scene_to_packed(tutorial_scene)
