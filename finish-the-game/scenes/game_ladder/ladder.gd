extends Node2D
class_name Ladder

signal line_added(start_pos: Vector2, end_pos: Vector2)
signal simulation_started(path: Array)

var LINE_NUM: int = 5  # 기본값은 5로 설정
const TOP_MARGIN: int = 300    # 상단 여백
const BOTTOM_MARGIN: int = 300 # 하단 여백

const MIN_ENDPOINT_DISTANCE: float = 50.0

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

func get_valid_ranges(x1: float, x2: float) -> Array:
	# 1. 유효한 y좌표의 전체 범위 설정
	const EXTRA_MARGIN: float = 100.0
	var min_y = TOP_MARGIN + EXTRA_MARGIN
	var max_y = get_viewport_rect().size.y - BOTTOM_MARGIN - EXTRA_MARGIN
	
	# 2. 현재 세로선에 연결된 모든 가로선의 y좌표 수집
	var forbidden_ranges = []
	for line in horizontal_lines:
		# x1 위치의 endpoint 체크 (양쪽 끝점 모두)
		if abs(line[0] - x1) < 0.1 or abs(line[2] - x1) < 0.1:
			# 왼쪽 끝점이 x1에 있는 경우
			if abs(line[0] - x1) < 0.1:
				forbidden_ranges.append([
					line[1] - MIN_ENDPOINT_DISTANCE,
					line[1] + MIN_ENDPOINT_DISTANCE
				])
			# 오른쪽 끝점이 x1에 있는 경우
			if abs(line[2] - x1) < 0.1:
				forbidden_ranges.append([
					line[3] - MIN_ENDPOINT_DISTANCE,
					line[3] + MIN_ENDPOINT_DISTANCE
				])
				
		# x2 위치의 endpoint 체크 (양쪽 끝점 모두)
		if abs(line[0] - x2) < 0.1 or abs(line[2] - x2) < 0.1:
			# 왼쪽 끝점이 x2에 있는 경우
			if abs(line[0] - x2) < 0.1:
				forbidden_ranges.append([
					line[1] - MIN_ENDPOINT_DISTANCE,
					line[1] + MIN_ENDPOINT_DISTANCE
				])
			# 오른쪽 끝점이 x2에 있는 경우
			if abs(line[2] - x2) < 0.1:
				forbidden_ranges.append([
					line[3] - MIN_ENDPOINT_DISTANCE,
					line[3] + MIN_ENDPOINT_DISTANCE
				])
	
	# 3. 금지 구간을 y좌표 순으로 정렬
	forbidden_ranges.sort_custom(func(a, b): return a[0] < b[0])
	
	# 4. 유효한 구간들 수집
	var valid_ranges = []
	var current_min = min_y
	
	for range in forbidden_ranges:
		if range[0] > current_min:
			valid_ranges.append([current_min, range[0]])
		current_min = max(current_min, range[1])
	
	if current_min < max_y:
		valid_ranges.append([current_min, max_y])
	
	return valid_ranges
	
func get_valid_y_from_ranges(valid_ranges: Array) -> float:
	var rng = RandomNumberGenerator.new()
	
	# 전체 유효 길이 계산
	var total_valid_length = 0.0
	for range in valid_ranges:
		total_valid_length += range[1] - range[0]
	
	# 랜덤 위치 선택
	var random_point = rng.randf() * total_valid_length
	
	# 실제 y좌표로 변환
	var accumulated_length = 0.0
	for range in valid_ranges:
		var range_length = range[1] - range[0]
		if accumulated_length + range_length > random_point:
			return range[0] + (random_point - accumulated_length)
		accumulated_length += range_length
	
	return valid_ranges[-1][1]

func add_random_line() -> void:
	var rng = RandomNumberGenerator.new()
	var indices = range(len(vertical_lines) - 1)
	# 인덱스들을 랜덤하게 섞음
	indices.shuffle()
	
	# 모든 가능한 세로선 쌍에 대해 시도
	for i in indices:
		var x1 = vertical_lines[i]
		var x2 = vertical_lines[i + 1]
		
		# 각 세로선에 대한 유효 범위 계산
		var valid_ranges = get_valid_ranges(x1, x2)
		
		# 유효 범위가 있는 경우에만 진행
		if not valid_ranges.is_empty():
			var y1 = get_valid_y_from_ranges(valid_ranges)
			var y2 = get_valid_y_from_ranges(valid_ranges)
			
			# 교차 검사
			if not check_cross([x1, y1, x2, y2]):
				add_horizontal_line(Vector2(x1, y1), Vector2(x2, y2))
				return
	
	# 만약 모든 세로선 쌍에 대해 실패하면
	print("No valid position found for new horizontal line")
