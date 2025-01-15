extends CanvasLayer
class_name BackgroundScrollingController

@export var scrolling_lines: Array[BackgroundScrollingLine] = []
@export var scrolling_line_scene: PackedScene

func _ready() -> void:
	initialize_scrolling_lines()

func initialize_scrolling_lines() -> void:
	var width: float = get_viewport().size.x
	var height: float = get_viewport().size.y
	const count = 3
	for i: int in range(count):
		var inst: BackgroundScrollingLine = scrolling_line_scene.instantiate() as BackgroundScrollingLine
		add_child(inst)
		scrolling_lines.append(inst)
		
		inst.position.y = (i + 1) * (height) / (count + 8)
		inst.position.x = -PI/3 * inst.size.y
		inst.rotation = -PI/6
		
		var inst2: BackgroundScrollingLine = scrolling_line_scene.instantiate() as BackgroundScrollingLine
		add_child(inst2)
		scrolling_lines.append(inst2)
		
		inst2.position.y = height - inst.position.y + 128
		inst2.position.x = width - inst.position.x
		inst2.rotation = inst.rotation + PI
		
		if i % 2 == 1:
			inst.toggle_label_direction()
			inst2.toggle_label_direction()
