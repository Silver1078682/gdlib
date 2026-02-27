class_name ClassUtil
## A helper to static analyze and manipulate Built-in and user-defined classes with ease.
##
## This class provide a uniform interface for classes in ClassDB (built-in and GD-extention)
## and Script-defined classes (those with class_name)
## You can pass one of the following as the class_id parameter in class_* methods[br]
## -String, the name of a built-in class or script-defined class[br]
## -Script, the script as a custom class[br]
## -Object, an object that extends from the class to be analyzed[br]

# Returns the names of all engine classes available.
static func get_class_list() -> PackedStringArray:
	return ClassDB.get_class_list() + \
	PackedStringArray(ProjectSettings.get_global_class_list().map(func(class_info): return class_info["class"]))


## Returns whether the specified class with [param name] is available or not.
static func class_exists(class_id: Variant) -> bool:
	return query_class(class_id) != null


## Returns true if objects can be instantiated from the specified class otherwise returns false.
static func can_class_instantiate(class_id: Variant) -> bool:
	var result = query_class(class_id)
	if result is StringName:
		return ClassDB.can_instantiate(result)
	if result is Script:
		var script: Script = result
		return script.can_instantiate()
	push_warning("Invalid class ID provided")
	return false


## Calls a static method on a class.
## Due to the restriction, class without a global name does not work with this function
static func class_call_static(class_id: Variant, method_name: StringName, ...args: Array) -> Variant:
	var result = query_class(class_id)
	if result is StringName:
		return ClassDB.class_call_static.callv([result, method_name] + args)
	if result is Script:
		var script: Script = result
		var method := Callable(script, method_name)
		if not method.is_valid():
			push_warning("method named %s not found" % method_name)
			return null
		return method.callv(args)
	push_warning("Invalid class ID provided")
	return null


## Returns the API type of the specified class.
static func class_get_api_type(class_id: Variant) -> ClassDB.APIType:
	var result = query_class(class_id)
	if result is StringName:
		return ClassDB.class_get_api_type(result)
	if result is Script:
		return ClassDB.APIType.API_NONE
	push_warning("Invalid class ID provided")
	return ClassDB.APIType.API_NONE


## Returns an array with all the keys in enum of class or its ancestry.
static func class_get_constant_names(
		class_id: Variant,
		no_inheritance: bool = false,
) -> PackedStringArray:
	return _class_get_recursively(
		class_id,
		func(db_name: StringName) -> PackedStringArray:
			return ClassDB.class_get_enum_list(db_name, no_inheritance) + ClassDB.class_get_integer_constant_list(db_name, no_inheritance),
		func(script: Script) -> PackedStringArray:
			return PackedStringArray(script.get_script_constant_map().keys()),
		func(a: PackedStringArray, b: PackedStringArray) -> PackedStringArray:
			return a + b,
		no_inheritance,
	)


## Returns this object's methods and their signatures as an Array of dictionaries, or its ancestry if no_inheritance is false.
## Each Dictionary contains the following entries:
## - name is the name of the method, as a String
## - args is an Array of dictionaries representing the arguments
## - default_args is the default arguments as an Array of variants
## - flags is a combination of MethodFlags
## - id is the method's internal identifier int
## - return is the returned value, as a Dictionary with following keys: class_name, hint, hint_string, name, type, usage.
## Note: The dictionaries of args and return are formatted identically to the results of get_property_list(),
## although not all entries are used.
## Note: In exported release builds the debug info from ClassDB is not available,
## so the returned dictionaries will contain only method names.
static func class_get_method_list(class_id: Variant, no_inheritance: bool = false) -> Array[Dictionary]:
	return _class_get_recursively(
		class_id,
		func(db_name: StringName) -> Array[Dictionary]:
			return ClassDB.class_get_method_list(db_name),
		func(script: Script) -> Array[Dictionary]:
			return script.get_script_method_list(),
		func(a: Array[Dictionary], b: Array[Dictionary]) -> Array[Dictionary]:
			return a + b,
		no_inheritance,
	)


## Returns the default value of property of class or its ancestor classes.
static func class_get_property_default_value(class_id: Variant, property: StringName) -> Variant:
	var result = query_class(class_id)
	if result is StringName:
		return ClassDB.class_get_property_default_value(result, property)
	if result is Script:
		var script: Script = result
		return script.get_property_default_value(property)
	push_warning("Invalid class ID provided")
	return null


## Returns the property list of class as an Array of dictionaries, or its ancestry if no_inheritance is false.
## Each Dictionary contains the following entries:[br]
## - name is the property's name, as a String[br]
## - class_name is an empty StringName, unless the property is TYPE_OBJECT and it inherits from a class[br]
## - type is the property's type, as an int (see Variant.Type)[br]
## - hint is how the property is meant to be edited (see PropertyHint)[br]
## - hint_string depends on the hint (see PropertyHint)[br]
## - usage is a combination of PropertyUsageFlags.[br]
## Note: In GDScript, all class members are treated as properties. In C# and GDExtension, it may be necessary to explicitly mark class members as Godot properties using decorators or attributes.
static func class_get_property_list(class_id: Variant, no_inheritance: bool = false) -> Array[Dictionary]:
	return _class_get_recursively(
		class_id,
		func(db_name: StringName) -> Array[Dictionary]:
			return ClassDB.class_get_property_list(class_id, no_inheritance),
		func(script: Script) -> Array[Dictionary]:
			return script.get_script_property_list(),
		func(a: Array[Dictionary], b: Array[Dictionary]) -> Array[Dictionary]:
			return a + b,
		no_inheritance,
	)


## Returns the list of existing signals as an Array of dictionaries, or its ancestry if no_inheritance is false.
## Every element of the array is a Dictionary as described in class_get_signal().
static func class_get_signal_list(class_id: Variant, no_inheritance: bool = false) -> Array[Dictionary]:
	return _class_get_recursively(
		class_id,
		func(db_name: StringName) -> Array[Dictionary]:
			return ClassDB.class_get_signal_list(class_id, no_inheritance),
		func(script: Script) -> Array[Dictionary]:
			return script.get_script_signal_list(),
		func(a: Array[Dictionary], b: Array[Dictionary]) -> Array[Dictionary]:
			return a + b,
		no_inheritance,
	)


static func get_parent_class(class_id: Variant) -> StringName:
	var result = query_class(class_id)
	if result is StringName:
		return ClassDB.get_parent_class(result)
	if result is Script:
		var script: Script = result
		var parent_script := script.get_base_script()
		return parent_script.get_global_name() if parent_script else parent_script.get_instance_base_type()
	push_warning("Invalid class ID provided")
	return ""


## Creates an instance of class.
static func instantiate(class_id: Variant) -> Variant:
	var result = query_class(class_id)
	if result is StringName:
		return ClassDB.instantiate(result)
	if result is Script:
		var script: Script = result
		return script.new()
	push_warning("Invalid class ID provided")
	return []


static func _class_get_recursively(
		class_id: Variant,
		class_db_method: Callable,
		custom_script_method: Callable,
		reduce_method: Callable,
		no_inheritance: bool,
		fallback = [],
) -> Variant:
	var result = query_class(class_id)
	if result is StringName:
		return class_db_method.call(result)
	if result is Script:
		var script: Script = result
		var parent: Script = script.get_base_script()
		var accumulated_result = custom_script_method.call(script)
		if no_inheritance:
			return accumulated_result

		while parent:
			script = parent
			parent = parent.get_base_script()
			accumulated_result = reduce_method.call(accumulated_result, custom_script_method.call(script))
		return reduce_method.call(accumulated_result, class_db_method.call(script.get_instance_base_type()))

	push_warning("Invalid class ID provided")
	return fallback


## Query the type of a class by class_id.
## Class id can extends from String, Script or Object
## Returns the name of built-in classes or the attached Script of a script-defined class
## Returns null an illegal argument is passed
static func query_class(class_id: Variant) -> Variant:
	if class_id is String or class_id is StringName:
		if ClassDB.class_exists(class_id):
			return StringName(class_id)
		if class_id in _cache_hash_map:
			return _cache_hash_map[class_id]
		for custom_class in ProjectSettings.get_global_class_list():
			# cache the query result
			# otherwise we have to iterate all registered global classes every time.
			if StringName(class_id) == custom_class["class"]:
				_cache_hash_map[class_id] = (load(custom_class["path"]) as Script)
				return _cache_hash_map[class_id]
		return null
	if class_id is Script:
		return class_id
	if class_id is Object:
		var script = class_id.get_script()
		return (script as Script) if script else (class_id.get_class() as StringName)
	return null


static var _cache_hash_map: Dictionary[String, Script]
