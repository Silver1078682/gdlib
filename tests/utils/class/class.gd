extends GutTest

const __ClassTestUnnamedScript__ = preload("uid://cswlfufiy0n3u")

var node2d = ["Node2D", Node2D, Node2D.new()]
var base = [__ClassTestScriptBase__, "__ClassTestScriptBase__"]
var test = [__ClassTestScript__, "__ClassTestScript__", __ClassTestScript__.new()]
var unnamed = [__ClassTestUnnamedScript__, __ClassTestUnnamedScript__.new()]
var unnamed_child = [
	__ClassTestUnnamedScriptChild__,
	"__ClassTestUnnamedScriptChild__",
	__ClassTestUnnamedScriptChild__.new(),
]
var undefined = ["__NonExistentClass__", "__ClassTestUnnamedScript__"]


func before_all():
	GutTestHelper.coverage(ClassUtil, self )

func test_get_class_list() -> void:
	var class_list = ClassUtil.get_class_list()
	for i in ClassDB.get_class_list():
		assert_true(i in class_list)
	for i in ProjectSettings.get_global_class_list():
		assert_true(i["class"] in class_list)

func test_query_class() -> void:
	assert_true(ClassUtil.query_class("ClassUtil") is Script)
	for i in node2d:
		assert_true(ClassUtil.query_class(i) is StringName)
	for i in base + test + unnamed + unnamed_child:
		assert_true(ClassUtil.query_class(i) is Script)
	for i in undefined:
		assert_null(ClassUtil.query_class(i))

func test_inherits_from() -> void:
	assert_true(ClassUtil.inherits_from(ClassUtil, "Object"))
	assert_false(ClassUtil.inherits_from(Object, "ClassUtil"))
	assert_true(ClassUtil.inherits_from(Node.new(), "Object"))
	assert_true(ClassUtil.inherits_from(Node.new(), "Node"))

	assert_true(ClassUtil.inherits_from(__ClassTestScript__.new(), "Node"))
	assert_true(ClassUtil.inherits_from(__ClassTestScript__.new(), Node))
	for i in base + test:
		assert_true(ClassUtil.inherits_from(__ClassTestScript__.new(), i))

func test_class_exists() -> void:
	for i in node2d + base + test + unnamed + unnamed_child:
		assert_true(ClassUtil.class_exists(i))
	for i in undefined:
		assert_false(ClassUtil.class_exists(i))

func test_get_parent_class() -> void:
	for i in node2d:
		assert_eq(ClassUtil.get_parent_class(i), &"CanvasItem")
	for i in base:
		assert_eq(ClassUtil.get_parent_class(i), &"Node")
	for i in test:
		assert_eq(ClassUtil.get_parent_class(i), &"__ClassTestScriptBase__")
	for i in unnamed:
		assert_eq(ClassUtil.get_parent_class(i), &"Node")
	for i in unnamed_child:
		assert_eq(ClassUtil.get_parent_class(i), &"")

func test_get_ancestry_classes() -> void:
	for i in node2d:
		assert_arr_eq(ClassUtil.get_ancestry_classes(i), ["Object", "Node", "CanvasItem"])
	for i in base:
		assert_arr_eq(ClassUtil.get_ancestry_classes(i), ["Object", "Node"])
	for i in test:
		assert_arr_eq(ClassUtil.get_ancestry_classes(i), [ "Object", "Node", "__ClassTestScriptBase__",])
	for i in unnamed:
		assert_arr_eq(ClassUtil.get_ancestry_classes(i), ["Object", "Node", ])
	for i in unnamed_child:
		assert_arr_eq(ClassUtil.get_ancestry_classes(i), ["Object", "Node","",   ])


func test_can_class_instantiate() -> void:
	for i in ClassDB.get_class_list():
		if not ClassDB.can_instantiate(i):
			assert_false(ClassUtil.can_class_instantiate(i))
		else:
			assert_true(ClassUtil.can_class_instantiate(i))

	for i in node2d + base + test + unnamed + unnamed_child:
		assert_true(ClassUtil.can_class_instantiate(i))
	var cnt = 0
	for i in undefined:
		cnt += 1
		assert_false(ClassUtil.can_class_instantiate(i))
		assert_push_warning_count(cnt)


func test_class_call_static() -> void:
	DirAccess.open("res://tests/non-existent-test")
	assert_eq(ClassUtil.class_call_static("DirAccess", &"get_open_error"), ERR_INVALID_PARAMETER)
	ClassUtil.class_call_static("Engine", &"is_editor_hint") # This is not a static function
	assert_engine_error_count(1)

	for i in base:
		assert_eq(ClassUtil.class_call_static(i, &"sum", 1, 2, 3), 6)
	#for i in unnamed:
	#assert_eq(ClassUtil.class_call_static(i, &"multiply", 1, 2, 3), 6)
	for i in unnamed_child:
		assert_eq(ClassUtil.class_call_static(i, &"mean", 1, 2, 3), 2)

	var cnt = 0
	for i in unnamed_child + undefined:
		cnt += 1
		assert_null(ClassUtil.class_call_static(i, &"multiply", 1, 2, 3))
		assert_push_warning_count(cnt)
	for i in base:
		cnt += 1
		assert_null(ClassUtil.class_call_static(i, &"no-existent-function", 1, 2, 3))
		assert_push_warning_count(cnt)


func test_class_get_constant_names() -> void:
	var a = ClassUtil.class_get_constant_names("Object")
	var b = ClassUtil.class_get_constant_names("ClassUtil")
	var c = ClassUtil.class_get_constant_names("Node")
	var d = ClassUtil.class_get_constant_names("__ClassTestScriptBase__")
	var e = ClassUtil.class_get_constant_names("__ClassTestScript__")

	var o = (
		ClassDB.class_get_enum_list("Object") + ClassDB.class_get_integer_constant_list("Object")
	)
	var n = (
		ClassDB.class_get_enum_list("Node", true)
		+ ClassDB.class_get_integer_constant_list("Node", true)
	)
	var dd = PackedStringArray((__ClassTestScriptBase__ as Script).get_script_constant_map().keys())
	var ee = PackedStringArray((__ClassTestScript__ as Script).get_script_constant_map().keys())

	assert_arr_c(a, o)
	assert_arr_c(b, o)
	assert_arr_c(c, n + o)
	assert_arr_c(d, dd + n + o)
	assert_arr_c(e, ee + dd + n + o)

	a = ClassUtil.class_get_constant_names("Object", true)
	b = ClassUtil.class_get_constant_names("ClassUtil", true)
	c = ClassUtil.class_get_constant_names("Node", true)
	d = ClassUtil.class_get_constant_names("__ClassTestScriptBase__", true)
	e = ClassUtil.class_get_constant_names("__ClassTestScript__", true)

	assert_arr_c(a, o)
	assert_arr_c(b, [])
	assert_arr_c(c, n)
	assert_arr_c(d, dd)
	assert_arr_c(e, ee)


func assert_arr_eq(a, b):
	assert_eq(Array(a), Array(b))

func assert_arr_c(a, b):
	a.sort()
	b.sort()
	assert_eq(Array(a), Array(b))
	if Array(a) != Array(b):
		print(a, b)
