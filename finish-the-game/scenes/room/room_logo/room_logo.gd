extends Node2D

const y_offset = 1080*2
var center: Vector2 = Vector2.ZERO

var FTGs: Array = []
var current_ftg: Node

signal start_ftg()

signal request_set_all_label_text(label_text_to_set)
signal request_display_ftg_result(result: bool)

func _ready() -> void:
	center = get_viewport().get_visible_rect().size / 2
	
	FTGs.append([load("res://scenes/game_pentago/ftg_pentago.tscn"), "PENTAGO"])
	FTGs.append([load("res://scenes/game_sliding_puzzle/ftg_sliding_puzzle.tscn"), "SLD.PZL."])
	FTGs.append([load("res://scenes/game_orbito/ftg_orbito.tscn"), "ORBITO"])
	FTGs.append([load("res://scenes/game_bomb_link/ftg_bomb_link.tscn"), "BMB.LNK."])
	
	var picked_ftg = FTGs.pop_front()
	current_ftg = picked_ftg[0].instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	current_ftg.position = center
	add_child(current_ftg)
	FTGs.push_back(picked_ftg)
	start_ftg.emit()
	request_set_all_label_text.emit(picked_ftg[1])

func end_ftg(result: bool) -> void:
	request_display_ftg_result.emit(result)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_fade_out: Tween = get_tree().create_tween()
	tween_fade_out.tween_property\
	(current_ftg, "position", center + Vector2(0, y_offset), 0.5).\
	set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween_fade_out.tween_callback(Callable(current_ftg, "queue_free"))
	
	await get_tree().create_timer(0.5).timeout
	
	var picked_ftg = FTGs.pop_front()
	current_ftg = picked_ftg[0].instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	current_ftg.position = center + Vector2(0, -y_offset)
	add_child(current_ftg)
	FTGs.push_back(picked_ftg)
	start_ftg.emit()
	request_set_all_label_text.emit(picked_ftg[1])
	
	var tween_fade_in: Tween = get_tree().create_tween()
	tween_fade_in.tween_property\
	(current_ftg, "position", center, 0.5).\
	set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
