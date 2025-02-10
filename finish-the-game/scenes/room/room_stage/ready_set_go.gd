extends Control
class_name ReadySetGo

func ready_set_go() -> void:
	await get_tree().create_timer(0.5).timeout
	
	visible = true
	
	%ReadySet.text = "Ready"
	%ReadySet.visible = true
	%SFXReadySet.play()
	await get_tree().create_timer(0.8).timeout
	%ReadySet.text = "Ready\nSet"
	%SFXReadySet.play()
	await get_tree().create_timer(0.8).timeout
	%ReadySet.visible = false
	%Go.visible = true
	%SFXGo.play()
	await get_tree().create_timer(0.5).timeout
	%Go.visible = false
	
	visible = false
	return
