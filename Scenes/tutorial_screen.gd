extends Control

signal navigate(to: String)

@onready var next_button = %NextButton

func _ready():
	visibility_changed.connect(func():
		if visible: next_button.grab_focus())

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed():
	navigate.emit("start")

func _on_next_button_pressed():
	navigate.emit("start")
