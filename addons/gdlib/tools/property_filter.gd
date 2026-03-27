class_name PropertyFilter
extends Resource

## Only properties declared by classes in this array will be included.
## You can also add a + prefix to also include properties declared by its ancestry classes.
## If set empty, properties declared by any classes will be included.
## [codeblock]
## declare_whitelist = [] # properties from any classes will be included.
## declare_whitelist = ["Node2D"] # properties from Node2D will be included.
## declare_whitelist = ["+Node2D"] # properties from Node2D, CanvasItem, Node, Object will be included.
## declare_blacklist = ["+Node"] # Now only properties from Node2D, CanvasItem will be excluded.
## [/codeblock]
## [b]Note:[/b] filter won't be applied if the target object does not derives from the classes in this array.
@export var declare_whitelist: PackedStringArray = []
## Properties declared by classes in this array will be filtered out.
## see [member declare_whitelist] for more details.
@export var declare_blacklist: PackedStringArray = []

@export var extends_whitelist: PackedStringArray = []
@export var extends_blacklist: PackedStringArray = []

@export var name_pattern_whitelist: PackedStringArray = []
@export var name_pattern_blacklist: PackedStringArray = []


func filter_on(object: Object) -> PackedStringArray:
	var declare_filter_list := parse_declare_filter(object)
	var object_list := object.get_property_list()
	var result: PackedStringArray = []
	for prop_info in object_list:  # name, class_name, type
		if not match_rule(
			name_pattern_whitelist,
			name_pattern_blacklist,
			prop_info,
			func(pattern: String, prop_info: Dictionary):
				return match_regex(pattern, prop_info.name)
		):
			continue

		if declare_whitelist:
			if prop_info.name not in declare_filter_list:
				continue
		elif prop_info.name in declare_filter_list:
			continue

		if prop_info.type == TYPE_OBJECT:
			if not match_rule(
				extends_whitelist,
				extends_blacklist,
				prop_info,
				func(class_id: String, prop_info: Dictionary):
					return class_id == prop_info.class_name
			):
				continue
		result.append(prop_info.name)
	return result


func parse_declare_filter(object: Object) -> Dictionary:
	var class_name_list := {}
	var result := {}
	var _parse_list = func(list: PackedStringArray, method: Callable):
		for i in list:
			var ancestry := false
			if i.begins_with("+"):
				i = i.trim_prefix("+")
				ancestry = true
			if not ClassUtil.inherits_from(object, i):
				continue
			method.call(i)
			if ancestry:
				for ancestor in ClassUtil.get_ancestry_classes(i):
					method.call(ancestor)
	if declare_whitelist:
		_parse_list.call(declare_whitelist, Callable.create(class_name_list, "set").bind(null))
		_parse_list.call(declare_blacklist, Callable.create(class_name_list, "erase"))
	else:
		_parse_list.call(declare_blacklist, Callable.create(class_name_list, "set").bind(null))

	for name in class_name_list:
		for prop_info in ClassUtil.class_get_property_list(name, true):
			result[prop_info.name] = null
	return result


func match_rule(
	whitelist: Array, blacklist: Array, prop_info: Dictionary, method: Callable
) -> bool:
	if whitelist:
		for element in whitelist:
			if not method.call(element, prop_info):
				return false
	for element in blacklist:
		if method.call(element, prop_info):
			return false
	return true


func match_regex(pattern: String, subject: String):
	return RegEx.create_from_string(pattern).search(subject) != null
