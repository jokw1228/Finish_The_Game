extends Node2D
class_name Ladder

signal line_added(start_pos: Vector2, end_pos: Vector2)
signal simulation_started(path: Array)

var LINE_NUM: int = 5  # 기본값은 5로 설정
const TOP_MARGIN: int = 300    # 상단 여백
const BOTTOM_MARGIN: int = 300 # 하단 여백

var LINE_BASE: float
var LINE_SPACING: float # 세로선 간격

var start_idx: int = -1
var end_idx: int = -1

var vertical_lines: Array = []   # 세로선 x좌표 저장
var horizontal_lines: Array = [] # 가로선 정보 저장 [x1, y1, x2, y2]

func _ready() -> void:
	pass
	
func init() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	#position = Vector2(0, 0)
	
	LINE_SPACING = viewport_size.x / (LINE_NUM + 1)  
	LINE_BASE = LINE_SPACING
	
	for i in range(LINE_NUM):
		vertical_lines.append(LINE_BASE + i * LINE_SPACING)

func add_horizontal_line(start_pos: Vector2, end_pos: Vector2) -> void:
	var start_x: float = find_nearest_vertical(start_pos.x)
	var end_x: float = find_nearest_vertical(end_pos.x)
	if not check_cross([start_x, start_pos.y, end_x, end_pos.y]):
		horizontal_lines.append([start_x, start_pos.y, end_x, end_pos.y])
		emit_signal("line_added", start_pos, end_pos)

func find_nearest_vertical(x: float, limit_dist: float = INF) -> float:
	var nearest: float = INF
	var min_dist: float = INF
	
	for line_x in vertical_lines:
		var dist: float = abs(x - line_x)
		if dist < min_dist and dist < limit_dist:
			min_dist = dist
			nearest = line_x
	return nearest

func ccw(p1x: float, p1y: float, p2x: float, p2y: float, p3x: float, p3y: float) -> float:
	return (p2x - p1x) * (p3y - p1y) - (p3x - p1x) * (p2y - p1y)
	
func check_cross(line: Array) -> bool:
	var x1: float = line[0]
	var y1: float = line[1]
	var x2: float = line[2]
	var y2: float = line[3]
	
	for existing_line in horizontal_lines:
		var x3: float = existing_line[0]
		var y3: float = existing_line[1]
		var x4: float = existing_line[2]
		var y4: float = existing_line[3]
		
		# 같은 세로선 쌍 사이의 선인지 먼저 확인
		if abs(min(x1, x2) - min(x3, x4)) < 0.1 and abs(max(x1, x2) - max(x3, x4)) < 0.1:
			var ab_c = ccw(x1, y1, x2, y2, x3, y3)
			var ab_d = ccw(x1, y1, x2, y2, x4, y4)
			var cd_a = ccw(x3, y3, x4, y4, x1, y1)
			var cd_b = ccw(x3, y3, x4, y4, x2, y2)
			
			# 두 선분이 교차하는지 확인
			if ab_c * ab_d <= 0 and cd_a * cd_b <= 0:
				return true
	
	return false

func check_win() -> bool:
	var start_x = vertical_lines[start_idx]
	var end_x = vertical_lines[end_idx]
	
	var path = simulate_path(start_x)
	var isWin = abs(path[-1][0] - end_x) < 0.1
	emit_signal("simulation_started", path)
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
	
func get_valid_y() -> float:
	var rng = RandomNumberGenerator.new()
	const EXTRA_MARGIN: float = 100.0
	var y = (TOP_MARGIN + EXTRA_MARGIN) + rng.randf() * (get_viewport_rect().size.y - TOP_MARGIN - BOTTOM_MARGIN - EXTRA_MARGIN * 2)
	return y

func add_random_line() -> void:
	var rng = RandomNumberGenerator.new()
	var vertical_idx: int = rng.randi_range(0, len(vertical_lines) - 2)
	var x1 = vertical_lines[vertical_idx]
	var x2 = vertical_lines[vertical_idx + 1]
	
	# 끝점 근처 체크를 위한 최소 거리
	const MIN_ENDPOINT_DISTANCE: float = 100.0

	# y1과 y2를 각각 유효한 값이 나올 때까지 재시도
	var y1 = get_valid_y()
	var y2 = get_valid_y()
	var retry_count = 0
	const MAX_RETRIES = 10  # 무한 루프 방지
	
	while retry_count < MAX_RETRIES:
		var need_retry = false
		
		# y1 검증
		for line in horizontal_lines:
			if abs(x1 - line[0]) < 0.1 && abs(y1 - line[1]) < MIN_ENDPOINT_DISTANCE:
				y1 = get_valid_y()
				need_retry = true
				break
		
		# y2 검증
		for line in horizontal_lines:
			if abs(x2 - line[2]) < 0.1 && abs(y2 - line[3]) < MIN_ENDPOINT_DISTANCE:
				y2 = get_valid_y()
				need_retry = true
				break
		
		if !need_retry:
			break
			
		retry_count += 1
	
	# 기존 교차 체크
	if check_cross([x1, y1, x2, y2]):
		add_random_line()
	else:
		add_horizontal_line(Vector2(x1, y1), Vector2(x2, y2))  
