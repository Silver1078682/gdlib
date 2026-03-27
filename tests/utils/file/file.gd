extends GutTest

const FOLDER = "res://tests/utils/file/test_folder/"

func before_all():
	GutTestHelper.coverage(FileUtil, self)

func before_each():
	DirAccess.make_dir_recursive_absolute(FOLDER)
	var dir := DirAccess.open(FOLDER)
	FileUtil.clear_dir(dir, true)
	assert_true(dir.get_files().is_empty() and dir.get_directories().is_empty())


func test_open_file() -> void:
	FileUtil.open_file(FOLDER + "test_file.txt", FileAccess.ModeFlags.WRITE)
	assert_true(FileAccess.file_exists(FOLDER + "test_file.txt"))


func test_open_dir() -> void:
	var dir := FileUtil.open_dir(FOLDER, true)
	assert_eq(dir.get_current_dir(), FOLDER.trim_suffix("/"))
	dir = FileUtil.open_dir(FOLDER + "a/b/c/d", true)
	assert_eq(dir.get_current_dir(), FOLDER + "a/b/c/d")


func test_file_stream() -> void:
	const TEST_FILE_PREFIX = "test_file"
	for i in 10:
		FileUtil.open_file(FOLDER + TEST_FILE_PREFIX + str(i), FileAccess.ModeFlags.WRITE)
	var stream := FileUtil.FileStream.new(FileUtil.open_dir(FOLDER))
	var a = []
	for file_name in stream:
		assert_true(file_name.begins_with(TEST_FILE_PREFIX))
		a.append(file_name[-1])
	a.sort()
	assert_eq(a, range(10).map(str))
	

func test_clear_dir() -> void:
	FileUtil.open_file(FOLDER + "test_file.txt", FileAccess.ModeFlags.WRITE)
	FileUtil.open_dir(FOLDER, true)
	FileUtil.open_dir(FOLDER + "a/b/c/d", true)

	var dir = FileUtil.open_dir(FOLDER)
	FileUtil.clear_dir(dir, false)
	assert_true(dir.get_files().is_empty())
	assert_false(dir.get_directories().is_empty())

	FileUtil.clear_dir(dir)
	assert_true(dir.get_files().is_empty() and dir.get_directories().is_empty())
