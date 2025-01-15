extends Control
class_name FTGResultOverlayO


const increase_duration = 0.4
const decrease_duration = 0.4

const radius = 512.0 - 64
const start_angle_offset = PI / 2
const point_count = 64
const width = 128

var start_angle: float = start_angle_offset
var angle_offset: float = 0
var color: Color = Color.LAWN_GREEN

func _ready() -> void:
	var tween_increase_angle_offset: Tween = get_tree().create_tween()
	tween_increase_angle_offset.tween_property(self, "angle_offset", 2*PI, increase_duration)\
	.set_trans(Tween.TRANS_SINE)
	await tween_increase_angle_offset.finished
	
	var tween_increase_start_angle: Tween = get_tree().create_tween()
	tween_increase_start_angle.tween_property(self, "start_angle", start_angle_offset + 2*PI, decrease_duration)\
	.set_trans(Tween.TRANS_SINE)
	
	var tween_decrease_angle_offset: Tween = get_tree().create_tween()
	tween_decrease_angle_offset.tween_property(self, "angle_offset", 0, decrease_duration)\
	.set_trans(Tween.TRANS_SINE)
	await tween_decrease_angle_offset.finished
	
	queue_free()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, start_angle, start_angle + angle_offset, point_count, color, width, true)
