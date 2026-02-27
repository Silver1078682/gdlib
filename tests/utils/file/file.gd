extends GutTest

const FOLDER = "res://tests/utils/file/test_folder/"


func before_each():
	var dir := FileUtil.open_dir(FOLDER, true)
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
