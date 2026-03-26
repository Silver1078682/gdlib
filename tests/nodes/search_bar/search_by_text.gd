extends SearchBar


func _should_filter(a : Node) -> bool:
	return a is Label and text in a.text
