class_name SearchBar
extends LineEdit
## A simple search bar implementation that filters children of a target parent

## The target parent whose children will be applied to the filter rule
@export var target_parent: Node

## Whether to filter children of target_parent automatically when text submitted
@export var on_submitted := false:
	set(p_on_submitted):
		if on_submitted == p_on_submitted:
			return
		if p_on_submitted:
			if text_submitted.is_connected(filter):
				return
			text_submitted.connect(filter.unbind(1))
		else:
			if not text_submitted.is_connected(filter):
				return
			text_submitted.disconnect(filter)
		on_submitted = p_on_submitted

## Whether to record search history
@export var can_record_history := false
## Maximum number of search history entries to keep
@export var max_history_count := 100:
	set(p_max_history_count):
		if p_max_history_count < 0:
			printerr("max_history_count must be non-negative, ignored")
			return
		if p_max_history_count == max_history_count:
			return
		_history_list =  CircularQueue.new(p_max_history_count, Array(get_history()))
		max_history_count = p_max_history_count

# circular queue of search history.
var _history_list := CircularQueue.new(10)

func get_history() -> PackedStringArray:
	return _history_list.to_array()


## Filter children of target_parent
func filter():
	if can_record_history:
		if _history_list.is_full():
			_history_list.pop_front()
		_history_list.push_back(text)

	if not target_parent:
		push_error("Target parent not set. Please set target_parent for SearchBar")
		return
	for node in target_parent.get_children():
		if _should_filter(node):
			_on_matched(node)
		else:
			_on_not_matched(node)

#region custom behavior
## Override this function to define custom filter logic
## Implement this function to make sure the SearchBar works as expected
func _should_filter(a: Node) -> bool:
	return false


## Custom logic applied to unmatched nodes
func _on_not_matched(a: Node) -> void:
	if a is CanvasItem:
		a.hide()


## Custom logic applied to matched nodes
func _on_matched(a: Node) -> void:
	if a is CanvasItem:
		a.show()
#endregion
