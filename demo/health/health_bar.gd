extends HSlider


# Called when the node enters the scene tree for the first time.
@onready var health: Node2D = $"../../.."
func _ready() -> void:
	value = health.hp


func _on_health_hp_changed(to: float) -> void:
	value = to
