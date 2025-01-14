extends Node2D

const board_size = 128
var direction = 0
var truck_type
var is_selected = false
#horizontal = 0 vertical = 1
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D

var start_pos = Vector2()
var target_pos = Vector2() 
var board_limits = Rect2(Vector2(0, 0), Vector2(6, 6))

signal collide

func _ready():
	position = position.snapped(Vector2(board_size, board_size))
	target_pos = position
	var truck1 = preload("res://sprites/sprite_rush_hour_truck_type1.png")
	var truck2 = preload("res://sprites/sprite_rush_hour_truck_type2.png")
	if truck_type == 1:
		sprite.texture = truck1
		collision_shape.shape.extents = Vector2(128, 64)
	else:
		sprite.texture = truck2
		collision_shape.shape.extents = Vector2(192, 64)
	if direction == 1:
		sprite.rotation_degrees = 90
	
func _process(delta):
	position = position.lerp(target_pos, 10*delta)

	
func _set_direction(num):
	direction = num
	
func _input(event):
	#if event is InputEventMouseButton and event.pressed:
		#start_pos = position
	if event is InputEventMouseButton and event.pressed:
			start_pos = position
			is_selected = true
	if is_selected:
		if event is InputEventMouseButton and event.pressed:
			start_pos = position
		elif event is InputEventMouseMotion:
			var drag_vector = event.relative
			if direction == 0:
				drag_vector.y = 0
			else:
				drag_vector.x = 0
			var drag_distance = drag_vector/board_size 
			move_piece(Vector2(round(drag_distance.x), round(drag_distance.y)))
			is_selected = false

func move_piece(dis):
	var new_pos = start_pos + dis * board_size
	if !board_limits.has_point(new_pos /board_size):
		target_pos = new_pos
	else:
		target_pos = start_pos

func is_collision(position: Vector2) -> bool:
	return false
	
		
func _on_body_entered(body: Node2D) -> void:
	collide.emit()
	target_pos = start_pos
	
func start(pos):
	position = pos
	show()
