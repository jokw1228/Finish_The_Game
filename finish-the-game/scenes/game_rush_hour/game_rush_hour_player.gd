extends CharacterBody2D

@onready var sprite = $Sprite2D

var direction = 0
var is_selected = false
#horizontal = 0 vertical = 1


var truck_type
@onready var collision_shape = $CollisionShape2D
var mouse_offset  
var camera_offset = Vector2(-120,0)
var delay = 10
var grid_size = 128 
var board_size = Vector2(768, 768) 
var additional_offset = Vector2(0 , 640) 
var local_mouse_pos
var mouse_sprite: Sprite2D 
var original_position =  Vector2(0,0)

var start_pos = Vector2()
var target_pos = Vector2() 
var board_limits = Rect2(Vector2(0, 0), Vector2(6, 6))
var speed = 300

var input_dir = Vector2(0,0)
var previous_mouse_position =  Vector2(0,0)

var collide = Vector2(0,0)
var prev_position = Vector2(0,0)
var max_speed = 50



func _ready():
	start_pos = position
	prev_position = position
	if direction == 1:
		sprite.rotation_degrees = 90
		collision_shape.rotation_degrees = 90
		

func _process(delta: float):
	if is_selected:
		sprite.modulate = Color(0, 0, 0.5)
	else:
		sprite.modulate = Color(1, 1, 1)
	if direction == 0:
		position = position.clamp(Vector2(-128-96, -128*2+8), Vector2(128*3-96-8, 128*3-8))
	else:
		position = position.clamp(Vector2(-128*2-32, -128-64+8), Vector2(128*3-32-8, 128*3-64-8))
	

func _physics_process(delta: float):
	#print(position)
	collide = input_dir.round() * speed
	if direction == 0:
		collide.y = 0
		position.y = clamp(position.y, start_pos.y, start_pos.y) 
	else:
		collide.x = 0
		position.x = clamp(position.x, start_pos.x, start_pos.x)  # Keep x fixed
		
	if collide.length() > max_speed:
		collide = collide.normalized() * max_speed
	
	var collision = move_and_collide(collide * delta)
	if collision:
		is_selected = false
		
	if direction == 0:
		position.y = clamp(position.y, start_pos.y, start_pos.y) 
	else:
		position.x = clamp(position.x, start_pos.x, start_pos.x)
	
	if not is_selected and collision:
		position = prev_position
		
	if is_selected == true:
		var current_position = position
		var new_position = Vector2(0,0)
		prev_position = position
		#collision = move_and_collide(collide * delta)
		if direction == 0:
			new_position = Vector2(
			get_global_mouse_position().x - mouse_offset.x-512-28,
			position.y)
			#new_position.x = round((new_position.x) / grid_size) * grid_size/2 -32
			#new_position.x = round((new_position.x) / grid_size) * grid_size/2 -256
			
		else:
			new_position = Vector2(
			position.x,  # Keep x constant
			get_global_mouse_position().y - mouse_offset.y-1024+64,)
			#new_position.y = round(new_position.y / grid_size) * grid_size/2 -32
		collision = move_and_collide(collide * delta)
		if direction == 0:
			new_position = new_position.clamp(Vector2(-128-96, -128*2+8), Vector2(128*3-96-8, 128*3-8))
		else:
			new_position = new_position.clamp(Vector2(-128*2-32, -128-64+8), Vector2(128*3-32-8, 128*3-64-8))
		if collision:
			new_position = new_position.clamp(position, collision.get_position())
		position += (new_position - position) * delta * 3
		
			
func _input(event):
	if is_selected:
		sprite.modulate
		var current_mouse_position = get_global_mouse_position()
		input_dir = (current_mouse_position - previous_mouse_position).normalized()
		previous_mouse_position = current_mouse_position
	else:
		input_dir = Vector2.ZERO 
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#var global_mouse_pos = get_global_mouse_position()

			local_mouse_pos = sprite.to_local(event.position)
			if sprite.get_rect().has_point(local_mouse_pos):
				is_selected = true
				#mouse_offset = global_position+Vector2(-200,-100)
				mouse_offset = get_global_mouse_position()-global_position
		
		else:
			is_selected = false


	
