extends ColorRect
class_name BackgroundScrollingLine

var generating: bool = true

@export var scrolling_label_scene: PackedScene
var label_text: String = "ORBITO"
var label_speed: float = 256.0
var label_period: float = 1.8
enum LABEL_DIRECTION {
	LEFT,
	RIGHT
}
var label_direction: LABEL_DIRECTION = LABEL_DIRECTION.RIGHT

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	scrolling()

func scrolling() -> void:
	while generating:
		var inst: BackgroundScrollingLabel = scrolling_label_scene.instantiate() as BackgroundScrollingLabel
		inst.text = label_text
		add_child(inst)
		
		inst.set_speed(label_speed)
		inst.set_direction(label_direction)
		
		if label_direction == LABEL_DIRECTION.LEFT:
			inst.position = Vector2(size.x, 0)
		elif label_direction == LABEL_DIRECTION.RIGHT:
			inst.position = Vector2(-inst.size.x, 0)
		
		await get_tree().create_timer(label_period).timeout

func set_label_text(label_text_to_set: String) -> void:
	label_text = label_text_to_set

func set_label_speed(label_speed_to_set: float) -> void:
	label_speed = label_speed_to_set

func set_label_period(label_period_to_set: float) -> void:
	label_period = label_period_to_set

func set_label_direction(label_direction_to_set: LABEL_DIRECTION) -> void:
	label_direction = label_direction_to_set

func toggle_label_direction() -> void:
	if label_direction == LABEL_DIRECTION.LEFT:
		set_label_direction(LABEL_DIRECTION.RIGHT)
	elif label_direction == LABEL_DIRECTION.RIGHT:
		set_label_direction(LABEL_DIRECTION.LEFT)
