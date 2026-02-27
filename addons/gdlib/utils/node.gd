class_name NodeUtil

## Ensure a node is ready before proceeding.
## await is required before this function
static func ensure_ready(node: Node) -> void:
	if not node:
		push_error("Invalid node provided.")
		return
	if node.is_queued_for_deletion():
		push_error("Node is queued for deletion.")
		return
	if not node.is_node_ready():
		await node.ready


## Set the parent of a node to [param]parent[/param].
static func set_parent_of(node: Node, parent: Node) -> void:
	if not node:
		push_error("Invalid node provided.") 
		return
	if not parent:
		push_error("Invalid parent provided.") 
		return
	if node.get_parent():
		node.reparent(parent)
	else:
		parent.add_child(node)


## Get a Node/Resource/Variant from [NodePath].
## Returns null on failure
## [codeblock]
## ┖╴Root
##    ┠╴Node
##    ┖╴Node2D
##       ┖╴Label
## [/codeblock]
## [codeblock]
## get_from_nodepath(root, "Node")
## get_from_nodepath(node2d, ":position")
## get_from_nodepath(root, "Node2D/Label:text")
## [/codeblock]
static func get_from_nodepath(node: Node, path: NodePath) -> Variant:
	var name: NodePath = String(path.get_concatenated_names())
	node = (node.get_node_or_null(name)) if name else node
	if node == null:
		push_error("Can not find node at ", name)
		return null
	var subname: NodePath = String(path.get_concatenated_subnames())
	return node.get_indexed(subname) if subname else node


## Free all children of the [param parent]
static func free_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


## Ensure the children of a node is all freed.
## await is required before this function.
## You can use if after [method free_children] when it's necessary
static func ensure_children_freed(node: Node) -> void:
	for child in node.get_children():
		if not child.is_queued_for_deletion():
			push_error("ensure_children_freed is called on a node, but queued_free never call on its child %s" % child)
		await child.tree_exited
		


## Returns an array containing all descendants nodes of node.
static func get_descendants(node : Node, include_internal : bool = false) -> Array[Node]:
	var result : Array[Node]
	for child in node.get_children(include_internal):
		result.append(child)
		result += get_descendants(child, include_internal)
	return result
