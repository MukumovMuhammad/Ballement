extends Line2D
@onready var timer = $Timer
@onready var small_timer = $small_timer
var has_done : bool = false

var Points : Array

func _ready():
	self.global_position = Vector2.ZERO

func appear(start_point: Vector2, end_point : Vector2) -> void:
	print_debug(" Positions that appear method recieves  " , start_point, end_point)
	self.global_position = Vector2.ZERO
	print_debug( " The global position of Line2D ", self.global_position)
	add_point(start_point)
	add_point(end_point)
	timer.start()

func disappear() -> void:
	clear_points()


func _on_timer_timeout():
	disappear()

func temp_show(start_point: Vector2, end_point : Vector2) -> void:
	if !has_done:
		add_point(start_point)
		add_point(end_point)
		has_done = true
	
	add_point(start_point)
	add_point(end_point)
	if get_point_count() > 2:
		remove_point(2)
		remove_point(3)
	#small_timer.start()


func _on_small_timer_timeout():
	disappear()
