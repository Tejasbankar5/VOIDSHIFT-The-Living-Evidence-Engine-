class_name EvidenceScreen
extends Control

## Full-screen Living Evidence Engine dossier for VOIDSHIFT.
## Accessed via TAB key during gameplay for deduction and investigation.

signal close_requested()

var evidence_engine: LivingEvidenceEngine = null
var active_tab: int = 0 # 0: Timeline, 1: Sightings, 2: Cameras, 3: Contradictions

func setup(p_engine: LivingEvidenceEngine) -> void:
	evidence_engine = p_engine

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("toggle_evidence") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		visible = false
		close_requested.emit()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_1: active_tab = 0
		elif event.keycode == KEY_2: active_tab = 1
		elif event.keycode == KEY_3: active_tab = 2
		elif event.keycode == KEY_4: active_tab = 3
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_ev := event as InputEventMouseButton
		var mpos: Vector2 = mouse_ev.position
		# Tabs along top
		for i in range(4):
			var tab_rect := Rect2(220 + (i * 180), 90, 160, 36)
			if tab_rect.has_point(mpos):
				active_tab = i
				queue_redraw()
				return
		# Close button
		var close_rect := Rect2(1040, 90, 80, 36)
		if close_rect.has_point(mpos):
			visible = false
			close_requested.emit()

func _draw() -> void:
	# Dark transparent overlay
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.04, 0.06, 0.10, 0.94))

	# Dossier Window Panel
	var panel := Rect2(160, 60, 960, 600)
	draw_rect(panel, Color(0.08, 0.12, 0.18, 0.98))
	draw_rect(panel, Color(0.0, 0.85, 1.0), false, 2.0)

	# Title Banner
	draw_string(ThemeDB.fallback_font, Vector2(200, 95), "VOIDSHIFT: THE LIVING EVIDENCE ENGINE — STATION DOSSIER", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1))

	# Tabs
	var tabs := ["1. TIMELINE", "2. WITNESS SIGHTINGS", "3. CCTV LOGS", "4. CONTRADICTIONS"]
	for i in range(tabs.size()):
		var tab_rect := Rect2(200 + (i * 190), 115, 175, 32)
		var is_selected := (active_tab == i)
		var bg_col := Color(0.0, 0.5, 0.7) if is_selected else Color(0.12, 0.16, 0.22)
		draw_rect(tab_rect, bg_col)
		draw_rect(tab_rect, Color(0.0, 0.85, 1.0) if is_selected else Color(0.3, 0.4, 0.5), false, 1.5)
		draw_string(ThemeDB.fallback_font, Vector2(tab_rect.position.x + 10, tab_rect.position.y + 21), tabs[i], HORIZONTAL_ALIGNMENT_CENTER, 155, 11, Color(1, 1, 1))

	# Close button [X]
	var close_btn := Rect2(1040, 115, 60, 32)
	draw_rect(close_btn, Color(0.8, 0.2, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(1060, 136), "[X]", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(1, 1, 1))

	# Content Area
	var content_rect := Rect2(200, 165, 880, 470)
	draw_rect(content_rect, Color(0.05, 0.08, 0.12))
	draw_rect(content_rect, Color(0.15, 0.25, 0.35), false, 1.5)

	if evidence_engine == null:
		draw_string(ThemeDB.fallback_font, Vector2(240, 220), "No evidence recorded yet.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.7, 0.7))
		return

	match active_tab:
		0:
			draw_timeline_tab(content_rect)
		1:
			draw_sightings_tab(content_rect)
		2:
			draw_cctv_tab(content_rect)
		3:
			draw_contradictions_tab(content_rect)

func draw_timeline_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	var ev_list := evidence_engine.get_recent_events(12)
	if ev_list.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 30, y), "No station events recorded yet.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.7, 0.8))
		return

	for ev in ev_list:
		var time_col := Color(0.0, 0.85, 1.0)
		var desc_col := Color(1.0, 0.35, 0.35) if ev.is_suspicious else Color(0.85, 0.9, 0.95)
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 25, y), "[%s]" % ev.formatted_time, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, time_col)
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 100, y), ev.description, HORIZONTAL_ALIGNMENT_LEFT, 720, 12, desc_col)
		y += 32.0

func draw_sightings_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	if evidence_engine.observations.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 30, y), "No direct character sightings logged.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.7, 0.8))
		return

	var start_idx: int = maxi(0, evidence_engine.observations.size() - 12)
	for i in range(evidence_engine.observations.size() - 1, start_idx - 1, -1):
		var obs := evidence_engine.observations[i]
		var mins: int = int(obs.timestamp) / 60
		var secs: int = int(obs.timestamp) % 60
		var text := "[%02d:%02d] Subject '%s' was observed in %s (%s)" % [mins, secs, obs.subject_name, obs.room_id, obs.action_observed]
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 25, y), text, HORIZONTAL_ALIGNMENT_LEFT, 800, 12, Color(0.8, 0.95, 0.85))
		y += 32.0

func draw_cctv_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	if evidence_engine.camera_sightings.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 30, y), "No optical camera movements logged.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.7, 0.8))
		return

	var start_idx: int = maxi(0, evidence_engine.camera_sightings.size() - 12)
	for i in range(evidence_engine.camera_sightings.size() - 1, start_idx - 1, -1):
		var cam := evidence_engine.camera_sightings[i]
		var text := "[%s] CAMERA '%s' detected motion from crewmate '%s'" % [cam["formatted"], cam["cam_name"], cam["actor_name"]]
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 25, y), text, HORIZONTAL_ALIGNMENT_LEFT, 800, 12, Color(0.3, 0.8, 1.0))
		y += 32.0

func draw_contradictions_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 25, y), "AUTOMATED DEDUCTION & CONTRADICTION MATRIX", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 0.85, 0.2))
	y += 35.0

	var desc_lines := [
		"- Cross-references station timeline events against testimony claims.",
		"- Checks whether claimed room locations align with door sensors and camera logs.",
		"- Flags any temporal impossibilities (e.g. character seen in Reactor at 02:30 claiming to be in Medical)."
	]
	for l in desc_lines:
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 35, y), l, HORIZONTAL_ALIGNMENT_LEFT, 800, 11, Color(0.7, 0.8, 0.9))
		y += 24.0

	y += 15.0
	draw_rect(Rect2(content_rect.position.x + 25, y, 830, 180), Color(0.08, 0.12, 0.16))
	draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 45, y + 30), "STATUS: SCANNING ACTIVE LOGS...", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.0, 0.9, 0.8))
	draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 45, y + 60), "Use during Emergency Meetings to automatically highlight false alibis with [CONTRADICTION!] flags.", HORIZONTAL_ALIGNMENT_LEFT, 750, 12, Color(0.85, 0.9, 1.0))
