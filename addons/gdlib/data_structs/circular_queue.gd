class_name CircularQueue
extends RefCounted
## A circular queue implementation using an array.
##
## Basic usage:
## [codeblock]
## var queue := CircularQueue.new(10)
## queue.push_back(1) # O(1) enqueue
## var a = queue.pop_front() # O(1) dequeue
## [/codeblock]
## You can also pass an initial array to the constructor to initialize the queue from an array
## [codeblock]
## var queue := CircularQueue.new(3, [1, 2, 3])
## var typed_arr: Array[int]
## var typed_queue := CircularQueue.new(3, typed_arr) # Initialize queue with typed array
## queue.push_back("string")
## typed_queue.push_back("string, but in a 'typed queue'") # Raises an error
## [/codeblock]

## The _capacity of the queue
var _capacity: int = 0
var _head: int = 0
var _size: int = 0
var _datas: Array


## Returns true if the array is empty ([]). See also [method is_full].
func is_empty():
	return _size == 0


## Returns true if the array is full (size == capacity). also [method is_empty].
func is_full():
	return _size == _capacity


## Returns the number of elements in the array. Empty arrays ([]) always return 0.
func size():
	return _size


## Removes and returns the first element of the queue. Returns null if the queue is empty. See also [method push_back].
func pop_front() -> Variant:
	if _size == 0:
		push_error("Can not call pop front on an empty array")
		return null
	_head += 1
	_head = _head % _capacity
	_size -= 1
	return _datas[_head - 1]


## Appends an element at the end of the queue. See also [method pop_front].
func push_back(value: Variant) -> void:
	if _size == _capacity:
		push_error("Can not call push back on a full array")
		return
	var _tail = (_head + _size) % _capacity
	_datas[_tail] = value
	if is_same(_datas[_tail], value): # Ensure the value modification succeed
		_size += 1


## Returns the first element of the queue. If the queue is empty, fails and returns null. See also [method back].
func front() -> Variant:
	if _size != 0:
		return _datas[_head]
	push_error("Can't take value from empty array.")
	return null


## Returns the last element of the queue. If the queue is empty, fails and returns null. See also [method front].
func back() -> Variant:
	if _size != 0:
		return _datas[(_head + _size - 1) % _capacity]
	push_error("Can't take value from empty array.")
	return null


## Clears the queue.
func clear() -> void:
	if _size == 0:
		return
	_size = 0


## Returns the Variant element at the specified index. Arrays start at index 0.
## If index is greater or equal to 0, the element is fetched starting from the beginning of the array.
## If index is a negative value, the element is fetched starting from the end.
## Accessing an array out-of-bounds will fails.
func get_at(index: int) -> Variant:
	if index < -_size or index >= _size:
		push_error('Out of bound gets index "%d"' % index)
		return
	return _datas[(_head + posmod(index, _size)) % _capacity]


## Returns the array representation of the circular queue.
## The array is ordered from the front to the back.
func to_array() -> Array:
	return _datas.slice(_head, _head + _size) + _datas.slice(0, max(0, _head + _size - _capacity))


func _init(p_capacity: int = 0, typed_arr := []) -> void:
	if p_capacity:
		_capacity = p_capacity
	if typed_arr or typed_arr.is_typed():
		_datas = typed_arr
		_size = min(typed_arr.size(), _capacity)
	_datas.resize(_capacity)
