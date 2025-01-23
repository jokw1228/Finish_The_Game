extends CharacterBody2D

@onready var sprite = $Sprite2D

var direction = 0
var is_selected = false
#horizontal = 0 vertical = 1


var truck_type

var mouse_offset  
var camera_offset = Vector2(-120,0)
var delay = 10
var grid_size = 128 
var board_size = Vector2(768, 768) 
var additional_offset = Vector2(0 ,256) 
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

signal selected


func _ready():
	start_pos = position
	if direction == 1:
		sprite.rotation_degrees = 90

	
	
func _set_direction(num):
	direction = num
	
func get_input():
	collide = input_dir * speed

func _physics_process(delta: float):
	collide = input_dir.round() * speed
	if direction == 0:
		collide.y = 0
		position.y = clamp(position.y, start_pos.y, start_pos.y) 
	else:
		collide.x = 0
		position.x = clamp(position.x, start_pos.x, start_pos.x)  # Keep x fixed
	var collision = move_and_collide(collide * delta)
	if collision:
		is_selected = false
	if direction == 0:
		position.y = clamp(position.y, start_pos.y, start_pos.y) 
	else:
		position.x = clamp(position.x, start_pos.x, start_pos.x)
		
	if is_selected == true:
		var tween = get_tree().create_tween()
		var current_position = position
		var new_position = Vector2(0,0)
		if direction == 0:
			new_position = Vector2(
			get_global_mouse_position().x - mouse_offset.x,  
			position.y)
			#new_position.x = round((new_position.x) / grid_size) * grid_size/2 -32
			new_position.x = round((new_position.x) / grid_size) * grid_size/2 -256
		else:
			new_position = Vector2(
			position.x,  # Keep x constant
			get_global_mouse_position().y - mouse_offset.y)
			new_position.y = round(new_position.y / grid_size) * grid_size/2 -32

			#lobal_position.y + rotated_vector.y - mouse_offset.y)
		new_position = new_position.clamp(Vector2(-128-96, -128-96), Vector2(128*3-96, 128*3-96))
		tween.tween_property(self, "position", new_position, delay * delta)
	

		

	#move_and_collide(collide * delta)
	


func _input(event):
	if is_selected:
		var current_mouse_position = get_global_mouse_position()
		input_dir = (current_mouse_position - previous_mouse_position).normalized()
		previous_mouse_position = current_mouse_position
	else:
		input_dir = Vector2.ZERO 
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#print("check1")
		if event.pressed:
			#print("check2")
			#print("Event Position:", event.position)
			if direction == 0:
				local_mouse_pos = to_local(event.position-Vector2(-128,128))
			else:
				local_mouse_pos = to_local(event.position-Vector2(-128,128))
			
			local_mouse_pos = to_local(event.position-camera_offset)
			if sprite.get_rect().has_point(local_mouse_pos):
				#print('clicked on sprite')
				is_selected = true
				#mouse_offset = global_position+Vector2(-200,-100)
				mouse_offset = get_global_mouse_position()-global_position
		
		else:
			is_selected = false
	
	print(input_dir)





func move_piece(dis):
	var new_pos = start_pos + dis * board_size
	if !board_limits.has_point(new_pos /board_size):
		target_pos = new_pos
	else:
		target_pos = start_pos
	position = target_pos

func is_collision(position: Vector2) -> bool:
	return false
	
		
func _on_area_entered(body: Node2D) -> void:
	print("collided!")
	collide.emit()
	target_pos = start_pos
	position = start_pos
	is_selected = false

	
