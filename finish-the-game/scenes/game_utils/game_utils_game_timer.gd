extends TextureProgressBar
class_name GameUtilsGameTimer

signal timeout

var tween_time: Tween

func start_timer(duration: float):
	visible = true
	tween_time = get_tree().create_tween()
	tween_time.tween_property(self, "value", 0.0, duration)
	await tween_time.finished
	timeout.emit()

func pause_timer():
	if tween_time.is_running():
		tween_time.pause()

func resume_timer():
	if tween_time.is_valid():
		tween_time.play()
