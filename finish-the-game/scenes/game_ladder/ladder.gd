extends Node2D
class_name Ladder

# 상수 정의
const LINE_NUM: int = 5

const LINE_THICKNESS: float = 12
const ANIME_LINE_THICKNESS: float = LINE_THICKNESS * 1.5
const CIRCLE_SIZE: float = 8
const POS_CIRCLE_SIZE: float = 20

const TOP_MARGIN: int = 300    # 상단 여백
const BOTTOM_MARGIN: int = 300 # 하단 여백

const ANIMATION_DURATION: float = 2.0  # 전체 애니메이션 시간
const CIRCLE_ANIMATION_DURATION: float = 0.2

# 색깔들
const LINE_COLOR: Color = Color.SKY_BLUE
const MAGNET_COLOR: Color = Color.GRAY
const CHECK_COLOR: Color = Color.RED
const ANIME_COLOR: Color = Color.RED

# 변수 정의
var LINE_BASE: float
var LINE_SPACING: float # 세로선 간격

var CLICK_MAGNET_LIMIT: float

var start_idx: int = -1
var end_idx: int = -1

var vertical_lines: Array = []   # 세로선 x좌표 저장
var horizontal_lines: Array = [] # 가로선 정보 저장 [x1, y1, x2, y2]
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

func _ready() -> void:
	pass
	
func init() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	
	# 화면 중앙으로 position 설정
	#position = Vector2(-viewport_size.x / 2, -viewport_size.y / 2)
	position = Vector2(0, 0)
	
	# 기존 로직 유지
	LINE_SPACING = viewport_size.x / (LINE_NUM + 1)  
	LINE_BASE = LINE_SPACING
	
	CLICK_MAGNET_LIMIT = LINE_BASE * 0.3
	
	for i in range(LINE_NUM):
		vertical_lines.append(LINE_BASE + i * LINE_SPACING)

func _process(_delta: float) -> void:
	# 마우스 위치 업데이트
	var mouse_pos: Vector2 = convert_to_local(get_viewport().get_mouse_position())
	current_mouse_pos = mouse_pos
	# 가장 가까운 세로선의 x 좌표 찾기
	var nearest_x: float = find_nearest_vertical(mouse_pos.x, CLICK_MAGNET_LIMIT)
	
	nearest_vertical_pos = Vector2(nearest_x, mouse_pos.y) if nearest_x else Vector2.ZERO
	
	# 시작 원 애니메이션 업데이트
	if is_start_animating:
		start_circle_progress += _delta / CIRCLE_ANIMATION_DURATION
		if start_circle_progress >= 1.0:
			start_circle_progress = 1.0
			is_start_animating = false
	
	# 끝 원 애니메이션 업데이트
	if is_end_animating:
		end_circle_progress += _delta / CIRCLE_ANIMATION_DURATION
		if end_circle_progress >= 1.0:
			end_circle_progress = 1.0
			is_end_animating = false
			on_end_anime()
	
	# 메인 애니메이션 업데이트
	if is_animating:
		animation_time += _delta
		if animation_time >= ANIMATION_DURATION:
			is_animating = false
			animation_time = ANIMATION_DURATION
			on_middle_anime()
	queue_redraw()

func _draw() -> void:
	# 기존 선 그리기
	for x in vertical_lines:
		draw_line(Vector2(x, TOP_MARGIN), 
				 Vector2(x, get_viewport_rect().size.y - BOTTOM_MARGIN), 
				 LINE_COLOR, 
				 LINE_THICKNESS)
	
	for line in horizontal_lines:
		draw_line(Vector2(line[0], line[1]), 
				 Vector2(line[2], line[3]), 
				 LINE_COLOR, 
				 LINE_THICKNESS)
	
	# 애니메이션 중인 경로 그리기
	if is_animating || animation_path.size() > 1:
		var progress: float = animation_time / ANIMATION_DURATION
		var current_length: float = 0.0
		var target_length: float = total_path_length * progress
		
		for i in range(animation_path.size() - 1):
			var start: Vector2 = Vector2(animation_path[i][0], animation_path[i][1])
			var end: Vector2 = Vector2(animation_path[i + 1][0], animation_path[i + 1][1])
			var segment_length: float = start.distance_to(end)
			
			if current_length + segment_length <= target_length:
				# 전체 선분 그리기
				draw_line(start, end, ANIME_COLOR, ANIME_LINE_THICKNESS)
				current_length += segment_length
			elif current_length < target_length:
				# 부분 선분 그리기
				var remaining: float = target_length - current_length
				var t: float = remaining / segment_length
				var partial_end: Vector2 = start.lerp(end, t)
				draw_line(start, partial_end, ANIME_COLOR, ANIME_LINE_THICKNESS)
				break

	if start_idx != -1:
		# 시작 위치 원 그리기 (테두리)
		draw_circle(Vector2(vertical_lines[start_idx], TOP_MARGIN), POS_CIRCLE_SIZE, LINE_COLOR)
		# 시작 위치 원 채우기 애니메이션
		if is_start_animating or start_circle_progress > 0:
			var radius = POS_CIRCLE_SIZE * start_circle_progress
			draw_circle(Vector2(vertical_lines[start_idx], TOP_MARGIN), radius, ANIME_COLOR)
			
	if end_idx != -1:
		# 끝 위치 원 그리기 (테두리)
		draw_circle(Vector2(vertical_lines[end_idx], get_viewport_rect().size.y - BOTTOM_MARGIN), POS_CIRCLE_SIZE, LINE_COLOR)
		# 끝 위치 원 채우기 애니메이션
		if is_end_animating or end_circle_progress > 0:
			var radius = POS_CIRCLE_SIZE * end_circle_progress
			draw_circle(Vector2(vertical_lines[end_idx], get_viewport_rect().size.y - BOTTOM_MARGIN), radius, ANIME_COLOR)
	
	if nearest_vertical_pos:
		draw_circle(nearest_vertical_pos, CIRCLE_SIZE, MAGNET_COLOR)
	
	if first_click_pos:
		draw_circle(first_click_pos, CIRCLE_SIZE, CHECK_COLOR)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 마우스 위치를 로컬 좌표로 변환
		var local_pos = convert_to_local(event.position)
		
		if !nearest_vertical_pos:
			first_click_pos = Vector2.ZERO
		elif nearest_vertical_pos.y < TOP_MARGIN:
			draw_simulation(nearest_vertical_pos.x)
		elif first_click_pos == Vector2.ZERO:
			first_click_pos = nearest_vertical_pos
		else:
			# 같은 열 클릭 방지
			var clicked_pos = Vector2(find_nearest_vertical(local_pos.x), local_pos.y)
			if abs(abs(clicked_pos.x - first_click_pos.x) - LINE_SPACING) < 0.1 && !check_cross([first_click_pos.x, first_click_pos.y, clicked_pos.x, clicked_pos.y]):
				add_horizontal_line(first_click_pos, clicked_pos)
			first_click_pos = Vector2.ZERO

func convert_to_local(global_pos: Vector2) -> Vector2:
	return global_pos
	#return global_pos - position

func draw_simulation(start_x: float) -> void:
	var path: Array = simulate_path(start_x)
	start_animation(path)
	
func start_animation(path: Array) -> void:
	animation_path = path
	is_animating = true
	animation_time = 0.0
	total_path_length = calculate_total_path_length(path)
	# 시작 원 애니메이션 시작
	is_start_animating = true
	start_circle_progress = 0.0

func on_middle_anime() -> void:
	# 끝 원 애니메이션 시작
	is_end_animating = true
	end_circle_progress = 0.0

func on_end_anime() -> void:
	pass

func calculate_total_path_length(path: Array) -> float:
	var total: float = 0.0
	for i in range(path.size() - 1):
		var start: Vector2 = Vector2(path[i][0], path[i][1])
		var end: Vector2 = Vector2(path[i + 1][0], path[i + 1][1])
		total += start.distance_to(end)
	return total

func add_random_line() -> void:
	var rng = RandomNumberGenerator.new()
	var vertical_idx: int = rng.randi_range(0, len(vertical_lines) - 2)
	var x1 = vertical_lines[vertical_idx]
	var y1 = TOP_MARGIN + rng.randf() * (get_viewport_rect().size.y - TOP_MARGIN - BOTTOM_MARGIN)
	var x2 = vertical_lines[vertical_idx + 1]
	var y2 = TOP_MARGIN + rng.randf() * (get_viewport_rect().size.y - TOP_MARGIN - BOTTOM_MARGIN)
	if check_cross([x1, y1, x2, y2]):
		add_random_line() # 반복
	else:
		add_horizontal_line(Vector2(x1, y1), Vector2(x2, y2))

func check_cross(line: Array) -> bool:
	# Get coordinates of the new line
	var x1: float = line[0]
	var y1: float = line[1]
	var x2: float = line[2]
	var y2: float = line[3]
	
	# Check intersection with each existing line
	for existing_line in horizontal_lines:
		var x3: float = existing_line[0]
		var y3: float = existing_line[1]
		var x4: float = existing_line[2]
		var y4: float = existing_line[3]
		
		# Check if lines share a vertical line (same x coordinates)
		if (abs(x1 - x3) < 0.1 and abs(x2 - x4) < 0.1) or \
		   (abs(x1 - x4) < 0.1 and abs(x2 - x3) < 0.1):
			# Check if y-ranges overlap
			var min_y_new = min(y1, y2)
			var max_y_new = max(y1, y2)
			var min_y_existing = min(y3, y4)
			var max_y_existing = max(y3, y4)
			
			if max_y_new > min_y_existing and min_y_new < max_y_existing:
				return true
	
	return false

func add_horizontal_line(start_pos: Vector2, end_pos: Vector2) -> void:
	var start_x: float = find_nearest_vertical(start_pos.x)
	var end_x: float = find_nearest_vertical(end_pos.x)
	
	horizontal_lines.append([start_x, start_pos.y, end_x, end_pos.y])
	queue_redraw()

func find_nearest_vertical(x: float, limit_dist: float = INF) -> float:
	var nearest: float = INF
	var min_dist: float = INF
	
	for line_x in vertical_lines:
		var dist: float = abs(x - line_x)
		if dist < min_dist and dist < limit_dist:
			min_dist = dist
			nearest = line_x
	return nearest

func check_win() -> bool:
	var start_x = vertical_lines[start_idx]
	var end_x = vertical_lines[end_idx]
	
	var path = simulate_path(start_x)
	var isWin = abs(path[-1][0] - end_x) < 0.1
	start_animation(path)
	return isWin
	
func simulate_path(start_x: float) -> Array:
	var current_x: float = start_x
	var current_y: float = TOP_MARGIN
	var path: Array = [[current_x, current_y]]
	var copy_horizontal_lines = horizontal_lines + []
	
	var st = -1
	var ed = -1
	
	while current_y < get_viewport_rect().size.y - BOTTOM_MARGIN:
		for line in copy_horizontal_lines:
			if abs(line[0] - current_x) + abs(line[1] - current_y) < 5:
				st = 0
				ed = 2
			elif abs(line[2] - current_x) + abs(line[3] - current_y) < 5:
				st = 2
				ed = 0
			else:
				st = -1
				ed = -1
			if st != -1:
				path.append([line[st], line[st + 1]])
				path.append([line[ed], line[ed + 1]])
				copy_horizontal_lines.erase(line)
				current_x = line[ed]
				current_y = line[ed + 1]
		current_y += 1
	path.append([current_x, current_y])
	return path
