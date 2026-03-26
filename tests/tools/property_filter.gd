extends GutTest

var filter: PropertyFilter
var node2d := Node2D.new()
var node := Node.new()
var resource := Resource.new()
func after_all():
	for i in [node2d, node]:
		i.free()
		
	

func before_each():
	filter = PropertyFilter.new()

func test_empty_filter() -> void:
	assert_arr_c(
		filter.filter_on(Node2D.new()),
		Node2D.new().get_property_list().map(func(prop_info): return prop_info.name)
	)

func test_declare_filter() -> void:
	filter.declare_whitelist = ["Node2D"]
	assert_arr_c(
		filter.filter_on(node2d),
		ClassUtil.class_get_property_list("Node2D", true).map(func(prop_info): return prop_info.name)
	)
	assert_eq(Array(filter.filter_on(node)), [])

	filter.declare_whitelist = ["+Node2D"]
	assert_arr_c(
		filter.filter_on(node2d),
		ClassUtil.class_get_property_list("Node2D", true).map(func(prop_info): return prop_info.name) + \
		ClassUtil.class_get_property_list("CanvasItem", true).map(func(prop_info): return prop_info.name) + \
		ClassUtil.class_get_property_list("Node", true).map(func(prop_info): return prop_info.name) + \
		ClassUtil.class_get_property_list("Object", true).map(func(prop_info): return prop_info.name)
	)
	assert_eq(Array(filter.filter_on(node)), [])

func test_declare_blacklist_filter() -> void:
	filter.declare_blacklist = ["Node2D"]
	assert_arr_c(
		filter.filter_on(node2d),
		ClassUtil.class_get_property_list("CanvasItem", true).map(func(prop_info): return prop_info.name) + \
		ClassUtil.class_get_property_list("Node", true).map(func(prop_info): return prop_info.name) + \
		ClassUtil.class_get_property_list("Object", true).map(func(prop_info): return prop_info.name) + \
		["CanvasItem", "Node", "Node2D", "script"] ## class is also in get_object_list
	)
	#filter.declare_blacklist = ["+Node2D"]
	#assert_eq(Array(filter.filter_on(node)), [])

func assert_arr_eq(a, b):
	assert_eq(Array(a), Array(b))

func assert_arr_c(a, b):
	a.sort()
	b.sort()
	assert_eq_deep(Array(a), Array(b))
	if Array(a) != Array(b):
		print(a, b)
