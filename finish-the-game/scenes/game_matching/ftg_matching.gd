extends Matching
class_name FTGMatching

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


func set_delete(set: Array, element) -> void:
	if element in set:
		set.remove_at(set.find(element))


func start_ftg() -> void:
	initialize_game_matching()

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var temp_card: Array
	var temp_card_set: Array
	var last_head: int
	temp_card = [randi_range(0, 6), randi_range(0, 6), 0]
	field_card_set.append(temp_card)
	temp_card_set.append(temp_card)
	
	for i in range(8):
		while true:
			temp_card = [randi_range(0, 6), randi_range(0, 6), 0]
			print(temp_card)
			if can_place_card(temp_card_set[len(temp_card_set) - 1], temp_card, 0):
				temp_card_set.append([temp_card[0], temp_card[1], 0])
				
				print("0")
				break;
			elif can_place_card(temp_card_set[len(temp_card_set) - 1], temp_card, 1):
				temp_card_set.append([temp_card[0], temp_card[1], 1])
				print("1")
				break;
		hand_card_set.append(temp_card)
	
	hand_card_set.shuffle()
	
	init_UI.emit()
	
	const duration = 10.0
	start_timer.emit(duration)


func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
