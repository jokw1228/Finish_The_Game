extends TextureButton
class_name OrbitoCell

const cell_image_width = 128

signal select_cell(selected_cell_index: Array[int])

@export var cell_index: Array[int] = []

func set_cell_index(index_to_set) -> void:
	cell_index = index_to_set

# Called when the node enters the scene tree for the first time.
func _on_pressed() -> void:
	select_cell.emit(cell_index)
	
func place_stone(color_to_place: Orbito.CELL_STATE) -> void:
	add_child(OrbitoStoneGenerator.generate(Vector2(cell_image_width/2, cell_image_width/2), color_to_place))

func set_cell_disabled(disabled_to_set):
	disabled = disabled_to_set
	
func remove_stone():
	var children = self.get_children()
	for c in children:
		c.queue_free()
		
