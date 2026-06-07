extends VehicleBody3D

var save_path = "user://player_data.save"
var package_score = 0
var package_scores = []
var finished_time = 0.0
var finished_times: Array = []
var player_money_total = 0
var money_to_add_total = 0
var van_purchased = true
var taxi_purchased = false
var suv_purchased = false
var lux_purchased = false
var sedan_purchased = true
var van_price = 0
var taxi_price = 300
var suv_price = 500
var lux_price = 1000
var sedan_price = 2500
var vehicles_id = [1, 2, 3, 4, 5]
var vehicle_selected = 1
@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 400
@export var CAMERA_FOLLOW_SPEED = 10.0
@onready var force_steering_label = %ForceSteeringLabel
var steer_display = 0.0
var steer_input = 0.0
var steer_amount = 0.0
var steer_text_from_int = ""
var force_input = 0.0
var engine_speed = 0.0
var force_display = 0.0
var handbrake_strength = 15.0
@export var drift_friction: float = 1.2
@export var normal_back_friction: float = 2.8
var is_drifting: bool = false

const CAR_STATS = {
	1: {engine=350, steer=0.7,  drift_f=1.3,  normal_f=2.8, label="Van — Heavy. Wide drifts."},
	2: {engine=420, steer=0.85, drift_f=1.1,  normal_f=2.8, label="Taxi — Balanced. Easy to drift."},
	3: {engine=380, steer=0.65, drift_f=1.4,  normal_f=3.2, label="SUV — Grippy. Hard to break loose."},
	4: {engine=500, steer=0.9,  drift_f=1.0,  normal_f=2.5, label="Lux — Fast. Loose. Expert only."},
	5: {engine=460, steer=0.95, drift_f=1.05, normal_f=2.6, label="Sedan — Nimble. Twitchy."},
}

var drift_score_total: float = 0.0
var drift_pending: float = 0.0
var drift_combo_multiplier: float = 1.0
var drift_sustained_time: float = 0.0
var _current_drift_angle: float = 0.0
var _actively_drifting: bool = false
var _all_wheels_off: bool = false
var _is_airtime: bool = false
var _cached_speed: float = 0.0
var _last_driving_score: float = 500.0
var drift_bar: ProgressBar
var _drift_bar_fill: StyleBoxFlat
var _drift_canvas: CanvasLayer
var _minimap_drawer_ref: Control
var _compass_drawer_ref: Control
var current_game_phase: int = 0
var _drift_mult_label: Label
var _drift_mult_label_timer: float = 0.0
var _drift_chain_grace: float = 0.0
var _drift_end_timer: float = 0.0
var _score_bonus_next: float = 50.0
var _drift_elapsed: float = 0.0

@export var sfx_crash: AudioStream
@export var sfx_tree_crash: AudioStream
@export var sfx_order_pickup: AudioStream
@export var sfx_delivery_pickup: AudioStream
@export var sfx_package_delivered: AudioStream
var _sfx_player: AudioStreamPlayer
var _prev_speed: float = 0.0
var _crash_cooldown: float = 0.0

@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D
@onready var front_right = $FrontRight
@onready var front_left = $FrontLeft
@onready var back_right = $BackRight
@onready var back_left = $BackLeft

#variables important for UI
var player_on_road = false
@onready var ray_cast_3d = %RayCast3D
@onready var scoreLabel = %ScoreLabel
@onready var win_label = %WinLabel
@onready var score_label_for_win = %ScoreLabelForWin
@onready var countdown_label = %CountdownLabel
@onready var countdown_timer = %CountdownTimer
@onready var checkpoint_label = %CheckpointLabel
@onready var checkpoint_timer = %CheckpointTimer
@onready var flag_count_label = %FlagCountLabel
@onready var order_count_label = %OrderCountLabel
@onready var driver_stars_check_timer = %DriverStarsCheckTimer
@export var countdown_duration: float = 80.0
@onready var c_o_m = %CoM
@export var z_angular_damping_factor: float = 2.0

@export var default_angular_damping: float = 0.5
@export var roll_damping_factor: float = 10.0

var player_score_from_road = 500
var driver_stars = ""
var driver_stars_score = 500
var player_reputation = 0
var flags_grabbed = 0
var orders_placed = 0
var orders_placed_stored_var = 0
var package_count = 0
var packages_delivered = 0
var hasLostScore = false
var grabbedFirstPackage = false
var isInPickup = false
var isInDropoff = false
var is_paused = false
var hasFinishedDropoff = false

var current_player_score = ""
var current_driver_stars = ""
var current_package_health = ""
var current_time_left = ""

@onready var first_gear_audio = %FirstGearAudio
@onready var second_gear_audio = %SecondGearAudio
@onready var third_gear_audio = %ThirdGearAudio
var inGearNumber = 0

@onready var Game = $".."
@onready var flag = $"../Flag"
@onready var flag_2 = $"../Flag2"
@onready var flag_3 = $"../Flag3"
@onready var order_flag_1 = $"../OrderFlag"
@onready var order_flag_2 = $"../OrderFlag2"
@onready var order_flag_3 = $"../OrderFlag3"
@onready var dropoff_flag_1 = $"../DropoffFlag2"
@onready var dropoff_flag_2_node = $"../DropoffFlag3"
@onready var dropoff_flag_3_node = $"../DropoffFlag4"
@onready var delivery_depot = $"../Checkpoint2"
@onready var win_screen = $WinScreen
@onready var pause_menu = %PauseMenu
@onready var pause_settings_menu = %PauseSettingsMenu
@onready var pause_free_roam_menu = %PauseFreeRoamMenu
@onready var win_canvas_layer = %WinCanvasLayer
var main_menu = preload("res://Scenes/main_menu.tscn")
#var win_screen = preload("res://Scenes/win_screen.tscn")

var packages_collected = []
var checkpoint_flags: Array = [flag, flag_2, flag_3]

@onready var minimap_marker = %MiniMapMarker
@onready var compass_marker = %CompassMarker
@onready var van_body = %vanBody
@onready var taxi_body = %taxiBody
@onready var suv_body = %suvBody
@onready var lux_body = %luxBody
@onready var sedan_body = %sedanBody

func _ready():
	contact_monitor = true
	max_contacts_reported = 6
	body_entered.connect(_on_tree_body_entered)
	if OS.get_name() == "Web":
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	countdown_timer.wait_time = countdown_duration
	countdown_timer.start()
	driver_stars = _player_score_to_driver_stars(player_score_from_road)
	_build_drift_bar()
	flag_count_label.text = ""
	order_count_label.text = "No Orders Yet"
	_display_selected_vehicle()
	_apply_car_stats()
	displayMessage("Stay on road — packages take damage off-road!", 5)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)
	_build_minimap_ui()

func _build_minimap_ui():
	var flag_groups = [
		[order_flag_1, order_flag_2, order_flag_3],
		[flag, flag_2, flag_3],
		[dropoff_flag_1, dropoff_flag_2_node, dropoff_flag_3_node],
		[delivery_depot],
	]
	var minimap_script := load("res://Scripts/MinimapDrawer.gd")
	var minimap := minimap_script.new() as Control
	minimap.player = self
	minimap.flag_groups = flag_groups
	minimap_marker.add_child(minimap)
	_minimap_drawer_ref = minimap

	compass_marker.set_anchors_preset(Control.PRESET_CENTER_TOP)
	compass_marker.offset_left = -compass_marker.size.x / 2.0
	compass_marker.offset_right = compass_marker.size.x / 2.0

	var compass_script := load("res://Scripts/CompassBar.gd")
	var compass := compass_script.new() as Control
	compass.player = self
	compass.flag_groups = flag_groups
	compass_marker.add_child(compass)
	_compass_drawer_ref = compass

func update_active_flags(orders: Array, pickups: Array, dropoffs: Array, depot: Array):
	if orders.size() > 0:
		current_game_phase = 0
	elif pickups.size() > 0:
		current_game_phase = 1
	elif dropoffs.size() > 0:
		current_game_phase = 2
	else:
		current_game_phase = 3
	var groups = [orders, pickups, dropoffs, depot]
	if _minimap_drawer_ref:
		_minimap_drawer_ref.flag_groups = groups
	if _compass_drawer_ref:
		_compass_drawer_ref.flag_groups = groups

func _on_tree_body_entered(body: Node):
	if not is_instance_valid(body):
		return
	var parent = body.get_parent()
	if not is_instance_valid(parent):
		return
	if not parent.name.to_lower().begins_with("tree-large"):
		return
	if linear_velocity.length() < 30.0 * 0.3:
		return
	_smash_tree(parent)

func _smash_tree(tree: Node):
	drift_score_total = max(drift_score_total - 500, 0)
	_play_sfx(sfx_tree_crash)
	var particles := CPUParticles3D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 24
	particles.lifetime = 1.8
	particles.initial_velocity_min = 4.0
	particles.initial_velocity_max = 10.0
	particles.direction = Vector3(0.0, 1.0, 0.0)
	particles.spread = 70.0
	particles.gravity = Vector3(0.0, -12.0, 0.0)
	particles.scale_amount_min = 0.2
	particles.scale_amount_max = 0.5
	particles.color = Color(0.25, 0.55, 0.15)
	var tree_pos = tree.global_position
	tree.queue_free()
	get_tree().root.add_child(particles)
	particles.global_position = tree_pos
	get_tree().create_timer(particles.lifetime + 0.5).timeout.connect(particles.queue_free)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		var canvas_layer_node = pause_menu.get_node_or_null("MarginContainer/MarginContainer/CanvasLayer")
		if not is_paused:
			pause_menu.show()
			if canvas_layer_node:
				canvas_layer_node.visible = true
			is_paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if OS.get_name() == "Web":
				Engine.time_scale = 0.0
			else:
				get_tree().paused = true
		else:
			pause_menu.hide()
			if canvas_layer_node:
				canvas_layer_node.visible = false
			is_paused = false
			if OS.get_name() == "Web":
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				Engine.time_scale = 1.0
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				get_tree().paused = false

	if is_paused:
		return
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * CAMERA_FOLLOW_SPEED)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5.0)
	#camera_pivot.look_at(global_position, camera_pivot.y)
	steer_input = Input.get_axis("ui_right", "ui_left") * MAX_STEER
	steering = lerp(steering, steer_input, delta * 7.0)
	var throttle = Input.get_axis("ui_down", "ui_up")
	var speed = linear_velocity.length()
	_crash_cooldown = max(_crash_cooldown - delta, 0.0)
	if _crash_cooldown <= 0.0 and _prev_speed > 8.0 and speed < _prev_speed * 0.45 and speed < 4.0:
		_play_sfx(sfx_crash)
		_crash_cooldown = 1.5
	_prev_speed = speed
	force_input = throttle * ENGINE_POWER
	var speed_ratio = clamp(speed / 30.0, 0.0, 1.0)
	engine_speed = force_input * (1.0 - speed_ratio * 0.88)
	#if Input.is_action_pressed("win_menu"):
		#_pause_menu()
		#if is_paused:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			#win_canvas_layer.show()
			##get_tree().change_scene_to_packed(win_screen)
		#else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			#win_canvas_layer.hide()
			##win_screen.hide()
			##win_canvas_layer.hide()
		#
	if Input.is_action_just_pressed("ui_up"):
		if inGearNumber == 0:
			first_gear_audio.play()
		inGearNumber += 1
	else:
		pass
		
	if Input.is_action_just_released("ui_up"):
		first_gear_audio.stop()
		inGearNumber = 0

	if Input.is_action_just_pressed("debug1"):
		print("facing: x=" + str(snappedf(rad_to_deg(global_rotation.x), 0.1)) + " y=" + str(snappedf(rad_to_deg(global_rotation.y), 0.1)) + " z=" + str(snappedf(rad_to_deg(global_rotation.z), 0.1)))
		
	#if linear_velocity.length() <= 0.2:
		#engine_speed = min(engine_speed, 100)
		#print("HIT A WALL OR SOMETHING")
	
	
	var local_vel = global_transform.basis.inverse() * linear_velocity
	var is_sliding = abs(local_vel.x) > 4.0 and speed > 6.0
	_current_drift_angle = abs(local_vel.x)
	_actively_drifting = _current_drift_angle > 2.0 and (is_drifting or speed > 10.0)
	_all_wheels_off = !front_left.is_in_contact() and !front_right.is_in_contact() and !back_left.is_in_contact() and !back_right.is_in_contact()
	_cached_speed = speed
	var rear_mid = (back_left.global_position + back_right.global_position) * 0.5

	var front_grip = 1.4 + clamp(speed / 20.0, 0.0, 0.8)
	front_left.wheel_friction_slip = front_grip
	front_right.wheel_friction_slip = front_grip
	var spin_damping = clamp(speed / 8.0, 0.2, 1.0)
	apply_torque(Vector3(0, -angular_velocity.y * spin_damping * 12.0, 0))

	var active_drift_friction = drift_friction + clamp((8.0 - speed) * 0.08, 0.0, 0.3) + clamp(speed / 22.0, 0.0, 0.55)
	if Input.is_action_pressed("handbrake") and speed > 2.0:
		_drift_elapsed += delta
		back_left.brake = 0.0
		back_right.brake = 0.0
		back_left.wheel_friction_slip = active_drift_friction
		back_right.wheel_friction_slip = active_drift_friction
		engine_force = engine_speed * 0.85
		is_drifting = true
		if throttle != 0 and speed > 1.0:
			var vel_dir = linear_velocity.normalized()
			var face_dir = -global_transform.basis.z
			var momentum_bias = clamp(speed / 25.0, 0.0, 1.0)
			var steer_blend = lerp(0.18, 0.04, momentum_bias)
			var drive_dir = vel_dir.lerp(face_dir, steer_blend)
			apply_central_force(drive_dir * throttle * ENGINE_POWER * 1.15)
		if throttle > 0.1:
			var swing_scale = clamp(0.12 + _drift_elapsed * 0.12, 0.12, 0.4)
			var oversteer = -global_transform.basis.x * sign(local_vel.x) * throttle * ENGINE_POWER * swing_scale
			apply_force(oversteer, rear_mid - global_position)
	elif is_drifting and is_sliding:
		_drift_elapsed += delta
		back_left.brake = 0
		back_right.brake = 0
		back_left.wheel_friction_slip = active_drift_friction
		back_right.wheel_friction_slip = active_drift_friction
		engine_force = engine_speed * 0.85
		if throttle != 0 and speed > 1.0:
			var vel_dir = linear_velocity.normalized()
			var face_dir = -global_transform.basis.z
			var momentum_bias = clamp(speed / 25.0, 0.0, 1.0)
			var steer_blend = lerp(0.18, 0.04, momentum_bias)
			var drive_dir = vel_dir.lerp(face_dir, steer_blend)
			apply_central_force(drive_dir * throttle * ENGINE_POWER * 1.15)
		if throttle > 0.1:
			var swing_scale = clamp(0.12 + _drift_elapsed * 0.12, 0.12, 0.4)
			var oversteer = -global_transform.basis.x * sign(local_vel.x) * throttle * ENGINE_POWER * swing_scale
			apply_force(oversteer, rear_mid - global_position)
	else:
		_drift_elapsed = 0.0
		back_left.brake = 0
		back_right.brake = 0
		back_left.wheel_friction_slip = lerpf(back_left.wheel_friction_slip, normal_back_friction, delta * 3.0)
		back_right.wheel_friction_slip = lerpf(back_right.wheel_friction_slip, normal_back_friction, delta * 3.0)
		engine_force = engine_speed
		is_drifting = false
	
	#steering_input = lerp(steering_input, )
	
	#self.angular_damping = default_angular_damping
	var back_wheel_in_contact = true
	if !back_left.is_in_contact() && !back_right.is_in_contact():
		back_wheel_in_contact = false
		print("BACK WHEELS NOT ON GROUND")
	else:
		back_wheel_in_contact = true
	
	var damped_angular_velocity = angular_velocity
	if linear_velocity.length() > 5 && back_wheel_in_contact:
		#print("PLAYER MOVING at " + str(linear_velocity.length()))
		gravity_scale = 2
		damped_angular_velocity.z = lerp(damped_angular_velocity.x, damped_angular_velocity.y, delta * z_angular_damping_factor / 2)
		#angular_velocity = damped_angular_velocity
		#print("IS THIS IT: " + str(angular_velocity))
		_set_suspension(100, 120)
		#below works as slipping on ice
		#angular_velocity.z = lerp(angular_velocity.z, 0.0, delta * roll_damping_factor)
	elif linear_velocity.length() > 10 && back_wheel_in_contact:
		#print("PLAYER MOVING at " + str(linear_velocity.length()))
		gravity_scale = 3
		print(str(linear_velocity.length()))
		_set_suspension(110, 130)
		#damped_angular_velocity.z = lerp(damped_angular_velocity.x, damped_angular_velocity.y, delta * z_angular_damping_factor)
	elif linear_velocity.length() > 20 && back_wheel_in_contact:
		#print("PLAYER MOVING at " + str(linear_velocity.length()))
		gravity_scale = 4
		print(str(linear_velocity.length()))
		#damped_angular_velocity.z = lerp(damped_angular_velocity.z, 0, delta * z_angular_damping_factor)
		print(str(angular_velocity))
		_set_suspension(120, 150)
	elif linear_velocity.length() > 5 && !back_wheel_in_contact:
		gravity_scale = 1.5
		apply_torque(Vector3(
			-angular_velocity.x * 18.0,
			0.0,
			-angular_velocity.z * 18.0
		))
	elif linear_velocity.length() > 10 && !back_wheel_in_contact:
		gravity_scale = 2
		apply_torque(Vector3(
			-angular_velocity.x * 18.0,
			0.0,
			-angular_velocity.z * 18.0
		))
	else:
		gravity_scale = 1
		#angular_velocity = Vector3(0, 0, -10)
		angular_damp = 0
		#print("Less than dampen: " + str(angular_velocity))
		_set_suspension(70, 100)
		
		
	
	
func _process(delta):
	
	#var decimalsAdded = ".00"
	#" + decimalsAdded + "
	#decimalsAdded = ""
	if !hasLostScore:
		driver_stars = str(int(driver_stars))
	
	if orders_placed && package_count >= 1:
		isInDropoff = true
	else:
		isInDropoff = false
		
	isInPickup = orders_placed >= 1
	
	
	if ray_cast_3d.player_on_road == true:
		if player_score_from_road < 500:
			player_score_from_road += 100 * delta
	elif ray_cast_3d.player_on_road == false and player_score_from_road > 0:
		if !is_paused && !hasFinishedDropoff:
			player_score_from_road -= 50 * delta
	player_score_from_road = clamp(player_score_from_road, 0, 500)
	if player_score_from_road <= 0:
		get_tree().reload_current_scene()

	if grabbedFirstPackage and player_score_from_road < _last_driving_score - 15.0:
		displayMessage("⚠  Package taking damage!", 1.5)
	_last_driving_score = player_score_from_road

	if !is_paused and _all_wheels_off and _cached_speed > 3.0:
		var pts = _cached_speed * delta * 2.0
		drift_pending += pts
		drift_bar.value = min(drift_pending, 35.0)
		_drift_bar_fill.bg_color = Color(0.2, 0.9, 0.3) if drift_pending >= 35.0 else Color(0.9, 0.7, 0.1)
		scoreLabel.text = "Score: %d" % int(drift_score_total)
		_drift_mult_label.visible = false
		_is_airtime = true
	elif !is_paused and _actively_drifting:
		_drift_chain_grace = 2.5
		_drift_end_timer = 0.0
		drift_sustained_time += delta
		if drift_sustained_time >= 0.75:
			drift_combo_multiplier = min(drift_combo_multiplier + 0.25, 4.0)
			drift_sustained_time = 0.0
		var pts = sqrt(_current_drift_angle) * _cached_speed * drift_combo_multiplier * delta * 0.9
		drift_pending += pts
		drift_bar.value = min(drift_pending, 35.0)
		_drift_bar_fill.bg_color = Color(0.2, 0.9, 0.3) if drift_pending >= 35.0 else Color(0.9, 0.7, 0.1)
		scoreLabel.text = "Score: %d" % int(drift_score_total)
		if drift_combo_multiplier > 1.0:
			_drift_mult_label.text = "x%.2f Drift Multiplier" % drift_combo_multiplier
			if drift_pending >= 35.0 or _drift_mult_label.visible:
				_drift_mult_label.visible = true
				_drift_mult_label_timer = 2.0
		_is_airtime = false
	else:
		_drift_end_timer += delta
		_drift_chain_grace -= delta
		if _drift_chain_grace <= 0.0:
			drift_combo_multiplier = 1.0
			_drift_chain_grace = 0.0
		if _drift_end_timer >= 0.3:
			if drift_pending >= 35.0:
				drift_score_total += drift_pending
				while drift_score_total >= _score_bonus_next:
					countdown_timer.start(countdown_timer.time_left + 2.0)
					_score_bonus_next += 50.0
				if _is_airtime:
					displayMessage("+%d AIRTIME!" % int(drift_pending), 2.0)
				else:
					displayMessage("+%d DRIFT POINTS!" % int(drift_pending), 2.0)
			drift_pending = 0.0
			drift_bar.value = 0.0
			_drift_bar_fill.bg_color = Color(0.9, 0.7, 0.1)
			drift_sustained_time = 0.0
			_is_airtime = false
		scoreLabel.text = "Score: %d" % int(drift_score_total)
		if _drift_mult_label_timer > 0.0:
			_drift_mult_label_timer -= delta
			if _drift_mult_label_timer <= 0.0:
				_drift_mult_label.visible = false
		
	
	steer_display = snapped(steering, 0.1)
	if steer_display > 0.2:
		steer_text_from_int = "Left"
	elif steer_display <= -0.2:
		steer_text_from_int = "Right"
	else:
		steer_text_from_int = "Centered"
	
	#str(steer_display)
	%ForceSteeringLabel.text = ""
	
	if countdown_timer.is_stopped():
		countdown_label.text = "0.0"
		get_tree().reload_current_scene()
		print("RELOAD SCENE")
	else:
		var time_left = countdown_timer.time_left
		var minutes_left = int(time_left) / 60
		var seconds_left = int(time_left) % 60
		if seconds_left < 10:
			countdown_label.text = "Time Left: " + str(minutes_left) + ":0" + str(seconds_left)
		else:
			countdown_label.text = "Time Left: " + str(minutes_left) + ":" + str(seconds_left)

		clamp(player_score_from_road, 0, 500)

func _build_drift_bar():
	_drift_canvas = CanvasLayer.new()
	_drift_canvas.layer = -1
	var canvas = _drift_canvas
	add_child(canvas)
	drift_bar = ProgressBar.new()
	drift_bar.max_value = 35.0
	drift_bar.value = 0.0
	drift_bar.custom_minimum_size = Vector2(220, 22)
	drift_bar.position = Vector2(20, 140)
	drift_bar.show_percentage = false
	_drift_bar_fill = StyleBoxFlat.new()
	_drift_bar_fill.bg_color = Color(0.9, 0.7, 0.1)
	_drift_bar_fill.corner_radius_top_left = 6
	_drift_bar_fill.corner_radius_top_right = 6
	_drift_bar_fill.corner_radius_bottom_left = 6
	_drift_bar_fill.corner_radius_bottom_right = 6
	drift_bar.add_theme_stylebox_override("fill", _drift_bar_fill)
	canvas.add_child(drift_bar)
	_drift_mult_label = Label.new()
	_drift_mult_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_drift_mult_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_drift_mult_label.anchor_left = 0.5
	_drift_mult_label.anchor_right = 0.5
	_drift_mult_label.anchor_top = 0.75
	_drift_mult_label.anchor_bottom = 0.75
	_drift_mult_label.offset_left = -150.0
	_drift_mult_label.offset_right = 150.0
	_drift_mult_label.offset_top = -20.0
	_drift_mult_label.offset_bottom = 20.0
	_drift_mult_label.add_theme_font_size_override("font_size", 28)
	_drift_mult_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.3))
	_drift_mult_label.add_theme_constant_override("outline_size", 8)
	_drift_mult_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	_drift_mult_label.visible = false
	canvas.add_child(_drift_mult_label)

func _play_sfx(stream: AudioStream):
	if stream == null or _sfx_player == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()

func _apply_car_stats():
	var stats = CAR_STATS.get(vehicle_selected, CAR_STATS[1])
	ENGINE_POWER = stats.engine
	MAX_STEER = stats.steer
	drift_friction = stats.drift_f
	normal_back_friction = stats.normal_f

func _set_suspension(stiffnessFront, stiffnessBack):
	front_left.suspension_stiffness = stiffnessFront
	front_right.suspension_stiffness = stiffnessFront
	back_left.suspension_stiffness = stiffnessBack
	back_right.suspension_stiffness = stiffnessBack
	
func _player_score_to_driver_stars(player_score):
	#driver_stars
	#var driver_score_atm = player_score / 100.0
	if grabbedFirstPackage && !hasFinishedDropoff:
		if player_score <= 475:
			driver_stars_score -= 2
		if player_score <= 450:
			driver_stars_score -= 5
		if player_score <= 425:
			driver_stars_score -= 7
		if player_score <= 400:
			driver_stars_score -= 10
		if player_score <= 300:
			driver_stars_score -= 13
		if player_score <= 250:
			driver_stars_score -= 15
		if player_score <= 200:
			driver_stars_score -= 17
		if player_score <= 100:
			driver_stars_score -= 20
		if player_score <= 001:
			driver_stars_score -= 500
		driver_stars_score = max(0, driver_stars_score)
	else:
		pass
	
	var driver_stars_formatted = str(driver_stars_score / 100.0).pad_decimals(2)
	print(driver_stars)
	return(driver_stars_formatted)
	
func _package_health_check(player_score, package_health_score):
	#driver_stars
	#var driver_score_atm = player_score / 100.0
	if !hasFinishedDropoff:
		if player_score <= 475:
			hasLostScore = true
		if player_score <= 475:
			package_health_score = float(package_health_score) - 0.02
		if player_score <= 450:
			package_health_score = float(package_health_score) - 0.05
		if player_score <= 425:
			package_health_score = float(package_health_score) - 0.07
		if player_score <= 400:
			package_health_score = float(package_health_score) - 0.10
		if player_score <= 300:
			package_health_score = float(package_health_score) - 0.13
		if player_score <= 250:
			package_health_score = float(package_health_score) - 0.15
		if player_score <= 200:
			package_health_score = float(package_health_score) - 0.17
		if player_score <= 100:
			package_health_score = float(package_health_score) - 0.20
		if player_score <= 001:
			package_health_score = float(package_health_score) - 5.00
		package_health_score = max(0, float(package_health_score))
		
		print("NEW PACKAGE SCORE: " + str(package_health_score))
	return(package_health_score)
	
#func _player_score_to_driver_stars(player_score):
	#driver_stars = player_score / 100.0
	#var driver_stars_formatted = str(player_score / 100.0).pad_decimals(2)
	#print(driver_stars)
	#return(driver_stars_formatted)

func _on_area_3d_body_entered(body):
	#player_on_road = true
	#print(player_on_road)
	pass


#func _on_area_3d_body_exited(body):
	#player_on_road = false
	#print(player_on_road)


func _on_driver_stars_check_timer_timeout():
	driver_stars = _player_score_to_driver_stars(player_score_from_road)
	for package in packages_collected:
		package.package_health = _package_health_check(player_score_from_road, package.package_health)


func _on_area_3d_area_entered(area):
	
#	CHECKPOINT UI
	var packages_health_at_pickup = ""
	for package in packages_collected:
		if float(package.package_health) >= 4.5:
			print(package.name + " in Nice Shape! Well Done")
			packages_health_at_pickup = packages_health_at_pickup + package.name + " in Nice Shape!\n"
		elif float(package.package_health) >= 4.0:
			print(package.name + " in Okay Shape")
			packages_health_at_pickup = packages_health_at_pickup + package.name + " in Okay Shape\n"
		else:
			print(package.name + " in Bad Shape.")
			packages_health_at_pickup = packages_health_at_pickup + package.name + " in Bad Shape.\n"
	
	current_package_health = packages_health_at_pickup
	print("this is the area: " + str(area))
	current_player_score = "Driving Score of " + str(int(player_score_from_road))
	current_driver_stars = driver_stars + " Stars!"
	
	
	if countdown_timer.time_left > 0:
		var minutes_left = int(countdown_timer.time_left) / 60
		var seconds_left = int(countdown_timer.time_left) % 60
		#var ms_left = countdown_timer.time_left - seconds_left
		#+ str(ms_left).pad_decimals(1)
		if seconds_left < 10:
			current_time_left = "Time Left: " + str(minutes_left) + ":0" + str(seconds_left)
		else:
			current_time_left = "Time Left: " + str(minutes_left) + ":" + str(seconds_left)
			
	checkpoint_label.text = current_player_score + "\n" + current_driver_stars + "\n" + current_time_left + "\n" + current_package_health
	checkpoint_timer.wait_time = 4
	checkpoint_timer.start()


func _on_checkpoint_timer_timeout():
	#get_tree().reload_current_scene()
	checkpoint_label.text = ""


#func _on_flag_area_area_entered(area):
	#_flag_collected()
	#print(str(area))
	#area.queue_free()
	
func _flag_collected():
	flags_grabbed += 1
	package_count += 1
	_play_sfx(sfx_delivery_pickup)
	Game.on_pickup_collected()
	if flags_grabbed > 0:
		flag_count_label.text = "Packages: " + str(package_count)
	else:
		flag_count_label.text = "No Packages Yet"
	
	var new_package = {
		name = "Package " + str(package_count),
		package_health = str(driver_stars)
	}
	
	packages_collected.append(new_package)
	print("New package collected: ", new_package)
	print("Total packages: ", packages_collected)
	
	var packages_health_at_pickup = ""
	for package in packages_collected:
		if float(package.package_health) >= 4.5:
			print(package.name + " in Nice Shape! Well Done")
			packages_health_at_pickup = packages_health_at_pickup + package.name + " in Nice Shape!\n"
		elif float(package.package_health) >= 4.0:
			print(package.name + " in Okay Shape")
			packages_health_at_pickup = packages_health_at_pickup + package.name + " in Okay Shape\n"
		else:
			print(package.name + " in Bad Shape.")
			packages_health_at_pickup = packages_health_at_pickup + package.name + " in Bad Shape.\n"
	
	current_package_health = packages_health_at_pickup
	
func _place_order_collected():
	orders_placed += 1
	orders_placed_stored_var += 1
	_play_sfx(sfx_order_pickup)
	if orders_placed > 0:
		order_count_label.text = "Orders: " + str(orders_placed)
	else:
		order_count_label.text = "No Orders Yet"
	Game.on_order_collected()
		
func _dropoff_order():
	if orders_placed && package_count > 0:
		packages_delivered += 1
		_play_sfx(sfx_package_delivered)
		orders_placed -= 1
		order_count_label.text = "Orders: " + str(orders_placed)
		package_count -= 1
		flag_count_label.text = "Packages: " + str(package_count)
		Game.on_dropoff_collected()
	else:
		displayMessage("You need an order and a package to deliver", 2.0)
		
func displayMessage(text, time):
	checkpoint_label.text = str(text)
	checkpoint_timer.wait_time = time
	checkpoint_timer.start()

func _on_flag_area_body_entered(body):
	if orders_placed >= 1:
		_flag_collected()
		grabbedFirstPackage = true
	else:
		displayMessage("You need to get an order first", 2.0)

func _on_order_flag_area_body_entered(body):
	_place_order_collected()


#func _on_dropoff_flag_area_body_entered(body):
	#_dropoff_order()
	#print("HELLOOOOO")
	##pass


func _on_dropoff_flag_area_body_entered(body):
	#print("HELOOOOOO")
	_dropoff_order()
	print("This is the child of the collision body: " + str(get_child(2)))
	#queue_free()


func _on_delivery_dropoff_area_3d_area_entered(area):
	if not Game.can_cash_out:
		displayMessage("Complete 3 deliveries first to cash out!", 2.5)
		return
	print("DELIVERY DEPOT")
	hasFinishedDropoff = true
	finished_time = countdown_timer.time_left
	win_canvas_layer.show()
	_drift_canvas.hide()
	if FileAccess.file_exists(save_path):
		print("WOAH THERE BUCKAROO")
	_save_and_load_data()
	#print("THIS IS PACKAGE SCORE: " + str(package_score))
	driver_stars_score = 500
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	is_paused = true
	#win_screen.score_label_for_win.text = ""
	score_label_for_win.text = ""
	if packages_delivered >= 2:
		var pkg_health = float(packages_collected[1].package_health)
		var reward = int(drift_score_total * (pkg_health / 5.0))
		var reward_line = "\nScore (%d) * Package Health (%.2f) = $%d" % [int(drift_score_total), pkg_health, reward]
		if pkg_health >= 4.95:
			print(packages_collected[1].name + " in Perfect Shape! Extremely Well Done!")
			win_label.text = "Extremely Well Done!"
			score_label_for_win.text = "You delivered the packages in Perfect Shape!" + reward_line
		elif pkg_health >= 4.5:
			print(packages_collected[1].name + " in Nice Shape! Well Done")
			win_label.text = "Well Done"
			score_label_for_win.text = "You delivered the packages in Nice Shape!" + reward_line
		elif pkg_health >= 4.0:
			print(packages_collected[1].name + " in Okay Shape")
			win_label.text = "Deliveries Completed"
			score_label_for_win.text = "You delivered the packages in Okay Shape" + reward_line
		else:
			print(packages_collected[1].name + " in Bad Shape.")
			win_label.text = "Deliveries Completed"
			score_label_for_win.text = "Packages were in Bad Shape.\nTry Again for a better outcome" + reward_line

func _pause_menu():
	is_paused = not is_paused
	#_package_scores_array()
	#print("PACKAGE SCORES: " + str(package_scores))
	
func _find_avg_package_health():
	if packages_collected[0]:
		var i = 0
		var total = 0
		var avg = 0
		for box in packages_collected:
			i += 1
			total += box.package_health
		total = total / i
		return total

func _package_scores_array():
	print("PACKAGE SCORE: " + str(package_score))
	package_scores.append(package_score)
	print("PACKAGE SCORES: " + str(package_scores))
	
func _finished_times_array():
	print("ALL FINISHED TIME: " + str(finished_time))
	finished_times.append(finished_time)
	print("ALL FINISHED TIMES: " + str(finished_times))
	
func _player_money_package_health_check():
	var avg_pkg_health = _find_avg_package_health()
	var money_to_add = 0
	if avg_pkg_health >= 4.95:
		money_to_add = 250
	elif avg_pkg_health >= 4.75:
		money_to_add = 225
	elif avg_pkg_health >= 4.50:
		money_to_add = 200
	elif avg_pkg_health >= 4.00:
		money_to_add = 150
	elif avg_pkg_health >= 3.50:
		money_to_add = 100
	elif avg_pkg_health >= 3.00:
		money_to_add = 50
	elif avg_pkg_health >= 2.00:
		money_to_add = 25
	else:
		money_to_add = 0
	return money_to_add
	
func _save_and_load_data():
	package_score = _find_avg_package_health()
	_load_data()
	_package_scores_array()
	_finished_times_array()
	money_to_add_total = _player_money_package_health_check()
	player_money_total = player_money_total + money_to_add_total
	_save_data()

func _save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(package_scores)
	file.store_var(finished_times)
	file.store_var(player_money_total)
	file.store_var(van_purchased)
	file.store_var(taxi_purchased)
	file.store_var(suv_purchased)
	file.store_var(lux_purchased)
	file.store_var(sedan_purchased)
	file.store_var(vehicle_selected)
	
func _load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		package_scores = file.get_var()
		finished_times = file.get_var()
		player_money_total = file.get_var()
		van_purchased = file.get_var()
		taxi_purchased = file.get_var()
		suv_purchased = file.get_var()
		lux_purchased = file.get_var()
		sedan_purchased = file.get_var()
		vehicle_selected = file.get_var()
		print("Finished Times on file: " + str(finished_times))

func _on_play_button_pressed():
	#print("WORKINGGGG")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	#win_screen.hide()
	
func _display_selected_vehicle():
	_load_data()
	if vehicle_selected == 1:
		van_body.show()
		taxi_body.hide()
		suv_body.hide()
		lux_body.hide()
		sedan_body.hide()
	elif vehicle_selected == 2 && taxi_purchased:
		van_body.hide()
		taxi_body.show()
		suv_body.hide()
		lux_body.hide()
		sedan_body.hide()
	elif vehicle_selected == 3 && suv_purchased:
		van_body.hide()
		taxi_body.hide()
		suv_body.show()
		lux_body.hide()
		sedan_body.hide()
	elif vehicle_selected == 4 && lux_purchased:
		van_body.hide()
		taxi_body.hide()
		suv_body.hide()
		lux_body.show()
		sedan_body.hide()
	elif vehicle_selected == 5 && sedan_purchased:
		van_body.hide()
		taxi_body.hide()
		suv_body.hide()
		lux_body.hide()
		sedan_body.show()
	else:
		van_body.show()
		taxi_body.hide()
		suv_body.hide()
		lux_body.hide()
		sedan_body.hide()
