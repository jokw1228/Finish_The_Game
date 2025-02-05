extends ScrollContainer
class_name StageScrollContainer

var stage_count: int = 0
var stage_width: float = 768

@export var stage_thumbnail_container: HBoxContainer

func receive_request_set_stage_datas(stage_datas_to_set: Array[StageData]) -> void:
	initialize(stage_datas_to_set)

func initialize(stage_datas: Array[StageData]) -> void:
	stage_count = stage_datas.size()
	if stage_count <= 0:
		stage_width = 0
	
	for stage_data: StageData in stage_datas:
		var image: TextureRect = TextureRect.new()
		image.texture = stage_data.stage_thumbnail
		stage_thumbnail_container.add_child(image)

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and not event.is_pressed())\
	or (event is InputEventMouseButton and not event.is_pressed()):
		snap_to_nearest_stage()

var tween_snap: Tween
func snap_to_nearest_stage() -> void:
	if stage_width == 0:
		return
	
	var target_stage: int = int(round(scroll_horizontal / stage_width))
	target_stage = clamp(target_stage, 0, stage_count - 1)
	set_current_stage(target_stage)
	var target_scroll: float = target_stage * stage_width
	
	if tween_snap != null:
		tween_snap.kill()
	tween_snap = get_tree().create_tween()
	tween_snap.tween_property(self, "scroll_horizontal", target_scroll, 0.1)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

var current_stage: int = 0
signal current_stage_has_been_changed(changed_current_stage: int)
func set_current_stage(current_stage_to_set: int) -> void:
	if current_stage != current_stage_to_set:
		current_stage = current_stage_to_set
		current_stage_has_been_changed.emit(current_stage)
