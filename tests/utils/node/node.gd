extends GutTest

var root: Node
var child: Node2D
var grandchild: Node2D
var sibling: Node2D
var material: CanvasItemMaterial
var conflict: Node


func before_all():
	var window := get_node("/root")
	var test_root := Node.new()
	test_root.name = "Test"
	window.add_child(test_root)
	root = test_root


func before_each():
	child = Node2D.new()
	child.name = "Child"
	root.add_child(child)

	grandchild = Node2D.new()
	grandchild.name = "GrandChild"
	material = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	grandchild.material = material
	child.add_child(grandchild)

	sibling = Node2D.new()
	sibling.name = "Sibling"
	root.add_child(sibling)

	conflict = Node.new()
	conflict.name = "position"
	child.add_child(conflict)


func after_each():
	NodeUtil.free_children(root)
	await NodeUtil.ensure_children_freed(root)


func test_get_from_nodepath() -> void:
	assert_nodepath(root, ^"Child", child)
	assert_nodepath(root, ^"Child/GrandChild", grandchild)

	assert_nodepath(child, ^":name", "Child")
	assert_nodepath(child, ^":position", Vector2.ZERO)
	assert_nodepath(child, ^":position:x", 0.0)

	assert_nodepath(root, ^"Child:name", "Child")

	assert_nodepath(root, ^"Child/GrandChild:name", "GrandChild")
	assert_nodepath(root, ^"Child/GrandChild:position:x", 0.0)
	assert_nodepath(root, ^"Child/GrandChild:material", material)
	assert_nodepath(root, ^"Child/GrandChild:material:blend_mode", material.BLEND_MODE_ADD)

	assert_nodepath(child, ^"position", conflict)
	assert_nodepath(child, ^":position", Vector2.ZERO)


func test_get_from_nodepath_failure() -> void:
	assert_nodepath(root, ^"", root)
	assert_engine_error_count(2)
	assert_nodepath_null(root, ^"12")
	assert_push_error("can not find")
	assert_nodepath_null(root, ^"@")
	assert_push_error("can not find")

	assert_nodepath_null(root, ^"NotAChild")
	assert_push_error("can not find")
	assert_nodepath_null(root, ^"Child/NotAGrandChild")
	assert_push_error("can not find")
	assert_nodepath_null(root, ^"NotAChild/GrandChild")
	assert_push_error("can not find")
	assert_nodepath_null(root, ^"NotAChild/NotAGrandChild")
	assert_push_error("can not find")

	assert_nodepath_null(child, ^":not_a_prop")
	assert_nodepath_null(child, ^":not_a_prop:x")
	assert_nodepath_null(child, ^":position:z")


func assert_nodepath(a, b, c):
	assert_eq(NodeUtil.get_from_nodepath(a, b), c)


func assert_nodepath_null(a, b):
	assert_null(NodeUtil.get_from_nodepath(a, b))


func test_get_descendants():
	assert_eq(NodeUtil.get_descendants(root), [child, grandchild, conflict, sibling])
	assert_eq(NodeUtil.get_descendants(child), [grandchild, conflict])
	assert_eq(NodeUtil.get_descendants(conflict), [])
	assert_eq(NodeUtil.get_descendants(grandchild), [])


func test_ensure_ready() -> void:
	var a := Node.new()
	get_tree().process_frame.connect(root.add_child.bind(a), CONNECT_ONE_SHOT)
	assert_false(a.is_node_ready())
	await NodeUtil.ensure_ready(a)
	assert_true(a.is_node_ready())


func test_set_parent_of():
	var b = Node.new()
	root.add_child(b)
	NodeUtil.set_parent_of(child, b)
	assert_eq(child.get_parent(), b)
	NodeUtil.set_parent_of(child, root)
	assert_eq(child.get_parent(), root)
	NodeUtil.set_parent_of(child, root)
	assert_eq(child.get_parent(), root)

	var c = Node.new()
	root.add_child(c)
	NodeUtil.set_parent_of(c, root)
	assert_eq(c.get_parent(), root)
	NodeUtil.set_parent_of(c, null)
	assert_push_error("Invalid parent provided.")
	NodeUtil.set_parent_of(null, null)
	assert_push_error("Invalid node provided.")
	NodeUtil.set_parent_of(null, c)
	assert_push_error("Invalid node provided.")


func test_free_children() -> void:
	for i in 100:
		var a = Node.new()
		root.add_child(a)
	var parent := root
	for i in 100:
		var a = Node.new()
		parent.add_child(a)
		parent = a

	NodeUtil.free_children(root)
	for i in root.get_children():
		assert_true(i.is_queued_for_deletion())

	await NodeUtil.ensure_children_freed(root)
	assert_eq(root.get_child_count(), 0)
