extends Node2D
class_name Ladder

signal line_added(start_pos: Vector2, end_pos: Vector2)
signal simulation_started(path: Array)

const LINE_NUM: int = 5
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
		
		if (abs(x1 - x3) < 0.1 and abs(x2 - x4) < 0.1) or \
		   (abs(x1 - x4) < 0.1 and abs(x2 - x3) < 0.1):
			var min_y_new = min(y1, y2)
			var max_y_new = max(y1, y2)
			var min_y_existing = min(y3, y4)
			var max_y_existing = max(y3, y4)
			
			if max_y_new > min_y_existing and min_y_new < max_y_existing:
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

func add_random_line() -> void:
	var rng = RandomNumberGenerator.new()
	var vertical_idx: int = rng.randi_range(0, len(vertical_lines) - 2)
	var x1 = vertical_lines[vertical_idx]
	var y1 = TOP_MARGIN + rng.randf() * (get_viewport_rect().size.y - TOP_MARGIN - BOTTOM_MARGIN)
	var x2 = vertical_lines[vertical_idx + 1]
	var y2 = TOP_MARGIN + rng.randf() * (get_viewport_rect().size.y - TOP_MARGIN - BOTTOM_MARGIN)
	
	# 끝점 근처 체크를 위한 최소 거리
	const MIN_ENDPOINT_DISTANCE: float = 50.0
	
	# 기존 선들의 끝점과의 거리 체크
	for line in horizontal_lines:
		# 왼쪽 끝점과의 거리 체크
		if abs(x1 - line[0]) < 0.1 && abs(y1 - line[1]) < MIN_ENDPOINT_DISTANCE:
			add_random_line()
			return
			
		# 오른쪽 끝점과의 거리 체크
		if abs(x2 - line[2]) < 0.1 && abs(y2 - line[3]) < MIN_ENDPOINT_DISTANCE:
			add_random_line()
			return
	
	# 기존 교차 체크
	if check_cross([x1, y1, x2, y2]):
		add_random_line()
	else:
		add_horizontal_line(Vector2(x1, y1), Vector2(x2, y2))
