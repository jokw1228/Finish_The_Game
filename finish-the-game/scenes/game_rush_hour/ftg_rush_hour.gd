extends RushHour
class_name FTGRushHour

signal end_ftg(game_cleard: bool)
var target_location = Vector2(128*6, 128*3) 
var threshold = 10
#func start_ftg() ->: void:
	
	
func _process(delta):
	var rush_hour_scene = get_parent() 
	var player_piece = rush_hour_scene.player_piece
	print("player_piece", player_piece)
	print(player_piece.position.distance_to(target_location))
	if player_piece and player_piece.position.distance_to(target_location) < threshold:
		end_ftg.emit(true)
		print("ftg")
