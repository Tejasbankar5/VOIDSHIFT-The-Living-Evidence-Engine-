class_name BriefingScreen
extends Control

## Mission Briefing & Role Reveal Interface for VOIDSHIFT.
## Fulfills Part VIII (Section 27) of the Master Game Production Specification:
## - Atmospheric campaign introduction & sector briefing
## - High-impact animated holographic role card reveal
## - Confidential secret objective & specialist ability assignment
## - Strict concealment of other characters' hidden roles

const CrewmateRenderer = preload("res://scripts/render/CrewmateRenderer.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")
const RoleAllocator = preload("res://scripts/core/RoleAllocator.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")

signal deploy_requested()

var campaign: CampaignData.CampaignDef = null
var player_assignment: RoleAllocator.RoleAssignment = null
var anim_timer: float = 0.0
var card_flip_progress: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)

func setup_briefing(p_campaign: CampaignData.CampaignDef, p_assign: RoleAllocator.RoleAssignment) -> void:
	campaign = p_campaign
	player_assignment = p_assign
	anim_timer = 0.0
	card_flip_progress = 0.0
	visible = true

func _process(delta: float) -> void:
	if not visible:
		return
	anim_timer += delta
	card_flip_progress = minf(1.0, card_flip_progress + delta * 1.5)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_E:
			deploy()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var btn_rect := Rect2(460, 620, 360, 48)
		if btn_rect.has_point(event.position):
			deploy()

func deploy() -> void:
	visible = false
	deploy_requested.emit()

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	if vp.y <= 0: vp.y = 720.0

	# 1. Dark Glass Overlay Backdrop
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.02, 0.04, 0.07, 0.96))

	# Tactical scanline sweep
	var sweep_y: float = fmod(anim_timer * 180.0, vp.y)
	draw_line(Vector2(0, sweep_y), Vector2(vp.x, sweep_y), Color(0.0, 0.85, 1.0, 0.15), 1.5)

	if campaign == null or player_assignment == null:
		return

	# 2. Top Campaign Header
	var header_y := 60.0
	draw_string(ThemeDB.fallback_font, Vector2(60, header_y), "VOIDSHIFT MISSION BRIEFING // " + campaign.genre.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, campaign.accent_color)
	draw_string(ThemeDB.fallback_font, Vector2(60, header_y + 34), campaign.title, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(60, header_y + 60), "LOCATION: " + campaign.location, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.65, 0.80, 0.95))

	# 3. Left Panel: Mission Dossier
	var dossier_rect := Rect2(60, 170, 520, 420)
	draw_rect(dossier_rect, Color(0.05, 0.08, 0.13, 0.90))
	draw_rect(dossier_rect, campaign.border_color, false, 1.5)

	draw_string(ThemeDB.fallback_font, Vector2(80, 205), "EXPEDITION DIRECTIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, campaign.cyan_highlight)
	draw_rect(Rect2(80, 218, 480, 2), campaign.cyan_highlight * 0.5)

	# Formatted Briefing Text
	draw_wrapped_text(Vector2(80, 245), campaign.briefing, 480.0, 18.0, 13, Color(0.85, 0.90, 0.95))

	# Primary Objective Callout Box
	var obj_box := Rect2(80, 420, 480, 100)
	draw_rect(obj_box, Color(0.08, 0.12, 0.18))
	draw_rect(obj_box, campaign.border_color, false, 1.2)
	draw_string(ThemeDB.fallback_font, Vector2(100, 445), "PRIMARY MISSION OBJECTIVE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, campaign.accent_color)
	draw_wrapped_text(Vector2(100, 470), campaign.primary_objective, 440.0, 18.0, 13, Color(1, 1, 1))

	# 4. Right Panel: Confidential Holographic Role Reveal Card
	var card_rect := Rect2(640, 170, 580, 420)
	draw_rect(card_rect, Color(0.05, 0.08, 0.13, 0.90))
	var role_border_col: Color = Color(1.0, 0.25, 0.3) if player_assignment.is_saboteur else Color(0.0, 0.85, 1.0)
	draw_rect(card_rect, role_border_col, false, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(665, 205), "CONFIDENTIAL ROLE ASSIGNMENT // EYES ONLY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, role_border_col)
	draw_rect(Rect2(665, 218, 530, 2), role_border_col * 0.5)

	# Animated Bust Portrait
	var portrait_box := Rect2(665, 240, 130, 140)
	draw_rect(portrait_box, Color(0.03, 0.05, 0.08))
	draw_rect(portrait_box, role_border_col, false, 1.5)
	CrewmateRenderer.draw_crewmate_portrait(self, Vector2(730, 310), player_assignment.role, 1.5)

	# Identity & Role Badge
	draw_string(ThemeDB.fallback_font, Vector2(815, 265), player_assignment.character_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(815, 290), player_assignment.role_title.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, role_border_col)

	var badge_rect := Rect2(815, 305, 120, 24)
	draw_rect(badge_rect, role_border_col * 0.3)
	draw_rect(badge_rect, role_border_col, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(825, 321), player_assignment.role_badge, HORIZONTAL_ALIGNMENT_CENTER, 100, 11, role_border_col)

	# Special Ability
	draw_string(ThemeDB.fallback_font, Vector2(815, 350), "SPECIALIST ACTION:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.7, 0.8, 0.9))
	draw_wrapped_text(Vector2(815, 370), player_assignment.special_ability, 380.0, 16.0, 12, Color(0.9, 0.95, 1.0))

	# Secret Objective Box
	var sec_rect := Rect2(665, 410, 530, 115)
	var sec_bg := Color(0.18, 0.05, 0.07, 0.7) if player_assignment.is_saboteur else Color(0.04, 0.14, 0.20, 0.7)
	draw_rect(sec_rect, sec_bg)
	draw_rect(sec_rect, role_border_col, false, 1.5)

	draw_string(ThemeDB.fallback_font, Vector2(685, 435), "SECRET MISSION DIRECTIVE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, role_border_col)
	draw_wrapped_text(Vector2(685, 460), player_assignment.secret_objective, 490.0, 18.0, 13, Color(1, 1, 1))

	# 5. Bottom Action Button: DEPLOY TO SECTOR
	var deploy_btn := Rect2((vp.x - 380) * 0.5, 620, 380, 50)
	var btn_glow: float = 0.8 + sin(anim_timer * 4.0) * 0.2
	draw_rect(deploy_btn, role_border_col * 0.3)
	draw_rect(deploy_btn, role_border_col * btn_glow, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(deploy_btn.position.x, 652), "[SPACE / ENTER] DEPLOY TO SECTOR", HORIZONTAL_ALIGNMENT_CENTER, int(deploy_btn.size.x), 15, Color(1, 1, 1))

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
