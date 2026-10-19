class_name InterrogationDialog
extends Control

## Interactive Dialogue & Interrogation Interface for VOIDSHIFT.
## Displays suspect anime portrait, initial testimony, declared alibi,
## and dynamic forensic cross-examination based on recovered clues.

const CampaignData = preload("res://scripts/core/CampaignData.gd")
const LivingEvidenceEngine = preload("res://scripts/evidence/LivingEvidenceEngine.gd")

signal dialogue_closed()
signal contradiction_confronted(suspect: CampaignData.SuspectDef, clue: CampaignData.EchoClueDef)

var current_suspect: CampaignData.SuspectDef = null
var current_campaign: CampaignData.CampaignDef = null
var evidence_engine: LivingEvidenceEngine = null
var portrait_texture: Texture2D = null
var contradicting_clue: CampaignData.EchoClueDef = null
var is_confronted: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)
	visible = false

func open_interrogation(suspect: CampaignData.SuspectDef, campaign: CampaignData.CampaignDef, engine: LivingEvidenceEngine) -> void:
	current_suspect = suspect
	current_campaign = campaign
	evidence_engine = engine
	is_confronted = false
	contradicting_clue = null

	# Load character portrait if available
	portrait_texture = null
	if not suspect.portrait_path.is_empty():
		var gpath := ProjectSettings.globalize_path(suspect.portrait_path)
		var img := Image.load_from_file(gpath)
		if img != null and not img.is_empty():
			portrait_texture = ImageTexture.create_from_image(img)
		elif ResourceLoader.exists(suspect.portrait_path):
			portrait_texture = load(suspect.portrait_path)

	# Scan for recovered contradictory evidence
	if campaign != null:
		for clue in campaign.clues:
			if clue.is_collected and clue.contradiction_target == suspect.id:
				contradicting_clue = clue
				break

	visible = true
	queue_redraw()

func close_dialogue() -> void:
	visible = false
	dialogue_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE, KEY_SPACE:
				close_dialogue()
			KEY_1, KEY_E:
				# Log statement in engine
				if evidence_engine != null and current_suspect != null:
					evidence_engine.record_event(
						0.0, 1, 0, "Rex", -1, current_suspect.name,
						current_suspect.location, current_suspect.location,
						"Questioned %s: \"%s\"" % [current_suspect.name, current_suspect.initial_statement],
						false
					)
				close_dialogue()
			KEY_2, KEY_C:
				if contradicting_clue != null:
					is_confronted = true
					contradiction_confronted.emit(current_suspect, contradicting_clue)
					if evidence_engine != null:
						evidence_engine.record_event(
							0.0, 1, 0, "Rex", -1, current_suspect.name,
							current_suspect.location, current_suspect.location,
							"CONFRONTATION: Presented %s to %s. Suspect alibi shattered." % [contradicting_clue.name, current_suspect.name],
							true
						)
					queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_ev := event as InputEventMouseButton
		var mpos: Vector2 = mouse_ev.position
		# Close button
		var close_btn := Rect2(1040, 140, 40, 36)
		if close_btn.has_point(mpos):
			close_dialogue()
			return

		# Action 1 button: Return
		var btn1 := Rect2(200, 520, 240, 42)
		if btn1.has_point(mpos):
			close_dialogue()
			return

		# Action 2 button: Confront
		var btn2 := Rect2(460, 520, 320, 42)
		if btn2.has_point(mpos) and contradicting_clue != null:
			is_confronted = true
			if evidence_engine != null and current_suspect != null:
				evidence_engine.record_event(
					0.0, 1, 0, "Rex", -1, current_suspect.name,
					current_suspect.location, current_suspect.location,
					"CONFRONTATION: Presented %s to %s." % [contradicting_clue.name, current_suspect.name],
					true
				)
			queue_redraw()
			return

		# Click outside modal closes it
		var modal_rect := Rect2(180, 120, 920, 470)
		if not modal_rect.has_point(mpos):
			close_dialogue()

func _draw() -> void:
	if not visible or current_suspect == null:
		return

	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	if vp.y <= 0: vp.y = 720.0

	# Translucent background backdrop
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.01, 0.02, 0.04, 0.85))

	# Dialogue Modal Box
	var modal := Rect2(180, 120, 920, 470)
	var accent_col: Color = current_campaign.accent_color if current_campaign else Color(0.0, 0.85, 1.0)
	draw_rect(modal, Color(0.05, 0.07, 0.11, 0.98))
	draw_rect(modal, accent_col, false, 2.0)

	# Close button [X]
	var close_btn := Rect2(1040, 135, 40, 32)
	draw_rect(close_btn, Color(0.7, 0.2, 0.2, 0.8))
	draw_string(ThemeDB.fallback_font, Vector2(1052, 156), "X", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

	# Portrait Frame (Left Column)
	var port_rect := Rect2(210, 160, 190, 190)
	draw_rect(port_rect, Color(0.08, 0.12, 0.18))
	draw_rect(port_rect, accent_col, false, 2.0)

	if portrait_texture != null:
		draw_texture_rect(portrait_texture, port_rect, false)
	else:
		draw_string(ThemeDB.fallback_font, Vector2(port_rect.position.x + 20, port_rect.position.y + 100),
			"[NO PORTRAIT]", HORIZONTAL_ALIGNMENT_CENTER, 150, 11, Color(0.6, 0.7, 0.8))

	# Location badge under portrait
	var loc_badge := Rect2(210, 360, 190, 24)
	draw_rect(loc_badge, Color(0.12, 0.16, 0.24))
	draw_string(ThemeDB.fallback_font, Vector2(loc_badge.position.x, loc_badge.position.y + 17),
		"LOCATION: " + current_suspect.location.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 190, 10, Color(0.7, 0.85, 1.0))

	# Suspect Name & Title Header
	var text_x: float = 430.0
	var name_str := "%s  //  %s" % [current_suspect.name.to_upper(), current_suspect.title.to_upper()]
	draw_string(ThemeDB.fallback_font, Vector2(text_x, 170), name_str, HORIZONTAL_ALIGNMENT_LEFT, 580, 18, Color(1, 1, 1))
	draw_line(Vector2(text_x, 185), Vector2(1040, 185), accent_col * Color(1, 1, 1, 0.6), 1.5)

	# Section 1: Initial Statement / Testimony
	draw_string(ThemeDB.fallback_font, Vector2(text_x, 215), "TESTIMONY & ACCOUNT:", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, accent_col)
	var stmt_quote := "\"%s\"" % current_suspect.initial_statement
	draw_string(ThemeDB.fallback_font, Vector2(text_x, 240), stmt_quote, HORIZONTAL_ALIGNMENT_LEFT, 610, 12, Color(0.92, 0.94, 0.98))

	# Section 2: Claimed Alibi
	draw_string(ThemeDB.fallback_font, Vector2(text_x, 290), "DECLARED ALIBI:", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.85, 0.65))
	var alibi_str := "\"%s\"" % current_suspect.alibi
	draw_string(ThemeDB.fallback_font, Vector2(text_x, 312), alibi_str, HORIZONTAL_ALIGNMENT_LEFT, 610, 11, Color(0.80, 0.88, 0.95))

	# Section 3: Forensic Cross-Examination & Contradictions
	var sec_y: float = 355.0
	draw_string(ThemeDB.fallback_font, Vector2(text_x, sec_y), "FORENSIC CROSS-EXAMINATION:", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.75, 0.2))

	if contradicting_clue != null:
		var warn_box := Rect2(text_x, sec_y + 12, 620, 60)
		var box_bg := Color(0.4, 0.1, 0.1, 0.7) if is_confronted else Color(0.25, 0.18, 0.05, 0.8)
		var box_border := Color(1.0, 0.25, 0.25) if is_confronted else Color(1.0, 0.75, 0.2)
		draw_rect(warn_box, box_bg)
		draw_rect(warn_box, box_border, false, 1.5)

		var title_msg := "[CONTRADICTION DETECTED — ALIBI SHATTERED]" if is_confronted else "[CONTRADICTION FOUND IN RECOVERED EVIDENCE]"
		draw_string(ThemeDB.fallback_font, Vector2(text_x + 12, sec_y + 32), title_msg, HORIZONTAL_ALIGNMENT_LEFT, 590, 11, box_border)

		var detail_msg := ""
		if is_confronted:
			detail_msg = "Motive Confessed: %s" % current_suspect.secret_motive
		else:
			detail_msg = "Clue '%s': %s" % [contradicting_clue.name, contradicting_clue.forensic_detail]
		draw_string(ThemeDB.fallback_font, Vector2(text_x + 12, sec_y + 55), detail_msg, HORIZONTAL_ALIGNMENT_LEFT, 595, 10, Color(1, 1, 1))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(text_x, sec_y + 25),
			"No direct contradictory evidence recovered yet. Search the sector for physical & digital traces.",
			HORIZONTAL_ALIGNMENT_LEFT, 600, 11, Color(0.65, 0.72, 0.80))

	# Interactive Action Buttons Along Bottom
	# Button 1: Return / End Conversation
	var btn1 := Rect2(text_x, 475, 220, 36)
	draw_rect(btn1, Color(0.12, 0.18, 0.28))
	draw_rect(btn1, Color(0.3, 0.5, 0.7), false, 1.2)
	draw_string(ThemeDB.fallback_font, Vector2(btn1.position.x, btn1.position.y + 23),
		"[1] Return to Search [ESC]", HORIZONTAL_ALIGNMENT_CENTER, 220, 11, Color(0.85, 0.92, 1.0))

	# Button 2: Confront with Evidence (if clue found)
	if contradicting_clue != null:
		var btn2 := Rect2(text_x + 240, 475, 280, 36)
		var b2_col := Color(0.7, 0.15, 0.15) if is_confronted else Color(0.85, 0.55, 0.1)
		draw_rect(btn2, b2_col * Color(1, 1, 1, 0.85))
		draw_rect(btn2, Color.WHITE, false, 1.5)
		var confront_str := "[CONFRONTED]" if is_confronted else "[2] Confront with Evidence [C]"
		draw_string(ThemeDB.fallback_font, Vector2(btn2.position.x, btn2.position.y + 23),
			confront_str, HORIZONTAL_ALIGNMENT_CENTER, 280, 11, Color.WHITE)
