extends Ladder
class_name FTGLadder

signal request_disable_input(disable)
signal end_ftg(is_game_cleared: bool)
signal start_timer(duration: float)
signal pause_timer()

const HORIZONTAL_COUNT: int = 5
const TIMER_DURATION: float = 5

var isWin: bool = false
var ui: LadderUI = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start_ftg() # 임시
	pass

func start_ftg(difficulty: float) -> void:
	# LadderUI 초기화는 외부에서 하도록 수정
	init()
	ui = $LadderUI
	ui.init(self)
	
	var rng = RandomNumberGenerator.new()
	for i in range(HORIZONTAL_COUNT):
		add_random_line()
	
	start_idx = rng.randi_range(0, len(vertical_lines) - 1)
	end_idx = rng.randi_range(0, len(vertical_lines) - 1)
	
	ui.enable_input = true
	start_timer.emit(TIMER_DURATION)
	await get_tree().create_timer(TIMER_DURATION).timeout
	#request_disable_input.emit(false)
	ui.enable_input = false
	check()

func check() -> void:
	isWin = check_win()

# UI의 애니메이션 관련 함수들은 UI에서 처리하도록 수정
func on_game_result() -> void:
	end_ftg.emit(isWin)
