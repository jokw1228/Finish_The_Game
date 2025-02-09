extends CanvasLayer
class_name HPBarCanvas

signal hp_depleted

var max_hp := 100.0
var current_hp := 100.0
var tween: Tween

@onready var progress_bar = $ProgressBar
@onready var damage_effect = $DamageEffect

func _ready():
	progress_bar.max_value = max_hp
	progress_bar.value = current_hp
	
	#take_damage(10)

func take_damage(amount: float):
	var previous_hp = current_hp
	current_hp = max(0, current_hp - amount)
	
	# HP 바 애니메이션
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(progress_bar, "value", current_hp, 0.3).set_trans(Tween.TRANS_QUAD)
	
	# 데미지 효과 애니메이션
	var effect_tween = create_tween()
	effect_tween.tween_property(damage_effect, "color:a", 0.3, 0.1)
	effect_tween.tween_property(damage_effect, "color:a", 0.0, 0.2)
	
	# HP가 0이 되었을 때
	if current_hp <= 0:
		hp_depleted.emit()

func heal(amount: float):
	current_hp = min(max_hp, current_hp + amount)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(progress_bar, "value", current_hp, 0.3).set_trans(Tween.TRANS_QUAD)
