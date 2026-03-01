extends GutTest


func test_rect2():
	var rects = [
		Rect2(Vector2(0, 0), Vector2(100, 200)),
		Rect2(Vector2(-100, -100), Vector2(100, 200)),
		Rect2(Vector2(0, 0), Vector2(0, 0)),
	]

	for i in 10:
		for rect: Rect2 in rects:
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
		for rect: Rect2i in rects:
			var point = RandUtil.rect2i(rect)
			if rect.size:
				assert_true(rect.abs().has_point(point))
			else:
				assert_eq(point, rect.position)


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
	assert_true(
		result >= -5 and result <= 5, "Result not between the given values with negative range"
	)
	result = RandUtil.between(Vector3.ZERO, Vector3.ONE)
	assert_true(
		(result.x == result.y) and (result.x == result.z) and result.x >= 0 and result.x <= 1
	)
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


func test_shuffle_bag() -> void:
	const LIST = ["apple", "banana", "peach"]
	_test_shuffle_bag(LIST)
	_test_shuffle_bag(range(100))


func _test_shuffle_bag(list: Array) -> void:
	var bag = RandUtil.shuffle_bag(list)
	for i in range(2):
		var j = bag.next()
		assert_true(j in list)

	bag.refill()
	var k := []
	for i in bag:
		k.append(i)
	k.sort()
	assert_eq(k, list)


func test_bs_wrs() -> void:
	var bs = RandUtil.bs_wrs({"abc": 2, "def": 3})
	var abc_count := 0
	var def_count := 0
	var count = 1000.0
	for i in range(count):
		var j = bs.pick()
		if j == "abc":
			abc_count += 1
		elif j == "def":
			def_count += 1
		else:
			fail_test("Invalid result: %s" % j)
	assert_almost_eq(abc_count / count, 2.0 / 5.0, 0.01)
	assert_almost_eq(def_count / count, 3.0 / 5.0, 0.01)


func test_alias_wrs() -> void:
	var alias = RandUtil.alias_wrs({"abc": 2, "def": 3})
	var abc_count := 0
	var def_count := 0
	var count = 1000.0
	for i in range(count):
		var j = alias.pick()
		if j == "abc":
			abc_count += 1
		elif j == "def":
			def_count += 1
		else:
			fail_test("Invalid result: %s" % j)
	assert_almost_eq(abc_count / count, 2.0 / 5.0, 0.01)
	assert_almost_eq(def_count / count, 3.0 / 5.0, 0.01)


func test_ares_wrs() -> void:
	var dict := {a = 10, b = 5, c = 3, d = 2}
	var item_count := dict.size()

	var unchosen := dict.duplicate()
	var a_res = RandUtil.ares_wrs(dict)

	for i in item_count:
		var choice = a_res.pop()[0]
		assert_true(choice in unchosen)
		unchosen.erase(choice)
	for i in 5:
		var choice := a_res.pop(i)
		assert_eq(choice, [])

	var count: Array[Dictionary] = []
	count.resize(item_count)
	for i in item_count:
		count[i] = {a = 0, b = 0, c = 0, d = 0}
	var count2 = count.duplicate_deep()

	var c := 50000
	for i in c:
		a_res.assign(dict)
		for j in 4:
			var choice = a_res.pop()[0]
			count[j][choice] += 1

	for item in dict:
		assert_almost_eq(count[0][item] / float(c), dict[item] / 20.0, 0.01)

	for i in c:
		a_res.assign(dict)
		var choice = a_res.pop(4)
		for j in 4:
			count2[j][choice[j]] += 1
	for j in 4:
		for item in dict:
			assert_almost_eq(count[j][item] / float(c), count2[j][item] / float(c), 0.01)  ## Should have silmilar result

	for i in 10:
		a_res.assign({a = 0, b = 2, c = 3, d = 4})
		var pop3 := PackedStringArray(a_res.pop(3))
		pop3.sort()
		assert_eq(pop3, PackedStringArray(["b", "c", "d"]))
		assert_eq(a_res.pop(3), [&"a"])
