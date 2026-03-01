class_name ArrUtil
## Provides a set of utility functions for working with arrays.

const FOUR_DIRECTIONS_2D = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const SIX_DIRECTIONS_3D = [
	Vector3i.LEFT, Vector3i.RIGHT, Vector3i.UP, Vector3i.DOWN, Vector3i.FORWARD, Vector3i.BACK
]


## Returns the sum of an array
static func sum(arr: Array) -> Variant:
	return arr.reduce(func(a, b): return a + b)


## Returns the mean value of an array
## Returns an empty array when arr is empty
static func mean(arr: Array) -> Variant:
	return arr.reduce(func(a, b): return a + b) / float(arr.size()) if arr else []


## Repeats this arr a number of times. count needs to be greater than 0.
## Otherwise, returns an empty string.
static func repeat(arr: Array, count: int) -> Variant:
	if count < 0:
		push_error("Parameter count should be a positive number.")
		return []
	var result := []
	for i in count:
		result += arr
	return result


## Drops duplicate elements in an array, using dictionary.
static func unique(arr: Array) -> Array:
	var dict := {}
	for i in arr:
		dict[i] = null
	return dict.keys()


## Returns a derangement of the [param arr].[br]
## i.e shuffle the array but any element won't stay at its previous position.
static func rand_derange(arr: Array) -> Array:
	var size := arr.size()
	var idx_arr := range(size)
	var result := idx_arr.duplicate()
	idx_arr.shuffle()
	for i in size:
		result[idx_arr[i]] = arr[idx_arr[i - 1]]
	return result


## Splits the array with given step
## [codeblock]
## [1, 2, 3, 4, 5].split(2) # Returns [[1, 2], [3, 4], [5]]
## [].split(2) # Returns []
## [/codeblock]
static func split(arr: Array, step: int) -> Array[Array]:
	var result: Array[Array] = []
	if step <= 0:
		push_error("Parameter step should be a positive number.")
		return result
	for i in range(0, arr.size(), step):
		result.append(arr.slice(i, i + step))
	return result


## Returns a nested matrix with any dimension.
## [param size] is an array of int that defines the dimension of the matrix,
## non-positive number is not allowed in [param size] and return undefined result
## an empty array with the desired type can be passed as [param typed_arr] optionally.
## [codeblock]
## var arr: Array[int] = []
## var matrix := ArrUtil.matrix([4, 2, 6, 3], 0, arr)
## print(matrix.size())			# 3
## print(matrix[2][5].size())	# 2
## print(matrix[2][5][0])		# [0, 0, 0, 0] (typed as an Array[int])
## [/codeblock]
static func matrix(size: Array, default: Variant, typed_arr: Array = []) -> Array[Array]:
	if size.size() < 2:
		push_error("A matrix must be at least 2 dimensional")
		return [[]]
	size = Array(size, TYPE_INT, "", null)
	var one := typed_arr.duplicate()  # Yes, it's okay to pass a non-empty array, but considering performance, just don't do that.
	one.resize(size[0])
	one.fill(default)
	var empty: Array[Array] = []
	var larger = empty.duplicate()
	var smaller := one
	for d in range(1, size.size()):
		for j in size[d]:
			larger.append(smaller.duplicate(true))
		smaller = larger
		larger = empty.duplicate()
	return smaller


## Same as [method matrix], but only accept Vector2i as [param size] and only return 2D matrices.
## to access an element at coordinate (x,y), use matrix[y][x].
static func matrix2d(size: Vector2i, default: Variant, typed_arr: Array = []) -> Array[Array]:
	var result: Array[Array] = []
	for y in size.y:
		var child := typed_arr.duplicate()
		child.resize(size.x)
		child.fill(default)
		result.append(child)
	return result
