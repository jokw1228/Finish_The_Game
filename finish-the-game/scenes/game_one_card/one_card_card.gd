extends TextureButton
class_name OneCardCard

@export var one_card_ui: OneCardUI

var card_info: Array
var is_field: bool = false
var card_pos_index: int
var can_press: bool
#var first_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func initialize_card(info: Array, is_in_field: bool, card_position: int) -> void:
	card_info = info
	is_field = is_in_field
	card_pos_index = card_position
	place_card(is_in_field, card_position)
	can_press = true
	
	
	
	#if is_in_field:
		#first_index = card_position


func place_card(is_in_field: bool, card_position: int, is_teleport: bool = true) -> void:
	var card_pixel_position: Vector2 = Vector2.ZERO
	
	if is_in_field:
		card_pixel_position.x = one_card_ui.size_unit * (1 + card_position) +\
								one_card_ui.interval_unit * (1 + card_position)
		card_pixel_position.y = 0
		
	else:
		card_pixel_position.x = one_card_ui.size_unit * (card_position % 4) +\
								one_card_ui.interval_unit * (card_position % 4)
		card_pixel_position.y = one_card_ui.size_unit * 2 * (1 + int(card_position / 4)) +\
								one_card_ui.interval_unit * (3 + int(card_position / 4))
	
	if is_teleport:
		position = card_pixel_position
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "position", card_pixel_position, 0.05)


func _on_pressed() -> void:
	if can_press:
		one_card_ui.card_pressed(is_field, card_pos_index)
