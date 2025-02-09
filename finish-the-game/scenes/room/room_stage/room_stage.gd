extends Control
class_name RoomStage

@export var stage_name: String = ""

@onready var background_scrolling_controller: BackgroundScrollingController = %BackgroundScrollingController
func _ready() -> void:
	background_scrolling_controller.set_all_label_text(stage_name)
	
	await get_tree().create_timer(0.5).timeout
	start_stage()

@onready var ready_set_go: ReadySetGo = %ReadySetGo
var clear_count: int = 0
@onready var hp_bar_canvas: HPBarCanvas = %HPBarCanvas
func start_stage() -> void:
	await ready_set_go.ready_set_go()
	
	create_ftg_scheduler()
	
	clear_count = 0
	hp_bar_canvas.visible = true
	
@export var ftg_game_datas: Array[FTGGameData] = []
@onready var ftg_result_overlay_controller: FTGResultOverlayController = %FTGResultOverlayController
var ftg: FTGScheduler
func create_ftg_scheduler() -> void:
	ftg = FTGScheduler.new()
	add_child(ftg)
	ftg.init(ftg_game_datas)
	ftg.connect("request_display_ftg_result", Callable(ftg_result_overlay_controller, "display_ftg_result"))
	ftg.connect("request_set_all_label_text", Callable(background_scrolling_controller, "set_all_label_text"))
	ftg.connect("request_display_ftg_result", Callable(self, "is_cleared"))

signal take_damage(amount: float)
func is_cleared(result: bool) -> void:
	if result == true:
		clear_count += 1
	elif result == false:
		take_damage.emit(25.0)

func on_hp_depleted() -> void:
	ftg.stop_scheduling()
