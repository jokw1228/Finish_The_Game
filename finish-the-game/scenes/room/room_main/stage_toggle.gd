extends Control
class_name StageToggle

var state: int = 0

signal request_display_mix_stages()
func _on_mix_button_pressed() -> void:
	if state == 1:
		state = 0
		%Mix.modulate.a = 1
		%Solo.modulate.a = 0.25
		request_display_mix_stages.emit()

signal request_display_solo_stages()
func _on_solo_button_pressed() -> void:
	if state == 0:
		state = 1
		%Mix.modulate.a = 0.25
		%Solo.modulate.a = 1
		request_display_solo_stages.emit()
