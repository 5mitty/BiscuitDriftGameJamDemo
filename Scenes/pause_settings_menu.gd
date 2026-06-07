extends Control

@onready var player = $".."
@onready var settings_canvas_layer = %SettingsCanvasLayer

var rebinding_action: String = ""
var rebind_buttons: Dictionary = {}
var rebound_actions: Array = []
var settings_path = "user://settings.cfg"

const REBINDABLE = {
	"ui_up":     "Accelerate",
	"ui_down":   "Reverse",
	"ui_left":   "Steer Left",
	"ui_right":  "Steer Right",
	"handbrake": "Handbrake",
	"ui_cancel": "Pause",
}

func _ready():
	_load_settings()
	_build_settings_ui()

func _build_settings_ui():
	var vbox = settings_canvas_layer.get_node("VBoxContainer")
	vbox.clip_contents = true

	# Hide the old placeholder nodes
	for n_name in ["SettingsChange", "MarginContainer", "MarginContainer2"]:
		var n = vbox.get_node_or_null(n_name)
		if n:
			n.hide()

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	var inner = VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 10)
	scroll.add_child(inner)

	_add_section_label(inner, "VOLUME")
	_add_slider(inner, "Master")
	_add_slider(inner, "Music")
	_add_slider(inner, "SFX")

	_add_section_label(inner, "KEYBINDS")
	for action in REBINDABLE:
		_add_keybind_row(inner, action, REBINDABLE[action])

	# Keep Back at the bottom
	var back_btn = vbox.get_node_or_null("Back")
	if back_btn:
		vbox.move_child(back_btn, vbox.get_child_count() - 1)

func _add_section_label(parent: Node, text: String):
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	parent.add_child(spacer)
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 16)
	parent.add_child(lbl)

func _add_slider(parent: Node, bus_name: String):
	var idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(idx) if idx != -1 else 0.0

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var lbl = Label.new()
	lbl.text = bus_name
	lbl.custom_minimum_size = Vector2(80, 0)
	lbl.add_theme_font_size_override("font_size", 26)

	var slider = HSlider.new()
	slider.min_value = -40.0
	slider.max_value = 6.0
	slider.step = 0.5
	slider.value = current_db
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(180, 0)
	slider.value_changed.connect(_on_volume_changed.bind(bus_name))

	var val_lbl = Label.new()
	val_lbl.text = "%d db" % int(current_db)
	val_lbl.custom_minimum_size = Vector2(55, 0)
	val_lbl.add_theme_font_size_override("font_size", 26)
	slider.value_changed.connect(_update_db_label.bind(val_lbl))

	row.add_child(lbl)
	row.add_child(slider)
	row.add_child(val_lbl)
	parent.add_child(row)

func _update_db_label(value: float, label: Label):
	label.text = "%d db" % int(value)

func _add_keybind_row(parent: Node, action: String, label_text: String):
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var lbl = Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(120, 0)
	lbl.add_theme_font_size_override("font_size", 26)

	var btn = Button.new()
	btn.text = _get_key_label(action)
	btn.custom_minimum_size = Vector2(120, 0)
	btn.add_theme_font_size_override("font_size", 26)
	btn.pressed.connect(_on_rebind_pressed.bind(action, btn))

	row.add_child(lbl)
	row.add_child(btn)
	rebind_buttons[action] = btn
	parent.add_child(row)

func _get_key_label(action: String) -> String:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			return e.as_text_physical_keycode()
	return "?"

func _on_volume_changed(value: float, bus_name: String):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, value)
	_save_settings()

func _on_rebind_pressed(action: String, btn: Button):
	if rebinding_action != "":
		rebind_buttons[rebinding_action].text = _get_key_label(rebinding_action)
	rebinding_action = action
	btn.text = "Press a key..."

func _input(event):
	if rebinding_action == "":
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var new_event = InputEventKey.new()
		new_event.physical_keycode = event.physical_keycode
		for e in InputMap.action_get_events(rebinding_action):
			if e is InputEventKey:
				InputMap.action_erase_event(rebinding_action, e)
		InputMap.action_add_event(rebinding_action, new_event)
		rebind_buttons[rebinding_action].text = event.as_text_physical_keycode()
		if rebinding_action not in rebound_actions:
			rebound_actions.append(rebinding_action)
		rebinding_action = ""
		_save_settings()
		get_viewport().set_input_as_handled()

func _save_settings():
	var cfg = ConfigFile.new()
	cfg.set_value("meta", "version", 2)
	for bus in ["Master", "Music", "SFX"]:
		var idx = AudioServer.get_bus_index(bus)
		if idx != -1:
			cfg.set_value("volume", bus.to_lower(), AudioServer.get_bus_volume_db(idx))
	for action in rebound_actions:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				cfg.set_value("keybinds", action, e.physical_keycode)
				break
	cfg.save(settings_path)

func _load_settings():
	InputMap.load_from_project_settings()
	var cfg = ConfigFile.new()
	if cfg.load(settings_path) != OK:
		return
	if cfg.get_value("meta", "version", 1) < 2:
		cfg.clear()
		cfg.set_value("meta", "version", 2)
		cfg.save(settings_path)
		return
	for bus in ["Master", "Music", "SFX"]:
		var idx = AudioServer.get_bus_index(bus)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, cfg.get_value("volume", bus.to_lower(), 0.0))
	for action in REBINDABLE:
		if cfg.has_section_key("keybinds", action):
			var keycode = cfg.get_value("keybinds", action)
			var new_e = InputEventKey.new()
			new_e.physical_keycode = keycode
			new_e.keycode = keycode
			for e in InputMap.action_get_events(action):
				if e is InputEventKey:
					InputMap.action_erase_event(action, e)
			InputMap.action_add_event(action, new_e)
			if action not in rebound_actions:
				rebound_actions.append(action)

func _on_back_pressed():
	if rebinding_action != "":
		rebind_buttons[rebinding_action].text = _get_key_label(rebinding_action)
		rebinding_action = ""
	settings_canvas_layer.hide()
	if OS.get_name() == "Web":
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Engine.time_scale = 1.0
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	player.is_paused = false
