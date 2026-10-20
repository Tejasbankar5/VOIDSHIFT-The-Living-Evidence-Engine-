class_name SabotageManager
extends RefCounted

## Sabotage Management System for VOIDSHIFT.
## Manages reactor meltdowns, power grid failures, and critical alerts.

signal sabotage_triggered(type: GameEnums.SabotageType)
signal sabotage_repaired()
signal critical_failure_reached()

var active_sabotage: GameEnums.SabotageType = GameEnums.SabotageType.NONE
var timer: float = 0.0
var max_timer: float = 45.0

func trigger_sabotage(type: GameEnums.SabotageType) -> void:
	active_sabotage = type
	match type:
		GameEnums.SabotageType.REACTOR:
			max_timer = 45.0
			timer = 45.0
		GameEnums.SabotageType.LIGHTS:
			max_timer = 60.0
			timer = 60.0
		GameEnums.SabotageType.COMMUNICATIONS:
			max_timer = 50.0
			timer = 50.0
		GameEnums.SabotageType.OXYGEN:
			max_timer = 35.0
			timer = 35.0
	sabotage_triggered.emit(type)

func update(delta: float) -> void:
	if active_sabotage != GameEnums.SabotageType.NONE:
		timer -= delta
		if timer <= 0.0:
			timer = 0.0
			if active_sabotage == GameEnums.SabotageType.REACTOR or active_sabotage == GameEnums.SabotageType.OXYGEN:
				critical_failure_reached.emit()

func repair_sabotage() -> void:
	active_sabotage = GameEnums.SabotageType.NONE
	timer = 0.0
	sabotage_repaired.emit()

func is_critical_failure() -> bool:
	return (active_sabotage == GameEnums.SabotageType.REACTOR or active_sabotage == GameEnums.SabotageType.OXYGEN) and timer <= 0.0
