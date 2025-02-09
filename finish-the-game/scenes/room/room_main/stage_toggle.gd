extends Control
class_name StageToggle

var state: int = 0

var shadow_tween: Tween

signal request_display_mix_stages()
func _on_mix_button_pressed() -> void:
	if state == 1:
		state = 0
		request_display_mix_stages.emit()
		
		%SFXStageToggle.play()
		
		%Mix.modulate.a = 1
		%Solo.modulate.a = 0.25
		%BoldLine.position.x = 0
		
		if shadow_tween != null:
			shadow_tween.kill()
		shadow_tween = create_tween()
		shadow_tween.tween_property(%StageToggleShadow, "position", Vector2(28, 72), 0.3)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		#%StageToggleShadow.position.x = 28

signal request_display_solo_stages()
func _on_solo_button_pressed() -> void:
	if state == 0:
		state = 1
		request_display_solo_stages.emit()
		
		%SFXStageToggle.play()
		
		%Mix.modulate.a = 0.25
		%Solo.modulate.a = 1
		%BoldLine.position.x = 384
		
		if shadow_tween != null:
			shadow_tween.kill()
		shadow_tween = create_tween()
		shadow_tween.tween_property(%StageToggleShadow, "position", Vector2(412, 72), 0.3)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		#%StageToggleShadow.position.x = 412
