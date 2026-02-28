extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dict := [
		{"a":1, "b":2, "c":3}
	]
	for i in dict:
		print_rich("[color=orange]Dictionary\n", JSON.stringify(i, "\t"), "[/color]")
		print_rich("[color=green]---construct---[/color]")
		_compare("alias", RandUtil.alias_wrs,"bs", RandUtil.bs_wrs, [i])
		var al := RandUtil.alias_wrs(i)
		var bs := RandUtil.bs_wrs(i)
		print_rich("[color=green]---sample---[/color]")
		_compare("alias", al.pick,"bs", bs.pick, [])


func _benchmark(method: Callable, count: int, args) -> int:
	var a := Time.get_ticks_usec()
	for i in count:
		method.callv(args)
	var b := Time.get_ticks_usec()
	return b - a

func _compare(na:String,a: Callable,nb:String, b: Callable, args: Array, count := [50, 100, 2000]):
	print_rich("[b]",na,"[/b]")
	for c in count:
		prints(c,"cost" ,_benchmark(a, c, args), "usec")
	print_rich("[b]",nb,"[/b]")
	for c in count:
		prints(c,"cost" ,_benchmark(b, c, args), "usec")
	await get_tree().process_frame

	
