extends Trails
 
var States = {
	"water" : 1,
	"fire" : 2,
	"earth" : 3
}

var colors = {
	"water" : Color(0.243, 0.238, 0.688),
	"fire" : Color(0.557, 0.118, 0.294),
	"earth" : Color(0.296, 0.292, 0.281)
}
 
func _get_position():
	return get_parent().position
 



func _on_player_state_changed(state):
	if state != "idle":
		g_draw_line =  true
	else:
		g_draw_line =  false
