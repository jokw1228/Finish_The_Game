extends RefCounted
class_name BombLinkChainReaction

var step_count: int = 0

var chain_reaction: Array = []

func get_step_count() -> int:
	return step_count

func append_step(step_to_append: Array[Array]) -> void:
	chain_reaction.append(step_to_append)
	step_count += 1

func get_step(step_to_get: int) -> Array[Array]:
	if step_to_get < step_count:
		return chain_reaction[step_to_get] as Array[Array]
	else:
		print("error: there is no step!")
		return []
