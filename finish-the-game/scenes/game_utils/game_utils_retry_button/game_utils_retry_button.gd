extends TextureButton
class_name GameUtilsRetryButton

@export var retry_sprite: Sprite2D

signal request_retry()

func _on_pressed() -> void:
	request_retry.emit()

var tween_rotation: Tween
var tween_alpha: Tween

func animate_retry_sprite() -> void:
	const rotation_start_offset = 0
	const rotation_amount = PI * 2
	const duration = 1.0
	
	retry_sprite.rotation = rotation_start_offset
	
	if tween_rotation != null:
		tween_rotation.kill()
	tween_rotation = get_tree().create_tween()
	
	tween_rotation.tween_property\
	(retry_sprite, "rotation", rotation_start_offset+rotation_amount, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	
	const alpha_start_offset = 1.0
	const alpha_amount = -1.0
	#const duration = 1.0
	
	var target_color: Color = retry_sprite.modulate
	target_color.a = alpha_start_offset + alpha_amount
	
	retry_sprite.modulate.a = alpha_start_offset
	
	if tween_alpha != null:
		tween_alpha.kill()
	tween_alpha = get_tree().create_tween()
	
	tween_alpha.tween_property\
	(retry_sprite, "modulate", target_color, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
