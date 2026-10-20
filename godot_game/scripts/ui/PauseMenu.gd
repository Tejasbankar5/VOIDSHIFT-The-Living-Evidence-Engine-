class_name PauseMenu
extends Control

## Tactical Pause Matrix and Mission Controls for VOIDSHIFT.
## Allows players to resume, view full operational controls, adjust audio,
## or safely return to the main menu without application crashes.

signal resume_requested()
signal return_to_menu_requested()
signal how_to_play_requested()
signal mute_toggled(is_muted: bool)

var is_audio_muted: bool = false
var show_controls_overlay: bool = false
var anim_timer: float = 0.0
var hovered_idx: int = -1

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)
	visible = false

func open(p_muted: bool = false) -> void:
	is_audio_muted = p_muted
	show_controls_overlay = false
	anim_timer = 0.0
	hovered_idx = -1
	visible = true

func close() -> void:
	visible = false
	show_controls_overlay = false

func _process(delta: float) -> void:
	if visible:
		anim_timer += delta
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		if show_controls_overlay:
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
				show_controls_overlay = false
				queue_redraw()
			return

		match event.keycode:
			KEY_ESCAPE, KEY_1:
				resume_requested.emit()
			KEY_2:
				show_controls_overlay = true
				queue_redraw()
			KEY_3:
				is_audio_muted = !is_audio_muted
				mute_toggled.emit(is_audio_muted)
				queue_redraw()
			KEY_4:
				return_to_menu_requested.emit()
			KEY_5:
				get_tree().quit()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	if vp.y <= 0: vp.y = 720.0

	if show_controls_overlay:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			show_controls_overlay = false
			queue_redraw()
		return

	var card_w: float = 460.0
	var card_x: float = (vp.x - card_w) * 0.5

	if event is InputEventMouseMotion:
		var mpos := (event as InputEventMouseMotion).position
		hovered_idx = -1
		var y := 240.0
		for i in range(5):
			var r := Rect2(card_x, y, card_w, 46)
			if r.has_point(mpos):
				hovered_idx = i
				break
			y += 56.0

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mpos := (event as InputEventMouseButton).position
		var y := 240.0
		for i in range(5):
			var r := Rect2(card_x, y, card_w, 46)
			if r.has_point(mpos):
				match i:
					0: resume_requested.emit()
					1: show_controls_overlay = true; queue_redraw()
					2:
						is_audio_muted = !is_audio_muted
						mute_toggled.emit(is_audio_muted)
						queue_redraw()
					3: return_to_menu_requested.emit()
					4: get_tree().quit()
				return
			y += 56.0

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0 or vp.y <= 0:
		vp = Vector2(1280, 720)

	# 1. Dark frosted glass backdrop
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.02, 0.04, 0.08, 0.88))

	if show_controls_overlay:
		draw_controls_guide(vp)
		return

	# 2. Main tactical modal panel
	var panel_w: float = 540.0
	var panel_h: float = 480.0
	var panel_x: float = (vp.x - panel_w) * 0.5
	var panel_y: float = (vp.y - panel_h) * 0.5
	var panel_rect := Rect2(panel_x, panel_y, panel_w, panel_h)

	draw_rect(panel_rect, Color(0.04, 0.07, 0.12, 0.96))
	var border_pulse: float = 0.8 + sin(anim_timer * 3.0) * 0.2
	draw_rect(panel_rect, Color(0.0, 0.85, 1.0) * border_pulse, false, 2.0)

	# Header Banner
	draw_string(ThemeDB.fallback_font, Vector2(panel_x + 30, panel_y + 40), "TACTICAL PAUSE MATRIX // DSS CHRONOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(panel_x + 30, panel_y + 58), "EXPEDITION SUSPENDED — SELECT PROTOCOL", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.0, 0.85, 1.0))
	draw_line(Vector2(panel_x + 30, panel_y + 68), Vector2(panel_x + panel_w - 30, panel_y + 68), Color(0.0, 0.85, 1.0, 0.4), 1.5)

	# 5 Action Cards
	var options := [
		{"num": "[1]", "title": "RESUME EXPEDITION", "sub": "Return directly to active sector gameplay", "col": Color(0.0, 0.95, 0.7)},
		{"num": "[2]", "title": "HOW TO PLAY & CONTROLS", "sub": "View keybinds, forensic systems, and objectives", "col": Color(0.0, 0.85, 1.0)},
		{"num": "[3]", "title": "AUDIO SYNTHESIZER: %s" % ("MUTED" if is_audio_muted else "ACTIVE"), "sub": "Toggle procedural audio generation & alarms", "col": Color(1.0, 0.75, 0.2) if is_audio_muted else Color(0.3, 0.9, 1.0)},
		{"num": "[4]", "title": "ABANDON TO MAIN MENU", "sub": "Conclude current match and return to title selection", "col": Color(1.0, 0.45, 0.45)},
		{"num": "[5]", "title": "QUIT TO DESKTOP", "sub": "Exit application completely", "col": Color(0.8, 0.3, 0.3)}
	]

	var card_w: float = 460.0
	var card_x: float = (vp.x - card_w) * 0.5
	var cy: float = panel_y + 90.0

	for i in range(options.size()):
		var opt = options[i]
		var is_hovered := (hovered_idx == i)
		var btn_rect := Rect2(card_x, cy, card_w, 46)
		var bg_col := Color(0.08, 0.14, 0.22, 0.95) if is_hovered else Color(0.03, 0.06, 0.11, 0.85)
		draw_rect(btn_rect, bg_col)
		draw_rect(btn_rect, opt["col"] * (1.2 if is_hovered else 0.6), false, 1.5 if is_hovered else 1.0)

		# Key Shortcut Pill
		var key_rect := Rect2(card_x + 12, cy + 10, 36, 26)
		draw_rect(key_rect, opt["col"] * 0.25)
		draw_rect(key_rect, opt["col"], false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(key_rect.position.x, key_rect.position.y + 17), opt["num"], HORIZONTAL_ALIGNMENT_CENTER, int(key_rect.size.x), 11, opt["col"])

		# Title & Subtitle
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 58, cy + 20), opt["title"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 58, cy + 35), opt["sub"], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.65, 0.78, 0.9))

		cy += 56.0

	# Footer
	var foot_y := panel_y + panel_h - 18
	draw_string(ThemeDB.fallback_font, Vector2(panel_x, foot_y), "PRESS [ESC / 1] TO RESUME  •  [ENTER / CLICK] CONFIRM", HORIZONTAL_ALIGNMENT_CENTER, int(panel_w), 9, Color(0.5, 0.7, 0.85))

func draw_controls_guide(vp: Vector2) -> void:
	var modal_w: float = 780.0
	var modal_h: float = 520.0
	var modal := Rect2((vp.x - modal_w) * 0.5, (vp.y - modal_h) * 0.5, modal_w, modal_h)

	draw_rect(modal, Color(0.03, 0.07, 0.13, 0.98))
	draw_rect(modal, Color(0.0, 0.85, 1.0), false, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 30, modal.position.y + 38), "EXPEDITION OPERATIONAL DIRECTIVE // FIELD MANUAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))
	draw_line(Vector2(modal.position.x + 30, modal.position.y + 48), Vector2(modal.position.x + modal_w - 30, modal.position.y + 48), Color(0.0, 0.85, 1.0, 0.4), 1.5)

	var controls := [
		"CREW & SOCIAL DEDUCTION CONTROLS:",
		"• WASD / Arrow Keys : Omnidirectional movement across the station corridors & bulkheads",
		"• [E] Contextual Interact : Perform maintenance tasks, repair active sabotages, or investigate clues",
		"• [E] or [R] Report Body : Instantly convene an emergency expedition meeting when discovering a fallen crewmate",
		"• [Q] or [F] Echo Vision : Toggle ultraviolet forensic sweep to illuminate hidden evidence & temporal footprints",
		"• [TAB] Evidence Workstation : Access chronological event logs, CCTV sightings, and contradiction analysis",
		"• [M] Tactical Map : Open full-screen architectural blueprint with live player coordinates",
		"• [ESC] Pause Menu : Suspend gameplay, review field manual, or toggle audio synthesizer",
		"",
		"SABOTEUR PROTOCOLS (INFILTRATOR & DISRUPTOR):",
		"• [SPACE] Eliminate Crewmate : Silently neutralize isolated targets within range (20s cooldown)",
		"• [C] or [Z] Tactical Sabotage : Trigger Reactor Overload (45s), Blackout, Comms Jammer, or O2 Depletion (35s)",
		"• [V] Vent Conduits : Enter sub-floor ventilation shafts; use [A] and [D] to traverse between rooms",
		"",
		"Click anywhere or press [ESC] to return to the Pause Matrix."
	]

	var y := modal.position.y + 75.0
	for l in controls:
		var is_hdr: bool = l.begins_with("CREW") or l.begins_with("SABOTEUR")
		var col := Color(0.0, 0.92, 1.0) if is_hdr else Color(0.85, 0.92, 0.98)
		if l.begins_with("Click"): col = Color(0.4, 0.8, 0.9)
		draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 30, y), l, HORIZONTAL_ALIGNMENT_LEFT, int(modal_w - 60), 10, col)
		y += 24.0
