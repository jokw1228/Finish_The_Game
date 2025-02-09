extends Node2D
class_name FTGScheduler_legacy

const y_offset: float = 1080*2
const FAIL_DAMAGE: float = 40
var center: Vector2 = Vector2.ZERO

var FTGs: Array = []
var FTG_dict = {}
var current_ftg: Node

var pq = PriorityQueue.new()

signal start_ftg(difficulty: float)
signal take_damage(amount: float)

signal request_set_all_label_text(label_text_to_set: String)
signal request_display_ftg_result(result: bool)

const FULL_GAME_LISTS = {
	"BINARY_PUZZLE": [1, "res://scenes/game_binary_puzzle/ftg_binary_puzzle.tscn"],
	"BOMB_LINK": [1, "res://scenes/game_bomb_link/ftg_bomb_link.tscn"],
	"FLIP_TILES": [1, "res://scenes/game_flip_tiles/ftg_flip_tiles.tscn"],
	"LADDER": [1, "res://scenes/game_ladder/ftg_ladder.tscn"],
	"MEMORY": [1, "res://scenes/game_memory/ftg_memory.tscn"],
	"ONE_CARD": [1, "res://scenes/game_one_card/ftg_one_card.tscn"],
	"ORBITO": [1, "res://scenes/game_orbito/ftg_orbito.tscn"],
	"PENTAGO": [1, "res://scenes/game_pentago/ftg_pentago.tscn"],
	"RICOCHET_ROBOT": [1, "res://scenes/game_ricochet_robot/ftg_richchet_robot.tscn"],
	"RUSH_HOUR": [1, "res://scenes/game_rush_hour/game_rush_hour.tscn"],
	"SET": [1, "res://scenes/game_set/ftg_set.tscn"],
	"SLIDING_PUZZLE": [1, "res://scenes/game_sliding_puzzle/ftg_sliding_puzzle.tscn"],
	"SUDOKU": [1, "res://scenes/game_sudoku/ftg_sudoku.tscn"],
}

func init(game_lists: Array[String], offset: float = 0) -> void:
	for g in game_lists:
		ftg_add(g, FULL_GAME_LISTS[g][0], load(FULL_GAME_LISTS[g][1]))
	schedule_ftg(offset)

func _ready() -> void:
	center = get_viewport().get_visible_rect().size / 2
	
	# 예시
	init(["BINARY_PUZZLE","SUDOKU","RUSH_HOUR","MEMORY", "LADDER", "SET", "BOMB_LINK"], 0)

func end_ftg(result: bool) -> void:
	request_display_ftg_result.emit(result)
	if !result: take_damage.emit(FAIL_DAMAGE)
	
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

func schedule_ftg(y_pos: float):
	var picked = pq.pop()
	var picked_ftg = FTG_dict[picked[0]][0]
	var picked_recent_time = picked[1]
	current_ftg = picked_ftg.instantiate()
	connect("start_ftg", Callable(current_ftg, "start_ftg"))
	current_ftg.connect("end_ftg", Callable(self, "end_ftg"))
	current_ftg.position = center + Vector2(0, -y_pos)
	add_child(current_ftg)
	pq.insert(picked[0],picked_recent_time+FTG_dict[picked[0]][1]+randf_range(0,0.1))
	#for i in pq.get_list():
	#	print(i)
	#print()
	start_ftg.emit(0.9)
	request_set_all_label_text.emit(picked[0])
	

func ftg_add(ftg_name: String, duration: float, tscn: PackedScene):
	FTG_dict[ftg_name] = [tscn, duration]
	FTGs.append(ftg_name)
	pq.insert(ftg_name,duration + randf_range(0,0.1))

func on_game_end() -> void:
	pass
