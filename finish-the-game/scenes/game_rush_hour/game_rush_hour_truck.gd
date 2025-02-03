extends CharacterBody2D

var direction = 0
var truck_type
var is_selected = false
var mouse_offset  
#var camera_offset = Vector2(250,700)
#var camera_offset = Vector2(500,900)
#vAR camera_offset = Vector2(-150,0)
var camera_offset = Vector2(0,0)
var delay = 10
var grid_size = 128 
var board_size = Vector2(768, 768) 
var additional_offset = Vector2(0, 360) 
var local_mouse_pos
var mouse_sprite: Sprite2D 
var original_position =  Vector2(0,0)
var prev_position = Vector2(0,0)
#horizontal = 0 vertical = 1

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

var start_pos = Vector2()
var target_pos = Vector2() 
var board_limits = Rect2(Vector2(0, 0), Vector2(6, 6))
var board_rect: Rect2 
var speed = 300
var input_dir = Vector2(0,0)
var previous_mouse_position =  Vector2(0,0)
var collide = Vector2(0,0)
var center 
var piece_type = ""
var cell_loc = Vector2(0,0)
#var camera_position = get_viewport().get_camera().global_position

func _ready():
	#position = position.snapped(Vector2(board_size, board_size))
	center = get_viewport().get_visible_rect().size / 2
	target_pos = position
	start_pos = position
	prev_position = position
	board_rect = Rect2(Vector2(-64, -64), Vector2(768-32, 768-32))
	var truck1 = preload("res://resources/images/game_rush_hour/sprite_rush_hour_truck_type1.png")
	var truck2 = preload("res://resources/images/game_rush_hour/sprite_rush_hour_truck_type2.png")
	if truck_type == 1:
		sprite.texture = truck1
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.extents = Vector2(128-8, 64-8)
			
	else:
		sprite.texture = truck2
		collision_shape.shape = RectangleShape2D.new()
		collision_shape.shape.extents = Vector2(192-8, 64-8)
	if direction == 1:
		sprite.rotation_degrees = 90
		collision_shape.rotation_degrees = 90
		
func _process(delta: float) -> void:
	if is_selected:
		sprite.modulate = Color(0, 0, 0.2)
	else:
		sprite.modulate = Color(1, 1, 1)
	
	if direction == 0:
		position.y = start_pos.y
	else:
		position.x = start_pos.x
	if truck_type == 2:
		if direction == 0:
			position =position.clamp(Vector2(-128-40, -128*2), Vector2(128*2-32, 128*3+96))
		else:
			position =position.clamp(Vector2(-128*2-32, -128-8), Vector2(128*3-32, 128*2+8))
	else:
		if direction == 0:
			position = position.clamp(Vector2(-128-96, -128*2), Vector2(128*3-96, 128*3))
		else:
			position = position.clamp(Vector2(-128*2-64, -128-64), Vector2(128*3-32, 128*2+64))
		

	
func _physics_process(delta: float):
	collide = input_dir * speed
	if direction == 0:
		collide.y = 0
		position.y = start_pos.y
	else:
		collide.x = 0
		position.x = start_pos.x
	var collision = move_and_collide(collide * delta)
	if collision:
		is_selected = false
	#horixontal or vertical fix
	if direction == 0:
		position.y = clamp(position.y, start_pos.y, start_pos.y) 
	else:
		position.x = clamp(position.x, start_pos.x, start_pos.x)
	#if not is_selected and collision:
		#position = prev_position
	
	if is_selected == true:
		var current_position = position
		prev_position = position
		var new_position = Vector2(0,0)
		if direction == 0:
			if truck_type ==2:
				additional_offset.x = 100
			new_position = Vector2(
			get_global_mouse_position().x - mouse_offset.x-512-28,
			position.y)
			#new_position.x = round((new_position.x) / grid_size) * grid_size
			#new_position.x = round((new_position.x) / grid_size) * grid_size/2  -256
		#(2560, 1494)
		else:
			new_position = Vector2(
			position.x,  # Keep x constant
			get_global_mouse_position().y - mouse_offset.y-1024+64,)
			#new_position.y = round(new_position.y / grid_size) * grid_size
		if truck_type == 2:
			if direction == 0:
				new_position =new_position.clamp(Vector2(-128-40, -128*2), Vector2(128*2-32, 128*3+96))
			else:
				new_position =new_position.clamp(Vector2(-128*2-32, -128-8), Vector2(128*3-32, 128*2+8))
		else:
			if direction == 0:
				new_position = new_position.clamp(Vector2(-128-96, -128*2), Vector2(128*3-96, 128*3))
			else:
				new_position = new_position.clamp(Vector2(-128*2-64, -128-64), Vector2(128*3-32, 128*2+64))
		collision = move_and_collide(collide * delta)
		if collision:
			new_position = new_position.clamp(position, collision.get_position())
		position += (new_position - position) * delta * 3
		


func _input(event):
	if is_selected:
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
				#print('clicked on sprite')
				is_selected = true
				#mouse_offset = global_position+Vector2(-200,-100)
				mouse_offset = get_global_mouse_position()-global_position
		else:
			is_selected = false
