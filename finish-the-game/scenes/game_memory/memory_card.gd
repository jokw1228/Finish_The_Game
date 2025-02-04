extends TextureRect
class_name MemoryCard

@export var memory_ui: MemoryUI

var shape_info: int
var card_pos_index: int

func initialize_card(info: int, card_position: int) -> void:
	shape_info = info
	card_pos_index = card_position
	pivot_offset = Vector2(64, 128)
	
	$Card.texture = memory_ui.card_image[1]
	$Shape.texture = null
	
	memory_ui.place_card(self, card_position)


func filp_card(is_up: bool):
	var tween: Tween = get_tree().create_tween()
	
	if is_up:
		tween.tween_property(self, "scale", Vector2.DOWN, 0.15)
		await tween.finished
		
		$Card.texture = memory_ui.card_image[0]
		$Shape.texture = memory_ui.shape_image[shape_info]
		
		tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2.LEFT + Vector2.DOWN, 0.15)
		
	else:
		tween.tween_property(self, "scale", Vector2.DOWN, 0.15)
		await tween.finished

		$Card.texture = memory_ui.card_image[1]
		$Shape.texture = null
		
		tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2.RIGHT + Vector2.DOWN, 0.15)
