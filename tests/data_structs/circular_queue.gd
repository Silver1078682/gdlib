extends GutTest


func before_all():
	GutTestHelper.coverage(CircularQueue, self)


var circular: CircularQueue


func before_each() -> void:
	circular = CircularQueue.new()


func test_is_empty() -> void:
	assert_true(circular.is_empty())
	assert_true(circular.size() == 0)


func test_is_full() -> void:
	assert_true(circular.is_full())
	circular = CircularQueue.new(1)
	assert_false(circular.is_full())
	circular.push_back(1)
	assert_true(circular.is_full())


func test_front() -> void:
	assert_null(circular.front())
	assert_push_error_count(1)


func test_back() -> void:
	assert_null(circular.back())
	assert_push_error_count(1)


func test_one() -> void:
	circular = CircularQueue.new(10)
	circular.push_back(1)
	assert_false(circular.is_empty())
	assert_eq(circular.front(), 1)
	assert_eq(circular.back(), 1)


func test_size() -> void:
	assert_eq(circular.size(), 0)
	circular = CircularQueue.new(10)
	assert_eq(circular.size(), 0)
	for i in 10:
		circular.push_back(i)
		assert_eq(circular.size(), i + 1)


func test_push_back() -> void:
	circular = CircularQueue.new(10)
	assert(circular.is_empty())
	for i in range(10):
		circular.push_back(i)
		assert_eq(circular.front(), 0)
		assert_eq(circular.back(), i)
		assert_eq(circular.size(), i + 1)
		assert_push_error_count(0)
	circular.push_back(10)
	assert_true(circular.is_full())
	assert_push_error_count(1)


func test_pop_front() -> void:
	circular = CircularQueue.new(10)
	assert(circular.is_empty())
	for i in range(10):
		circular.push_back(i)
	for i in range(10):
		assert_eq(circular.front(), i)
		assert_eq(circular.back(), 9)
		assert_eq(circular.size(), 10 - i)
		assert_eq(circular.pop_front(), i)
		assert_push_error_count(0)
	circular.pop_front()
	assert_push_error_count(1)


func test_clear() -> void:
	circular = CircularQueue.new(10)
	for i in range(10):
		circular.push_back(i)
		assert_eq(circular.front(), 0)
		assert_eq(circular.back(), i)
		assert_eq(circular.size(), i + 1)
	circular.clear()
	assert_true(circular.is_empty())
	assert_true(circular.size() == 0)
	assert_push_error_count(0)
	assert_null(circular.pop_front())
	assert_push_error_count(1)


func test_get_at() -> void:
	circular = CircularQueue.new(10)
	# Test getting elements from the queue
	circular.push_back(1)
	circular.push_back(2)
	circular.push_back(3)

	# Test getting front element
	assert_eq(circular.get_at(0), 1)
	# Test getting back element
	assert_eq(circular.get_at(-1), 3)
	# Test getting middle element
	assert_eq(circular.get_at(1), 2)

	# Test out-of-bounds access
	assert_eq(circular.get_at(-4), null)
	assert_eq(circular.get_at(3), null)
	assert_push_error_count(2)


func test_typed_queue() -> void:
	var typed_arr: Array[int] = [1, 2, 3]
	circular = CircularQueue.new(4, typed_arr)
	assert_eq(circular.size(), 3)
	assert_eq(circular.get_at(0), 1)
	assert_eq(circular.get_at(-1), 3)

	# Test pushing a string to a typed queue
	circular.push_back("string")  # Should fail because the queue
	assert_engine_error_count(2)

	# Test pushing an int to a typed queue
	circular.push_back(4)
	assert_true(circular.is_full())
	assert_eq(circular.size(), 4)
	assert_eq(circular.get_at(0), 1)
	assert_eq(circular.get_at(-1), 4)


func test_to_array() -> void:
	circular = CircularQueue.new(10)
	assert_true(circular.is_empty())
	assert_eq(circular.size(), 0)
	assert_true(circular.to_array().is_empty())
	for i in 10:
		circular.push_back(i)
		assert_eq(circular.to_array(), range(i + 1))
	assert_true(circular.to_array().size() == 10)
	for i in 10:
		circular.pop_front()
		assert_eq(circular.to_array(), range(i + 1, 10))
	assert_true(circular.to_array().is_empty())
