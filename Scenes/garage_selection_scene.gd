extends Node3D

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

func _physics_process(delta):
	pass

func _on_van_button_pressed():
	van.show()
	taxi.hide()
	suv.hide()
	suv_luxury.hide()
	sedan.hide()

func _on_taxi_button_pressed():
	van.hide()
	taxi.show()
	suv.hide()
	suv_luxury.hide()
	sedan.hide()

func _on_suv_button_pressed():
	van.hide()
	taxi.hide()
	suv.show()
	suv_luxury.hide()
	sedan.hide()

func _on_lux_button_pressed():
	van.hide()
	taxi.hide()
	suv.hide()
	suv_luxury.show()
	sedan.hide()

func _on_sedan_button_pressed():
	van.hide()
	taxi.hide()
	suv.hide()
	suv_luxury.hide()
	sedan.show()
