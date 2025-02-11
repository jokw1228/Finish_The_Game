extends Control
class_name RoomStage

@export var stage_name: String = ""

@onready var background_scrolling_controller: BackgroundScrollingController = %BackgroundScrollingController as BackgroundScrollingController
func _ready() -> void:
	start_stage()
	
signal give_stage_up()
var is_game_ongoing: bool = false

@onready var ready_set_go: ReadySetGo = %ReadySetGo as ReadySetGo
var clear_count: int = 0
var original_high_score: int
@onready var hp_bar_canvas: HPBarCanvas = %HPBarCanvas as HPBarCanvas
func start_stage() -> void:
	$GiveupButton.visible = false
	$GiveupButton.disabled = true
	print("HIGH SCORE BEF. THIS SESSION = ", SaveManager.get_score(stage_name))
	background_scrolling_controller.set_all_label_text(stage_name)
	%Score.visible = false
	await ready_set_go.ready_set_go()
	is_game_ongoing = true
	
	
	create_ftg_scheduler()
	
	clear_count = 0
	original_high_score = SaveManager.get_score(stage_name)
	hp_bar_canvas.visible = true
	hp_bar_canvas.current_hp = 100.0
	hp_bar_canvas.progress_bar.value = 100.0
	%Score.text = "0"
	%Score.visible = true
	$GiveupButton.visible = true
	$GiveupButton.disabled = false
	
	AudioManager.play_bgm(bgm_ingame)
	
@export var ftg_game_datas: Array[FTGGameData] = []
@onready var ftg_result_overlay_controller: FTGResultOverlayController = %FTGResultOverlayController as FTGResultOverlayController
var ftg: FTGScheduler
func create_ftg_scheduler() -> void:
	ftg = FTGScheduler.new()
	add_child(ftg)
	ftg.connect("request_display_ftg_result", Callable(ftg_result_overlay_controller, "display_ftg_result"))
	ftg.connect("request_set_all_label_text", Callable(background_scrolling_controller, "set_all_label_text"))
	ftg.connect("request_display_ftg_result", Callable(self, "is_cleared"))
	ftg.init(ftg_game_datas)
	


signal take_damage(amount: float)
func is_cleared(result: bool) -> void:
	if result == true:
		clear_count += 1
		ftg.ftg_difficulty += 0.025
		if ftg.ftg_difficulty > 1.0:
			ftg.ftg_difficulty = 1.0
	elif result == false:
		take_damage.emit(25.0)
		
	%Score.text = str(clear_count)

@onready var game_over: GameOver = %GameOver as GameOver
func on_hp_depleted() -> void:
	if is_game_ongoing:
		is_game_ongoing = false
	else:
		return
	ftg.disconnect("request_set_all_label_text", Callable(background_scrolling_controller, "set_all_label_text"))
	await ftg.stop_scheduling()
	%Score.visible = false
	game_over.show_game_over(clear_count, original_high_score)
	if original_high_score < clear_count:
		print("New High Score of", clear_count, " instead of", original_high_score)
		SaveManager.set_score(stage_name, clear_count)
		
	SaveManager.save_file()
	AudioManager.stop_bgm(1.0)

func receive_request_retry_stage() -> void:
	game_over._initialize()
	start_stage()


func _on_giveup_button_pressed() -> void:
	give_stage_up.emit()
	take_damage.emit(120)
	$GiveupButton.visible = false
	$GiveupButton.disabled = true
	pass # Replace with function body.


@export var bgm_ingame: AudioStreamInteractive
