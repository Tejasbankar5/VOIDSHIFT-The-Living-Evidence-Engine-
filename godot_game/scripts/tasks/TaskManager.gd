class_name TaskManager
extends Node

## Task Manager and Mini-Game controller for VOIDSHIFT.
## Handles task progression, mini-game states, and completion signals.

signal task_completed(task_id: int, task_name: String)
signal all_tasks_finished()

var active_task_spot: StationData.TaskSpotDef = null
var is_active: bool = false
var progress: float = 0.0

# Mini-game state variables
var wiring_connections: Array[int] = [-1, -1, -1, -1]
var selected_wire: int = -1

var keypad_sequence: Array[int] = [0, 2, 1, 3]
var keypad_player_input: Array[int] = []

var dial_angle: float = 0.0
var transfer_progress: float = 0.0
var is_transferring: bool = false

func start_task(spot: StationData.TaskSpotDef) -> void:
	active_task_spot = spot
	is_active = true
	progress = 0.0
	
	wiring_connections = [-1, -1, -1, -1]
	selected_wire = -1
	keypad_sequence = [randi() % 4, randi() % 4, randi() % 4, randi() % 4]
	keypad_player_input.clear()
	dial_angle = randf_range(30.0, 300.0)
	transfer_progress = 0.0
	is_transferring = false

func close_task() -> void:
	is_active = false
	active_task_spot = null

func update_task(delta: float) -> void:
	if not is_active or active_task_spot == null:
		return

	match active_task_spot.task_type:
		GameEnums.TaskType.CALIBRATE_NAVIGATION:
			# Rotating dial needle
			dial_angle += delta * 180.0
			if dial_angle >= 360.0:
				dial_angle -= 360.0

		GameEnums.TaskType.UPLOAD_RESEARCH_LOGS, GameEnums.TaskType.RUN_MEDICAL_SCAN:
			if is_transferring:
				transfer_progress += delta * 0.4
				progress = clampf(transfer_progress, 0.0, 1.0)
				if progress >= 1.0:
					finish_current_task()

		GameEnums.TaskType.DIVERT_POWER:
			if is_transferring:
				transfer_progress += delta * 0.35
				progress = clampf(transfer_progress, 0.0, 1.0)
				if progress >= 1.0:
					finish_current_task()

func handle_wiring_click(wire_index: int, is_left_side: bool) -> void:
	if is_left_side:
		selected_wire = wire_index
	else:
		if selected_wire != -1:
			wiring_connections[selected_wire] = wire_index
			selected_wire = -1
			# Check win condition
			var matches: int = 0
			for i in range(4):
				if wiring_connections[i] == i:
					matches += 1
			progress = float(matches) / 4.0
			if matches == 4:
				finish_current_task()

func handle_keypad_press(button_id: int) -> void:
	keypad_player_input.append(button_id)
	var current_idx: int = keypad_player_input.size() - 1
	if keypad_player_input[current_idx] != keypad_sequence[current_idx]:
		# Wrong input, reset
		keypad_player_input.clear()
		progress = 0.0
	else:
		progress = float(keypad_player_input.size()) / float(keypad_sequence.size())
		if keypad_player_input.size() == keypad_sequence.size():
			finish_current_task()

func handle_dial_click() -> void:
	# Success if clicked near 0° or 360° (top green sector within +/- 25 degrees)
	if dial_angle <= 25.0 or dial_angle >= 335.0:
		progress = 1.0
		finish_current_task()

func handle_transfer_toggle() -> void:
	is_transferring = true

func finish_current_task() -> void:
	if active_task_spot != null:
		var completed_id := active_task_spot.id
		var completed_name := active_task_spot.name
		close_task()
		task_completed.emit(completed_id, completed_name)
