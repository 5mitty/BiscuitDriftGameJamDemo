extends Node3D

var save_path = "user://player_data.save"
var package_scores = []
var finished_times = []
var player_money_total = 0
var van_purchased = true
var taxi_purchased = false
var suv_purchased = false
var lux_purchased = false
var sedan_purchased = true
var vehicle_selected = 1

@onready var player = %Player

@onready var _order_flags: Array = [$"OrderFlag", $"OrderFlag2", $"OrderFlag3"]
@onready var _pickup_flags: Array = [$"Flag", $"Flag2", $"Flag3"]
@onready var _dropoff_flags: Array = [$"DropoffFlag2", $"DropoffFlag3", $"DropoffFlag4"]
@onready var _respawn_points: Array = [%FlagRespawn1, %FlagRespawn2, %FlagRespawn3]

var _active_order_idx: int = -1
var _active_pickup_idx: int = -1
var _prev_order_idx: int = -1
var _prev_pickup_idx: int = -1
var orders_completed: int = 0
var can_cash_out: bool = false

const BASE_TIME_BONUS := 30.0

func _ready():
	MusicManager.play_game_music($AudioStreamPlayer2D.stream)
	_load_data()
	_hide_all_flags()
	_next_order()

func _hide_all_flags():
	for f in _order_flags:
		_set_flag_active(f, "OrderFlagArea", false)
	for f in _pickup_flags:
		_set_flag_active(f, "FlagArea", false)
	for f in _dropoff_flags:
		_set_flag_active(f, "DropoffFlagArea", false)
	_set_flag_active($"DropoffFlag", "DropoffFlagArea", false)

func _set_flag_active(flag_node: Node3D, area_name: String, active: bool):
	flag_node.visible = active
	var area = flag_node.get_node_or_null(area_name)
	if area:
		area.set_deferred("monitoring", active)
		area.set_deferred("monitorable", active)

func _next_order():
	var idx = _pick_different(_prev_order_idx, _order_flags.size())
	_active_order_idx = idx
	_prev_order_idx = idx
	_set_flag_active(_order_flags[idx], "OrderFlagArea", true)
	_refresh_minimap()
	player.displayMessage("New order available!", 2.5)

func on_order_collected():
	_set_flag_active(_order_flags[_active_order_idx], "OrderFlagArea", false)
	_start_pickup()

func _start_pickup():
	var idx = _pick_different(_prev_pickup_idx, _pickup_flags.size())
	_active_pickup_idx = idx
	_prev_pickup_idx = idx
	_set_flag_active(_pickup_flags[idx], "FlagArea", true)
	_refresh_minimap()
	player.displayMessage("Go pick up your package!", 2.5)

func on_pickup_collected():
	_set_flag_active(_pickup_flags[_active_pickup_idx], "FlagArea", false)
	_start_dropoff()

func _start_dropoff():
	var f = _dropoff_flags[_active_pickup_idx]
	f.global_position = _respawn_points[_active_pickup_idx].global_position
	_set_flag_active(f, "DropoffFlagArea", true)
	_refresh_minimap()
	player.displayMessage("Deliver the package!", 2.5)

func on_dropoff_collected():
	_set_flag_active(_dropoff_flags[_active_pickup_idx], "DropoffFlagArea", false)
	orders_completed += 1
	var bonus := _time_bonus(orders_completed)
	player.countdown_timer.start(player.countdown_timer.time_left + bonus)
	if orders_completed == 3:
		can_cash_out = true
		player.displayMessage("+%ds! Head to the depot to cash out, or keep going!" % int(bonus), 4.0)
	elif orders_completed > 3:
		player.displayMessage("+%ds! %d orders done!" % [int(bonus), orders_completed], 2.5)
	else:
		player.displayMessage("+%ds! %d/3 to unlock cashout" % [int(bonus), orders_completed], 2.5)
	_refresh_minimap()
	await get_tree().create_timer(2.0).timeout
	_next_order()

func _time_bonus(count: int) -> float:
	if count <= 3:
		return BASE_TIME_BONUS
	return max(BASE_TIME_BONUS - (count - 3), 10.0)

func _pick_different(prev: int, count: int) -> int:
	if count <= 1:
		return 0
	var idx = randi() % count
	while idx == prev:
		idx = randi() % count
	return idx

func _refresh_minimap():
	var orders: Array = []
	var pickups: Array = []
	var dropoffs: Array = []
	var depot: Array = []
	if _active_order_idx >= 0 and _order_flags[_active_order_idx].visible:
		orders = [_order_flags[_active_order_idx]]
	if _active_pickup_idx >= 0 and _pickup_flags[_active_pickup_idx].visible:
		pickups = [_pickup_flags[_active_pickup_idx]]
	for f in _dropoff_flags:
		if f.visible:
			dropoffs = [f]
			break
	if can_cash_out:
		depot = [player.delivery_depot]
	player.update_active_flags(orders, pickups, dropoffs, depot)

func _spawn_flags():
	pass

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
