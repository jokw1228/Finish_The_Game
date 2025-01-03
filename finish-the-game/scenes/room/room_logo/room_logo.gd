extends Node2D

signal asdf

func _ready() -> void:
	asdf.emit()

func restart(_1: bool) -> void:
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()
