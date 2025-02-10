extends Set
class_name FTGSet

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


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


func start_ftg(difficulty: float) -> void:
	initialize_game_set()
	handle_difficulty(difficulty)
	
	var card_set: Array = []
	var solution_set: Array = []
	var temp_ranges = []
	for i in range(attribute_amount):
		temp_ranges.append(3)
	
	generate_cards(card_set, temp_ranges, [true])
	
	for i in range(int(attribute_amount / 3)):
		temp_ranges.append([])
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var temp_card: Array
	var no_solution: bool = false
	for i in range(int(card_amount / 3)):
		no_solution = true
		
		while no_solution:
			if solution_set != []:
				for j in solution_set:
					card_set.append(j)
				solution_set.clear()
			
			for j in range(2):
				temp_card = card_set[randi_range(0, len(card_set) - 1)]
				solution_set.append(temp_card)
				set_delete(card_set, temp_card)
			
			for j in card_set:
				if can_delete_card_set(solution_set + [j]):
					field_card_set += solution_set + [j]
					set_delete(card_set, j)
					solution_set.clear()
					no_solution = false
					break
	
	field_card_set.shuffle()
	
	init_UI.emit()
	
	const duration = 15.0
	start_timer.emit(time_limit)


func handle_difficulty(difficulty: float) -> void:
	"""
	time_limit : 시간 제한
	card_amount : 나오는 카드 수, 항상 3의 배수, 6 or 9
	attribute_amount : 나오는 속성의 수, 2 or 3
	"""
	if difficulty < 0.2:
		time_limit = 15
		card_amount = 6
		attribute_amount = 2
	
	elif difficulty < 0.4:
		time_limit = 15
		card_amount = 6
		attribute_amount = 3
	
	elif difficulty < 0.6:
		time_limit = 15
		card_amount = 9
		attribute_amount = 3
	
	elif difficulty < 0.8:
		time_limit = 13
		card_amount = 9
		attribute_amount = 3
	
	elif difficulty >= 0.8:
		time_limit = 13 - (difficulty - 0.8) * 6
		card_amount = 9
		attribute_amount = 3


func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
