extends Set
class_name FTGSet

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


func _ready() -> void:
	start_ftg()


func set_delete(set: Array, element) -> void:
	if element in set:
		set.remove_at(set.find(element))


func generate_cards(cards: Array, ranges: Array, object: Array) -> void:
	for i in range(ranges[0]):
		if len(ranges) == 1:
			cards.append(object + [i])
		else:
			var temp_ranges: Array
			for j in range(1, len(ranges)):
				temp_ranges.append(ranges[j])
			generate_cards(cards, temp_ranges, object + [i])


func start_ftg() -> void:
	initialize_game_set()
	
	var card_set: Array = []
	var temp_ranges = []
	for i in range(attribute_num):
		temp_ranges.append(3)
	
	generate_cards(card_set, temp_ranges, [true])
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	#########
	
	for i in range(9):
		field_card_set.append(card_set[randi_range(0, 26)])
	
	init_UI.emit(9)
	
	const duration = 10.0
	#start_timer.emit(duration)


func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
