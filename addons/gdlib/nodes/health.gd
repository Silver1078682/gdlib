class_name Health
extends Node
## A health component

## Emitted when hp changes
signal hp_changed(to: int)
## Emitted when health is revived
signal revived
## Emitted when hp reaches zero
signal death

const DEFAULT_MAX_HP = 100
## Maximum hp value [br]
## Will reduce current if greater than updated max.[br]
@export var max_hp: int = DEFAULT_MAX_HP:
	set(p_):
		pass
## Current hp value, the value is clamped between 0 and max_hp
## [codeblock]
## health.hp = 30
## health.hp -= 10 # Equivalent to health.take_damage(10)
## [/codeblock]
@export var hp: int = DEFAULT_MAX_HP:
	get:
		return _hp
	set(p_hp):
		if _hp < p_hp:
			_heal_to(p_hp)
		if _hp > p_hp:
			_hurt_to(p_hp)

## Health percentage, the value is clamped between 0 and 1
var percent: float:
	get:
		return float(_hp) / max_hp
	set(p_percent):
		hp = max_hp * percent

# Current hp value, used internally
var _hp: int = DEFAULT_MAX_HP

@export_group("Condition")
## If the health can be healed
@export var healable := true
## If the health can be damaged
@export var damageable := true
## If the health can be killed
@export var killable := true
## Health to keep on deadly attack, ignored when killable set false
## If set 0, it will remains its current health.
@export var hp_on_deadly_attack := 10
## If the health can be revived even after death
@export var revivable := true


#region SetterAPI
## Set hp
func set_hp(p_hp: int) -> void:
	hp = p_hp


## Take damage, damage should be a negative number
func take_damage(damage: int) -> void:
	if damage > 0:
		_hurt_to(_hp - damage)


## Set hp to zero and emit death signal
func die() -> void:
	if not killable:
		_hurt_to(1)
		return
	_hurt_to(0)


## Recover hp by a certain amount
func heal(amount: int) -> void:
	if amount > 0:
		_heal_to(_hp + amount)


## Recover hp to full hp value
func heal_full() -> void:
	if healable:
		_heal_to(max_hp)


#endregion


#region GetterAPI
## Return if the health is alive
func is_alive() -> bool:
	return _hp > 0


## Return if the health is dead
func is_dead() -> bool:
	return _hp <= 0 and killable


## Return if the health is full hp value
func is_full() -> bool:
	return _hp == max_hp


#endregion


# heal to given hp, respect healable and revivable flag
# This function won't fail even if new_hp is not greater than _hp, AVOID this case manually
# used internally
func _heal_to(new_hp: int) -> void:
	if not healable:
		return
	if _hp == 0 and not revivable:
		return
	_hp = mini(new_hp, max_hp)
	hp_changed.emit(new_hp)


# hurt to given hp, respect damageable and killable flag
# This function won't fail even if new_hp is not smaller than _hp, AVOID this case manually
# used internally
func _hurt_to(new_hp: int) -> void:
	if not damageable:
		return
	if new_hp < 0:
		if killable:
			new_hp = 0
		else:
			new_hp = hp_on_deadly_attack if hp_on_deadly_attack else _hp
	_hp = new_hp
	hp_changed.emit(new_hp)
	if new_hp == 0:
		death.emit()
