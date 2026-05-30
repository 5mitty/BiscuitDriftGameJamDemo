extends Control

signal navigate(to: String)

@onready var back_button = %BackButton
@onready var next_button = %NextButton

func _ready():
	next_button.pressed.connect(_on_next_button_pressed)

func _on_back_button_pressed():
	navigate.emit("start")

func _on_next_button_pressed():
	navigate.emit("main_menu")
