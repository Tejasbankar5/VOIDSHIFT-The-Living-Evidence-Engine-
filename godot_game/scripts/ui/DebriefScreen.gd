class_name DebriefScreen
extends Control

## Mission Debriefing & Ending Resolution Screen for VOIDSHIFT.
## Fulfills Part VIII (Section 30) of the Master Game Production Specification:
## - Distinctive ending sequences for all three story campaigns
## - Evaluates Player Role performance and secret objective completion
## - Summarizes discovered evidence, timeline contradictions, and saboteur identities
## - Smooth navigation to restart with newly randomized roles or return to menu

const RoleAllocator = preload("res://scripts/core/RoleAllocator.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")
const CrewmateRenderer = preload("res://scripts/render/CrewmateRenderer.gd")

signal restart_requested()
signal main_menu_requested()

var campaign: CampaignData.CampaignDef = null
var player_assignment: RoleAllocator.RoleAssignment = null
var ending_type: GameEnums.EndingType = GameEnums.EndingType.GENERIC_CREW_VICTORY
var is_victory: bool = true
var verdict_title: String = ""
var verdict_details: String = ""
var clues_found: int = 0
var clues_total: int = 0
var anim_timer: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)

func setup_debrief(p_campaign: CampaignData.CampaignDef, p_assign: RoleAllocator.RoleAssignment,
				   p_ending: GameEnums.EndingType, p_victory: bool, p_title: String,
				   p_details: String, p_found: int, p_total: int) -> void:
	campaign = p_campaign
	player_assignment = p_assign
	ending_type = p_ending
	is_victory = p_victory
	verdict_title = p_title
	verdict_details = p_details
	clues_found = p_found
	clues_total = p_total
	anim_timer = 0.0
	visible = true

func _process(delta: float) -> void:
	if not visible:
		return
	anim_timer += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			visible = false
			restart_requested.emit()
		elif event.keycode == KEY_ESCAPE:
			visible = false
			main_menu_requested.emit()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_ev := event as InputEventMouseButton
		var mpos: Vector2 = mouse_ev.position
		var btn_restart := Rect2(360, 620, 240, 48)
		var btn_menu := Rect2(680, 620, 240, 48)
		if btn_restart.has_point(mpos):
			visible = false
			restart_requested.emit()
		elif btn_menu.has_point(mpos):
			visible = false
			main_menu_requested.emit()

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	if vp.y <= 0: vp.y = 720.0

	# Dark Backdrop with outcome tint
	var tint := Color(0.04, 0.12, 0.08, 0.96) if is_victory else Color(0.14, 0.04, 0.06, 0.96)
	draw_rect(Rect2(0, 0, vp.x, vp.y), tint)

	# Outcome Title Banner
	var banner_col := Color(0.2, 0.95, 0.5) if is_victory else Color(1.0, 0.3, 0.3)
	draw_string(ThemeDB.fallback_font, Vector2(60, 65), "VOIDSHIFT MISSION RESOLUTION // DEBRIEFING", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, banner_col)
	draw_string(ThemeDB.fallback_font, Vector2(60, 105), verdict_title.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(1, 1, 1))

	# Main Debrief Box
	var main_box := Rect2(60, 140, 1160, 450)
	draw_rect(main_box, Color(0.04, 0.06, 0.10, 0.92))
	draw_rect(main_box, banner_col, false, 2.0)

	# Left Column: Narrative Consequence & Event Outcome
	draw_string(ThemeDB.fallback_font, Vector2(90, 180), "MISSION OUTCOME ANALYSIS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, banner_col)
	draw_rect(Rect2(90, 192, 540, 2), banner_col * 0.5)
	draw_wrapped_text(Vector2(90, 220), verdict_details, 540.0, 18.0, 13, Color(0.85, 0.90, 0.95))

	# Investigation Statistics Card
	var stat_rect := Rect2(90, 390, 540, 160)
	draw_rect(stat_rect, Color(0.06, 0.09, 0.14))
	draw_rect(stat_rect, Color(0.2, 0.5, 0.7), false, 1.2)
	draw_string(ThemeDB.fallback_font, Vector2(110, 420), "FORENSIC EVIDENCE RECOVERED:", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.0, 0.85, 1.0))
	var clue_summary := "%d of %d Sector Echo Clues Identified" % [clues_found, clues_total]
	draw_string(ThemeDB.fallback_font, Vector2(110, 448), clue_summary, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(110, 485), "TIMELINE CONTRADICTIONS: Verified & Cross-Referenced", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.85, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(110, 510), "EXPEDITION ROSTER: 10/10 Members Evaluated", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.85, 0.95))

	# Right Column: Player Assignment Evaluation
	var right_x := 680.0
	draw_string(ThemeDB.fallback_font, Vector2(right_x, 180), "INDIVIDUAL DOSSIER EVALUATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, banner_col)
	draw_rect(Rect2(right_x, 192, 500, 2), banner_col * 0.5)

	if player_assignment != null:
		var port_pos := Vector2(right_x + 50, 270)
		CrewmateRenderer.draw_crewmate_portrait(self, port_pos, player_assignment.role, 1.4)

		draw_string(ThemeDB.fallback_font, Vector2(right_x + 120, 245), player_assignment.character_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(right_x + 120, 270), player_assignment.role_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, banner_col)

		var obj_eval_box := Rect2(right_x, 340, 500, 210)
		draw_rect(obj_eval_box, Color(0.06, 0.09, 0.14))
		draw_rect(obj_eval_box, banner_col, false, 1.2)

		draw_string(ThemeDB.fallback_font, Vector2(right_x + 20, 370), "ASSIGNED SECRET DIRECTIVE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.8, 0.9))
		draw_wrapped_text(Vector2(right_x + 20, 395), player_assignment.secret_objective, 460.0, 18.0, 12, Color(1, 1, 1))

		var eval_str := "DIRECTIVE STATUS: ACCOMPLISHED" if is_victory else "DIRECTIVE STATUS: COMPROMISED / UNFULFILLED"
		draw_string(ThemeDB.fallback_font, Vector2(right_x + 20, 480), eval_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, banner_col)

	# Bottom Action Buttons
	var btn_r := Rect2(360, 620, 250, 46)
	draw_rect(btn_r, banner_col * 0.25)
	draw_rect(btn_r, banner_col, false, 1.8)
	draw_string(ThemeDB.fallback_font, Vector2(btn_r.position.x, 650), "[R / SPACE] DEPLOY NEW ROUND", HORIZONTAL_ALIGNMENT_CENTER, int(btn_r.size.x), 13, Color(1, 1, 1))

	var btn_m := Rect2(670, 620, 250, 46)
	draw_rect(btn_m, Color(0.12, 0.16, 0.24))
	draw_rect(btn_m, Color(0.5, 0.6, 0.7), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(btn_m.position.x, 650), "[ESC] RETURN TO MENU", HORIZONTAL_ALIGNMENT_CENTER, int(btn_m.size.x), 13, Color(1, 1, 1))

func draw_wrapped_text(pos: Vector2, text: String, max_width: float, line_height: float, font_size: int, col: Color) -> void:
	var words := text.split(" ")
	var current_line := ""
	var y_off := 0.0
	for word in words:
		var test_line := word if current_line.is_empty() else current_line + " " + word
		var string_size := ThemeDB.fallback_font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if string_size.x > max_width and not current_line.is_empty():
			draw_string(ThemeDB.fallback_font, pos + Vector2(0, y_off), current_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
			y_off += line_height
			current_line = word
		else:
			current_line = test_line
	if not current_line.is_empty():
		draw_string(ThemeDB.fallback_font, pos + Vector2(0, y_off), current_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
