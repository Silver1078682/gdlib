extends Node2D
## Weighted Random Sampling benchmark
## (Alias VS BinarySearch)
## Alias: Slower construction, Faster sampling
## BinarySearch: Faster construction, Slower Sampling

var _construct_result: Array
var _sample_result: Array

const ALIAS_NAME = "Alias"
const BINARY_SEARCH_NAME = "Binary Search"

const INT_DICT = { "a": 1, "b": 2, "c": 3 }
const FLOAT_DICT = { "a": 1.0, "b": 2.0, "c": 3.0 }
const LARGE_FLOAT_DICT = {
	"a1": 1.0,
	"b1": 2.0,
	"c1": 3.0,
	"a2": 1.1,
	"b2": 2.1,
	"c2": 3.1,
	"a3": 1.2,
	"b3": 2.2,
	"c3": 3.2,
	"a4": 1.3,
	"b4": 2.3,
	"c4": 3.3,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dicts := [INT_DICT, FLOAT_DICT, LARGE_FLOAT_DICT]
	for dict in dicts:
		print_rich("[color=orange]Dictionary\n", JSON.stringify(dict, "\t"), "[/color]")

		print_rich("[color=green]---construct---[/color]")
		_construct_result = await _compare(
			ALIAS_NAME,
			RandUtil.alias_wrs,
			BINARY_SEARCH_NAME,
			RandUtil.bs_wrs,
			[dict],
		)

		var al := RandUtil.alias_wrs(dict)
		var bs := RandUtil.bs_wrs(dict)
		print_rich("[color=green]---sample---[/color]")
		_sample_result = await _compare(
			ALIAS_NAME,
			al.pick,
			BINARY_SEARCH_NAME,
			bs.pick,
			[],
		)

	queue_redraw()


const TEST_COUNT = 10000
const PERF_FORMAT = "cost %d usec"


func _compare(na: String, a: Callable, nb: String, b: Callable, args: Array):
	var perf: int
	var ans: Array[int]
	print_rich("[b]", na, "[/b]")
	perf = _benchmark(a, TEST_COUNT, args)
	prints(PERF_FORMAT % perf)
	ans.append(perf)

	print_rich("[b]", nb, "[/b]")
	perf = _benchmark(b, TEST_COUNT, args)
	prints(PERF_FORMAT % perf)
	ans.append(perf)

	await get_tree().process_frame
	return ans


func _benchmark(method: Callable, count: int, args: Array) -> int:
	var a := Time.get_ticks_usec()
	for i in count:
		method.callv(args)
	var b := Time.get_ticks_usec()
	return b - a


func _draw() -> void:
	draw_grid()
	draw_axis()
	draw_results()


const GRID_SIZE = 50
const GRID_COUNT = 20


func draw_axis():
	draw_line(Vector2.UP * 1000, Vector2.DOWN * 1000, Color.GREEN)
	draw_line(Vector2.LEFT * 1000, Vector2.RIGHT * 1000, Color.RED)


func draw_grid():
	var polylines := []
	for i in range(-GRID_COUNT, GRID_COUNT):
		polylines.append(GRID_SIZE * Vector2i(i, -100))
		polylines.append(GRID_SIZE * Vector2i(i, +100))
		polylines.append(GRID_SIZE * Vector2i(-100, i))
		polylines.append(GRID_SIZE * Vector2i(+100, i))
	draw_polyline(polylines, Color.GRAY)


func draw_results():
	if not (_construct_result and _sample_result):
		return
	draw_one_result(0, Color.AQUA, ALIAS_NAME)
	draw_one_result(1, Color.ORANGE, BINARY_SEARCH_NAME)


func draw_one_result(idx: int, color: Color, algo_name: String):
	var k: int = _sample_result[idx]
	var b: int = _construct_result[idx]
	var dire := Vector2(TEST_COUNT, -k)
	var y_axis = Vector2(0, -b / float(TEST_COUNT)) * GRID_SIZE
	draw_line(
		+dire + y_axis,
		-dire + y_axis,
		color,
	)
	var font = SystemFont.new()
	draw_string(font, dire / 100. + y_axis, algo_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, color)
