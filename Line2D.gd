extends Line2D
@onready var timer = $Timer


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
