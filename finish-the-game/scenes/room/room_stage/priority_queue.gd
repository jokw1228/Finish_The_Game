extends Node
class_name PriorityQueue

var _top: int = -1
var _pq: Array = []

func _ready() -> void:
	pass

func insert_array(items: Array, keys: Array) -> void:
	for i in range(items.size()):
		self.insert(items[i],keys[i])

func insert(item, key) -> void:
	_pq.append([item,key])
	_top += 1
	if _top == 0:
		return
	var _current = _top
	var _parent
	while true:
		_parent = (_current-1) / 2
		if _pq[_current][1] < _pq[_parent][1]:
			var temp = _pq[_current]
			_pq[_current] = _pq[_parent]
			_pq[_parent] = temp
			_current = _parent
			if _current == 0:
				break
		else:
			break

func pop():
	if _top == -1:
		print('Queue is empty.')
		return
	var _item = _pq[0]#.duplicate(true)
	if _top == 0:
		_top -= 1
		_pq.pop_back()
		return _item
	_pq[0] = _pq.pop_back()
	_top -= 1
	var _current = 0
	#var _left_child
	#var _right_child
	var mn
	while true:
		if _current * 2 + 2 <= _top:
			#_right_child = _pq[_current*2+2]
			#_left_child = _pq[_current*2+1]
			if _pq[_current*2+2][1] < _pq[_current*2+1][1]:
				if _pq[_current*2+2][1] < _pq[_current][1]:
					var _temp = _pq[_current]
					_pq[_current] = _pq[_current*2+2]
					_pq[_current*2+2] = _temp
					_current = _current * 2 + 2
					#print("right_smallest",_pq)
			elif _pq[_current*2+1][1] < _pq[_current*2+2][1]:
				if _pq[_current*2+1][1] < _pq[_current][1]:
					var _temp = _pq[_current]
					_pq[_current] = _pq[_current*2+1]
					_pq[_current*2+1] = _temp
					_current = _current * 2 + 1
					#print("left_smallest",_pq)
			else:
				break
		elif _current * 2 + 1 == _top:
			#_left_child = _pq[_current*2+1]
			if _pq[_current*2+1][1] < _pq[_current][1]:
				var _temp = _pq[_current]
				_pq[_current] = _pq[_current*2+1]
				_pq[_current*2+1] = _temp
				_current = _current * 2 + 1
				#print("only_left_smallest",_pq)
			else:
				break
		else:
			break
	return _item

func get_size() -> int:
	return _top + 1

func get_list() -> Array:
	return _pq
