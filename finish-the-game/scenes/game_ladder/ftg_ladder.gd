extends Ladder
class_name FTGLadder

signal request_disable_input(disable)
signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

const HORIZONTAL_COUNT: int = 5
const TIMER_DURATION: float = 10

var isWin: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_ftg() # 임시

func start_ftg() -> void:
	init()
	var rng = RandomNumberGenerator.new()
	for i in range(HORIZONTAL_COUNT):
		add_random_line()
	
	start_idx = rng.randi_range(0, len(vertical_lines) - 1)
	end_idx = rng.randi_range(0, len(vertical_lines) - 1)
	start_timer.emit(TIMER_DURATION)
	await get_tree().create_timer(TIMER_DURATION).timeout
	request_disable_input.emit(true)
	check()

func check() -> void:
	isWin = check_win()
	
func on_middle_anime() -> void:
	if isWin:
		# 끝 원 애니메이션 시작
		is_end_animating = true
		end_circle_progress = 0.0
	else:
		on_end_anime()

func on_end_anime() -> void:
	print(isWin)
	end_ftg.emit(isWin)
