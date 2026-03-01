@icon("res://path/to/optional/icon.svg")
class_name __ClassTestScript__

# Inheritance:
extends __ClassTestScriptBase__

# Member variables.
var a1 = 5
var s1 = "Hello"
var arr1 = [1, 2, 3]
var dict1 = {"key": "value", 2: 3}
var other_dict1 = {key = "value", other_key = 2}
var typed_var1: int
var inferred_type1 := "String"

# Constants.
const NEW_ANSWER = 42

# Enums.
enum { FIRE, WATER, WIND }
enum Named1 { THING_1, THING_2, ANOTHER_THING = -1 }

var v21 = Vector2(1, 2)
var v31 = Vector3(1, 2, 3)


# Function, with a default value for the last parameter.
func some_function(param1, param2, param3 = 123):
	const local_const = 5

	if param1 < local_const:
		print(param1)
	elif param2 > 5:
		print(param2)
	else:
		print("Fail!")

	for i in range(20):
		print(i)

	while param2 != 0:
		param2 -= 1

	match param3:
		3:
			print("param3 is 3!")
		_:
			print("param3 is not 3!")

	var local_var = param1 + 3
	return local_var


# Functions override functions with the same name on the base/super class.
# If you still want to call them, use "super":
func something(p1, p2):
	super(p1, p2)


# Inner class
class Something:
	var a = 9


class SomethingElse:
	var a = 9


# Constructor
func _init():
	print("Constructed!")
	var lv = Something.new()
	print(lv.a)
