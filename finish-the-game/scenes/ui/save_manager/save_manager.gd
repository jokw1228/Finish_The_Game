extends Node

const save_path: String = "res://save.save"
var save_data: Dictionary
var empty_save: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func save_file() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(save_data, true)
	file.close()
	print("SAVE OK")
	pass

func reset_file() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(empty_save, true)
	file.close()
	save_data.clear()
	print("RESET OK")
	pass

func init_file() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(save_data, true)
	file.close()
	print("NO FILE - CREATED A NEW ONE")
	pass

func set_score(stage_name: String, score: int) -> void:
	save_data[stage_name] = score
	
	pass

func load_file() -> void:
	if not FileAccess.file_exists(save_path):
		init_file()
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	save_data = file.get_var(true)
	file.close()
	print("LOAD OK")
	
	pass	

func get_score(stage_name) -> int:
	if not stage_name in save_data:
		print("NO SAVE AVAILABLE FOR", stage_name)
		return 0
	return save_data[stage_name]
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
