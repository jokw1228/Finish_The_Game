extends ColorRect
class_name BackgroundScrollingLine

var label_text: String = "test text"
var label_speed: float = 256.0
var label_period: float = 1.8
enum LABEL_DIRECTION {
	LEFT,
	RIGHT
}
var label_direction: LABEL_DIRECTION = LABEL_DIRECTION.RIGHT

func _ready() -> void:
	scrolling()

func scrolling() -> void:
	while true:
		var inst: Label = Label.new()
		inst.text = label_text
		add_child(inst)
		
		if label_direction == LABEL_DIRECTION.LEFT:
			inst.position = Vector2(size.x, 0)
			var tween_position: Tween = get_tree().create_tween()
			tween_position.tween_property(inst, "position", Vector2(-inst.size.x, 0), size.x / label_speed)
		elif label_direction == LABEL_DIRECTION.RIGHT:
			inst.position = Vector2(-inst.size.x, 0)
			var tween_position: Tween = get_tree().create_tween()
			tween_position.tween_property(inst, "position", Vector2(size.x, 0), size.x / label_speed)
		
		await get_tree().create_timer(label_period).timeout
