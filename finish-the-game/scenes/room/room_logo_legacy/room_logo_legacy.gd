extends Node2D

const y_offset = 1080*2
var center: Vector2 = Vector2.ZERO

var FTGs: Array = []
var FTG_dict = {}
var current_ftg: Node

const priority_queue = preload("res://scenes/room/priority_queue.gd")
var pq = priority_queue.new()

signal start_ftg()

signal request_set_all_label_text(label_text_to_set)
signal request_display_ftg_result(result: bool)

func _ready() -> void:
	center = get_viewport().get_visible_rect().size / 2
	'''
	FTGs.append([load("res://scenes/game_ladder/ftg_ladder.tscn"), "LADDER"])
	FTGs.append([load("res://scenes/game_memory/ftg_memory.tscn"), "MEMORY"])
	FTGs.append([load("res://scenes/game_one_card/ftg_one_card.tscn"), "ONECARD"])
	FTGs.append([load("res://scenes/game_set/ftg_set.tscn"), "SET"])
	FTGs.append([load("res://scenes/game_pentago/ftg_pentago.tscn"), "PENTAGO"])
	FTGs.append([load("res://scenes/game_sliding_puzzle/ftg_sliding_puzzle.tscn"), "SLD.PZL."])
	FTGs.append([load("res://scenes/game_orbito/ftg_orbito.tscn"), "ORBITO"])
	FTGs.append([load("res://scenes/game_bomb_link/ftg_bomb_link.tscn"), "BOMBLINK"])
	FTGs.append([load("res://scenes/game_rush_hour/game_rush_hour.tscn"), "RUSHHOUR"])
	FTGs.append([load("res://scenes/game_ricochet_robot/ftg_richchet_robot.tscn"), "RICOCHET_ROBOT"])
	'''
	
	#ftg_add("LADDER", 3, load("res://scenes/game_ladder/ftg_ladder.tscn"))
	#ftg_add("MATCHING", 5, load("res://scenes/game_matching/ftg_matching.tscn"))
	#ftg_add("MEMORY", 5, load("res://scenes/game_memory/ftg_memory.tscn"))
	#ftg_add("ONECARD", 5, load("res://scenes/game_one_card/ftg_one_card.tscn"))
	ftg_add("SET", 7, load("res://scenes/game_set/ftg_set.tscn"))
	#ftg_add("PENTAGO", 7, load("res://scenes/game_pentago/ftg_pentago.tscn"))
	#ftg_add("SLD.PZL.", 5, load("res://scenes/game_sliding_puzzle/ftg_sliding_puzzle.tscn"))
	#ftg_add("ORBITO", 11, load("res://scenes/game_orbito/ftg_orbito.tscn"))
	#ftg_add("BOMBLINK", 7, load("res://scenes/game_bomb_link/ftg_bomb_link.tscn"))
	#ftg_add("RUSHHOUR", 9, load("res://scenes/game_rush_hour/ftg_rush_hour.tscn"))
	#ftg_add("RICOCHET_ROBOT", 9, load("res://scenes/game_ricochet_robot/ftg_richchet_robot.tscn"))

	#for i in pq.get_list():
	#	print(i)
	#print()
	
	schedule_ftg(0)

func end_ftg(result: bool) -> void:
	request_display_ftg_result.emit(result)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween_fade_out: Tween = get_tree().create_tween()
	tween_fade_out.tween_property\
	(current_ftg, "position", center + Vector2(0, y_offset), 0.5).\
	set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween_fade_out.tween_callback(Callable(current_ftg, "queue_free"))
	
	await get_tree().create_timer(0.5).timeout
	
	schedule_ftg(y_offset)
	
	var tween_fade_in: Tween = get_tree().create_tween()
	tween_fade_in.tween_property\
	(current_ftg, "position", center, 0.5).\
	set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func schedule_ftg(y_offset):
	var picked = pq.pop()
	var picked_ftg = FTG_dict[picked[0]][0]
	var picked_recent_time = picked[1]
	current_ftg = picked_ftg.instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	current_ftg.position = center + Vector2(0, -y_offset)
	add_child(current_ftg)
	pq.insert(picked[0],picked_recent_time+FTG_dict[picked[0]][1]+randf_range(0,0.1))
	#for i in pq.get_list():
	#	print(i)
	#print()
	start_ftg.emit()
	request_set_all_label_text.emit(picked[0])
	

func ftg_add(ftg_name, duration, tscn):
	FTG_dict[ftg_name] = [tscn, duration]
	FTGs.append(ftg_name)
	pq.insert(ftg_name,duration + randf_range(0,0.1))
	
