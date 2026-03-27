extends GutTest

var root: Node
var target: Node2D
const LABEL_COUNT = 10


func before_all():
	var window := get_node("/root")
	root = Node.new()
	root.name = "Test"
	window.add_child(root)


func before_each():
	NodeUtil.free_children(root)
	await NodeUtil.ensure_children_freed(root)
	target = Node2D.new()
	root.add_child(target)
	# Create test labels
	for i in range(LABEL_COUNT):
		var label := Label.new()
		label.text = str(i)
		label.name = "Label" + str(i)
		target.add_child(label, true)


class CustomSearchBar extends SearchBar:
	var search_cnt := 0
	func search():
		search_cnt += 1
		super()

	func _should_match(a: Node) -> bool:
		if a is Label:
			return a.text.containsn(text) or text.is_empty()
		return false

	func _sort(a: Node, b: Node) -> bool:
		return (a as Label).text > (b as Label).text


## Test the filter functionality
func test_filter() -> void:
	var search_bar := CustomSearchBar.new()
	search_bar.target_parent = target

	# Test with a matching keyword
	search_bar.text = "5"
	search_bar.search()
	_assert_only_label_n_is_visible(5)

## Test the sort functionality
func test_sort() -> void:
	var search_bar := CustomSearchBar.new()
	search_bar.target_parent = target
	search_bar.text = ""
	search_bar.search()
	for i in target.get_child_count():
		var node := target.get_child(i)
		assert_true(node.name.ends_with(str(LABEL_COUNT - i - 1)))
		assert_true(node.visible)

## Test on_submitted functionality
func test_on_submitted():
	var search_bar := CustomSearchBar.new()
	assert_eq(search_bar.search_cnt, 0)
	search_bar.target_parent = target
	search_bar.text = "5"
	search_bar.text_submitted.emit(search_bar.text)
	assert_eq(search_bar.search_cnt, 1)
	_assert_only_label_n_is_visible(5)




## Test search history functionality
func test_history() -> void:
	var search_bar := SearchBar.new()
	search_bar.target_parent = root
	search_bar.can_record_history = true
	_test_history(search_bar, 3)


## Test search history functionality
func test_varying_history() -> void:
	var search_bar := SearchBar.new()
	search_bar.target_parent = root
	search_bar.can_record_history = true
	search_bar.max_history_count = 3
	_test_history(search_bar, 3)

	var arr = search_bar.get_history()
	search_bar.max_history_count = 5
	assert_eq(search_bar.get_history(), arr)
	for i in 5 - 3:
		_search(search_bar, "extend%d" % i, arr)
		assert_eq(search_bar.get_history(), arr)
	for i in 10:
		_search(search_bar, "more%d" % i, arr)
		arr.remove_at(0)
		assert_eq(search_bar.get_history(), arr)

	arr = search_bar.get_history().slice(-3)
	search_bar.max_history_count = 3
	assert_eq(search_bar.get_history(), arr)
	for i in 10:
		_search(search_bar, "shrinkMore%d" % i, arr)
		arr.remove_at(0)
		assert_eq(search_bar.get_history(), arr)

	arr = search_bar.get_history()
	search_bar.max_history_count = 5
	search_bar.max_history_count = 4
	assert_eq(search_bar.get_history(), arr)

	_search(search_bar, "shrink1More", arr)
	assert_eq(search_bar.get_history(), arr)
	for i in 10:
		_search(search_bar, "shrink2More%d" % i, arr)
		arr.remove_at(0)
		assert_eq(search_bar.get_history(), arr)


func _test_history(search_bar: SearchBar, max_history_count: int):
	search_bar.max_history_count = max_history_count
	# Test history recording
	var a: PackedStringArray
	for i in max_history_count:
		_search(search_bar, "test%d" % i, a)
		assert_eq(search_bar.get_history(), a)

	## Test history limit
	const MORE_TEST_CNT = 10
	for i in range(max_history_count, max_history_count + MORE_TEST_CNT):
		_search(search_bar, "test%d" % i, a)
		a.remove_at(0)
		assert_eq(search_bar.get_history(), a)

	search_bar.can_record_history = false
	for i in MORE_TEST_CNT:
		_search(search_bar, "no%d" % i)
	for i in MORE_TEST_CNT:
		assert_does_not_have(search_bar.get_history(), ("no%d" % i), "search term no%d recorded when history recording is disabled" % i)
		assert_true(search_bar.get_history().size() == max_history_count, "History list size is incorrect after limit")
	search_bar.can_record_history = true


func _search(search_bar: SearchBar, search: String, arr = null):
	search_bar.text = search
	search_bar.search()
	if arr != null:
		arr.append(search)

func _assert_only_label_n_is_visible(n: int):
	for i in range(LABEL_COUNT):
		var node := target.get_child(i)
		if node.name.ends_with(str(n)):
			assert_true(node.visible, "Label%d should be visible" % n)
			assert_true(i == 0, "Label%d should be first node" % n)
		else:
			assert_false(node.visible, "Node #%d should be hidden" % i)
