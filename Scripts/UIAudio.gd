extends Node

const FREQ_TOP    := 720.0
const FREQ_BOTTOM := 280.0
const HOVER_DUR   := 0.055  # seconds
const CLICK_DUR   := 0.030  # seconds
const SAMPLE_RATE := 22050

var _hover_player: AudioStreamPlayer
var _click_player: AudioStreamPlayer
var _last_freq: float = -1.0

func _ready():
	_hover_player = AudioStreamPlayer.new()
	_hover_player.bus = "Master"
	_hover_player.volume_db = -10.0
	add_child(_hover_player)

	_click_player = AudioStreamPlayer.new()
	_click_player.bus = "Master"
	_click_player.volume_db = -5.0
	add_child(_click_player)

	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.focus_entered.connect(func(): _hover(node))
		node.mouse_entered.connect(func(): _hover(node))
		node.pressed.connect(click)

func _hover(node: Control) -> void:
	var vp = node.get_viewport()
	if vp == null:
		return
	var vp_height: float = vp.get_visible_rect().size.y
	if vp_height <= 0.0:
		return
	var center_y: float = node.get_global_rect().get_center().y
	var t: float = clamp(center_y / vp_height, 0.0, 1.0)
	var freq: float = lerp(FREQ_TOP, FREQ_BOTTOM, t)

	if _hover_player.playing and abs(freq - _last_freq) < 15.0:
		return

	_last_freq = freq
	_hover_player.stream = _make_sine(freq, HOVER_DUR, 0.55)
	_hover_player.play()

func click() -> void:
	_click_player.stream = _make_click()
	_click_player.play()

func _make_sine(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var n := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t    := float(i) / SAMPLE_RATE
		var env  := pow(1.0 - float(i) / float(n), 2.5)
		var s    := int(clamp(sin(TAU * freq * t) * env * volume, -1.0, 1.0) * 32767.0)
		data[i * 2]     = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	return _to_wav(data)

func _make_click() -> AudioStreamWAV:
	var n := int(SAMPLE_RATE * CLICK_DUR)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var t   := float(i) / SAMPLE_RATE
		var env := exp(-float(i) / float(n) * 12.0)
		var sig := sin(TAU * 520.0 * t) * 0.6 + sin(TAU * 1040.0 * t) * 0.4
		var s   := int(clamp(sig * env * 0.85, -1.0, 1.0) * 32767.0)
		data[i * 2]     = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	return _to_wav(data)

func _to_wav(data: PackedByteArray) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav
