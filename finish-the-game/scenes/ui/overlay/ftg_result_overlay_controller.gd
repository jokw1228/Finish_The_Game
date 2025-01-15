extends CanvasLayer
class_name FTGResultOverlayController

var center: Vector2 = Vector2.ZERO
@export var o_scene: PackedScene
@export var x_scene: PackedScene

func display_ftg_result(result: bool) -> void:
	if result == true:
		var inst: FTGResultOverlayO = o_scene.instantiate() as FTGResultOverlayO
		add_child(inst)
		inst.position = center
	elif result == false:
		var inst: FTGResultOverlayX = x_scene.instantiate() as FTGResultOverlayX
		add_child(inst)
		inst.position = center

func _ready() -> void:
	center = get_viewport().get_visible_rect().size / 2
