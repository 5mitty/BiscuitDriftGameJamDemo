extends Control

@onready var player = $".."
@onready var settings_canvas_layer = %SettingsCanvasLayer

var rebinding_action: String = ""
var rebind_buttons: Dictionary = {}
var rebound_actions: Array = []
var settings_path = "user://settings.cfg"
var touch_gamepad_enabled: bool = false
var _default_key_events: Dictionary = {}
var _default_joy_events: Dictionary = {}
var _settings_scroll: ScrollContainer = null
var _first_slider: HSlider = null
var _rebind_mode: String = "keyboard"
var _tab_kbd_btn: Button = null
var _tab_joy_btn: Button = null
var _focus_chain: Array = []

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
	call_deferred("_build_settings_ui")

func _process(delta: float) -> void:
	if _settings_scroll == null or not settings_canvas_layer.visible:
		return
	var joy_y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(joy_y) > 0.15:
		_settings_scroll.scroll_vertical += int(joy_y * 320.0 * delta)


func _build_settings_ui():
	_focus_chain.clear()
	var vbox = settings_canvas_layer.get_node("VBoxContainer")

	var old_bg = settings_canvas_layer.get_node_or_null("ColorRect")
	if old_bg: old_bg.hide()

	var full_rect := Control.new()
	full_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	full_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_canvas_layer.add_child(full_rect)
	settings_canvas_layer.move_child(full_rect, 0)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	full_rect.add_child(center)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.09, 0.13, 0.24, 0.88)
	bg_style.corner_radius_top_left    = 12
	bg_style.corner_radius_top_right   = 12
	bg_style.corner_radius_bottom_left  = 12
	bg_style.corner_radius_bottom_right = 12
	bg_style.border_width_left   = 1
	bg_style.border_width_top    = 1
	bg_style.border_width_right  = 1
	bg_style.border_width_bottom = 1
	bg_style.border_color = Color(0.18, 0.77, 0.71, 0.45)
	var panel_cont := PanelContainer.new()
	panel_cont.custom_minimum_size = Vector2(700.0, 0.0)
	panel_cont.add_theme_stylebox_override("panel", bg_style)
	center.add_child(panel_cont)

	vbox.reparent(panel_cont)
	vbox.clip_contents = true

	var title = vbox.get_node_or_null("SettingsLabel")
	if title:
		title.add_theme_font_size_override("font_size", 20)
		title.add_theme_color_override("font_color", Color("#2ec4b6"))
		title.add_theme_constant_override("outline_size", 1)
		title.add_theme_color_override("font_outline_color", Color.BLACK)

	for n_name in ["SettingsChange", "MarginContainer", "MarginContainer2"]:
		var n = vbox.get_node_or_null(n_name)
		if n: n.hide()

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0.0, 220.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	vbox.add_child(scroll)
	_settings_scroll = scroll

	var margin_wrap := MarginContainer.new()
	margin_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin_wrap.add_theme_constant_override("margin_left", 14)
	margin_wrap.add_theme_constant_override("margin_right", 14)
	margin_wrap.add_theme_constant_override("margin_top", 4)
	margin_wrap.add_theme_constant_override("margin_bottom", 4)
	scroll.add_child(margin_wrap)

	var inner := VBoxContainer.new()
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.add_theme_constant_override("separation", 8)
	margin_wrap.add_child(inner)

	_add_section_label(inner, "TOUCH CONTROLS")
	_add_touch_toggle(inner)
	_add_section_label(inner, "VOLUME")
	_add_slider(inner, "Master")
	_add_slider(inner, "Music")
	_add_slider(inner, "SFX")
	_add_section_label(inner, "KEYBINDS")
	_add_input_tabs(inner)
	for action in REBINDABLE:
		_add_keybind_row(inner, action, REBINDABLE[action])

	var back_btn = vbox.get_node_or_null("Back")
	if back_btn:
		back_btn.add_theme_font_size_override("font_size", 16)
		back_btn.add_theme_color_override("font_color", Color.WHITE)
		vbox.move_child(back_btn, vbox.get_child_count() - 1)

	# explicit up/down chain so items below scroll fold aren't skipped
	for i in range(_focus_chain.size()):
		var curr: Control = _focus_chain[i]
		var nxt: Control  = _focus_chain[i + 1] if i + 1 < _focus_chain.size() else back_btn
		var prv: Control  = _focus_chain[i - 1] if i > 0 else null
		curr.set_focus_neighbor(SIDE_BOTTOM, curr.get_path_to(nxt))
		nxt.set_focus_neighbor(SIDE_TOP, nxt.get_path_to(curr))
		if prv:
			curr.set_focus_neighbor(SIDE_TOP, curr.get_path_to(prv))
	if _tab_kbd_btn and _tab_joy_btn:
		for side in [SIDE_TOP, SIDE_BOTTOM]:
			var nb := _tab_kbd_btn.get_focus_neighbor(side)
			if nb != NodePath(""):
				_tab_joy_btn.set_focus_neighbor(side, _tab_joy_btn.get_path_to(
					_tab_kbd_btn.get_node(nb)))
	if back_btn and _focus_chain.size() > 0:
		back_btn.set_focus_neighbor(SIDE_TOP, back_btn.get_path_to(_focus_chain[-1]))

	if not settings_canvas_layer.visibility_changed.is_connected(_on_settings_shown):
		settings_canvas_layer.visibility_changed.connect(_on_settings_shown)

func _on_settings_shown() -> void:
	if settings_canvas_layer.visible and _first_slider != null:
		_first_slider.grab_focus()

func _add_input_tabs(parent: Node):
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	_tab_kbd_btn = Button.new()
	_tab_kbd_btn.text = "KEYBOARD"
	_tab_kbd_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_kbd_btn.add_theme_font_size_override("font_size", 14)
	_tab_kbd_btn.pressed.connect(func(): _set_rebind_mode("keyboard"))

	_tab_joy_btn = Button.new()
	_tab_joy_btn.text = "CONTROLLER"
	_tab_joy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_joy_btn.add_theme_font_size_override("font_size", 14)
	_tab_joy_btn.pressed.connect(func(): _set_rebind_mode("controller"))

	row.add_child(_tab_kbd_btn)
	row.add_child(_tab_joy_btn)
	parent.add_child(row)
	_tab_kbd_btn.set_focus_neighbor(SIDE_RIGHT, _tab_kbd_btn.get_path_to(_tab_joy_btn))
	_tab_joy_btn.set_focus_neighbor(SIDE_LEFT,  _tab_joy_btn.get_path_to(_tab_kbd_btn))
	_focus_chain.append(_tab_kbd_btn)
	_refresh_tab_styles()

func _set_rebind_mode(mode: String) -> void:
	_rebind_mode = mode
	_refresh_tab_styles()
	for action in rebind_buttons:
		var btn: Button = rebind_buttons[action]
		btn.text = _get_key_label(action) if mode == "keyboard" else _get_joy_label(action)

func _refresh_tab_styles() -> void:
	if _tab_kbd_btn == null or _tab_joy_btn == null:
		return
	var active_n := load("res://themes/secondary_normal.tres")
	var active_h := load("res://themes/secondary_hover.tres")
	var active_p := load("res://themes/secondary_pressed.tres")
	var idle_n   := load("res://themes/carselect_normal.tres")
	var idle_h   := load("res://themes/carselect_hover.tres")
	var idle_p   := load("res://themes/carselect_pressed.tres")

	var kbd_active := _rebind_mode == "keyboard"
	_tab_kbd_btn.add_theme_stylebox_override("normal",  active_n if kbd_active else idle_n)
	_tab_kbd_btn.add_theme_stylebox_override("hover",   active_h if kbd_active else idle_h)
	_tab_kbd_btn.add_theme_stylebox_override("pressed", active_p if kbd_active else idle_p)
	_tab_kbd_btn.add_theme_color_override("font_color", Color.WHITE)

	_tab_joy_btn.add_theme_stylebox_override("normal",  active_n if not kbd_active else idle_n)
	_tab_joy_btn.add_theme_stylebox_override("hover",   active_h if not kbd_active else idle_h)
	_tab_joy_btn.add_theme_stylebox_override("pressed", active_p if not kbd_active else idle_p)
	_tab_joy_btn.add_theme_color_override("font_color", Color.WHITE)

func _add_touch_toggle(parent: Node):
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var lbl := Label.new()
	lbl.text = "Touch Gamepad"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.WHITE)

	var btn := Button.new()
	btn.text = "ON" if touch_gamepad_enabled else "OFF"
	btn.custom_minimum_size = Vector2(80, 0)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color.WHITE)
	_style_touch_toggle(btn, touch_gamepad_enabled)
	btn.pressed.connect(_on_touch_gamepad_toggled.bind(btn))
	_focus_chain.append(btn)

	row.add_child(lbl)
	row.add_child(btn)
	parent.add_child(row)

func _style_touch_toggle(btn: Button, enabled: bool) -> void:
	if enabled:
		btn.add_theme_stylebox_override("normal",  load("res://themes/primary_normal.tres"))
		btn.add_theme_stylebox_override("hover",   load("res://themes/primary_hover.tres"))
		btn.add_theme_stylebox_override("pressed", load("res://themes/primary_pressed.tres"))
	else:
		btn.add_theme_stylebox_override("normal",  load("res://themes/secondary_normal.tres"))
		btn.add_theme_stylebox_override("hover",   load("res://themes/secondary_hover.tres"))
		btn.add_theme_stylebox_override("pressed", load("res://themes/secondary_pressed.tres"))

func _on_touch_gamepad_toggled(btn: Button) -> void:
	touch_gamepad_enabled = not touch_gamepad_enabled
	btn.text = "ON" if touch_gamepad_enabled else "OFF"
	_style_touch_toggle(btn, touch_gamepad_enabled)
	_apply_touch_gamepad(touch_gamepad_enabled)
	_save_settings()

func _apply_touch_gamepad(enabled: bool) -> void:
	var wasd   = player.get_node_or_null("UI/TouchGamepadWASD/MarginContainer/MarginContainer/CanvasLayer")
	var pedals = player.get_node_or_null("UI/TouchGamepadPedals/MarginContainer/MarginContainer/CanvasLayer")
	if wasd:   wasd.visible   = enabled
	if pedals: pedals.visible = enabled

func _add_section_label(parent: Node, text: String):
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 4.0)
	parent.add_child(spacer)
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color("#2ec4b6"))
	lbl.add_theme_constant_override("outline_size", 1)
	lbl.add_theme_color_override("font_outline_color", Color.BLACK)
	parent.add_child(lbl)

func _add_slider(parent: Node, bus_name: String):
	var idx = AudioServer.get_bus_index(bus_name)
	var current_db = AudioServer.get_bus_volume_db(idx) if idx != -1 else 0.0

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var lbl := Label.new()
	lbl.text = bus_name
	lbl.custom_minimum_size = Vector2(70, 0)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.WHITE)

	var slider := HSlider.new()
	if _first_slider == null:
		_first_slider = slider
	_focus_chain.append(slider)
	slider.min_value = -40.0
	slider.max_value = 6.0
	slider.step = 0.5
	slider.value = current_db
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(120, 0)
	slider.value_changed.connect(_on_volume_changed.bind(bus_name))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#2ec4b6")
	fill.corner_radius_top_left    = 4
	fill.corner_radius_bottom_left = 4
	slider.add_theme_stylebox_override("grabber_area", fill)

	var val_lbl := Label.new()
	val_lbl.text = "%d db" % int(current_db)
	val_lbl.custom_minimum_size = Vector2(48, 0)
	val_lbl.add_theme_font_size_override("font_size", 16)
	val_lbl.add_theme_color_override("font_color", Color("#2ec4b6"))
	slider.value_changed.connect(_update_db_label.bind(val_lbl))

	row.add_child(lbl)
	row.add_child(slider)
	row.add_child(val_lbl)
	parent.add_child(row)

func _update_db_label(value: float, label: Label):
	label.text = "%d db" % int(value)

func _add_keybind_row(parent: Node, action: String, label_text: String):
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(110, 0)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color.WHITE)

	var btn := Button.new()
	btn.text = _get_key_label(action)
	btn.custom_minimum_size = Vector2(100, 0)
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_stylebox_override("normal",  load("res://themes/secondary_normal.tres"))
	btn.add_theme_stylebox_override("hover",   load("res://themes/secondary_hover.tres"))
	btn.add_theme_stylebox_override("pressed", load("res://themes/secondary_pressed.tres"))
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(_on_rebind_pressed.bind(action, btn))

	var reset_btn := Button.new()
	reset_btn.text = "↺"
	reset_btn.custom_minimum_size = Vector2(36, 0)
	reset_btn.add_theme_font_size_override("font_size", 16)
	reset_btn.add_theme_stylebox_override("normal",  load("res://themes/destructive_normal.tres"))
	reset_btn.add_theme_stylebox_override("hover",   load("res://themes/destructive_hover.tres"))
	reset_btn.add_theme_stylebox_override("pressed", load("res://themes/destructive_pressed.tres"))
	reset_btn.add_theme_color_override("font_color", Color(0.353, 0.267, 0.0, 1))
	reset_btn.pressed.connect(_reset_action.bind(action, btn))

	row.add_child(lbl)
	row.add_child(btn)
	row.add_child(reset_btn)
	rebind_buttons[action] = btn
	parent.add_child(row)

	# left/right locked within row
	btn.set_focus_neighbor(SIDE_RIGHT, btn.get_path_to(reset_btn))
	reset_btn.set_focus_neighbor(SIDE_LEFT, reset_btn.get_path_to(btn))
	_focus_chain.append(btn)


func _get_key_label(action: String) -> String:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			return e.as_text_physical_keycode()
	return "—"

func _get_joy_label(action: String) -> String:
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton:
			return _joy_button_name(e.button_index)
		if e is InputEventJoypadMotion:
			return _joy_axis_name(e.axis, e.axis_value)
	return "—"

func _joy_button_name(idx: int) -> String:
	match idx:
		JOY_BUTTON_A:             return "A / Cross"
		JOY_BUTTON_B:             return "B / Circle"
		JOY_BUTTON_X:             return "X / Square"
		JOY_BUTTON_Y:             return "Y / Triangle"
		JOY_BUTTON_LEFT_SHOULDER: return "LB / L1"
		JOY_BUTTON_RIGHT_SHOULDER:return "RB / R1"
		JOY_BUTTON_LEFT_STICK:    return "L3"
		JOY_BUTTON_RIGHT_STICK:   return "R3"
		JOY_BUTTON_BACK:          return "Select / Back"
		JOY_BUTTON_START:         return "Start / Menu"
		JOY_BUTTON_DPAD_UP:       return "D-Pad ↑"
		JOY_BUTTON_DPAD_DOWN:     return "D-Pad ↓"
		JOY_BUTTON_DPAD_LEFT:     return "D-Pad ←"
		JOY_BUTTON_DPAD_RIGHT:    return "D-Pad →"
		_:                        return "Btn %d" % idx

func _joy_axis_name(axis: int, value: float) -> String:
	var dir := "+" if value > 0 else "−"
	match axis:
		JOY_AXIS_LEFT_X:       return "L-Stick H%s" % dir
		JOY_AXIS_LEFT_Y:       return "L-Stick V%s" % dir
		JOY_AXIS_RIGHT_X:      return "R-Stick H%s" % dir
		JOY_AXIS_RIGHT_Y:      return "R-Stick V%s" % dir
		JOY_AXIS_TRIGGER_LEFT: return "LT / L2"
		JOY_AXIS_TRIGGER_RIGHT:return "RT / R2"
		_:                     return "Axis %d%s" % [axis, dir]


func _on_rebind_pressed(action: String, btn: Button):
	if rebinding_action != "":
		_cancel_rebind()
	rebinding_action = action
	btn.text = "Press a key..." if _rebind_mode == "keyboard" else "Press a button..."

func _cancel_rebind():
	if rebinding_action == "":
		return
	var display := _get_key_label(rebinding_action) if _rebind_mode == "keyboard" \
				else _get_joy_label(rebinding_action)
	rebind_buttons[rebinding_action].text = display
	rebinding_action = ""

func _reset_action(action: String, keybind_btn: Button) -> void:
	if _rebind_mode == "keyboard":
		if action not in _default_key_events:
			return
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				InputMap.action_erase_event(action, e)
		InputMap.action_add_event(action, _default_key_events[action].duplicate())
		keybind_btn.text = _get_key_label(action)
	else:
		if action not in _default_joy_events:
			return
		for e in InputMap.action_get_events(action):
			if e is InputEventJoypadButton or e is InputEventJoypadMotion:
				InputMap.action_erase_event(action, e)
		InputMap.action_add_event(action, _default_joy_events[action].duplicate())
		keybind_btn.text = _get_joy_label(action)
	rebound_actions.erase(action)
	_save_settings()

func _input(event):
	if rebinding_action == "" and event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		return
	if rebinding_action == "":
		return

	if _rebind_mode == "keyboard":
		if event is InputEventKey and event.pressed and not event.echo:
			var new_e := InputEventKey.new()
			new_e.physical_keycode = event.physical_keycode
			for e in InputMap.action_get_events(rebinding_action):
				if e is InputEventKey:
					InputMap.action_erase_event(rebinding_action, e)
			InputMap.action_add_event(rebinding_action, new_e)
			rebind_buttons[rebinding_action].text = event.as_text_physical_keycode()
			if rebinding_action not in rebound_actions:
				rebound_actions.append(rebinding_action)
			rebinding_action = ""
			_save_settings()
			get_viewport().set_input_as_handled()
	else:
		var captured := false
		var new_e: InputEvent = null
		if event is InputEventJoypadButton and event.pressed:
			var je := InputEventJoypadButton.new()
			je.button_index = event.button_index
			new_e = je
			captured = true
		elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.5:
			var je := InputEventJoypadMotion.new()
			je.axis = event.axis
			je.axis_value = sign(event.axis_value)
			new_e = je
			captured = true
		if captured:
			for e in InputMap.action_get_events(rebinding_action):
				if e is InputEventJoypadButton or e is InputEventJoypadMotion:
					InputMap.action_erase_event(rebinding_action, e)
			InputMap.action_add_event(rebinding_action, new_e)
			var display := _get_joy_label(rebinding_action)
			rebind_buttons[rebinding_action].text = display
			if rebinding_action not in rebound_actions:
				rebound_actions.append(rebinding_action)
			rebinding_action = ""
			_save_settings()
			get_viewport().set_input_as_handled()


func _on_volume_changed(value: float, bus_name: String):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, value)
	_save_settings()

func _save_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", 2)
	cfg.set_value("controls", "touch_gamepad", touch_gamepad_enabled)
	for bus in ["Master", "Music", "SFX"]:
		var idx = AudioServer.get_bus_index(bus)
		if idx != -1:
			cfg.set_value("volume", bus.to_lower(), AudioServer.get_bus_volume_db(idx))
	for action in rebound_actions:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				cfg.set_value("keybinds", action, e.physical_keycode)
			elif e is InputEventJoypadButton:
				cfg.set_value("joy_binds", action + "_btn", e.button_index)
			elif e is InputEventJoypadMotion:
				cfg.set_value("joy_binds", action + "_axis", [e.axis, e.axis_value])
	cfg.save(settings_path)

func _load_settings():
	InputMap.load_from_project_settings()
	for action in REBINDABLE:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey and action not in _default_key_events:
				_default_key_events[action] = e.duplicate()
			elif (e is InputEventJoypadButton or e is InputEventJoypadMotion) \
					and action not in _default_joy_events:
				_default_joy_events[action] = e.duplicate()

	var cfg := ConfigFile.new()
	if cfg.load(settings_path) != OK:
		return
	if cfg.get_value("meta", "version", 1) < 2:
		cfg.clear()
		cfg.set_value("meta", "version", 2)
		cfg.save(settings_path)
		return

	touch_gamepad_enabled = cfg.get_value("controls", "touch_gamepad", false)
	call_deferred("_apply_touch_gamepad", touch_gamepad_enabled)

	for bus in ["Master", "Music", "SFX"]:
		var idx = AudioServer.get_bus_index(bus)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, cfg.get_value("volume", bus.to_lower(), 0.0))

	for action in REBINDABLE:
		if cfg.has_section_key("keybinds", action):
			var keycode = cfg.get_value("keybinds", action)
			var new_e := InputEventKey.new()
			new_e.physical_keycode = keycode
			new_e.keycode = keycode
			for e in InputMap.action_get_events(action):
				if e is InputEventKey:
					InputMap.action_erase_event(action, e)
			InputMap.action_add_event(action, new_e)
			if action not in rebound_actions:
				rebound_actions.append(action)
		if cfg.has_section_key("joy_binds", action + "_btn"):
			var idx: int = cfg.get_value("joy_binds", action + "_btn")
			var new_e := InputEventJoypadButton.new()
			new_e.button_index = idx
			for e in InputMap.action_get_events(action):
				if e is InputEventJoypadButton:
					InputMap.action_erase_event(action, e)
			InputMap.action_add_event(action, new_e)
			if action not in rebound_actions:
				rebound_actions.append(action)
		elif cfg.has_section_key("joy_binds", action + "_axis"):
			var data: Array = cfg.get_value("joy_binds", action + "_axis")
			var new_e := InputEventJoypadMotion.new()
			new_e.axis = data[0]
			new_e.axis_value = data[1]
			for e in InputMap.action_get_events(action):
				if e is InputEventJoypadMotion:
					InputMap.action_erase_event(action, e)
			InputMap.action_add_event(action, new_e)
			if action not in rebound_actions:
				rebound_actions.append(action)

func _on_back_pressed():
	_cancel_rebind()
	settings_canvas_layer.hide()
	if OS.get_name() == "Web":
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Engine.time_scale = 1.0
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
	player.is_paused = false
