extends Node

var _player: AudioStreamPlayer

func _ready():
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player.finished.connect(_on_finished)

func play_menu():
	_player.stream = load("res://Music/OST/ironM006 mel last min.wav")
	_player.play()

func play_game_music(stream: AudioStream):
	_player.stream = stream
	_player.play()

func stop():
	_player.stop()

func _on_finished():
	_player.play()
