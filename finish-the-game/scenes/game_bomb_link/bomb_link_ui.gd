extends Node2D
class_name BombLinkUI

const width = 4
const height = 10

const cell_image_size = 128.0
const top_left_x = -width / 2 * cell_image_size
const top_left_y = -height / 2 * cell_image_size

const delay = 0.2

var cells: Array[Array] = []

signal request_bomb_rotation(index_to_request: Array[int])

func _ready() -> void:
	initialize_cells()

func initialize_cells() -> void:
	for y: int in range(height):
		var temp: Array[BombLinkBombCell] = []
		for x: int in range(width):
			temp.append(null)
		cells.append(temp)

func receive_request_insert_bomb_row_bottom(bomb_row_to_insert: Array) -> void:
	var inserted_cells: Array[Array] = []
	for y: int in range(1, height):
		var temp: Array[BombLinkBombCell] = []
		for x: int in range(width):
			if cells[y][x] != null:
				cells[y][x].set_index([x, y-1] as Array[int])
				cells[y][x].move_to_position(Vector2(top_left_x + x*cell_image_size, top_left_y + (y-1)*cell_image_size))
			temp.append(cells[y][x])
		inserted_cells.append(temp)
	var row: Array[BombLinkBombCell] = []
	for x: int in range(width):
		var inst: BombLinkBombCell = BombLinkBombCell.create(\
		bomb_row_to_insert[x].bomb_type, \
		bomb_row_to_insert[x].fuse_direction, \
		Vector2(top_left_x + x*cell_image_size, top_left_y + (height-1)*cell_image_size), \
		[x, int(height - 1)], \
		Callable(self, "receive_request_bomb_rotation")\
		)
		row.append(inst)
		add_child(inst)
	inserted_cells.append(row)
	
	cells = inserted_cells

func receive_request_append_bomb_row_top(_bomb_row_to_append: Array) -> void:
	pass

func receive_request_apply_gravity(move_commands_to_execute: Array[BombLinkMoveCommand]) -> void:
	for move_command: BombLinkMoveCommand in move_commands_to_execute:
		var target_index: Array[int] = move_command.get_target_index()
		var _x: int = target_index[0]
		var _y: int = target_index[1]
		var y_offset: int = move_command.get_y_offset()
		
		cells[_y][_x].set_index([_x, _y+y_offset])
		cells[_y][_x].move_to_position(Vector2(\
		top_left_x + _x*cell_image_size, \
		top_left_y + (_y+y_offset)*cell_image_size) )
		cells[_y+y_offset][_x] = cells[_y][_x]
		cells[_y][_x] = null

func receive_request_bomb_rotation(index_to_request: Array[int]) -> void:
	request_bomb_rotation.emit(index_to_request)

func receive_approve_and_reply_bomb_rotation(approved_index: Array[int]) -> void:
	var _x: int = approved_index[0]
	var _y: int = approved_index[1]
	cells[_y][_x].rotate_cw()

func receive_request_chain_reaction(chain_reaction_to_execute:BombLinkChainReaction) -> void:
	for chain_step: int in range(chain_reaction_to_execute.get_step_count()):
		var step_to_explode: Array[Array] = chain_reaction_to_execute.get_step(chain_step)
		for cell_index_to_explode: Array in step_to_explode:
			var _x: int = cell_index_to_explode[0] as int
			var _y: int = cell_index_to_explode[1] as int
			cells[_y][_x].explode()
			cells[_y][_x] = null
		await get_tree().create_timer(delay).timeout
