extends TextureProgressBar
class_name GameUtilsGameTimer

signal timeout

func start_timer(duration: float):
	visible = true
	var tween_time: Tween = get_tree().create_tween()
	tween_time.tween_property(self, "value", 0.0, duration)
	await tween_time.finished
	timeout.emit()
