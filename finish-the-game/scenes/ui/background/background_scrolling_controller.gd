extends CanvasLayer
class_name BackgroundScrollingController

@export var scrolling_lines: Array[BackgroundScrollingLine] = []
@export var scrolling_line_scene: PackedScene

func _ready() -> void:
	initialize_scrolling_lines()

func initialize_scrolling_lines() -> void:
	var width: float = get_viewport().get_visible_rect().size.x
	var height: float = get_viewport().get_visible_rect().size.y
	const count = 3
	for i: int in range(count):
		var inst: BackgroundScrollingLine = scrolling_line_scene.instantiate() as BackgroundScrollingLine
		add_child(inst)
		scrolling_lines.append(inst)
		
		inst.size.x = 796 + 256 * i
		inst.position.y = (i + 1) * (height) / (count + 8)
		inst.position.x = -PI/3 * inst.size.y
		inst.rotation = -PI/6
		inst.set_label_speed(128 + 64 * i)
		inst.set_label_period(4.0 * 128 / (128 + 64 * float(i)))
		
		var inst2: BackgroundScrollingLine = scrolling_line_scene.instantiate() as BackgroundScrollingLine
		add_child(inst2)
		scrolling_lines.append(inst2)
		
		inst2.size.x = 796 + 256 * i
		inst2.position.y = height - inst.position.y
		inst2.position.x = width - inst.position.x
		inst2.rotation = inst.rotation + PI
		inst2.set_label_speed(128 + 64 * i)
		inst2.set_label_period(4.0 * 128 / (128 + 64 * float(i)))
		
		if i % 2 == 1:
			inst.toggle_label_direction()
			inst2.toggle_label_direction()
		
		inst.set_generating(true)
		inst2.set_generating(true)

func set_all_label_text(label_text_to_set) -> void:
	for inst: BackgroundScrollingLine in scrolling_lines:
		inst.set_label_text(label_text_to_set)
