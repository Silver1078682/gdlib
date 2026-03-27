class_name SearchBar
extends LineEdit
## A simple search bar implementation that search(filter and resort) children of a target parent
##
## [b]NOTE[/b]: to make a search bar works, you should set [member target_parent] manually[br]
## You should also implement search logic yourself.[br]
## Please override method [method _should_match] and [method _sort]
## [codeblock]
## func _should_match(a : Node) -> bool:
## 	if a is Label:
## 		# filter labels by their content
## 		return a.text.containsn(text) or text.is_empty()
## 	return false
##
## func _sort(a: Node, b: Node) -> bool:
## 	return a.text < b.text
##
## [/codeblock]

## The target parent whose children will be searched
@export var target_parent: Node
## Whether to sort children after filtering. See also [method _sort]
@export var custom_sort := true


#region custom behavior
## Override this function to define custom filter logic
## Implement this function to make sure the SearchBar works as expected
func _should_match(a: Node) -> bool:
	return a.name.contains(text)


## Custom logic to sort the order node was arranged
func _sort(a: Node, b: Node) -> bool:
	return a.name < b.name


## Custom logic applied to unmatched nodes
func _on_not_matched(a: Node) -> void:
	if a is CanvasItem:
		a.hide()


## Custom logic applied to matched nodes
func _on_matched(a: Node) -> void:
	if a is CanvasItem:
		a.show()


## Search children of target_parent
func search():
	if can_record_history:
		add_history(text)
	if not target_parent:
		push_error("Target parent not set. Please set target_parent for SearchBar")
		return

	var filtered := target_parent.get_children().filter(_should_match)
	filtered.map(_on_matched)
	if custom_sort:
		filtered.sort_custom(_sort)
		for i in filtered.size():
			target_parent.move_child(filtered[i], i)
	(
		target_parent
		. get_children()
		. filter(func(a: Node): return not _should_match(a))
		. map(_on_not_matched)
	)


#endregion

#region History
signal history_navigated
@export_group("History")
## Whether to record search history
@export var can_record_history := false
## Whether to drop duplicate search history
@export var drop_duplicate_history := true
## Whether to allow history navigation
@export var allow_history_navigation := false
## Maximum number of search history entries to keep
@export var max_history_count := 100:
	set(p_max_history_count):
		if p_max_history_count < 0:
			printerr("max_history_count must be non-negative, ignored")
			return
		if p_max_history_count == max_history_count:
			return
		_history_list = (
			_history_list
			. slice(
				max(_history_list.size() - p_max_history_count, 0),
				_history_list.size(),
			)
		)
		max_history_count = p_max_history_count

# search history.
var _history_list: PackedStringArray


## Return the history list
func get_history() -> PackedStringArray:
	return _history_list.duplicate()


## Add a history entry
func add_history(text: String) -> void:
	if drop_duplicate_history:
		_history_list.erase(text)
	if _history_list.size() >= max_history_count:
		_history_list.remove_at(0)
	_history_list.append(text)


# index pointer to thw history we are currently at.
var _history_pointer := -1


func _navigate_history(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		if not allow_history_navigation or not _history_list:
			return

		var p_history_pointer: int
		if event.is_action_pressed("ui_up"):
			if _history_pointer == -1:
				add_history(text)  # Add current text to history
			p_history_pointer = _history_pointer - 1
		elif event.is_action_pressed("ui_down"):
			p_history_pointer = _history_pointer + 1

		p_history_pointer = clampi(p_history_pointer, -_history_list.size(), -1)
		if _history_pointer != p_history_pointer:
			history_navigated.emit()
			_history_pointer = p_history_pointer

		text = _history_list.get(_history_list.size() + _history_pointer)
		caret_column = text.length()
		get_viewport().set_input_as_handled()  # Override the default behavior of ui_up/down


func _init() -> void:
	gui_input.connect(_navigate_history)
	text_submitted.connect(search.unbind(1))
#endregion
