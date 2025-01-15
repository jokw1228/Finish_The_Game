extends RushHour
class_name FTGRushHour

#signal end_ftg(game_cleard: bool)
#var target_location = Vector2(128*6, 128*3) 
#var threshold = 10
#func start_ftg() ->: void:

func _ready():
	print("FTGRushHour ready")
	
func _on_player_piece_instantiated(instantiated_piece: Node):
	print("Player piece instantiated: ", instantiated_piece)

func _process(delta):
	print("player_piece", player_piece)
	var parent = get_parent()
	if parent and parent.has_method("get_instantiated_scene"):
		var player_piece = parent.get_instantiated_scene()
	print(player_piece.position.distance_to(target_location))
	if player_piece and player_piece.position.distance_to(target_location) < threshold:
		end_ftg.emit(true)
		print("ftg")
