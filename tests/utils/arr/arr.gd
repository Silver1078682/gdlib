extends GutTest

func before_all():
	GutTestHelper.coverage(ArrUtil, self)

func test_sum() -> void:
	var arr: Array
	arr = []
	assert_null(ArrUtil.sum(arr))
	arr = [1, 2]
	assert_eq(ArrUtil.sum(arr), 3)
	arr = [-1, -2, -3]
	assert_eq(ArrUtil.sum(arr), -6)
	arr = [1.5, 2.3]
	assert_almost_eq(ArrUtil.sum(arr), 3.8, .0001)
	arr = ["a", "b", "c"]
	assert_eq(ArrUtil.sum(arr), "abc")


func test_mean() -> void:
	var arr: Array
	arr = []
	#ArrUtil.mean(arr)
	arr = [1, 2]
	assert_almost_eq(ArrUtil.mean(arr), 1.5, .0001)
	arr = [-1, -2, -3]
	assert_eq(ArrUtil.mean(arr), -2)
	arr = [1.5, 2.]
	assert_almost_eq(ArrUtil.mean(arr), 1.75, .0001)


func test_repeat() -> void:
	var arr: Array
	arr = []
	assert_eq(ArrUtil.repeat(arr, 3), [])
	arr = [1, 2, 3]
	assert_eq(ArrUtil.repeat(arr, 0), [])
	assert_eq(ArrUtil.repeat(arr, 1), [1, 2, 3])
	assert_eq(ArrUtil.repeat(arr, 2), [1, 2, 3, 1, 2, 3])
	assert_eq(ArrUtil.repeat(arr, -1), [])
	assert_push_error("count should be a positive number.")
	arr = ["a", "b"]
	assert_eq(ArrUtil.repeat(arr, 3), ["a", "b", "a", "b", "a", "b"])


func test_unique() -> void:
	var arr: Array
	arr = []
	assert_eq(ArrUtil.unique(arr), [])
	arr = [1, 2, 3]
	assert_eq(ArrUtil.unique(arr), [1, 2, 3])
	arr = [1, 2, 2]
	assert_eq(ArrUtil.unique(arr), [1, 2])
	arr = ["a", "b", "c"]
	assert_eq(ArrUtil.unique(arr), ["a", "b", "c"])
	arr = ["a", "b", "a"]
	assert_eq(ArrUtil.unique(arr), ["a", "b"])


func test_split() -> void:
	var arr: Array
	arr = []
	ArrUtil.split(arr, -1)
	assert_push_error("step should be a positive number.")
	ArrUtil.split(arr, 0)
	assert_push_error("step should be a positive number.")

	assert_eq(ArrUtil.split(arr, 2), [])
	arr = [1, 2, 3]
	assert_eq(ArrUtil.split(arr, 1), [[1], [2], [3]])
	assert_eq(ArrUtil.split(arr, 2), [[1, 2], [3]])
	arr = [1, 2, 3, 4]
	assert_eq(ArrUtil.split(arr, 2), [[1, 2], [3, 4]])


func test_rand_derange() -> void:
	var arr := range(200)
	var deranged_arr := ArrUtil.rand_derange(arr)
	assert_true(deranged_arr.size() == arr.size())
	for i in range(deranged_arr.size()):
		assert_true(deranged_arr[i] != arr[i])
