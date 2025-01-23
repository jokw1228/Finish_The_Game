extends Node2D

# 상수 정의
const LINE_BASE = 100
const LINE_SPACING = 100  # 세로선 간격
const LINE_NUM = 5

const TOP_MARGIN = 50    # 상단 여백
const BOTTOM_MARGIN = 50 # 하단 여백

const CLICK_MAGNET_LIMIT = LINE_BASE * .2

const ANIMATION_DURATION = 2.0  # 전체 애니메이션 시간

# 변수 정의
var vertical_lines = []   # 세로선 x좌표 저장
var horizontal_lines = [] # 가로선 정보 저장 [x1, y1, x2, y2]
var first_click_pos = null

var current_mouse_pos = Vector2.ZERO
var nearest_vertical_pos = Vector2.ZERO

var animation_path = []
var is_animating = false
var animation_time = 0.0
var total_path_length = 0.0

func _ready():
	# 세로선 초기 위치 설정 (예: 5개의 세로선)
	for i in range(LINE_NUM):
		vertical_lines.append(LINE_BASE + i * LINE_SPACING)
	
	# 디버그 출력으로 세로선 위치 확인
	#print("Vertical lines positions: ", vertical_lines)

func _process(_delta):
	# 마우스 위치 업데이트
	var mouse_pos = get_viewport().get_mouse_position()
	current_mouse_pos = mouse_pos
	# 가장 가까운 세로선의 x 좌표 찾기
	var nearest_x = find_nearest_vertical(mouse_pos.x, CLICK_MAGNET_LIMIT)
	
	nearest_vertical_pos = Vector2(nearest_x, mouse_pos.y) if nearest_x else null
	# 화면 갱신
	if is_animating:
		animation_time += _delta
		if animation_time >= ANIMATION_DURATION:
			is_animating = false
			animation_time = ANIMATION_DURATION
	queue_redraw()


func _draw():
	# 기존 선 그리기
	for x in vertical_lines:
		draw_line(Vector2(x, TOP_MARGIN), 
				 Vector2(x, get_viewport_rect().size.y - BOTTOM_MARGIN), 
				 Color.SKY_BLUE, 
				 4.0)
	
	for line in horizontal_lines:
		draw_line(Vector2(line[0], line[1]), 
				 Vector2(line[2], line[3]), 
				 Color.YELLOW, 
				 4.0)
	# 애니메이션 중인 경로 그리기
	if is_animating and animation_path.size() > 1:
		var progress = animation_time / ANIMATION_DURATION
		var current_length = 0.0
		var target_length = total_path_length * progress
		
		for i in range(animation_path.size() - 1):
			var start = Vector2(animation_path[i][0], animation_path[i][1])
			var end = Vector2(animation_path[i + 1][0], animation_path[i + 1][1])
			var segment_length = start.distance_to(end)
			
			if current_length + segment_length <= target_length:
				# 전체 선분 그리기
				draw_line(start, end, Color.RED, 10.0)
				current_length += segment_length
			elif current_length < target_length:
				# 부분 선분 그리기
				var remaining = target_length - current_length
				var t = remaining / segment_length
				var partial_end = start.lerp(end, t)
				draw_line(start, partial_end, Color.RED, 10.0)
				break
	
	if nearest_vertical_pos:
		draw_circle(nearest_vertical_pos, 8.0, Color.RED)
	
	if first_click_pos:
		draw_circle(first_click_pos, 8.0, Color.CORAL)
		
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !nearest_vertical_pos:
			first_click_pos = null
		elif nearest_vertical_pos.y < TOP_MARGIN:
			draw_simulation(nearest_vertical_pos.x)
		elif !first_click_pos:
			first_click_pos = nearest_vertical_pos
		else:
			# 같은 열 클릭 방지
			if abs(event.position.y - first_click_pos.y) > .1:  # 최소 거리 체크
				add_horizontal_line(first_click_pos, event.position)
			first_click_pos = null
			
func draw_simulation(start_x):
	var path = simulate_path(start_x)
	start_animation(path)
	
func start_animation(path):
	animation_path = path
	is_animating = true
	animation_time = 0.0
	total_path_length = calculate_total_path_length(path)

func calculate_total_path_length(path):
	var total = 0.0
	for i in range(path.size() - 1):
		var start = Vector2(path[i][0], path[i][1])
		var end = Vector2(path[i + 1][0], path[i + 1][1])
		total += start.distance_to(end)
	return total
	
func add_horizontal_line(start_pos, end_pos):
	var start_x = find_nearest_vertical(start_pos.x)
	var end_x = find_nearest_vertical(end_pos.x)
	
	# 같은 x 좌표여도 선을 그리도록 수정
	horizontal_lines.append([start_x, start_pos.y, end_x, end_pos.y])
	queue_redraw()

func find_nearest_vertical(x, limit_dist = INF):
	var nearest = null
	var min_dist = INF
	
	for line_x in vertical_lines:
		var dist = abs(x - line_x)
		if dist < min_dist && dist < limit_dist:
			min_dist = dist
			nearest = line_x
	return nearest

func simulate_path(start_x):
	var current_x = start_x
	var current_y = TOP_MARGIN
	var path = [[current_x, current_y]]
	var copy_horizontal_lines = horizontal_lines + []
	
	var st = -1
	var ed = -1
	
	while current_y < get_viewport_rect().size.y - BOTTOM_MARGIN:
		# 현재 위치에서 가로선 찾기
		for line in copy_horizontal_lines:
			if abs(line[0] - current_x) + abs(line[1] - current_y) < 5:  # 허용 오차
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
