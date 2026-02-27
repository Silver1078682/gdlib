extends GutTest


var parser: CommandLineParser
func before_each():
	parser = CommandLineParser.new()


func test_parser_init() -> void:
	assert_eq(parser.program_name, "")
	assert_eq(parser.positional_args.size(), 0)
	assert_eq(parser.option_args.size(), 0)
	assert_eq(parser.aliases.size(), 0)

func test_positional_arg():
	parser.add_positional_arg("input", "input file location")
	assert_eq(parser.positional_args.size(), 1)
	parser.add_positional_arg("output", "output file location")
	assert_eq(parser.positional_args.size(), 2)

	assert_true(parser.parse("abc def"))
	var pos := parser.get_positional_args()
	assert_eq(pos[0], "abc")
	assert_eq(pos[1], "def")

	assert_false(parser.parse(""))
	assert_false(parser.parse("abc"))
	assert_false(parser.parse("ABC DEF GHI"))
	pos = parser.get_positional_args()
	assert_eq(pos[0], "abc")
	assert_eq(pos[1], "def")

func test_option_arg() -> void:
	parser.add_option_arg("help", "print help")
	assert_eq(parser.option_args.size(), 1)
	parser.add_option_arg("output", "output file location")
	assert_eq(parser.option_args.size(), 2)

	assert_true(parser.parse("--help"))
	var opt := parser.get_option_args()
	assert_true(opt.has("help"))
	assert_eq(opt["help"], PackedStringArray())

	assert_true(parser.parse("--help option"))
	opt = parser.get_option_args()
	assert_true(opt.has("help"))
	assert_eq(opt["help"], PackedStringArray(["option"]))
	
	assert_true(parser.parse("--help --output res://b.txt"))
	opt = parser.get_option_args()
	assert_true(opt.has("help"))
	assert_eq(opt["help"], PackedStringArray())
	assert_eq(opt["output"], PackedStringArray(["res://b.txt"]))

func test_aliases() -> void:
	parser.add_option_arg("help", "print help", "h")
	assert_eq(parser.option_args.size(), 1)
	parser.add_option_arg("output", "output file location", "o")
	assert_eq(parser.option_args.size(), 2)

	assert_true(parser.parse("-h"))
	var opt := parser.get_option_args()
	assert_true(opt.has("help"))
	assert_eq(opt["help"], PackedStringArray())

	assert_true(parser.parse("-h option"))
	opt = parser.get_option_args()
	assert_true(opt.has("help"))
	assert_eq(opt["help"], PackedStringArray(["option"]))
	assert_true(parser.parse("--output res://b.txt"))
	


func test_hybrid() -> void:
	parser.check_validation = false
	parser.parse("pos1 pos2 --one 1 --two 2 string \t\t--space\t\n 5\t\t --flag --repeat 1 --repeat 2")
	assert_eq(Array(parser.get_positional_args()), ["pos1", "pos2"])
	var opt : Dictionary[StringName, Array] = {}
	opt.assign(parser.get_option_args())
	assert_eq_deep(opt, {"one": ['1'], "two": ['2', "string"], "space": ["5"], "flag": [], "repeat": ["1", "2"]})

func test_help() -> void:
	parser.add_positional_arg("input", "input file location")
	parser.add_option_arg("help", "print help" , "h")
	parser.add_option_arg("output", "output file location", "o")
	parser.add_option_arg("log", "log level", "")
	assert_eq(parser.get_help_string(), """Usage: <input> [options]
-o        --output  output file location
-h        --help    print help
          --log     log level
""")
