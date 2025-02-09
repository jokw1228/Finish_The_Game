extends Node2D

var start
var end
var map_arr = []

signal map_chosen

func _on_rush_hour_gen_map(num) -> void:
	var file = FileAccess.open("res://resources/images/game_rush_hour/rush_hour_map.txt", FileAccess.READ)
	if file:
		while file.get_position() < file.get_length():
			var line = file.get_line()
			var num_turns = line[0]+line[1]
			if int(num_turns) == num:
				map_arr.append(line)
			if int(num_turns)< num:
				break
	var index = randi_range(0, map_arr.size() - 1)
	var chosen_map = map_arr[index]
	map_chosen.emit(chosen_map.substr(3,36))
	#print(chosen_map)
	print(chosen_map.substr(3,36))
