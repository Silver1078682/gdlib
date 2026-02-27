extends GutTest


func test_rect2():
	var rects = [
		Rect2(Vector2(0, 0), Vector2(100, 200)),
		Rect2(Vector2(-100, -100), Vector2(100, 200)),
		Rect2(Vector2(0, 0), Vector2(0, 0)),
	]

	for i in 10:
		for rect:Rect2 in rects:
			var point = RandUtil.rect2(rect)
			if rect.size:
				assert_true(rect.abs().has_point(point))
			else:
				assert_eq(point, rect.position)

func test_rect2i():
	var rects = [
		Rect2i(Vector2i(0, 0), Vector2i(100, 200)),
		Rect2i(Vector2i(-100, -100), Vector2i(100, 200)),
		Rect2i(Vector2i(0, 0), Vector2i(0, 0)),
	]
	for i in 10:
		for rect in rects:
			var point = RandUtil.rect2i(rect)
			assert_true(rect.has_point(point))

func test_child_of():
	var parent = Node.new()
	for i in 100:
		parent.add_child(Node.new())
	var result = RandUtil.child_of(parent)
	assert_true(result.get_parent() == parent, "Did not return a child node")

	var parent2 = Node.new()
	result = RandUtil.child_of(parent2)
	assert_true(result == null, "Did not return null when no children")


func test_element():
	var arr = [1, 2, 3, 4, 5]
	var result = RandUtil.element(arr)
	assert_true(arr.has(result), "Did not return an element from the array")

	var string = "abc"
	var str_result = RandUtil.element(string)
	assert_true(str_result in string, "Did not return an element from the string")

	var packed_arr = PackedVector3Array([Vector3.ONE, Vector3(2, 2, 2)])
	var packed_result = RandUtil.element(packed_arr)
	assert_true(packed_arr.has(packed_result), "Did not return an element from the packed array")

	var empty = []
	result = RandUtil.element(empty)
	assert_true(result == null, "Did not return null when array is empty")
	assert_push_error("Cannot pick")


func test_between():
	var result = RandUtil.between(0, 10)
	assert_true(result >= 0 and result <= 10, "Result not between the given values")
	result = RandUtil.between(-5, 5)
	assert_true(result >= -5 and result <= 5, "Result not between the given values with negative range")
	result = RandUtil.between(Vector3.ZERO, Vector3.ONE)
	assert_true((result.x == result.y) and (result.x ==  result.z) and result.x >= 0 and result.x <= 1 )
	result = RandUtil.between(0, 0)
	assert_true(result == 0, "Result not equal to the given value when both values are equal")


func test_circle():
	var arr := PackedVector2Array()
	for i in 5000:
		var point = RandUtil.circle(10)
		assert_true(point.distance_to(Vector2(0, 0)) <= 10, "Point not inside the circle")
		arr.append(point)


func test_triangle():
	var a = Vector2(0, 0)
	var b = Vector2(1, 0)
	var c = Vector2(0, 1)
	var point = RandUtil.triangle(a, b, c)
	assert_true(point.distance_to(Vector2(0.5, 0.5)) < 0.5, "Point not inside the triangle")
	

func test_string():
	var result = RandUtil.string(5, "abc")
	assert_true(result.length() == 5, "String length is incorrect")
	for char in result:
		assert_true(char in "abc", "String contains invalid character")
	

# Add similar test functions for all other static methods
# func test_shuffle_bag() -> void:
# 	pass
# func test_bs_wrs() -> void:
# 	pass
# func test_ares_wrs() -> void:
# 	pass
# func test_alias_wrs() -> void:
# 	pass
