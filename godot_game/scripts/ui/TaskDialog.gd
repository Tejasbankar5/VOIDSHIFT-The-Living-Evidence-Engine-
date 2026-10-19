class_name TaskDialog
extends Control

## Interactive modal dialog for station task mini-games in VOIDSHIFT.

const GameEnums = preload("res://scripts/core/GameEnums.gd")
const StationData = preload("res://scripts/core/StationData.gd")
const TaskManager = preload("res://scripts/tasks/TaskManager.gd")

signal closed()

var task_manager: TaskManager = null
var current_spot: StationData.TaskSpotDef = null

func setup(p_manager: TaskManager) -> void:
	task_manager = p_manager

func open(spot: StationData.TaskSpotDef) -> void:
	current_spot = spot
	if task_manager:
		task_manager.start_task(spot)
	visible = true

func close() -> void:
	visible = false
	if task_manager:
		task_manager.close_task()
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_X):
		close()

func _gui_input(event: InputEvent) -> void:
	if not visible or task_manager == null:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_ev := event as InputEventMouseButton
		var mpos: Vector2 = mouse_ev.position

		# Close button
		var close_rect := Rect2(920, 110, 50, 30)
		if close_rect.has_point(mpos):
			close()
			return

		if current_spot == null:
			return

		match current_spot.task_type:
			GameEnums.TaskType.FIX_WIRING:
				# Left nodes at x=420, Right nodes at x=860
				for i in range(4):
					var ny: float = 260.0 + (i * 70.0)
					if mpos.distance_to(Vector2(420, ny)) <= 24.0:
						task_manager.handle_wiring_click(i, true)
						queue_redraw()
						return
					elif mpos.distance_to(Vector2(860, ny)) <= 24.0:
						task_manager.handle_wiring_click(i, false)
						queue_redraw()
						return

			GameEnums.TaskType.STABILIZE_REACTOR:
				# 4 Keypad buttons
				for i in range(4):
					var bx: float = 520.0 + (i % 2) * 130.0
					var by: float = 270.0 + (i / 2) * 120.0
					var btn_rect := Rect2(bx, by, 110, 100)
					if btn_rect.has_point(mpos):
						task_manager.handle_keypad_press(i)
						queue_redraw()
						return

			GameEnums.TaskType.CALIBRATE_NAVIGATION:
				# Click anywhere on dial when needle is aligned
				var dial_rect := Rect2(480, 220, 320, 320)
				if dial_rect.has_point(mpos):
					task_manager.handle_dial_click()
					queue_redraw()
					return

			GameEnums.TaskType.UPLOAD_RESEARCH_LOGS, GameEnums.TaskType.RUN_MEDICAL_SCAN, GameEnums.TaskType.DIVERT_POWER:
				var transfer_btn := Rect2(540, 440, 200, 50)
				if transfer_btn.has_point(mpos):
					task_manager.handle_transfer_toggle()
					queue_redraw()
					return

func _process(delta: float) -> void:
	if visible and task_manager:
		task_manager.update_task(delta)
		if not task_manager.is_active:
			# Finished task
			visible = false
			closed.emit()
		queue_redraw()

func _draw() -> void:
	# Semi-transparent backdrop
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.04, 0.06, 0.10, 0.85))

	# Dialog frame
	var frame := Rect2(320, 100, 640, 520)
	draw_rect(frame, Color(0.08, 0.12, 0.18, 0.98))
	draw_rect(frame, Color(0.0, 0.85, 1.0), false, 2.0)

	var title: String = current_spot.name if current_spot else "Station Maintenance Task"
	draw_string(ThemeDB.fallback_font, Vector2(360, 135), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(360, 160), current_spot.description if current_spot else "", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.85, 0.95))

	# Close button [X]
	var close_btn := Rect2(905, 115, 40, 26)
	draw_rect(close_btn, Color(0.8, 0.2, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(918, 133), "X", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(1, 1, 1))

	# Progress Bar
	var p: float = task_manager.progress if task_manager else 0.0
	draw_rect(Rect2(360, 180, 560, 16), Color(0.12, 0.18, 0.25))
	draw_rect(Rect2(360, 180, 560 * p, 16), Color(0.0, 0.9, 0.6))
	draw_rect(Rect2(360, 180, 560, 16), Color(0.2, 0.45, 0.7), false, 1.0)

	if current_spot == null:
		return

	# Draw specific mini-game visuals
	match current_spot.task_type:
		GameEnums.TaskType.FIX_WIRING:
			draw_wiring_minigame()
		GameEnums.TaskType.STABILIZE_REACTOR:
			draw_reactor_keypad_minigame()
		GameEnums.TaskType.CALIBRATE_NAVIGATION:
			draw_calibrate_dial_minigame()
		_:
			draw_transfer_minigame()

func draw_wiring_minigame() -> void:
	var wire_colors := [
		Color(0.9, 0.2, 0.2), # Red
		Color(0.2, 0.6, 0.95), # Blue
		Color(0.95, 0.85, 0.15), # Yellow
		Color(0.2, 0.85, 0.4) # Green
	]

	for i in range(4):
		var ny: float = 260.0 + (i * 70.0)
		var left_node := Vector2(420, ny)
		var right_node := Vector2(860, ny)

		# Terminals
		draw_circle(left_node, 16.0, wire_colors[i])
		draw_circle(right_node, 16.0, wire_colors[i])
		draw_arc(left_node, 16.0, 0, TAU, 24, Color.WHITE, 2.0)
		draw_arc(right_node, 16.0, 0, TAU, 24, Color.WHITE, 2.0)

		# Selected highlight
		if task_manager.selected_wire == i:
			draw_arc(left_node, 22.0, 0, TAU, 24, Color(1, 1, 1, 0.9), 2.5)

		# Connected wire line
		var target_idx: int = task_manager.wiring_connections[i]
		if target_idx != -1:
			var target_pos := Vector2(860, 260.0 + (target_idx * 70.0))
			draw_line(left_node, target_pos, wire_colors[i], 6.0)

	draw_string(ThemeDB.fallback_font, Vector2(480, 570), "Click left terminal, then click matching color right terminal.", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.8, 0.85, 0.9))

func draw_reactor_keypad_minigame() -> void:
	for i in range(4):
		var bx: float = 520.0 + (i % 2) * 130.0
		var by: float = 270.0 + (i / 2) * 120.0
		var is_pressed: bool = (i in task_manager.keypad_player_input)
		var col := Color(0.2, 0.85, 0.4) if is_pressed else Color(0.15, 0.3, 0.5)
		draw_rect(Rect2(bx, by, 110, 100), col)
		draw_rect(Rect2(bx, by, 110, 100), Color.WHITE, false, 2.0)
		draw_string(ThemeDB.fallback_font, Vector2(bx + 48, by + 58), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 24, Color(1, 1, 1))

	var seq_str := "Input Sequence: "
	for val in task_manager.keypad_sequence:
		seq_str += str(val + 1) + " "
	draw_string(ThemeDB.fallback_font, Vector2(460, 540), seq_str, HORIZONTAL_ALIGNMENT_CENTER, 360, 14, Color(0.0, 0.9, 0.8))

func draw_calibrate_dial_minigame() -> void:
	var center := Vector2(640, 360)
	var radius: float = 120.0
	draw_circle(center, radius, Color(0.1, 0.16, 0.24))
	draw_arc(center, radius, 0, TAU, 48, Color(0.3, 0.5, 0.7), 3.0)

	# Target green sector at top (0 degrees / 12 o'clock)
	var top_sector := center - Vector2(0, radius - 15)
	draw_circle(top_sector, 18.0, Color(0.2, 0.9, 0.4))
	draw_arc(top_sector, 18.0, 0, TAU, 24, Color.WHITE, 2.0)

	# Rotating needle
	var rad := deg_to_rad(task_manager.dial_angle)
	var needle_tip := center + Vector2(sin(rad), -cos(rad)) * (radius - 10.0)
	draw_line(center, needle_tip, Color(1.0, 0.3, 0.3), 4.0)
	draw_circle(center, 8.0, Color.WHITE)

	draw_string(ThemeDB.fallback_font, Vector2(460, 540), "Click when the red needle aligns with the GREEN sector!", HORIZONTAL_ALIGNMENT_CENTER, 360, 13, Color(1, 1, 1))

func draw_transfer_minigame() -> void:
	# Progress bar and start transfer button
	var btn_rect := Rect2(540, 440, 200, 50)
	var is_busy: bool = task_manager.is_transferring
	draw_rect(btn_rect, Color(0.0, 0.7, 0.5) if not is_busy else Color(0.2, 0.3, 0.4))
	draw_rect(btn_rect, Color.WHITE, false, 2.0)
	var btn_txt := "START TRANSFER" if not is_busy else "TRANSFERRING..."
	draw_string(ThemeDB.fallback_font, Vector2(560, 471), btn_txt, HORIZONTAL_ALIGNMENT_CENTER, 160, 13, Color(1, 1, 1))
