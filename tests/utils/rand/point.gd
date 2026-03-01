extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func _draw() -> void:
	for i in range(10000).map(RandUtil.circle.bind(100, Vector2.ZERO).unbind(1)):
		draw_circle(i, 1, Color.RED)

	for i in range(10000).map(RandUtil.ring.bind(150, 200, Vector2.ZERO).unbind(1)):
		draw_circle(i, 1, Color.BLUE)

	for i in range(10000).map(
		RandUtil.triangle.bind(Vector2(100, 300), Vector2(100, 200), Vector2(500, 500)).unbind(1)
	):
		draw_circle(i, 1, Color.GREEN)
