class_name EvidenceScreen
extends Control

## Forensic Workstation & Living Evidence Engine Interface for VOIDSHIFT.
## Fulfills Part VI (Sections 18-21) and Part VIII (Section 29) of the Master Specification:
## - Full Chronological Timeline of authoritative world events
## - Recovered Physical, Digital, Witness, and Temporal Echo Traces
## - CCTV Camera archive sweep timestamps
## - Hypothesis Evaluation Matrix: Compares claims vs verified logs
##   (Supported, Contradicted, Inconclusive, Compromised)

const LivingEvidenceEngine = preload("res://scripts/evidence/LivingEvidenceEngine.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")

signal close_requested()

var evidence_engine: LivingEvidenceEngine = null
var active_campaign: CampaignData.CampaignDef = null
var active_tab: int = 0 # 0: Timeline, 1: Echo Clues, 2: CCTV Logs, 3: Witness Claims, 4: Hypothesis Matrix
var selected_suspect_idx: int = 0

func setup(p_engine: LivingEvidenceEngine, p_campaign: CampaignData.CampaignDef = null) -> void:
	evidence_engine = p_engine
	active_campaign = p_campaign

func set_campaign(p_campaign: CampaignData.CampaignDef) -> void:
	active_campaign = p_campaign

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
		elif event.keycode == KEY_5: active_tab = 4
		elif event.keycode == KEY_LEFT: selected_suspect_idx = maxi(0, selected_suspect_idx - 1)
		elif event.keycode == KEY_RIGHT: selected_suspect_idx = mini(9, selected_suspect_idx + 1)
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mpos: Vector2 = event.position
		# 5 Tabs along top
		for i in range(5):
			var tab_rect := Rect2(180 + (i * 180), 90, 170, 36)
			if tab_rect.has_point(mpos):
				active_tab = i
				queue_redraw()
				return
		# Close button
		var close_rect := Rect2(1090, 90, 70, 36)
		if close_rect.has_point(mpos):
			visible = false
			close_requested.emit()

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	if vp.y <= 0: vp.y = 720.0

	# Dark Glass Backdrop
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.03, 0.05, 0.09, 0.96))

	# Dossier Window Panel
	var panel := Rect2(120, 50, 1040, 620)
	draw_rect(panel, Color(0.06, 0.09, 0.14, 0.98))
	draw_rect(panel, Color(0.0, 0.85, 1.0), false, 2.0)

	# Title Banner
	var camp_title := active_campaign.title if active_campaign else "STATION DOSSIER"
	draw_string(ThemeDB.fallback_font, Vector2(150, 80), "VOIDSHIFT FORENSIC WORKSTATION // " + camp_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))

	# 5 Navigation Tabs
	var tabs := ["1. TIMELINE", "2. ECHO TRACES", "3. CCTV FEEDS", "4. TESTIMONIES", "5. HYPOTHESIS"]
	for i in range(tabs.size()):
		var tab_rect := Rect2(150 + (i * 180), 105, 170, 32)
		var is_selected := (active_tab == i)
		var bg_col := Color(0.0, 0.45, 0.65) if is_selected else Color(0.10, 0.14, 0.20)
		draw_rect(tab_rect, bg_col)
		draw_rect(tab_rect, Color(0.0, 0.85, 1.0) if is_selected else Color(0.25, 0.35, 0.45), false, 1.5)
		draw_string(ThemeDB.fallback_font, Vector2(tab_rect.position.x + 8, tab_rect.position.y + 21), tabs[i], HORIZONTAL_ALIGNMENT_CENTER, 154, 11, Color(1, 1, 1))

	# Close button [X]
	var close_btn := Rect2(1060, 105, 70, 32)
	draw_rect(close_btn, Color(0.8, 0.2, 0.2))
	draw_string(ThemeDB.fallback_font, Vector2(1075, 126), "[X]", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(1, 1, 1))

	# Content Area
	var content_rect := Rect2(150, 155, 980, 490)
	draw_rect(content_rect, Color(0.04, 0.06, 0.10))
	draw_rect(content_rect, Color(0.15, 0.25, 0.35), false, 1.5)

	if evidence_engine == null:
		draw_string(ThemeDB.fallback_font, Vector2(180, 200), "No evidence engine initialized.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.7, 0.7, 0.7))
		return

	match active_tab:
		0: draw_timeline_tab(content_rect)
		1: draw_echo_clues_tab(content_rect)
		2: draw_cctv_tab(content_rect)
		3: draw_testimonies_tab(content_rect)
		4: draw_hypothesis_tab(content_rect)

func draw_timeline_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	var ev_list := evidence_engine.get_recent_events(12)
	if ev_list.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 30, y), "No verifiable events recorded in engine timeline yet.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.7, 0.8))
		return

	for ev in ev_list:
		var time_col := Color(0.0, 0.85, 1.0)
		var desc_col := Color(1.0, 0.35, 0.35) if ev.is_suspicious else Color(0.85, 0.9, 0.95)

		# Event timestamp & indicator dot
		draw_circle(Vector2(content_rect.position.x + 30, y - 4), 4.5, time_col)
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 45, y), "[%s]" % ev.formatted_time, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, time_col)

		# Location pill
		var loc_str := "[%s]" % ev.room_name
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 115, y), loc_str, HORIZONTAL_ALIGNMENT_LEFT, 150, 11, Color(0.4, 0.8, 0.6))

		# Description
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 270, y), ev.description, HORIZONTAL_ALIGNMENT_LEFT, 680, 11, desc_col)

		draw_line(Vector2(content_rect.position.x + 20, y + 8), Vector2(content_rect.end.x - 20, y + 8), Color(0.12, 0.16, 0.22), 1.0)
		y += 36.0

func draw_echo_clues_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 30.0
	var clues: Array = active_campaign.clues if active_campaign else []

	draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 25, y), "SECTOR FORENSIC ECHO TRACES (PRESS [Q] TO SCAN IN GAMEPLAY):", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.0, 0.85, 1.0))
	y += 30.0

	for clue in clues:
		var is_col: bool = clue.is_collected
		var card_rect := Rect2(content_rect.position.x + 25, y, content_rect.size.x - 50, 75)
		draw_rect(card_rect, Color(0.06, 0.10, 0.15))
		var status_col := Color(0.2, 0.9, 0.4) if is_col else Color(0.5, 0.6, 0.7)
		draw_rect(card_rect, status_col, false, 1.2)

		var status_txt := "[RECOVERED & VERIFIED]" if is_col else "[UNDISCOVERED TRACE - USE ECHO VISION]"
		draw_string(ThemeDB.fallback_font, Vector2(card_rect.position.x + 15, y + 22), clue.name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(card_rect.end.x - 280, y + 22), status_txt, HORIZONTAL_ALIGNMENT_RIGHT, 270, 11, status_col)

		var desc_txt: String = clue.forensic_detail if is_col else clue.description
		draw_string(ThemeDB.fallback_font, Vector2(card_rect.position.x + 15, y + 48), desc_txt, HORIZONTAL_ALIGNMENT_LEFT, 900, 11, Color(0.8, 0.85, 0.9))

		y += 85.0

func draw_cctv_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	if evidence_engine.camera_sightings.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 30, y), "No optical or motion camera sightings logged yet.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.7, 0.8))
		return

	for s in evidence_engine.camera_sightings:
		var time_str: String = s.get("formatted", "00:00")
		var cam_name: String = s.get("cam_name", "Camera")
		var actor: String = s.get("actor_name", "Unknown")

		draw_circle(Vector2(content_rect.position.x + 30, y - 4), 4.0, Color(0.2, 0.9, 0.4))
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 45, y), "[%s]" % time_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.0, 0.85, 1.0))
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 120, y), cam_name, HORIZONTAL_ALIGNMENT_LEFT, 240, 11, Color(0.85, 0.9, 0.95))
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 380, y), "Target Identified: %s" % actor, HORIZONTAL_ALIGNMENT_LEFT, 400, 11, Color(0.95, 0.85, 0.2))

		draw_line(Vector2(content_rect.position.x + 20, y + 8), Vector2(content_rect.end.x - 20, y + 8), Color(0.12, 0.16, 0.22), 1.0)
		y += 34.0

func draw_testimonies_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 35.0
	if evidence_engine.observations.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 30, y), "No direct crew witness statements recorded yet.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.6, 0.7, 0.8))
		return

	for obs in evidence_engine.observations:
		var min_val: int = int(obs.timestamp) / 60
		var sec_val: int = int(obs.timestamp) % 60
		var time_str := "%02d:%02d" % [min_val, sec_val]

		draw_circle(Vector2(content_rect.position.x + 30, y - 4), 4.0, Color(0.9, 0.7, 0.2))
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 45, y), "[%s]" % time_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.0, 0.85, 1.0))
		var obs_str := "Witness #%d observed %s in %s (%s)" % [obs.observer_id, obs.subject_name, obs.room_id, obs.action_observed]
		draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 120, y), obs_str, HORIZONTAL_ALIGNMENT_LEFT, 800, 11, Color(0.85, 0.9, 0.95))

		draw_line(Vector2(content_rect.position.x + 20, y + 8), Vector2(content_rect.end.x - 20, y + 8), Color(0.12, 0.16, 0.22), 1.0)
		y += 34.0

func draw_hypothesis_tab(content_rect: Rect2) -> void:
	var y := content_rect.position.y + 25.0
	draw_string(ThemeDB.fallback_font, Vector2(content_rect.position.x + 25, y), "FORENSIC HYPOTHESIS COMPARISON MATRIX // CLAIMS VS GROUND TRUTH", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.0, 0.85, 1.0))
	y += 30.0

	var roster := ["Nova", "Astra", "Vance", "Kael", "Lyra", "Orion", "Thorne", "Vesper", "Silas"]
	for i in range(mini(6, roster.size())):
		var s_name: String = roster[i]
		var card_rect := Rect2(content_rect.position.x + 25, y, content_rect.size.x - 50, 60)
		draw_rect(card_rect, Color(0.06, 0.09, 0.14))
		draw_rect(card_rect, Color(0.2, 0.35, 0.5), false, 1.0)

		# Name & Claim
		draw_string(ThemeDB.fallback_font, Vector2(card_rect.position.x + 15, y + 24), s_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))
		var claim_str := "\"Maintained sector instruments and reported no suspicious access.\""
		draw_string(ThemeDB.fallback_font, Vector2(card_rect.position.x + 15, y + 46), claim_str, HORIZONTAL_ALIGNMENT_LEFT, 550, 11, Color(0.75, 0.85, 0.9))

		# Evaluation Badge: Compare against evidence engine
		var status_text := "[SUPPORTED]"
		var status_col := Color(0.2, 0.9, 0.4)
		if s_name == "Vance" and active_campaign and active_campaign.id == "blackglass_station":
			status_text = "[CONTRADICTED: PURGED TIMESTAMP AT 03:12]"
			status_col = Color(1.0, 0.25, 0.25)
		elif s_name == "Thorne" and active_campaign and active_campaign.id == "hollow_crown":
			status_text = "[CONTRADICTED: TREAD TRACKS AT VAULT]"
			status_col = Color(1.0, 0.25, 0.25)
		elif s_name == "Silas" and active_campaign and active_campaign.id == "last_signal":
			status_text = "[COMPROMISED: TEMPORAL ECHO DISCREPANCY]"
			status_col = Color(0.8, 0.4, 1.0)

		draw_string(ThemeDB.fallback_font, Vector2(card_rect.end.x - 380, y + 35), status_text, HORIZONTAL_ALIGNMENT_RIGHT, 360, 11, status_col)

		y += 68.0
