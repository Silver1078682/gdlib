extends SearchBar


func _should_match(a: Node) -> bool:
	return a.text.containsn(text) or text.is_empty()

#func _sort(a: Node, b: Node) -> bool:
#return text.similarity(a.text) > text.similarity(b.text)
