extends GutTest


func before_all() -> void:
	GutTestHelper.coverage(DictUtil, self)


func test_filter_keys() -> void:
	var dict = {"a": 1, "b": 2, "c": 3}
	var method = func(key: String) -> bool: return key != "b"
	DictUtil.filter_keys(dict, method)
	assert_eq(dict, {"a": 1, "c": 3})

	dict = {}
	method = func(_key: String) -> bool: return true
	DictUtil.filter_keys(dict, method)
	assert_eq(dict, {})
	method = func(_key: String) -> bool: return false
	DictUtil.filter_keys(dict, method)
	assert_eq(dict, {})


func test_filter_items() -> void:
	var dict = {"a": 1, "b": 2, "c": 3}
	var method = func(value: int) -> bool: return value != 2
	DictUtil.filter_values(dict, method)
	assert_eq(dict, {"a": 1, "c": 3})

	dict = {}
	method = func(_value: String) -> bool: return true
	DictUtil.filter_values(dict, method)
	assert_eq(dict, {})
	method = func(_value: String) -> bool: return false
	DictUtil.filter_values(dict, method)
	assert_eq(dict, {})


func test_compose() -> void:
	var keys = ["a", "b", "c"]
	var values = [1, 2, 3]
	var result = DictUtil.compose(keys, values)
	assert_eq(result, {"a": 1, "b": 2, "c": 3})
	keys = ["a", "b"]
	values = [1, 2, 3]
	result = DictUtil.compose(keys, values)
	assert_eq(result, {"a": 1, "b": 2})
	assert_push_warning("Keys and values arrays must be of the same length.")

	keys = ["a", "b"]
	values = [1]
	result = DictUtil.compose(keys, values)
	assert_eq(result, {"a": 1})
	assert_push_warning("Keys and values arrays must be of the same length.")


func test_reverse() -> void:
	var dict = {"a": 1, "b": 2, "c": 3}
	var reversed_dict = DictUtil.reverse(dict)
	assert_eq(reversed_dict, {1: "a", 2: "b", 3: "c"})

	dict = {}
	reversed_dict = DictUtil.reverse(dict)
	assert_eq(reversed_dict, {})
