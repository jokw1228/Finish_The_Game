extends OneCard
class_name FTGOneCard

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


func start_ftg(difficulty: float) -> void:
	initialize_card()
	handle_difficulty(difficulty)
	
	var card_set: Array = []
	for i in range(4):
		for j in range(13):
			card_set.append([i, j])
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var temp_cards: Array = []
	var temp_: Array = []  # [[_, _], _]
	var prev_index: int = rng.randi_range(0, 1)
	can_one_more = true
	var can_shape_change: bool = false
	
	for i in range(2):
		temp_cards.append([card_set[rng.randi_range(0, 51 - i)]])
		set_delete(card_set, temp_cards[i][0])
		if i == 0:
			field_stack_1.append(temp_cards[i][0])
		else:
			field_stack_2.append(temp_cards[i][0])
	
	var available_set: Array = []
	var weights: PackedFloat32Array = []
	for i in range(card_amount):
		available_set = []
		weights = []
		temp_ = []
			
		if can_one_more:
			for j in card_set:
				for k in range(2):
					if can_place_card(j, k, [temp_cards[0][-1], temp_cards[1][-1]], prev_index, can_one_more):
						available_set.append([j, k])
						
						if j[1] in [6, 10, 11, 12]:
							if k == prev_index:
								weights.append(1)
							else:
								weights.append(10 * hard_card_multiplyer)
						else:
							if k == prev_index:
								weights.append(1)
							else:
								weights.append(7)
			
		elif can_shape_change:
			for j in card_set:
				for k in range(4):
					if can_place_card([k, j[1]], prev_index, [temp_cards[0][-1], temp_cards[1][-1]], prev_index, can_one_more):
						available_set.append([j, prev_index])
						
						if j[1] in [6, 10, 11, 12]:
							if j[0] != temp_cards[prev_index][-1][0]:
								weights.append(5 * hard_card_multiplyer)
							else:
								weights.append(2.5 * hard_card_multiplyer)
						else:
							if j[0] != temp_cards[prev_index][-1][0]:
								weights.append(3 * hard_card_multiplyer)
							else:
								weights.append(1)
			
		else:
			for j in card_set:
				if can_place_card(j, prev_index, [temp_cards[0][-1], temp_cards[1][-1]], prev_index, can_one_more):
					available_set.append([j, prev_index])
					
					if j[1] in [6, 10, 11, 12]:
						weights.append(2.5 * hard_card_multiplyer)
					else:
						weights.append(1)
		
		temp_ = available_set[rng.rand_weighted(weights)]
		
		set_delete(card_set, temp_[0])
		hand_card_set.append(temp_[0])
		temp_cards[temp_[1]].append(temp_[0])
		
		prev_index = temp_[1]
		if temp_[0][1] in [10, 11, 12]:
			can_one_more = true
			can_shape_change = false
		elif temp_[0][1] == 6:
			can_one_more = false
			can_shape_change = true
		else:
			can_one_more = false
			can_shape_change = false
	
	can_one_more = true
	
	init_UI.emit()
	
	const duration = 20.0
	start_timer.emit(time_limit)


func handle_difficulty(difficulty: float) -> void:
	"""
	time_limit : 시간 제한
	card_amount : 나오는 카드 수, 4 ~ 8
	hard_card_multiplyer : 특수 카드 나올 확률 배수
	"""
	if difficulty < 0.2:
		time_limit = 12
		card_amount = 4
		hard_card_multiplyer = 0.8
	
	elif difficulty < 0.4:
		time_limit = 16
		card_amount = 6
		hard_card_multiplyer = 0.8
	
	elif difficulty < 0.6:
		time_limit = 18
		card_amount = 6
		hard_card_multiplyer = 1
	
	elif difficulty < 0.8:
		time_limit = 20
		card_amount = 8
		hard_card_multiplyer = 1.5
	
	elif difficulty >= 0.8:
		time_limit = 20 - (difficulty - 0.8) * 10
		card_amount = 8
		hard_card_multiplyer = 1.5

func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
