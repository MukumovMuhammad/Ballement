extends Node
class_name Element_state

var States = ["simple" , "water", "fire" , "earth"]

var in_fire_cant = ["water" , "simple"]
var current_state = States[0]

func Change_state(state_num : int):
	#return States[state_num]
	current_state = States[state_num]
	print_debug("The state of element was chaged to " , current_state)


func get_current_state():
	return current_state

func possible_to_stay(_state: Element_state):
	
	print("This is state of _state : "  + _state.current_state)
	print("This is current state : "  + current_state)
	#if an object is no Element_state at all
	if _state.current_state not in States: return true
	# if states are same
	if _state.current_state == current_state: return true
	
	if _state.current_state != "earth" or current_state != "earth":
		
		#if self is fire
		if current_state == "fire":
			if _state.current_state in in_fire_cant:
				return false
			else:
				return true
		
		#if an object is fire
		elif _state.current_state == "fire":
			if current_state in in_fire_cant:
				return false
			else:
				return true
		else:
			return true
	else: #if object is stone
		return true
