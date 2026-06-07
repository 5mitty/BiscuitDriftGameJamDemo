extends Control

signal navigate(to: String)

@onready var play_button = %PlayButton
@onready var tutorial_button = %TutorialButton
@onready var quit_button = %QuitButton

@export var sfx_hover: AudioStream
@export var sfx_click: AudioStream
@export var ui_font: FontFile

var _sfx: AudioStreamPlayer

func _ready():
	_setup_audio()
	_apply_font()

	var bg_texture = get_node_or_null("TextureRect")
	if bg_texture:
		bg_texture.hide()

	for btn in [play_button, tutorial_button, quit_button]:
		btn.mouse_entered.connect(_on_button_hover)

	play_button.grab_focus()

func _setup_audio():
	_sfx = AudioStreamPlayer.new()
	_sfx.volume_db = -6.0
	add_child(_sfx)

func _on_button_hover():
	if sfx_hover and not _sfx.playing:
		_sfx.stream = sfx_hover
		_sfx.play()

func _play_click():
	if sfx_click:
		_sfx.stream = sfx_click
		_sfx.play()

func _on_play_button_pressed():
	_play_click()
	MusicManager.play_menu()
	navigate.emit("load_save")

func _on_quit_button_pressed():
	_play_click()
	get_tree().quit()

func _on_tutorial_button_pressed():
	_play_click()
	navigate.emit("tutorial")

func _apply_font():
	if not ui_font:
		return
	for btn in [play_button, tutorial_button, quit_button]:
		btn.add_theme_font_override("font", ui_font)
