extends Memory
class_name FTGMemory

signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()


func set_delete(set: Array, element) -> void:
	if element in set:
		set.remove_at(set.find(element))


func start_ftg() -> void:
	initialize_game_memory()
	
	var card_set: Array = []

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var temp_card: int
	
	for i in range(4):
		temp_card = randi_range(0, 7)
		while temp_card in card_set:
			temp_card = randi_range(0, 7)
		card_set.append(temp_card)
		field_card_set.append([true, temp_card])
		field_card_set.append([true, temp_card])
	
	field_card_set.shuffle()
	
	init_UI.emit()
	
	const duration = 8.0
	start_timer.emit(duration)


func finish_game() -> void:
	stop_UI.emit()
	pause_timer.emit()
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)


func _on_game_utils_game_timer_timeout() -> void:
	stop_UI.emit()
	end_ftg.emit(false)
