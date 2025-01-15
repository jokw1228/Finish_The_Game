extends Label
class_name BackgroundScrollingLabel

var speed_x: float = 0
var direction: BackgroundScrollingLine.LABEL_DIRECTION = BackgroundScrollingLine.LABEL_DIRECTION.RIGHT

func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()

func _process(delta: float) -> void:
	if direction == BackgroundScrollingLine.LABEL_DIRECTION.RIGHT:
		position.x += speed_x * delta
	elif direction == BackgroundScrollingLine.LABEL_DIRECTION.LEFT:
		position.x -= speed_x * delta

func set_speed(speed_to_set: float) -> void:
	speed_x = speed_to_set

func set_direction(direction_to_set: BackgroundScrollingLine.LABEL_DIRECTION) -> void:
	direction = direction_to_set
