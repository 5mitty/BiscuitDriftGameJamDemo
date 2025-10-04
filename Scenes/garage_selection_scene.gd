extends Node3D

var save_path = "user://player_data.save"
var package_score = 0
var package_scores = []
var finished_time = 0.0
var finished_times = []
var player_money_total = 0
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
var vehicle_selection_save = 1
var vehicles_purchased = [van_purchased, taxi_purchased, suv_purchased, lux_purchased, sedan_purchased]
@onready var van_button = %VanButton
@onready var taxi_button = %TaxiButton
@onready var suv_button = %SuvButton
@onready var lux_button = %LuxButton
@onready var sedan_button = %SedanButton
@onready var van = %van
@onready var taxi = %taxi
@onready var suv = %suv
@onready var suv_luxury = %"suv-luxury"
@onready var sedan = %sedan
@onready var money_label = %MoneyLabel
@onready var vehicle_price_label = %VehiclePriceLabel
@onready var vehicle_purchase_button = %VehiclePurchaseButton

func _ready():
	_load_data()
	if vehicle_selected == 1:
		_on_van_button_pressed()
	elif vehicle_selected == 2:
		_on_taxi_button_pressed()
	elif vehicle_selected == 3:
		_on_suv_button_pressed()
	elif vehicle_selected == 4:
		_on_lux_button_pressed()
	elif vehicle_selected == 5:
		_on_sedan_button_pressed()

func _physics_process(delta):
	_load_data()
	if player_money_total:
		money_label.text = "MONEY: " + str(player_money_total)
	else:
		money_label.text = "MONEY: " + str(0)

func _save_and_load_data():
	#package_score = _find_avg_package_health()
	_load_data()
	#_on_vehicle_purchase_pressed()
	
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
		
func _on_vehicle_purchase_pressed(vehicle_price, vehicle_id):
	_load_data()
	if player_money_total >= vehicle_price:
		if vehicle_id == 1 && !van_purchased:
			vehicle_price_label.text = "PRICE: 0"
			vehicle_purchase_button.text = "OWNED"
		elif vehicle_id == 2 && !taxi_purchased:
			taxi_purchased = true
			player_money_total -= taxi_price
			vehicle_price_label.text = "PRICE: 0"
			vehicle_purchase_button.text = "OWNED"
		elif vehicle_id == 3 && !suv_purchased:
			suv_purchased = true
			player_money_total -= suv_price
			vehicle_price_label.text = "PRICE: 0"
			vehicle_purchase_button.text = "OWNED"
		elif vehicle_id == 4 && !lux_purchased:
			lux_purchased = true
			player_money_total -= lux_price
			vehicle_price_label.text = "PRICE: 0"
			vehicle_purchase_button.text = "OWNED"
		elif vehicle_id == 5 && !sedan_purchased:
			sedan_purchased = true
			player_money_total -= sedan_price
			vehicle_price_label.text = "PRICE: 0"
			vehicle_purchase_button.text = "OWNED"
		else:
			vehicle_price_label.text = "PRICE: 0"
			vehicle_purchase_button.text = "OWNED"
	else:
		vehicle_purchase_button.text = "NEED $"
	_save_data()

func _on_van_button_pressed():
	van.show()
	taxi.hide()
	suv.hide()
	suv_luxury.hide()
	sedan.hide()
	if van_purchased:
		vehicle_price_label.text = "PRICE: 0"
		vehicle_purchase_button.text = "OWNED"
	else:
		vehicle_price_label.text = "PRICE: 0"
		vehicle_purchase_button.text = "OWNED"
	vehicle_selected = 1
	if van_purchased:
		_save_data()
	else:
		_load_data()
	print("Vehicle selected: " + str(vehicle_selected))

func _on_taxi_button_pressed():
	van.hide()
	taxi.show()
	suv.hide()
	suv_luxury.hide()
	sedan.hide()
	#_on_vehicle_purchase_pressed(taxi_price, 2)
	if taxi_purchased:
		vehicle_price_label.text = "PRICE: 0"
		vehicle_purchase_button.text = "OWNED"
	else:
		vehicle_price_label.text = "PRICE: " + str(taxi_price)
		vehicle_purchase_button.text = "PURCHASE"
	vehicle_selected = 2
	if taxi_purchased:
		_save_data()
	else:
		_load_data()
	print("Vehicle selected: " + str(vehicle_selected))

func _on_suv_button_pressed():
	van.hide()
	taxi.hide()
	suv.show()
	suv_luxury.hide()
	sedan.hide()
	#_on_vehicle_purchase_pressed(suv_price, 3)
	if suv_purchased:
		vehicle_price_label.text = "PRICE: 0"
		vehicle_purchase_button.text = "OWNED"
	else:
		vehicle_price_label.text = "PRICE: " + str(suv_price)
		vehicle_purchase_button.text = "PURCHASE"
	vehicle_selected = 3
	if suv_purchased:
		_save_data()
	else:
		_load_data()
	print("Vehicle selected: " + str(vehicle_selected))

func _on_lux_button_pressed():
	van.hide()
	taxi.hide()
	suv.hide()
	suv_luxury.show()
	sedan.hide()
	#_on_vehicle_purchase_pressed(lux_price, 4)
	if lux_purchased:
		vehicle_price_label.text = "PRICE: 0"
		vehicle_purchase_button.text = "OWNED"
	else:
		vehicle_price_label.text = "PRICE: " + str(lux_price)
		vehicle_purchase_button.text = "PURCHASE"
	vehicle_selected = 4
	if lux_purchased:
		_save_data()
	else:
		_load_data()
	print("Vehicle selected: " + str(vehicle_selected))

func _on_sedan_button_pressed():
	van.hide()
	taxi.hide()
	suv.hide()
	suv_luxury.hide()
	sedan.show()
	#_on_vehicle_purchase_pressed(sedan_price, 5)
	if sedan_purchased:
		vehicle_price_label.text = "PRICE: 0"
		vehicle_purchase_button.text = "OWNED"
	else:
		vehicle_price_label.text = "PRICE: " + str(sedan_price)
		vehicle_purchase_button.text = "PURCHASE"
	vehicle_selected = 5
	if sedan_purchased:
		_save_data()
	else:
		_load_data()
	print("Vehicle selected: " + str(vehicle_selected))
	
func _on_vehicle_purchase_button_pressed():
	var local_price = 0
	if vehicle_selected == 2:
		local_price = taxi_price
	elif vehicle_selected == 3:
		local_price = suv_price
	elif vehicle_selected == 4:
		local_price = lux_price
	elif vehicle_selected == 5:
		local_price = sedan_price
	_on_vehicle_purchase_pressed(local_price, vehicle_selected)
	
func _on_debug_button_pressed():
	player_money_total += 250
	_save_data()
	_load_data()
	
func _on_next_button_pressed():
	_save_data()
	print("Vehicle selected: " + str(vehicle_selected))
