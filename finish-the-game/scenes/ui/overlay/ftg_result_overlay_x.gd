extends Control
class_name FTGResultOverlayX

const increase_duration = 0.2
const decrease_duration = increase_duration

const width = 128.0
const length = (512.0 - 64.0) * 2.0
# for easy calculations...
const rt2 = sqrt(2.0)
const l = length / 2.0 / rt2

var from_1: Vector2
var to_1: Vector2
var from_2: Vector2
var to_2: Vector2
var color: Color = Color.CRIMSON

func _ready() -> void:
	from_1 = Vector2(l, -l)
	to_1 = Vector2(l, -l)
	from_2 = Vector2(-l, -l)
	to_2 = Vector2(-l, -l)
	
	var tween_increase_1: Tween = get_tree().create_tween()
	tween_increase_1\
	.tween_property(self, "to_1", Vector2(-l, l), increase_duration)\
	.set_trans(Tween.TRANS_SINE)
	await tween_increase_1.finished
	
	var tween_increase_2: Tween = get_tree().create_tween()
	tween_increase_2\
	.tween_property(self, "to_2", Vector2(l, l), increase_duration)\
	.set_trans(Tween.TRANS_SINE)
	await tween_increase_2.finished
	
	var tween_decrease_1: Tween = get_tree().create_tween()
	tween_decrease_1\
	.tween_property(self, "from_1", Vector2(-l, l), decrease_duration)\
	.set_trans(Tween.TRANS_SINE)
	await tween_decrease_1.finished
	
	var tween_decrease_2: Tween = get_tree().create_tween()
	tween_decrease_2\
	.tween_property(self, "from_2", Vector2(l, l), decrease_duration)\
	.set_trans(Tween.TRANS_SINE)
	await tween_decrease_2.finished
	
	queue_free()
	

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# line 1
	draw_line(from_1, to_1, color, width, true)
	
	# line 2
	draw_line(from_2, to_2, color, width, true)
