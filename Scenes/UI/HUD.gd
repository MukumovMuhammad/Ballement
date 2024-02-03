extends Control

@onready var progress_bar = $CanvasGroup/ProgressBar
@export var Player : CharacterBody2D
var ability_active : bool = false
var super_power_active : bool = false
@onready var panel = $CanvasGroup/Panel
@onready var menu_pause = $CanvasGroup/Panel/menu_pause
@onready var continue_btn = $CanvasGroup/Panel/continue_btn
@onready var reload_btn = $CanvasGroup/Panel/reload_btn

@onready var energy_compile = $CanvasGroup/energy_compile

@onready var configs : Dictionary = {
	"water" : {
		"panel" : preload("res://Assets/UI/menu_water.png"),
		"btn" : preload("res://Assets/UI/water_btn.png")
		#"pos" : Vector2(577,320)
	},
	"fire" : {
		"panel" : preload("res://Assets/UI/menu_fire.png"),
		"btn" : preload("res://Assets/UI/fire_btn (3).png")
		#"pos" : Vector2(552,331)
	},
	"earth" : {
		"panel" : preload("res://Assets/UI/menu_rock.png"),
		"btn" : preload("res://Assets/UI/rock_btn.png")
	},
	"simple" : {
		"panel" : preload("res://Assets/UI/menu_rock.png"),
		"btn" : preload("res://Assets/UI/rock_btn.png")
	}
}

func _ready():
	progress_bar.max_value = 5
	progress_bar.hide()
	panel.hide()
	energy_compile.hide()


func _process(delta):
	if ability_active:
		epmtying_bar()
		if super_power_active:
			empying_power_bar()
	else:
		progress_bar.hide()




func epmtying_bar():
	progress_bar.value = Player.ability_time

func empying_power_bar():
	energy_compile.value = Player.super_power_time

func _on_player_state_changed(state):
	if state != "simple":
		ability_active = true
		progress_bar.show()
	else:
		ability_active = false
	menu_pause.texture = configs[state]["panel"]
	continue_btn.icon = configs[state]["btn"]
	reload_btn.icon = configs[state]["btn"]



func _on_pause_btn_pressed():
	
	get_tree().paused = true
	panel.show()
	print("The game is on pause ")





func _on_continue_btn_pressed():
	get_tree().paused = false
	panel.hide()
	
	print("The game now is going on")


func _on_reload_btn_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_player_power_compile(active):
	super_power_active = active
	if active:
		energy_compile.show()
	else:
		energy_compile.hide()
	
	
