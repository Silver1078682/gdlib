class_name CommandLineParser
extends RefCounted
## Parses command line input into arguments
##
## This class is used to parse command line arguments into a structured format.
## It allows for both positional and non-positional arguments, and provides methods to access them.
## It also provides error handling for invalid arguments and missing required options.
## [codeblock]
## var parser := CommandLineParser.new()
## parser.program_name = "parser"
## parser.add_positional_arg("input", "input file location")
## parser.add_option_arg("help", "print help", "h")
## parser.add_option_arg("output", "output file location", "o")
## parser.add_option_arg("verbose", "print verbosely", "v")
##
## var args := OS.get_cmdline_user_args()
## # assume args are ["res://file_a.txt", "-o", "res://file_b.txt", "-v"]
## if parser.parse_arr(args):
## 	parser.get_positional_args()	# Returns ["res://file_a.txt"]
## 	parser.get_option_args()		# Returns { &"output": ["res://file_b.txt"], &"verbose": [] }
## else:
##	print("failed to parse")
## parser.print_help()
## [/codeblock]

#region parse
const UNKNOWN_OPTION_ERR = "Unknown option_args %s"
const UNKNOWN_ALIAS_ERR = "Unknown alias %s"
const NOT_ENOUGH_POSITIONAL_ARGS = "Not enough positional args, require %d, got %d"
const TOO_MANY_POSITIONAL_ARGS = "Too many positional args, require %d, got %d"

var _positional_args: PackedStringArray
var _option_args: Dictionary[StringName, PackedStringArray]


## Parses a command line string into arguments
## Returns if the parsing was successful
func parse(string: String) -> bool:
	var regex = RegEx.create_from_string(r"""['"].*['"]|\S+""")
	return parse_arr(regex.search_all(string).map(func(a: RegExMatch): return a.strings[0]))


## Parses a command line array into arguments
## Returns if the parsing was successful
func parse_arr(args: PackedStringArray) -> bool:
	_has_errors = false
	var _pos := PackedStringArray()
	var _opt: Dictionary[StringName, PackedStringArray] = { }

	var store := _pos
	for i in args:
		if i.begins_with("--"):
			if check_validation and not i.trim_prefix("--") in option_args:
				_error(UNKNOWN_OPTION_ERR % i)
			store = _opt.get_or_add(i.trim_prefix("--"), [])

		elif i.begins_with("-"):
			if check_validation and not i.trim_prefix("-") in aliases:
				_error(UNKNOWN_ALIAS_ERR % i)
			var arg_name = aliases[i.trim_prefix("-")]
			store = _opt.get_or_add(arg_name, [])

		else:
			store.append(i)

	if check_validation:
		if _pos.size() < positional_args.size():
			_error(NOT_ENOUGH_POSITIONAL_ARGS % [positional_args.size(), _pos.size()])
		elif _pos.size() > positional_args.size():
			_error(TOO_MANY_POSITIONAL_ARGS % [positional_args.size(), _pos.size()])

	if _has_errors:
		return false
	_positional_args = _pos
	_option_args = _opt
	return true


## Returns the list of positional arguments for the last command executed.
func get_positional_args() -> PackedStringArray:
	return _positional_args.duplicate()


## Returns the list of option arguments for the last command executed.
func get_option_args() -> Dictionary[StringName, PackedStringArray]:
	return _option_args.duplicate()


var _has_errors = false


# Prints an error message.
func _error(message: String):
	_has_errors = true
	printerr(message)
	print_help()

#endregion

#region config
## The name of the program.
var program_name = ""
## If we should check the validation of arguments.
## When set to false, the parser will no longer raise errors
## and any positional and option args will be accepted and parsed.
var check_validation := true
var positional_args: Array[PositionalArgument]
var option_args: Dictionary[StringName, OptionArgument]
var aliases: Dictionary[StringName, StringName]


## Adds a positional argument to the parser.
func add_positional_arg(name: StringName, description: String = "") -> void:
	if name.is_empty():
		push_warning("Positional argument name cannot be empty")
		return
	if positional_args.any(func(positional: PositionalArgument): return positional.name == name):
		push_warning("Positional argument %s already exists")
		return
	positional_args.append(PositionalArgument.new(name, description))


## Adds an option argument to the parser.
func add_option_arg(name: StringName, description := "", alias: StringName = "") -> void:
	if name.is_empty():
		push_warning("Option argument name cannot be empty")
		return
	if name in option_args:
		push_warning("Option argument %s already exists")
		return
	if name in aliases:
		push_warning("Option argument %s already exists")
		return
	option_args[name] = OptionArgument.new(description)
	if alias != "":
		aliases[alias] = name


class PositionalArgument:
	var name: StringName
	var description: StringName


	func _init(p_name, p_description) -> void:
		name = p_name
		description = p_description


class OptionArgument:
	var description: StringName


	func _init(p_description) -> void:
		description = p_description
#endregion

#region help
## The format of the help string.
## placeholders are replaced with actual values.[br]
## prog - program name[br]
## pos - positional arguments hint[br]
## option - option arguments hint[br]
## option_doc - description of the arguments
## Elements are concatenated with spaces, empty tring will be ignored
var usage_string_format := ["Usage:", "{prog}", "{pos}", "{option}"]
var usage_string_bbcode := ["[color=green]%s[/color]", "[color=lightblue][b]%s[/b][/color]", "[color=lightblue]%s[/color]", "[color=lightblue]%s[/color]"]

## Whether to use alphabetical order for option arguments.
## If false, the order of option arguments is determined by their registration order.
var option_docs_use_alphabetical_order := true
var bbcode_output := true


## Display help message.
func print_help():
	if bbcode_output:
		print_rich(get_help_string(true))
	else:
		print(get_help_string(false))


## Get help string.
func get_help_string(use_bbcode := false) -> String:
	var formatted_arr := usage_string_format.map(
		func(str: String):
			return str.format(
				{
					"prog": program_name,
					"pos": _get_positional_hint(),
					"option": _get_option_hint(),
					"option_doc": _get_option_docs_hint(),
				},
			)
	)
	formatted_arr = formatted_arr.filter(func(str): return not str.is_empty())
	if use_bbcode:
		for i in formatted_arr.size():
			formatted_arr[i] = usage_string_bbcode[i] % formatted_arr[i]
	var usage_string = " ".join(formatted_arr)
	return usage_string + "\n" + _get_option_docs_hint()


func _get_positional_hint() -> String:
	return " ".join(positional_args.map(func(arg: PositionalArgument): return "<%s>" % arg.name))


func _get_option_hint() -> String:
	if option_args.size() > 1:
		return "[options]"
	if option_args.size() == 1:
		return "[%s]" % option_args.keys()[0]
	return ""


func _get_option_docs_hint() -> String:
	var lines = []
	var keys: PackedStringArray = option_args.keys() + aliases.keys()
	if option_docs_use_alphabetical_order:
		keys.sort()
	var unused_options := option_args.duplicate()
	for i in keys:
		var alias := ""
		var option := ""
		if i in aliases:
			alias = i
			option = aliases[i]
		else:
			option = i
		if option in unused_options:
			unused_options.erase(option)
		else:
			continue
		lines.append("%-10s%-20s%s" % [("-" + alias) if alias else "", "--" + option, option_args[option].description])
	return "\n".join(lines)
#endregion
