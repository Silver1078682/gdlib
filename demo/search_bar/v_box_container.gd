extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NodeUtil.assert_children_type(self, Label)
	for i in 10:
		var a = Label.new()
		var b = Label.new()
		a.text = RandUtil.string(10, range(ord("A"), ord("Z")).map(char))
		b.text = a.text.to_lower()
		[a, b].map(add_child)
	for i in 20:
		var a = Label.new()
		a.text = "ABC" + str(i)
		add_child(a)
