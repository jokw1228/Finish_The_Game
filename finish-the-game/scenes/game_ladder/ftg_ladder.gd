extends Ladder
class_name FTGLadder

signal request_disable_input(disable)
signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()

const TIMER_DURATION: float = 7.0

# 난이도에 따른 최소/최대값 상수 정의
const MIN_HORIZONTAL_COUNT: int = 4
const MAX_HORIZONTAL_COUNT: int = 10
const MIN_LINE_NUM: int = 3
const MAX_LINE_NUM: int = 6

var isWin: bool = false
var ui: LadderUI = null

func _ready() -> void:
	pass

func start_ftg(difficulty: float) -> void: # difficulty: 0.0 ~ 1.0
	# 가로선 개수를 난이도에 따라 3~8개로 조절
	var horizontal_count = int(lerp(MIN_HORIZONTAL_COUNT, MAX_HORIZONTAL_COUNT, difficulty))
	
	# 세로선 개수 조절 (난이도가 높을수록 더 많아짐)
	LINE_NUM = int(lerp(MIN_LINE_NUM, MAX_LINE_NUM, difficulty))
	
	init()  # LINE_NUM 설정 후 init 호출
	
	ui = $LadderUI
	ui.init(self)
	
	var rng = RandomNumberGenerator.new()
	for i in range(horizontal_count):
		add_random_line()
	
	start_idx = rng.randi_range(0, len(vertical_lines) - 1)
	end_idx = rng.randi_range(0, len(vertical_lines) - 1)
	
	ui.enable_input = true
	start_timer.emit(TIMER_DURATION)
	await get_tree().create_timer(TIMER_DURATION).timeout
	ui.enable_input = false
	check()

func check() -> void:
	isWin = check_win()

func on_game_result() -> void:
	end_ftg.emit(isWin)
