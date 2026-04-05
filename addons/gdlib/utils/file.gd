class_name FileUtil
## A helper to manipulate files and directories with ease.

## Open a file, print human-readable error messages on failure.
static func open_file(path: String, access_mode: FileAccess.ModeFlags) -> FileAccess:
	var file = FileAccess.open(path, access_mode)
	var error := FileAccess.get_open_error()
	if error:
		_print_error(error, OPEN_FILE_FAILURE_MESSAGE, path)
	return file


## Open a directory, print human-readable error messages on failure.
## When force set true, create the directory (recursively) if the directory does not exist.
static func open_dir(path: String, force := false) -> DirAccess:
	var error: int
	if force and not DirAccess.dir_exists_absolute(path):
		error = DirAccess.make_dir_recursive_absolute(path)
		if error:
			_print_error(error, OPEN_DIR_FAILURE_MESSAGE, path)
			return
		return open_dir(path, true)

	var dir = DirAccess.open(path)
	error = DirAccess.get_open_error()
	if error:
		_print_error(error, OPEN_DIR_FAILURE_MESSAGE, path)
	return dir


## Open a ConfigFile, print human-readable error messages on failure.
## When force set true, create the ConfigFile if the [ConfigFile] at [param path] does not exist.
static func open_config_file(path: String, force := false) -> ConfigFile:
	var file: ConfigFile = ConfigFile.new()
	var error: Error
	if FileAccess.file_exists(path):
		error = file.load(path)
		if error:
			_print_error(error, OPEN_CONFIG_FILE_FAILURE_MESSAGE, path)
	elif force:
		error = file.save(path)
		if error:
			_print_error(error, CREATE_CONFIG_FILE_FAILURE_MESSAGE, path)

	return file


## Clear a directory.
static func clear_dir(dir: DirAccess, recursive := false) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and recursive:
			dir.change_dir(file_name)
			clear_dir(dir, true)
			dir.change_dir("..")
		dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


## An iterator for files in a folder
## [codeblock]
## var dir = FileUtil.open_dir("res://folder")
## for file in FileUtil.FileStream(dir):
##     pass # do something here
## [/codeblock]
## [b]NOTE[/b]: The order is undefined
class FileStream:
	var _dir: DirAccess


	func _init(dir: DirAccess) -> void:
		_dir = dir


	func _iter_init(iter: Array) -> bool:
		_dir.list_dir_begin()
		iter[0] = _dir.get_next()
		return not iter[0].is_empty()


	func _iter_next(iter: Array) -> bool:
		iter[0] = _dir.get_next()
		return not iter[0].is_empty()


	func _iter_get(iter: Variant) -> String:
		return iter


## Call [method load on all files in the folder [param folder_path].
## An optional [param type_hint] can be used to further specify the [Resource] type
## return a dictionary containing all Resource and their file_name
static func preload_resources(folder_path: String, type_hint: String = "", recursive := false) -> Dictionary[String, Resource]:
	var result: Dictionary = { }
	for resource_name in ResourceLoader.list_directory(folder_path):
		if resource_name.ends_with("/"):
			continue
		var file_path := folder_path.path_join(resource_name)
		result[resource_name] = ResourceLoader.load(file_path, type_hint, ResourceLoader.CACHE_MODE_REPLACE)
	return result


const OPEN_FILE_FAILURE_MESSAGE = "opening file at %s failed: "
const OPEN_DIR_FAILURE_MESSAGE = "opening directory at %s failed: "
const CREATE_DIR_FAILURE_MESSAGE = "creating directory at %s failed: "
const OPEN_CONFIG_FILE_FAILURE_MESSAGE = "opening config file at %s failed: "
const CREATE_CONFIG_FILE_FAILURE_MESSAGE = "creating config file at %s failed: "


static func _print_error(error: Error, message: String, path: String) -> void:
	push_error(
		message % ProjectSettings.globalize_path(path) + error_string(error),
	)
