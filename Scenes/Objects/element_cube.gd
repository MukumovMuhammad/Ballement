extends RigidBody2D

var state : Element_state = Element_state.new()
@onready var sprite_2d = $Sprite2D
@onready var spray = $spray

@export var first_state : String


var do_teleport : bool = false
var new_pos : Vector2
var Wind_forse : Vector2
var going_up : bool = false

var states : Dictionary = {
	"water" : 1,
	"fire" : 2,
	"earth" : 3
}

@export var Masses : Dictionary = {
	"water" : 1.0,
	"fire" : 1.0,
	"earth" : 3.0
}
var Element_texture : Dictionary = {
	"water" : preload("res://Assets/Spritesheet/kandinsky-download-1706615106444.png") ,
	"fire" : preload("res://Assets/shape-character/PNG/Double/red_body_square.png"),
	"earth" : preload("res://Assets/Spritesheet/kandinsky-download-1706615431595.png")
		#preload("res://Assets/shape-character/PNG/Double/purple_body_square.png")
}

var sprite_settings : Dictionary = {
	"water" : {"hframes" : 1, "vframes" : 1, "frame" : 1, "frame_coords" : Vector2(0,1), "scale" : Vector2(0.048,0.048)},
	"fire" : {"hframes" : 3, "vframes" : 3, "frame" : 3, "frame_coords" : Vector2(0,1), "scale" : Vector2(1,1)},
	"earth" : {"hframes" : 1, "vframes" : 1, "frame" : 1, "frame_coords" : Vector2(0,0), "scale" : Vector2(0.048,0.048)},
}

func _ready():
	Change_state(first_state)




func _integrate_forces(_state):
	
	if do_teleport:
		print("Rigid Body is teleporting ", global_position)
		_state.transform = Transform2D(0.0, new_pos)
		print("to ", global_position)
		do_teleport = false
	if going_up and state.current_state != "earth":
		apply_impulse(Wind_forse / 10)
	
func Teleport(_new_pos : Vector2):
	do_teleport = true
	new_pos = _new_pos


func Change_state(new_state : String):
	state.Change_state(states[new_state])
	sprite_2d.texture = Element_texture[state.current_state]
	mass = Masses[new_state]
	spray.Object_changed_state(state.current_state)
	for i in sprite_settings[new_state]:
		sprite_2d[i] = sprite_settings[new_state][i]
	
	if state.current_state != "earth":
		set_collision_mask_value(4, false)
	else:
		set_collision_mask_value(4, true)
	
func get_state() -> Element_state:
	return state

func self_destroy():
	self.queue_free()
