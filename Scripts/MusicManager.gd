extends Node

var _player: AudioStreamPlayer

func _ready():
	_setup_buses()
	_player = AudioStreamPlayer.new()
	_player.bus = "Music"
	add_child(_player)
	_player.finished.connect(_on_finished)

func _setup_buses():
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "Music")
		AudioServer.set_bus_send(AudioServer.get_bus_index("Music"), "Master")
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, "SFX")
		AudioServer.set_bus_send(AudioServer.get_bus_index("SFX"), "Master")

func play_menu():
	_player.pitch_scale = 1.0
	_player.stream = load("res://Music/OST/ironM006 mel last min.wav")
	_player.play()

func play_game_music(stream: AudioStream):
	_player.pitch_scale = 1.0
	_player.stream = stream
	_player.play()

func stop():
	_player.stop()

func set_pitch(value: float):
	_player.pitch_scale = value

func _on_finished():
	_player.play()
