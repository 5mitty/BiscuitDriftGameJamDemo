extends Control

#@onready var score_label = $VBoxContainer/ScoreLabel
@onready var win_label = %WinLabel
@onready var score_label_for_win = %ScoreLabelForWin
@onready var play_button = %PlayButton
@onready var quit_button = %QuitButton
@onready var player = $".."
const MAIN_MENU = preload("res://Scenes/main_menu.tscn")
@export var game_large: PackedScene = preload("res://Scenes/gameLarge.tscn")
const START_SCREEN = preload("res://Scenes/start_screen.tscn")

func _ready():
	#play_button.pressed.connect(_on_play_button_pressed)
	#quit_button.pressed.connect(_on_quit_button_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#score_label.text = 
	#if player.package_count >= 2:
		#if float(player.packages_collected[1].package_health) >= 4.5:
			#print(player.packages_collected[1].package.name + " in Nice Shape! Well Done")
			#score_label_for_win.text = "You delivered the packages in Nice Shape!\n"
		#elif float(player.packages_collected[1].package.package_health) >= 4.0:
			#print(player.packages_collected[1].package.name + " in Okay Shape")
			#score_label_for_win.text = "You delivered the packages in Okay Shape\n"
		#else:
			#print(player.packages_collected[1].package.name + " in Bad Shape.")
			#score_label_for_win.text = "You delivered the packages in Bad Shape.\n"

#
#func _on_win_play_button_pressed():
	##get_tree().change_scene_to_packed(main_menu)
	#print("WTFFF")

#func _on_play_button_pressed():
	#print("WORKS1")
	#get_tree().change_scene_to_packed(MAIN_MENU)

func _on_quit_button_pressed():
	print("WORKS2")
	get_tree().quit()
