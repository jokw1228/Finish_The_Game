extends Label
#class_name TapAnywhereToStart

var color_on: Color = Color.WHITE
var color_off: Color = Color(0.5, 0.5, 0.5, 1)
var toggle: bool = true

func _ready() -> void:
	blink()

const period = 0.65
func blink() -> void:
	while true:
		await get_tree().create_timer(period).timeout
		
		if toggle == true:
			toggle = false
			modulate = color_off
		elif toggle == false:
			toggle = true
			modulate = color_on
