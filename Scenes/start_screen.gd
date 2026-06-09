extends Control

signal navigate(to: String)

@onready var play_button = %PlayButton
@onready var tutorial_button = %TutorialButton
@onready var quit_button = %QuitButton

func _ready():
	var bg_texture = get_node_or_null("TextureRect")
	if bg_texture:
		bg_texture.hide()
	visibility_changed.connect(func():
		if visible: play_button.grab_focus())

func _on_play_button_pressed():
	MusicManager.play_menu()
	navigate.emit("load_save")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_tutorial_button_pressed():
	navigate.emit("tutorial")
