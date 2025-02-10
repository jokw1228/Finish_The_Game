extends Node2D
class_name LadderUI

const LINE_THICKNESS: float = 12
const ANIME_LINE_THICKNESS: float = LINE_THICKNESS * 1.5
const CIRCLE_SIZE: float = 15
const POS_CIRCLE_SIZE: float = 20

const ANIMATION_DURATION: float = 1.0
const CIRCLE_ANIMATION_DURATION: float = 0.2

# 색깔들
const LINE_COLOR: Color = Color.SKY_BLUE
const MAGNET_COLOR: Color = Color.GRAY
const CHECK_COLOR: Color = Color.RED
const ANIME_COLOR: Color = Color.RED

var ladder: Ladder = null
var CLICK_MAGNET_LIMIT: float = 0.0

var first_click_pos: Vector2 = Vector2.ZERO
var current_mouse_pos: Vector2 = Vector2.ZERO
var nearest_vertical_pos: Vector2 = Vector2.ZERO

var animation_path: Array = []
var is_animating: bool = false
var animation_time: float = 0.0
var total_path_length: float = 0.0

var start_circle_progress: float = 0.0
var end_circle_progress: float = 0.0
var is_start_animating: bool = false
var is_end_animating: bool = false

var enable_input: bool = true

func init(ladder_node: Ladder) -> void:
	ladder = ladder_node
	CLICK_MAGNET_LIMIT = ladder.LINE_SPACING * 0.3
	position = -get_viewport().get_visible_rect().size / 2
	
	# 시그널 연결
	ladder.simulation_started.connect(_on_simulation_started)

func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	current_mouse_pos = mouse_pos
	
	var nearest_x: float = ladder.find_nearest_vertical(mouse_pos.x, CLICK_MAGNET_LIMIT)
	nearest_vertical_pos = Vector2(nearest_x, mouse_pos.y) if nearest_x else Vector2.ZERO
	
	if is_start_animating:
		start_circle_progress += _delta / CIRCLE_ANIMATION_DURATION
		if start_circle_progress >= 1.0:
			start_circle_progress = 1.0
			is_start_animating = false
	
	if is_end_animating:
		end_circle_progress += _delta / CIRCLE_ANIMATION_DURATION
		if end_circle_progress >= 1.0:
			end_circle_progress = 1.0
			is_end_animating = false
			on_end_anime()
	
	if is_animating:
		animation_time += _delta
		if animation_time >= ANIMATION_DURATION:
			is_animating = false
			animation_time = ANIMATION_DURATION
			on_middle_anime()
	
	queue_redraw()

func _draw() -> void:
	# 세로선 그리기
	for x in ladder.vertical_lines:
		draw_line(Vector2(x, ladder.TOP_MARGIN), 
				 Vector2(x, get_viewport_rect().size.y - ladder.BOTTOM_MARGIN), 
				 LINE_COLOR, 
				 LINE_THICKNESS)
	
	# 가로선 그리기
	for line in ladder.horizontal_lines:
		draw_line(Vector2(line[0], line[1]), 
				 Vector2(line[2], line[3]), 
				 LINE_COLOR, 
				 LINE_THICKNESS)
	
	# 애니메이션 경로 그리기
	if is_animating || animation_path.size() > 1:
		var progress: float = animation_time / ANIMATION_DURATION
		var current_length: float = 0.0
		var target_length: float = total_path_length * progress
		
		for i in range(animation_path.size() - 1):
			var start: Vector2 = Vector2(animation_path[i][0], animation_path[i][1])
			var end: Vector2 = Vector2(animation_path[i + 1][0], animation_path[i + 1][1])
			var segment_length: float = start.distance_to(end)
			
			if current_length + segment_length <= target_length:
				draw_line(start, end, ANIME_COLOR, ANIME_LINE_THICKNESS)
				current_length += segment_length
			elif current_length < target_length:
				var remaining: float = target_length - current_length
				var t: float = remaining / segment_length
				var partial_end: Vector2 = start.lerp(end, t)
				draw_line(start, partial_end, ANIME_COLOR, ANIME_LINE_THICKNESS)
				break

	if ladder.start_idx != -1:
		draw_circle(Vector2(ladder.vertical_lines[ladder.start_idx], ladder.TOP_MARGIN), 
				   POS_CIRCLE_SIZE, LINE_COLOR)
		if is_start_animating or start_circle_progress > 0:
			var radius = POS_CIRCLE_SIZE * start_circle_progress
			draw_circle(Vector2(ladder.vertical_lines[ladder.start_idx], ladder.TOP_MARGIN), 
					   radius, ANIME_COLOR)
			
	if ladder.end_idx != -1:
		draw_circle(Vector2(ladder.vertical_lines[ladder.end_idx], 
				   get_viewport_rect().size.y - ladder.BOTTOM_MARGIN), POS_CIRCLE_SIZE, LINE_COLOR)
		if is_end_animating or end_circle_progress > 0:
			var radius = POS_CIRCLE_SIZE * end_circle_progress
			draw_circle(Vector2(ladder.vertical_lines[ladder.end_idx], 
					   get_viewport_rect().size.y - ladder.BOTTOM_MARGIN), radius, ANIME_COLOR)
	
	if nearest_vertical_pos:
		draw_circle(nearest_vertical_pos, CIRCLE_SIZE, MAGNET_COLOR)
	
	if first_click_pos:
		draw_circle(first_click_pos, CIRCLE_SIZE, CHECK_COLOR)

func _input(event: InputEvent) -> void:
	if enable_input and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !nearest_vertical_pos:
			first_click_pos = Vector2.ZERO
		elif nearest_vertical_pos.y < ladder.TOP_MARGIN:
			#ladder.check_win()
			pass
		elif nearest_vertical_pos.y > get_viewport_rect().size.y - ladder.BOTTOM_MARGIN:
			pass 
		elif first_click_pos == Vector2.ZERO:
			first_click_pos = nearest_vertical_pos
		else:
			var clicked_pos = Vector2(ladder.find_nearest_vertical(event.position.x), event.position.y)
			if abs(abs(clicked_pos.x - first_click_pos.x) - ladder.LINE_SPACING) < 0.1:
				ladder.add_horizontal_line(first_click_pos, clicked_pos)
			first_click_pos = Vector2.ZERO

func _on_simulation_started(path: Array) -> void:
	start_animation(path)

func start_animation(path: Array) -> void:
	animation_path = path
	is_animating = true
	animation_time = 0.0
	total_path_length = calculate_total_path_length(path)
	is_start_animating = true
	start_circle_progress = 0.0

func calculate_total_path_length(path: Array) -> float:
	var total: float = 0.0
	for i in range(path.size() - 1):
		var start: Vector2 = Vector2(path[i][0], path[i][1])
		var end: Vector2 = Vector2(path[i + 1][0], path[i + 1][1])
		total += start.distance_to(end)
	return total

func on_middle_anime() -> void:
	if ladder is FTGLadder && ladder.isWin:
		is_end_animating = true
		end_circle_progress = 0.0
	else:
		on_end_anime()

func on_end_anime() -> void:
	if ladder is FTGLadder:
		ladder.on_game_result()
