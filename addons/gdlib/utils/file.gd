class_name FileUtil
## A helper to manipulate files and directories with ease.


## Open a file, print human-readable error messages on failure.
static func open_file(path: String, access_mode: FileAccess.ModeFlags) -> FileAccess:
	var file = FileAccess.open(path, access_mode)
	var error := FileAccess.get_open_error()
	if error:
		printerr(
			(
				"opening file at %s failed: " % ProjectSettings.globalize_path(path)
				+ error_string(error)
			)
		)
	return file


## Open a directory, print human-readable error messages on failure.
## When force set true, create the directory (recursively) if the directory does not exist.
static func open_dir(path: String, force := false) -> DirAccess:
	var error: int
	if force and not DirAccess.dir_exists_absolute(path):
		error = DirAccess.make_dir_recursive_absolute(path)
		if error:
			printerr(
				(
					"creating directory at %s failed: " % ProjectSettings.globalize_path(path)
					+ error_string(error)
				)
			)
			return
		return open_dir(path, true)

	var dir = DirAccess.open(path)
	error = DirAccess.get_open_error()
	if error:
		printerr(
			(
				"opening directory at %s failed: " % ProjectSettings.globalize_path(path)
				+ error_string(error)
			)
		)
	return dir


## Clear a directory.
static func clear_dir(dir: DirAccess, recursive := true) -> void:
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
## for file in FileStream(dir):
##     pass
## [/codeblock]
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

	func _iter_get(iter: Variant) -> Variant:
		return iter


## Call [method]load[method] on all files in the folder [param folder_path].
## An optional [param type_hint] can be used to further specify the [Resource] type
## return a dictionary containing all Resource and their file_name (extension stripped)
static func preload_resources(folder_path: String, type_hint: String = "") -> Dictionary:
	var result: Dictionary = {}
	var dir_access := open_dir(folder_path)
	if dir_access:
		var file_list = dir_access.get_files()
		for file_name in file_list:
			var file_path = folder_path + "/" + file_name
			var resource := ResourceLoader.load(
				file_path, type_hint, ResourceLoader.CACHE_MODE_REPLACE
			)
			if resource:
				result[file_name.rsplit(".", 1)[0]] = resource
	return result
