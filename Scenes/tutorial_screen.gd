extends Control

@onready var back_button = %BackButton
@onready var next_button = %NextButton
var main_menu_scene = preload("res://Scenes/main_menu.tscn")

func _ready():
	next_button.pressed.connect(_on_next_button_pressed)

#func _on_back_button_pressed():
	#get_tree().change_scene_to_packed(main_menu_scene)


func _on_next_button_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)
