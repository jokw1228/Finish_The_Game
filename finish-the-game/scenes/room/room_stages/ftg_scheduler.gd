extends Control
class_name FTGScheduler

const y_offset: float = 1080*2
var center: Vector2 = Vector2.ZERO

var FTGs: Array = []
var FTG_dict = {}
var current_ftg: Node

var pq = PriorityQueue.new()

signal start_ftg(difficulty: float)

signal request_set_all_label_text(label_text_to_set: String)
signal request_display_ftg_result(result: bool)

func _ready() -> void:
	center = get_viewport().get_visible_rect().size / 2

func ftg_add(ftg_name: String, duration: float, tscn: PackedScene):
	FTG_dict[ftg_name] = [tscn, duration]
	FTGs.append(ftg_name)
	pq.insert(ftg_name,duration + randf_range(0,0.1))

func schedule_ftg():
	var picked = pq.pop()
	var picked_ftg = FTG_dict[picked[0]][0]
	var picked_recent_time = picked[1]
	current_ftg = picked_ftg.instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	current_ftg.position = center + Vector2(0, -y_offset)
	add_child(current_ftg)
	pq.insert(picked[0],picked_recent_time+FTG_dict[picked[0]][1]+randf_range(0,0.1))
	
	start_ftg.emit(0.9)
	request_set_all_label_text.emit(picked[0])

func end_ftg(result: bool) -> void:
	request_display_ftg_result.emit(result)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_fade_out: Tween = get_tree().create_tween()
	tween_fade_out.tween_property\
	(current_ftg, "position", center + Vector2(0, y_offset), 0.5).\
	set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween_fade_out.tween_callback(Callable(current_ftg, "queue_free"))
	
	await get_tree().create_timer(0.5).timeout
	
	schedule_ftg()
	
	var tween_fade_in: Tween = get_tree().create_tween()
	tween_fade_in.tween_property\
	(current_ftg, "position", center, 0.5).\
	set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func init(games) -> void:
	for game in games:
		pass
	schedule_ftg()
