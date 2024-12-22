extends Node2D
class_name PentagoBoard

const cell_image_size = 128.0 # pixel size

var board_size: int = 2
var subboard_size: int = 3

var subboards: Array = []

func _ready() -> void:
	set_board()
	wait_put_stone(1)

func set_board() -> void:
	var subboard_pixel_size: float = subboard_size * cell_image_size
	for i in range(board_size):
		var temp: Array[PentagoSubBoard] = []
		for j in range(board_size):
			var inst: PentagoSubBoard \
			= PentagoSubBoardCreator.create\
			(Vector2(\
			(j - float(board_size - 1.0) / 2.0) * subboard_pixel_size, \
			(i - float(board_size - 1.0) / 2.0) * subboard_pixel_size), \
			subboard_size)
			temp.append(inst)
			add_child(inst)
		subboards.append(temp)

func wait_put_stone(color_to_put: int = 1):
	# waiting for a mouse left click
	await get_tree().process_frame
	while !Input.is_action_just_pressed("ui_left_click"):
		await get_tree().process_frame
	
	# select: cell index in this pentago board
	var select: Vector2 = \
	(get_global_mouse_position()\
	 - position\
	 + Vector2(\
	cell_image_size*board_size*subboard_size/2, \
	cell_image_size*board_size*subboard_size/2\
	)) / cell_image_size
	select.x = int(select.x)
	select.y = int(select.y)
	if select.x < 0:
		select.x = 0
	elif select.x >= board_size*subboard_size:
		select.x = board_size*subboard_size - 1
	if select.y < 0:
		select.y = 0
	elif select.y >= board_size*subboard_size:
		select.y = board_size*subboard_size - 1
		
	# find the right subboard
	var subboard_index: Vector2 = Vector2\
	(int(select.x / subboard_size), int(select.y / subboard_size))
	# find the index in that subboard
	var inner_index: Vector2 = Vector2\
	(int(select.x) % subboard_size, int(select.y) % subboard_size)
	# put the stone
	var success: bool = subboards[subboard_index.y][subboard_index.x].put_stone(inner_index, color_to_put)
	if success == false:
		wait_put_stone(color_to_put)
