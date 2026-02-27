@tool
class_name MyClass
extends EditorScript

static func can_instantiate(bar: bool):
	return bar

static func get_base_script(foo: bool):
	return foo


func _run():
	print(MyClass.can_instantiate(false))
	print(MyClass.get_base_script(false))
