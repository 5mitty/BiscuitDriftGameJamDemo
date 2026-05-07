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
var handbrake_strength = 2.0

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
@onready var win_screen = $WinScreen
@onready var pause_menu = %PauseMenu
@onready var pause_settings_menu = %PauseSettingsMenu
@onready var pause_free_roam_menu = %PauseFreeRoamMenu
@onready var win_canvas_layer = %WinCanvasLayer
var main_menu = preload("res://Scenes/main_menu.tscn")
#var win_screen = preload("res://Scenes/win_screen.tscn")

var packages_collected = []
var checkpoint_flags: Array = [flag, flag_2, flag_3]

@onready var van_body = %vanBody
@onready var taxi_body = %taxiBody
@onready var suv_body = %suvBody
@onready var lux_body = %luxBody
@onready var sedan_body = %sedanBody

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	countdown_timer.wait_time = countdown_duration
	countdown_timer.start()
	driver_stars = _player_score_to_driver_stars(player_score_from_road)
	flag_count_label.text = ""
	order_count_label.text = "No Orders Yet"
	displayMessage("Collect all orders in the neighborhood", 4)
	_display_selected_vehicle()
	
func _physics_process(delta):
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * CAMERA_FOLLOW_SPEED)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5.0)
	#camera_pivot.look_at(global_position, camera_pivot.y)
	steer_input = Input.get_axis("ui_right", "ui_left") * MAX_STEER
	#steer_amount = lerp(steer_amount, steer_input, delta * 8)
	steering = move_toward(steering, steer_input, delta * 2.5)
	force_input = Input.get_axis("ui_down", "ui_up") * ENGINE_POWER
	#back_left.engine_force = force_input
	#back_right.engine_force = force_input
	
	if linear_velocity.length() > 25 || Input.is_action_pressed("handbrake"):
		force_input = 0.0
		engine_speed = 0.0
	else:
		if linear_velocity.length() > 5:
			#engine_speed = lerp(engine_speed, force_input, delta * 0.75)
			engine_speed = force_input / 1.6
		elif linear_velocity.length() > 10:
			engine_speed = force_input / 1.5
		elif linear_velocity.length() > 20:
			engine_speed = force_input / 1.25
		elif linear_velocity.length() > 25:
			engine_speed = force_input / 1.1
		else:
			engine_speed = lerp(engine_speed, force_input, delta * 0.9)
			#engine_speed = force_input / 2
			
		#engine_speed = force_input
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
		
	if Input.is_action_pressed("ui_cancel"):
		_pause_menu()
		if is_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			pause_menu.canvas_layer.show()
			#win_canvas_layer.show()
			#win_screen.show()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			pause_menu.canvas_layer.hide()
			#win_screen.hide()
			#win_canvas_layer.show()
		
	#if linear_velocity.length() <= 0.2:
		#engine_speed = min(engine_speed, 100)
		#print("HIT A WALL OR SOMETHING")
	
	
	if Input.is_action_pressed("handbrake"):
		back_left.brake = handbrake_strength
		back_right.brake = handbrake_strength
		engine_force = 0
	else:
		engine_force = engine_speed
	
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
	elif linear_velocity.length() > 10 && !back_wheel_in_contact:
		gravity_scale = 2
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
		
	if orders_placed >= 3:
		isInPickup = true
	
	
	if ray_cast_3d.player_on_road == true:
		if player_score_from_road < 500:
			player_score_from_road += 100 * (delta)
			clamp(player_score_from_road, 0, 500)
			if packages_collected:
				scoreLabel.text = driver_stars + "/5 Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
			else:
				scoreLabel.text = "-/- Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
			#scoreLabel.text = _player_score_to_driver_stars(player_score_from_road) + " Stars" + "\n" + str(int(player_score_from_road))
		else:
			if packages_collected:
				scoreLabel.text = driver_stars + "/5 Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
			else:
				scoreLabel.text = "-/- Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
	elif ray_cast_3d.player_on_road == false && player_score_from_road > 0:
		if !is_paused && !hasFinishedDropoff:
			player_score_from_road -= 50 * (delta)
		if packages_collected:
			scoreLabel.text = driver_stars + "/5 Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
		else:
			scoreLabel.text = "-/- Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
	else:
		if packages_collected:
			scoreLabel.text = driver_stars + "/5 Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
		else:
			scoreLabel.text = "-/- Package Health" + "\n" + str(int(player_score_from_road)) + " Driving Score"
		#+ str(int(player_score_from_road))
	clamp(player_score_from_road, 0, 500)
	if player_score_from_road <= 0:
		get_tree().reload_current_scene()
		print("RELOAD SCENE")
		
	
	steer_display = snapped(steering, 0.1)
	if steer_display > 0.2:
		steer_text_from_int = "Left"
	elif steer_display <= -0.2:
		steer_text_from_int = "Right"
	else:
		steer_text_from_int = "Centered"
	
	#str(steer_display)
	%ForceSteeringLabel.text = "Engine Speed: " + str(int(engine_speed)) + " Force: " + str(force_input) + " Steering: " + steer_text_from_int
	
	if countdown_timer.is_stopped():
		countdown_label.text = "0.0"
		get_tree().reload_current_scene()
		print("RELOAD SCENE")
	else:
		# Format the remaining time to one decimal place.
		var minutes_left = int(countdown_timer.time_left) / 60
		var seconds_left = int(countdown_timer.time_left) % 60
		#var ms_left = countdown_timer.time_left - seconds_left
		#+ str(ms_left).pad_decimals(1)
		if seconds_left < 10:
			countdown_label.text = "Time Left: " + str(minutes_left) + ":0" + str(seconds_left)
		else:
			countdown_label.text = "Time Left: " + str(minutes_left) + ":" + str(seconds_left)
		#str(countdown_timer.time_left).pad_decimals(1)
		
		clamp(player_score_from_road, 0, 500)

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
	#print("entered flag area 3d")
	flags_grabbed += 1
	package_count += 1
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
	
	if orders_placed > 0:
		order_count_label.text = "Orders: " + str(orders_placed)
	else:
		order_count_label.text = "No Orders Yet"
		
func _dropoff_order():
	print("YOOOOOOO")
	if orders_placed && package_count > 0:
		packages_delivered += 1
		orders_placed -= 1
		order_count_label.text = "Orders: " + str(orders_placed)
		package_count -= 1
		flag_count_label.text = "Packages: " + str(package_count)
		if packages_delivered == 3:
			countdown_timer.paused = true
			player_score_from_road = 500
			hasFinishedDropoff = true
			finished_time = countdown_timer.time_left
			if finished_time <= 0.5:
				displayMessage("WOW That Was Close!!\nDrive to the Delivery Depot in the woods", 4)
			else:
				displayMessage("Drive to the Delivery Depot in the woods", 4)
			print("Finished Time: " + str(finished_time))
	elif orders_placed_stored_var == 3 && packages_delivered == 2:
		if orders_placed && package_count == 1:
			checkpoint_label.text = "Nice Driving! Proceed back to the\n Delivery Depot in the woods"
			checkpoint_timer.start()
	else:
		checkpoint_label.text = "You need an order and a package to deliver"
		checkpoint_timer.start()
		
func displayMessage(text, time):
	checkpoint_label.text = str(text)
	checkpoint_timer.wait_time = time
	checkpoint_timer.start()

func _on_flag_area_body_entered(body):
	if orders_placed >= 3:
		_flag_collected()
		grabbedFirstPackage = true
		Game._spawn_flags()
		#print(str(body.get_child()))
		#print("Deleting: " + str(body))
		#body.queue_free()
	else:
		checkpoint_label.text = "You need to get all orders first"
		checkpoint_timer.wait_time = 2
		checkpoint_timer.start()

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
	print("DELIVERY DEPOT")
	win_canvas_layer.show()
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
		if float(packages_collected[1].package_health) >= 4.95:
			print(packages_collected[1].name + " in Perfect Shape! Extremely Well Done!")
			win_label.text = "Extremely Well Done!"
			score_label_for_win.text = "You delivered the packages in Perfect Shape!\n"
		elif float(packages_collected[1].package_health) >= 4.5:
			print(packages_collected[1].name + " in Nice Shape! Well Done")
			win_label.text = "Well Done"
			score_label_for_win.text = "You delivered the packages in Nice Shape!\n"
		elif float(packages_collected[1].package_health) >= 4.0:
			print(packages_collected[1].name + " in Okay Shape")
			win_label.text = "Deliveries Completed"
			score_label_for_win.text = "You delivered the packages in Okay Shape\n"
		else:
			print(packages_collected[1].name + " in Bad Shape.")
			win_label.text = "Deliveries Completed"
			score_label_for_win.text = "Packages were in Bad Shape.\nTry Again for a better outcome"

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
