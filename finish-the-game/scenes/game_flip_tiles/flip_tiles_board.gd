extends Sprite2D
class_name FlipTilesBoard


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change_state(pos: int) -> void:
	var cell = get_node("GridContainer/FlipTilesCell" + str(pos + 1))
	cell.change_tile_state()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
