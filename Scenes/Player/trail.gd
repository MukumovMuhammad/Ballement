extends Line2D
 
var queue : Array
@onready var g_draw_line : bool = false
@export var how_low : float =  10
@export var MAX_LENGTH : int = 10
@export var Player : Node2D

func _process(delta):
	
	if g_draw_line:
		Draw()
	else:
		clear_points()
		queue.clear()


func Draw():
	var pos = Player.global_position
	self.global_position = pos
	#pos.y += how_low
	queue.push_front(pos)
 
	if queue.size() > MAX_LENGTH:
		queue.pop_back()
 
	clear_points()
 
 
	for point in queue:
		add_point(point)
 

func _get_position():
	return get_parent()
 
