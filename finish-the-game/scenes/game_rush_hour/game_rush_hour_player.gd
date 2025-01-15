extends Node2D

@onready var sprite = $Sprite2D

var direction = 0
var is_selected = false
#horizontal = 0 vertical = 1


var truck_type

var mouse_offset  
var camera_offset = Vector2(500,900)
var delay = 5
var grid_size = 128 
var board_size = Vector2(768, 768) 
var additional_offset = Vector2(0 ,256) 
var local_mouse_pos
var mouse_sprite: Sprite2D 
var original_position =  Vector2(0,0)

var start_pos = Vector2()
var target_pos = Vector2() 
var board_limits = Rect2(Vector2(0, 0), Vector2(6, 6))

signal collide
signal selected


func _ready():
	start_pos = position
	if direction == 1:
		sprite.rotation_degrees = 90

	
	
func _set_direction(num):
	direction = num

	
	
#func _process(delta):
	
	#position = position.lerp(target_pos, 10*delta)
	
func _physics_process(delta: float):
	if is_selected == true:
		var tween = get_tree().create_tween()
		var current_position = position
		var new_position = Vector2(0,0)
		if direction == 0:
			new_position = Vector2(
			get_global_mouse_position().x - mouse_offset.x,  
			position.y)
			
			new_position.x = round((new_position.x) / grid_size) * grid_size/2 -32		
		else:
			new_position = Vector2(
			position.x,  # Keep x constant
			get_global_mouse_position().y - mouse_offset.y)
			new_position.y = round(new_position.y / grid_size) * grid_size/2 -32

			#lobal_position.y + rotated_vector.y - mouse_offset.y)
		new_position = new_position.clamp(Vector2(-128-96, -128-96), Vector2(128*3-96, 128*3-96))
		tween.tween_property(self, "position", new_position, delay * delta)


func _input(event):
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#print("check1")
		start_pos = position
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
	is_selected = false

	
