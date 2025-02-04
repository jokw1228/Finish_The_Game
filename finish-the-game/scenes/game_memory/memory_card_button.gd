extends TextureButton
class_name MemoryButton

@export var memory_ui: MemoryUI
var pos_index: int


func initialize_button(button_pos_index: int):
	pos_index = button_pos_index
	pivot_offset = Vector2(64, 128)
	memory_ui.place_card(self, button_pos_index)


func _on_pressed() -> void:
	print("game_memory: ", pos_index, " pressed")
	memory_ui.card_pressed(pos_index)
