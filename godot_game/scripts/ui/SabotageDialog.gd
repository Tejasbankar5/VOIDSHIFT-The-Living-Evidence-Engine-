class_name SabotageDialog
extends Control

## Tactical Holographic Sabotage Matrix for VOIDSHIFT Saboteurs.
## Allows Infiltrators and Disruptors to trigger covert facility failures:
## - Reactor Meltdown (45s critical timer)
## - Electrical Blackout (Dims facility lighting, narrows vision)
## - Comms Jammer (Scrambles minimap & camera feeds)
## - Oxygen Depletion (35s life-support failure)

const GameEnums = preload("res://scripts/core/GameEnums.gd")

signal sabotage_selected(type: GameEnums.SabotageType)
signal closed()

var active_sabotage: GameEnums.SabotageType = GameEnums.SabotageType.NONE
var sabotage_timer: float = 0.0
var anim_timer: float = 0.0
var hovered_idx: int = -1

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)
	visible = false

func open(p_active: GameEnums.SabotageType, p_timer: float) -> void:
	active_sabotage = p_active
	sabotage_timer = p_timer
	anim_timer = 0.0
	hovered_idx = -1
	visible = true

func close() -> void:
	visible = false
	closed.emit()

func _process(delta: float) -> void:
	if visible:
		anim_timer += delta
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE, KEY_C, KEY_Z:
				close()
			KEY_1:
				trigger_type(GameEnums.SabotageType.REACTOR)
			KEY_2:
				trigger_type(GameEnums.SabotageType.LIGHTS)
			KEY_3:
				trigger_type(GameEnums.SabotageType.COMMUNICATIONS)
			KEY_4:
				trigger_type(GameEnums.SabotageType.OXYGEN)

func trigger_type(type: GameEnums.SabotageType) -> void:
	if active_sabotage == GameEnums.SabotageType.NONE:
		sabotage_selected.emit(type)
		close()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	var panel_w: float = 720.0
	var panel_x: float = (vp.x - panel_w) * 0.5
	var card_w: float = 640.0
	var card_x: float = (vp.x - card_w) * 0.5

	if event is InputEventMouseMotion:
		var mpos: Vector2 = event.position
		hovered_idx = -1
		var y := 175.0
		for i in range(4):
			var r := Rect2(card_x, y, card_w, 82)
			if r.has_point(mpos):
				hovered_idx = i
				break
			y += 94.0

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mpos: Vector2 = event.position
		# Close button
		var close_rect := Rect2(panel_x + panel_w - 54, 90, 40, 32)
		if close_rect.has_point(mpos):
			close()
			return

		var y := 175.0
		var types := [
			GameEnums.SabotageType.REACTOR,
			GameEnums.SabotageType.LIGHTS,
			GameEnums.SabotageType.COMMUNICATIONS,
			GameEnums.SabotageType.OXYGEN
		]
		for i in range(4):
			var r := Rect2(card_x, y, card_w, 82)
			if r.has_point(mpos):
				trigger_type(types[i])
				return
			y += 94.0

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0

	# Darkened Backdrop
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.02, 0.03, 0.06, 0.88))

	# Tactical Matrix Main Panel
	var panel_w: float = 720.0
	var panel_h: float = 540.0
	var panel_x: float = (vp.x - panel_w) * 0.5
	var panel_y: float = 80.0
	var panel_rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	draw_rect(panel_rect, Color(0.08, 0.04, 0.06, 0.96))
	var border_pulse: float = 0.8 + sin(anim_timer * 4.0) * 0.2
	draw_rect(panel_rect, Color(1.0, 0.22, 0.28) * border_pulse, false, 2.0)

	# Header Banner
	draw_string(ThemeDB.fallback_font, Vector2(panel_x + 30, panel_y + 36), "COVERT SYSTEM INTERFERENCE MATRIX // SABOTEUR PROTOCOL", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.35, 0.35))
	draw_line(Vector2(panel_x + 30, panel_y + 48), Vector2(panel_x + panel_w - 30, panel_y + 48), Color(1.0, 0.2, 0.3, 0.5), 1.5)

	# Close [X] Button
	var close_rect := Rect2(panel_x + panel_w - 54, panel_y + 16, 36, 24)
	draw_rect(close_rect, Color(0.25, 0.08, 0.10))
	draw_rect(close_rect, Color(1.0, 0.3, 0.3), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(close_rect.position.x, close_rect.position.y + 16), "X", HORIZONTAL_ALIGNMENT_CENTER, int(close_rect.size.x), 11, Color(1, 1, 1))

	# 4 Sabotage Cards
	var cards: Array[Dictionary] = [
		{
			"key": "[1]",
			"title": "REACTOR CORE OVERLOAD",
			"room": "Target: Sector Reactor Core",
			"desc": "Initiates 45s catastrophic meltdown sequence. Crew must stabilize console or fail immediately.",
			"col": Color(1.0, 0.22, 0.25),
			"type": GameEnums.SabotageType.REACTOR
		},
		{
			"key": "[2]",
			"title": "ELECTRICAL GRID BLACKOUT",
			"room": "Target: Electrical Junction Hub",
			"desc": "Cuts station lighting grid. Plunges corridors into deep noir shadows and limits crew flashlight range.",
			"col": Color(1.0, 0.75, 0.15),
			"type": GameEnums.SabotageType.LIGHTS
		},
		{
			"key": "[3]",
			"title": "COMMUNICATIONS & RADAR JAMMER",
			"room": "Target: Communications Deck",
			"desc": "Scrambles minimap radar telemetry, disables CCTV camera logs, and hides room labels.",
			"col": Color(0.0, 0.85, 1.0),
			"type": GameEnums.SabotageType.COMMUNICATIONS
		},
		{
			"key": "[4]",
			"title": "ATMOSPHERIC O2 DEPLETION",
			"room": "Target: Life Support & Storage",
			"desc": "Vents breathable oxygen from life support. 35s countdown until atmospheric collapse.",
			"col": Color(0.4, 0.95, 0.7),
			"type": GameEnums.SabotageType.OXYGEN
		}
	]

	var card_w: float = 640.0
	var card_x: float = (vp.x - card_w) * 0.5
	var cy: float = 150.0

	var is_busy: bool = (active_sabotage != GameEnums.SabotageType.NONE)

	for i in range(4):
		var c: Dictionary = cards[i]
		var card_r := Rect2(card_x, cy, card_w, 78)
		var is_hovered := (hovered_idx == i) and not is_busy
		var bg_col := Color(0.14, 0.05, 0.08) if not is_hovered else Color(0.24, 0.08, 0.12)
		draw_rect(card_r, bg_col)
		draw_rect(card_r, c["col"] * (1.2 if is_hovered else 0.7), false, 1.6 if is_hovered else 1.0)

		# Key Shortcut Pill
		var key_rect := Rect2(card_x + 16, cy + 22, 38, 34)
		draw_rect(key_rect, c["col"] * 0.25)
		draw_rect(key_rect, c["col"], false, 1.2)
		draw_string(ThemeDB.fallback_font, Vector2(key_rect.position.x, key_rect.position.y + 22), c["key"], HORIZONTAL_ALIGNMENT_CENTER, int(key_rect.size.x), 13, c["col"])

		# Title & Location
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 66, cy + 26), c["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 66, cy + 44), c["room"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, c["col"])
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 66, cy + 62), c["desc"], HORIZONTAL_ALIGNMENT_LEFT, int(card_w - 180), 9, Color(0.8, 0.85, 0.9))

		# Status Badge on right
		var status_rect := Rect2(card_x + card_w - 110, cy + 24, 96, 30)
		if is_busy and active_sabotage == c["type"]:
			draw_rect(status_rect, Color(0.85, 0.1, 0.2, 0.8))
			draw_string(ThemeDB.fallback_font, Vector2(status_rect.position.x, status_rect.position.y + 20), "ACTIVE", HORIZONTAL_ALIGNMENT_CENTER, int(status_rect.size.x), 11, Color(1, 1, 1))
		elif is_busy:
			draw_rect(status_rect, Color(0.2, 0.2, 0.25, 0.7))
			draw_string(ThemeDB.fallback_font, Vector2(status_rect.position.x, status_rect.position.y + 20), "BLOCKED", HORIZONTAL_ALIGNMENT_CENTER, int(status_rect.size.x), 10, Color(0.6, 0.6, 0.6))
		else:
			draw_rect(status_rect, c["col"] * 0.25)
			draw_rect(status_rect, c["col"], false, 1.2)
			draw_string(ThemeDB.fallback_font, Vector2(status_rect.position.x, status_rect.position.y + 20), "TRIGGER", HORIZONTAL_ALIGNMENT_CENTER, int(status_rect.size.x), 11, c["col"])

		cy += 90.0

	# Footer Prompt
	var foot_y := panel_y + panel_h - 18
	draw_string(ThemeDB.fallback_font, Vector2(panel_x, foot_y), "PRESS [1-4] OR CLICK TO ACTIVATE  •  [ESC / C] CLOSE MATRIX", HORIZONTAL_ALIGNMENT_CENTER, int(panel_w), 10, Color(0.7, 0.5, 0.6))
