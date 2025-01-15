extends ColorRect
class_name BackgroundScrollingLine

var labels: Array[Label] = []

var text: String = "test text"
var duration: float = 3.0

func _ready() -> void:
	scrolling()

func scrolling() -> void:
	while true:
		var inst: Label = Label.new()
		inst.text = text
		add_child(inst)
		
		inst.position = Vector2(inst.size.x * (-1), 0)
		var tween_position: Tween = get_tree().create_tween()
		tween_position.tween_property(inst, "position", Vector2(1080, 0), duration)
		
		await tween_position.finished
