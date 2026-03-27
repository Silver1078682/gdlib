extends Health



func _on_damage_pressed() -> void:
	hp -= 1
	take_damage(1)


func _on_heal_pressed() -> void:
	hp += 1
	heal(1)


func _on_damagable_toggled(toggled_on: bool) -> void:
	damageable = toggled_on

func _on_healable_toggled(toggled_on: bool) -> void:
	healable = toggled_on

func _on_killable_toggled(toggled_on: bool) -> void:
	killable = toggled_on

func _on_revivable_toggled(toggled_on: bool) -> void:
	revivable = toggled_on
