extends Memory
class_name FTGMemory

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


func set_delete(set: Array, element) -> void:
	if element in set:
		set.remove_at(set.find(element))


func start_ftg(difficulty: float) -> void:
	initialize_game_memory()
	handle_difficulty(difficulty)
	
	var card_set: Array = []

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var temp_card: int
	
	for i in range(card_amount / 2):
		temp_card = randi_range(0, available_shape_pool - 1)
		while temp_card in card_set:
			temp_card = randi_range(0, available_shape_pool - 1)
		card_set.append(temp_card)
		field_card_set.append([true, temp_card])
		field_card_set.append([true, temp_card])
	
	field_card_set.shuffle()
	
	init_UI.emit()
	
	start_timer.emit(time_limit)
	

func handle_difficulty(difficulty: float) -> void:
	"""
	time_limit : 시간 제한
	card_amount : 나오는 카드 수, 항상 짝수, available_shape_pool * 2 이상이여야 함
					4 or 6 or 8
	available_shape_pool : 나올 수 있는 모양 개수의 범위, 1 ~ 12
							(난이도에 미치는 영향이 적음)
	"""
	if difficulty < 0.2:
		time_limit = 7
		card_amount = 4
		available_shape_pool = 2
	
	elif difficulty < 0.4:
		time_limit = 7
		card_amount = 6
		available_shape_pool = 3
	
	elif difficulty < 0.6:
		time_limit = 7
		card_amount = 6
		available_shape_pool = 9
	
	elif difficulty < 0.8:
		time_limit = 7
		card_amount = 8
		available_shape_pool = 12
	
	elif difficulty >= 0.8:
		time_limit = 7 - (difficulty - 0.8) * 2
		card_amount = 8
		available_shape_pool = 12


func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
