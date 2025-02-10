extends Matching
class_name FTGMatching

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


func set_delete(set: Array, element) -> void:
	if element in set:
		set.remove_at(set.find(element))


func start_ftg(difficulty: float) -> void:
	initialize_game_matching()
	handle_difficulty(difficulty)

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var temp_card: Array
	var temp_card_set: Array
	var last_head: int
	temp_card = [randi_range(0, 6), randi_range(0, 6), 0]
	field_card_set.append(temp_card)
	temp_card_set.append(temp_card)
	
	for i in range(card_amount):
		while true:
			temp_card = [randi_range(0, 6), randi_range(0, 6), 0]
			
			print(temp_card)
			if can_place_card(temp_card_set[len(temp_card_set) - 1], temp_card, 0):
				if temp_card[0] == temp_card[1] or temp_card in hand_card_set or \
			   	   [temp_card[1], temp_card[0], 0] in hand_card_set:
				
					if randi_range(1, 100) <= easy_reroll_chance:
						continue
						
				temp_card_set.append([temp_card[0], temp_card[1], 0])
				break
				
			elif can_place_card(temp_card_set[len(temp_card_set) - 1], temp_card, 1):
				if temp_card[0] == temp_card[1] or temp_card in hand_card_set or \
			   	   [temp_card[1], temp_card[0], 0] in hand_card_set:
				
					if randi_range(1, 100) <= easy_reroll_chance:
						continue
						
				temp_card_set.append([temp_card[0], temp_card[1], 1])
				break
				
		hand_card_set.append(temp_card)
	
	hand_card_set.shuffle()
	
	init_UI.emit()
	
	const duration = 10.0
	start_timer.emit(time_limit)


func handle_difficulty(difficulty: float) -> void:
	"""
	time_limit : 시간 제한
	card_amount : 나오는 카드 수, 4 ~ 8
	easy_reroll_chance : 쉬운 상황 (두 눈이 똑같거나, 그냥 혹은 뒤집었을 때 동일한 눈 배열이 손패에 있음)
						 일 경우에 다시 눈을 결정할 확률, 0 ~ 100 (%)
						 이 보정이 생각보다 매움
	"""
	
	
	if difficulty <= 0:
		time_limit = 12
		card_amount = 4
		easy_reroll_chance = 20
	
	elif difficulty >= 1:
		time_limit = 16
		card_amount = 8
		easy_reroll_chance = 50
		
	else:
		time_limit = 12 - difficulty * 4
		
		if difficulty <= 0.334:
			time_limit += 2
			card_amount = 5
			easy_reroll_chance = 20
			
		elif difficulty <= 0.667:
			time_limit += 4
			card_amount = 6
			easy_reroll_chance = 30
			
		else:
			time_limit += 6
			card_amount = 7
			easy_reroll_chance = 40


func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
