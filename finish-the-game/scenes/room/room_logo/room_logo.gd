extends Node2D

var FTGs: Array[Resource] = []
var current_ftg: Node

signal start_ftg()

func _ready() -> void:
	#FTGs.append(load("res://scenes/game_pentago/ftg_pentago.tscn"))
	FTGs.append(load("res://scenes/game_sliding_puzzle/ftg_sliding_puzzle.tscn"))
	#FTGs.append(load("res://scenes/game_orbito/ftg_orbito.tscn"))
	#FTGs.append(load("res://scenes/game_bomb_link/ftg_bomb_link.tscn"))
	
	var picked_ftg: Resource = FTGs.pop_front()
	current_ftg = picked_ftg.instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	add_child(current_ftg)
	FTGs.push_back(picked_ftg)
	start_ftg.emit()

func end_ftg(_1: bool) -> void:
	const y_offset = 1080*2
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_fade_out: Tween = get_tree().create_tween()
	tween_fade_out.tween_property\
	(current_ftg, "position", Vector2(0, y_offset), 0.5).\
	set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween_fade_out.tween_callback(Callable(current_ftg, "queue_free"))
	
	await get_tree().create_timer(0.5).timeout
	
	var picked_ftg: Resource = FTGs.pop_front()
	current_ftg = picked_ftg.instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	current_ftg.position = Vector2(0, -y_offset)
	add_child(current_ftg)
	FTGs.push_back(picked_ftg)
	start_ftg.emit()
	
	var tween_fade_in: Tween = get_tree().create_tween()
	tween_fade_in.tween_property\
	(current_ftg, "position", Vector2(0, 0), 0.5).\
	set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
