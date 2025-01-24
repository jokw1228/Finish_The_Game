extends TextureRect
class_name SetCard

@export var set_ui: SetUI
@export var shape_image: PackedScene

var card_info: Array
var card_pos_index: int
var shapes: Array


func initialize_card(info: Array, card_position: int) -> void:
	card_info = info
	card_pos_index = card_position
	
	var temp_scale: float
	var temp_position: Array
	
	for i in range(info[2] + 1):
		var shape: SetCardShape = shape_image.instantiate()
		temp_scale = set_ui.standard_shape_scale[info[2]]
		temp_position = set_ui.standard_shape_position[info[2]][i]
		
		shape.scale = Vector2(temp_scale, temp_scale)
		shape.position = Vector2(temp_position[0], temp_position[1])
		shape.texture = set_ui.shape_image[info[1]][info[3]][info[4]]
		
		add_child(shape)
	
	set_ui.place_card(self, card_position)


func move_card(is_up: bool):
	if is_up:
		position.y += -20
	else:
		position.y += 20
