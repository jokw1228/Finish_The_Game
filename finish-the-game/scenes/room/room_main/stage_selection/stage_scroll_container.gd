extends ScrollContainer
class_name StageScrollContainer

var stage_count: int = 0
var stage_width: float = 768

@export var stage_thumbnail_container: HBoxContainer

func receive_request_set_stage_datas(stage_datas_to_set: Array[StageData]) -> void:
	initialize(stage_datas_to_set)

func initialize(stage_datas_to_set: Array[StageData]) -> void:
	scroll_horizontal = 0
	
	for inst in %StageThumbnailContainer.get_children():
		inst.queue_free()
	
	stage_count = stage_datas_to_set.size()
	if stage_count <= 0:
		stage_width = 0
	
	for stage_data: StageData in stage_datas_to_set:
		var image: TextureRect = TextureRect.new()
		image.texture = stage_data.stage_thumbnail
		image.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		stage_thumbnail_container.add_child(image)
		
	

func set_stage_index(stage_index: int) -> void:
	set_deferred("scroll_horizontal", RoomManager.get_scene_index() * stage_width)
	print(stage_index)

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
	
	%SFXScrollSnap.play()

var current_stage: int = 0
signal current_stage_has_been_changed(changed_current_stage: int)
func set_current_stage(current_stage_to_set: int) -> void:
	if current_stage != current_stage_to_set:
		current_stage = current_stage_to_set
		RoomManager.set_scene_state(RoomManager.get_scene_type(), current_stage)
		current_stage_has_been_changed.emit(current_stage)

func receive_stage_selection_state_has_been_changed(changed_state: StageSelection.StageSelectionState) -> void:
	if changed_state == StageSelection.StageSelectionState.STAGE_SCROLLING:
		enable_input()
	else:
		disable_input()

func enable_input() -> void:
	set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	%StageSelectionButton.disabled = false
	%StageSelectionButton.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	
	%RightArrow.disabled = false
	%RightArrow.set_mouse_filter(Control.MOUSE_FILTER_PASS)
	%LeftArrow.disabled = false
	%LeftArrow.set_mouse_filter(Control.MOUSE_FILTER_PASS)

func disable_input() -> void:
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	%StageThumbnailContainer.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	#for inst in %StageThumbnailContainer.get_children():
	#	inst.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	%StageSelectionButton.disabled = true
	%StageSelectionButton.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	%RightArrow.disabled = true
	%RightArrow.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	%LeftArrow.disabled = true
	%LeftArrow.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)

signal stage_selection_button_pressed()
func _on_stage_selection_button_pressed() -> void:
	stage_selection_button_pressed.emit()


func _on_right_arrow_pressed() -> void:
	var target_stage: int = int(round(scroll_horizontal / stage_width)) + 1
	target_stage = clamp(target_stage, 0, stage_count - 1)
	set_current_stage(target_stage)
	var target_scroll: float = target_stage * stage_width
	scroll_horizontal = target_scroll
	
	%SFXScrollSnap.play()

func _on_left_arrow_pressed() -> void:
	var target_stage: int = int(round(scroll_horizontal / stage_width)) - 1
	target_stage = clamp(target_stage, 0, stage_count - 1)
	set_current_stage(target_stage)
	var target_scroll: float = target_stage * stage_width
	scroll_horizontal = target_scroll
	
	%SFXScrollSnap.play()
