extends CharacterBody2D
signal make_default
signal State_changed(state)
signal power_compile(active : bool)
var mouse_pos : Vector2
var coyote : bool = false
var last_floor : bool= false
var jumping : bool = false
var compiling : bool = false
@onready var label = $Label
var dashing : bool = false
var dash_allow : bool  = true
var Power_active : bool = false
var can_stay : bool = true
var compile_ready : bool = false
#var super_power_working : bool = false
@export_category("Player speeds")
@export var Normal_speed = {
	"simple" : 500.0,
	"water" : 500.0,
	"fire" : 800.0,
	"earth" : 300.0
}
@export var dash_speed = {"simple" : 1000.0, "water" : 1000.0, "fire" : 1500.0, "earth" :600.0}
@export var jump_velocity = {"simple" : -950.0, "water" : -900.0, "fire" : -1200.0, "earth" :-700.0}
#float = -1000.0
@export var line_2d : Line2D

@export_category("Player physics")
@export var coyote_frames = 6
@export var Weights = {"simple" : 4, "water" : 4.2, "fire" : 3.8, "earth" : 5}
@export var Push_forse = {"simple" : 10.0,"water" : 10.0,"fire" : 5.0, "earth" : 30.0}
@export var Abilities_opened = {"water" : false, "fire" : false, "earth" : false}
############ Element class ############


var Scales = {"simple" : 0.18, "water" : 0.18, "fire" : 0.23, "earth" : 0.15}
var anim_pos = {"simple" : Vector2(0.355,0), "water" : Vector2(-0.435,0.825), "fire" : Vector2(1.135,-0.85), "earth" :Vector2(0.5,0)}
@onready var state : Element_state = Element_state.new()

@onready var spray = $spray
@onready var energy_timer = $Energy_timer

@onready var anim = $AnimatedSprite2D
@onready var dashing_time = $Dashing_time
@onready var dashing_cooldown = $Dashing_cooldown
@onready var ability_timer = $Ability_timer
@onready var ability_time = ability_timer.wait_time

@onready var super_power_time = energy_timer.wait_time

@onready var going_up : bool = false
@onready var Veclociting_wind : Vector2
var entity_to_command = null 
var can_command : bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var Direction = 1
@onready var coyote_timer = $Coyote_timer


func _ready():
	State_changed.emit(state.current_state)
	anim.play(state.current_state)
	coyote_timer.wait_time = coyote_frames / 60.0

func _physics_process(delta):
	if !compiling:
		if !dashing:
			#Movement
			Movement()
			#JUMP & GRAVITY
			Jump_gravity(delta)
		
		
		#Dashing
		Dash()
	go_up()
	
	
	last_floor = is_on_floor()
	chacking_ability()
	Moving_rig_body()
	move_and_slide()
	if compiling:
		super_power_time = energy_timer.time_left
		mouse_pos = get_global_mouse_position()
		#line_2d.temp_show(self.position, True_distance(self.global_position, mouse_pos))
		$Dot.global_position = True_distance(self.global_position, mouse_pos)

func _process(delta):
	Getting_collide_name()
	
	#Activating Super Power
	if Power_active:
		if Input.is_action_pressed("super_power"):
			if !compile_ready:
				anim.rotate(5)
			else:
				anim.rotate(5/100)
			if state.current_state == "fire":
				super_power_time = energy_timer.time_left
				mouse_pos = get_global_mouse_position()
				#line_2d.temp_show(self.position, True_distance(self.global_position, mouse_pos))
				$Dot.global_position = True_distance(self.global_position, mouse_pos)
			

			if energy_timer.is_stopped() and !compile_ready:
				$Dot.show()
				self.velocity = Vector2.ZERO
				energy_timer.start()
				compiling = true
				power_compile.emit(true)
				
	if Input.is_action_just_released("super_power") and compiling:
			compiling = false
			energy_timer.stop()
			energy_timer.wait_time = 1
			print("The time just left is ", energy_timer.wait_time)
			power_compile.emit(false)
			line_2d.disappear()
			$Dot.hide()
	if Input.is_action_just_released("super_power") and compile_ready:
			$Dot.hide()
			Super_power(state.current_state)
	


# JUMP and Gravity
func Jump_gravity(_delta):
	# Add the gravity.
	if not is_on_floor() and (!going_up or (state.current_state == "earth")):
		velocity.y += gravity * _delta * Weights[state.current_state]

	# Handle Jump.
	if Input.is_action_pressed("jump") and (is_on_floor() or coyote) and !jumping:
		velocity.y = jump_velocity[state.current_state]
		jumping = true
		
	if is_on_floor() and jumping:
		jumping = false
	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		coyote_timer.start()
#Dashing 
func Dash():
	
	if Input.is_action_just_pressed("dash") and dash_allow:
		dashing = true
		dash_allow = false
		velocity.y = 0
		self.position.y = position.y
		dashing_time.start()
		velocity.x = dash_speed[state.current_state] * Direction
#Movement
func Movement():
	var direction = Input.get_axis("left", "right")
	#anim.rotate(direction / 30)
	if direction:
		Direction = direction
		anim.rotate(Direction / 6)
		velocity.x = direction * Normal_speed[state.current_state]
	else:
		velocity.x = move_toward(velocity.x, 0, Normal_speed[state.current_state])

#Ability checking
func chacking_ability():
	if !Power_active:
		if Input.is_action_just_pressed("1_pw") and Abilities_opened["water"]:
			state.Change_state(1)
			Ability_change()
			
		if Input.is_action_just_pressed("2_pw") and Abilities_opened["fire"]:
			state.Change_state(2)
			Ability_change()
			
		if Input.is_action_just_pressed("3_pw") and Abilities_opened["earth"]:
			state.Change_state(3)
			Ability_change()
	
	if Input.is_action_just_pressed("g") and can_command:
			entity_to_command.command()
			
	if Power_active:
		ability_time = ability_timer.time_left
#Ability trigering
func Ability_change():
	anim.play(state.current_state)
	State_changed.emit(state.current_state)
	spray.Object_changed_state(state.current_state)
	ability_timer.start()
	var _scale = Scales[state.current_state]
	anim.scale = Vector2(_scale,_scale)
	anim.position = anim_pos[state.current_state]
	Power_active = true
	if state.current_state != "earth":
		set_collision_mask_value(4, false)
		
		

############ Super Power ############

func Super_power(_state):
	compiling = false
	compile_ready = false
	if _state == "fire":
		mouse_pos = get_global_mouse_position()
	
		print_debug("Here it is a global positions of  player " , self.position, mouse_pos)
		
		### The calculations when The Player will Teleport but with conditions  
		var The_distance : Vector2 = True_distance(self.global_position, mouse_pos)
		
		line_2d.appear(self.position, The_distance)
		self.global_position = The_distance
			
		
		
		to_default_state()
	elif _state == "earth":
		pass
	elif _state == "water":
		pass

func to_default_state():
	state.Change_state(0)
	anim.play(state.current_state)
	State_changed.emit(state.current_state)
	
	Power_active = false
	set_collision_mask_value(4, true)
	var _scale = Scales[state.current_state]
	anim.scale = Vector2(_scale,_scale)
	anim.position = anim_pos[state.current_state]
	spray.Object_changed_state(state.current_state)
	#line_2d.disappear()
#Moving ather objects
func Moving_rig_body():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * Push_forse[state.current_state])

func Getting_collide_name():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i).get_collider()
		
		if c.is_in_group("Elemental"):
			if c.has_method("get_state"):
				if !state.possible_to_stay(c.get_state()):
					var distance = (self.position - c.position)
					print(distance)
					var small_velocity = Vector2.ZERO
					dashing_time.wait_time = 0.1
					if distance.y < 0:
						small_velocity = Vector2(800 * Direction, 0)
					else:
						if distance.x > 0:
							small_velocity = Vector2(800, 0)
						else:
							small_velocity = Vector2(-800, 0)
						

					dashing = true
					dash_allow = false
					velocity.y = 0
					self.position.y = position.y
					dashing_time.start()
					velocity = small_velocity


func hit():
	self.queue_free()


func go_up():
	if going_up and dashing and (state.current_state != "earth"):
		velocity.y = Veclociting_wind.y / Weights[state.current_state]
		velocity.x = dash_speed[state.current_state] * Direction
	elif going_up and (state.current_state != "earth"):
		velocity.y = Veclociting_wind.y / Weights[state.current_state]


func True_distance(player_pos : Vector2, _mouse_pos : Vector2):
	var To_move_pos : Vector2  = Vector2(400, 300)
	var dis = player_pos - _mouse_pos

	# Calculate the distance for each axis separately
	var abs_dis_x = abs(dis.x)
	var abs_dis_y = abs(dis.y)

	# Check if teleport distance is not too far
	if abs_dis_x < To_move_pos.x and abs_dis_y < To_move_pos.y:
		return _mouse_pos
	else:
		# If it is too far, limit the teleportation distance
		# Adjust the x-axis
		if abs_dis_x > To_move_pos.x:
			dis.x = sign(dis.x) * To_move_pos.x

		# Adjust the y-axis
		if abs_dis_y > To_move_pos.y:
			dis.y = sign(dis.y) * To_move_pos.y

		return player_pos - dis

####################  TIME OUTS   ####################

#dashes
func _on_dashing_time_timeout():
	dashing = false
	dashing_cooldown.start()
func _on_dashing_cooldown_timeout():
	dash_allow = true
	dashing_time.wait_time = 0.2

#ability
func _on_ability_timer_timeout():
	if !compiling and !compile_ready:
		to_default_state()

#Coyote timer 
func _on_coyote_timer_timeout():
	coyote = false



####################  Areas Enter and exit  ####################
func _on_area_2d_area_entered(area):
	if area.is_in_group("button"):
		label.text = area.get_command()
		if area.is_in_group("g_command"):
			entity_to_command = area
			can_command = true
func _on_area_2d_area_exited(area):
	if area.is_in_group("button"):
		label.text = ""
		if area.is_in_group("g_command"):
			entity_to_command = null
			can_command = false





func _on_energy_timer_timeout():
	compile_ready = true
