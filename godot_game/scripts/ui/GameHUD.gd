class_name GameHUD
extends Node2D

## Next-Generation Sci-Fi In-Game HUD for VOIDSHIFT: The Living Evidence Engine.
## Recreates the visual aesthetic of the reference UI (Image 1 & 3):
## - Top-center objective pill with progress meter, mission state & digital timer
## - Top-left compact tasks card with checkboxes, room sublabels & count
## - Top-right architectural blueprint minimap with rooms, player cone & crew dots
## - Bottom-left Rex player card with rendered helmet portrait, role badge & suit status
## - Bottom-center contextual interaction pill [E] and dynamic control prompts
## - Bottom-right Recent Events feed driven by the Living Evidence Engine
## - Responsive viewport scaling (no hardcoded resolution clipping)

const CampaignData = preload("res://scripts/core/CampaignData.gd")
const RoleAllocator = preload("res://scripts/core/RoleAllocator.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")
const StationData = preload("res://scripts/core/StationData.gd")
const LivingEvidenceEngine = preload("res://scripts/evidence/LivingEvidenceEngine.gd")

var player: PlayerController = null
var campaign_def: CampaignData.CampaignDef = null
var player_assignment: RoleAllocator.RoleAssignment = null
var echo_vision_active: bool = false
var match_time: float = 0.0
var completed_task_ids: Array[int] = []
var recent_events: Array[LivingEvidenceEngine.TimelineEvent] = []
var active_sabotage: GameEnums.SabotageType = GameEnums.SabotageType.NONE
var sabotage_timer: float = 0.0
var context_prompt: String = ""
var all_characters: Array = []
var is_map_expanded: bool = false

func setup(p_player: PlayerController) -> void:
	player = p_player

func setup_campaign(p_campaign: CampaignData.CampaignDef, p_assign: RoleAllocator.RoleAssignment) -> void:
	campaign_def = p_campaign
	player_assignment = p_assign

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_map"):
		is_map_expanded = !is_map_expanded
		queue_redraw()

func update_hud(delta: float, time_sec: float, completed: Array[int],
				events: Array[LivingEvidenceEngine.TimelineEvent],
				sab_type: GameEnums.SabotageType, sab_time: float, prompt: String,
				characters: Array = []) -> void:
	match_time = time_sec
	completed_task_ids = completed
	recent_events = events
	active_sabotage = sab_type
	sabotage_timer = sab_time
	context_prompt = prompt
	all_characters = characters
	queue_redraw()

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0 or vp.y <= 0:
		vp = Vector2(1280, 720)

	draw_top_objective_pill(vp)
	draw_tasks_card(vp)
	draw_blueprint_minimap(vp)
	draw_rex_status_card(vp)
	draw_recent_events_card(vp)
	draw_bottom_controls_bar(vp)

	if active_sabotage != GameEnums.SabotageType.NONE:
		draw_sabotage_banner(vp)

	if context_prompt != "":
		draw_contextual_action_pill(vp)

	if is_map_expanded:
		draw_expanded_map_modal(vp)

# =========================================================================
# 1. TOP-CENTER OBJECTIVE PILL
# =========================================================================
func draw_top_objective_pill(vp: Vector2) -> void:
	var pill_w: float = 480.0
	var pill_h: float = 38.0
	var pill_x: float = (vp.x - pill_w) * 0.5
	var pill_y: float = 14.0
	var pill_rect := Rect2(pill_x, pill_y, pill_w, pill_h)

	# Glassmorphic pill body with cyan trim
	draw_rect(pill_rect, Color(0.03, 0.06, 0.12, 0.88))
	var border_col := Color(0.12, 0.55, 0.85, 0.9) if active_sabotage == GameEnums.SabotageType.NONE else Color(1.0, 0.25, 0.25, 0.95)
	draw_rect(pill_rect, border_col, false, 1.8)

	# Left Icon: Target reticle
	var icon_center := Vector2(pill_x + 20.0, pill_y + 19.0)
	var reticle_col := Color(0.0, 0.85, 1.0) if active_sabotage == GameEnums.SabotageType.NONE else Color(1.0, 0.3, 0.3)
	draw_arc(icon_center, 7.0, 0, TAU, 20, reticle_col, 1.5)
	draw_circle(icon_center, 2.5, reticle_col)

	# Objective text
	var obj_text := "Complete maintenance tasks or deduce the saboteur"
	if echo_vision_active:
		obj_text = "[ECHO VISION ACTIVE] Scanning for forensic micro-traces..."
	elif active_sabotage == GameEnums.SabotageType.REACTOR:
		obj_text = "CRITICAL ALERT: Contain Reactor Core Meltdown!"
	elif active_sabotage == GameEnums.SabotageType.LIGHTS:
		obj_text = "EMERGENCY: Restore Electrical Grid Breakers!"
	elif campaign_def != null and campaign_def.primary_objective != "":
		obj_text = campaign_def.primary_objective

	var text_col := Color(0.92, 0.96, 1.0) if active_sabotage == GameEnums.SabotageType.NONE else Color(1.0, 0.45, 0.45)
	if echo_vision_active:
		text_col = Color(0.0, 0.95, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(pill_x + 36.0, pill_y + 20.0), obj_text, HORIZONTAL_ALIGNMENT_LEFT, 320, 11, text_col)

	# Progress underline meter beneath text
	var total_tasks := StationData.get_task_spots().size()
	var pct: float = float(completed_task_ids.size()) / float(total_tasks) if total_tasks > 0 else 0.0
	var prog_x := pill_x + 36.0
	var prog_w := 280.0
	var prog_y := pill_y + 28.0
	draw_line(Vector2(prog_x, prog_y), Vector2(prog_x + prog_w, prog_y), Color(0.14, 0.20, 0.30), 2.5)
	if pct > 0.0:
		draw_line(Vector2(prog_x, prog_y), Vector2(prog_x + (prog_w * pct), prog_y), Color(0.0, 0.92, 0.75), 2.5)

	# Clock Icon & Digital Timer on Right
	var clock_center := Vector2(pill_x + 392.0, pill_y + 19.0)
	draw_arc(clock_center, 6.5, 0, TAU, 16, Color(0.2, 0.85, 1.0), 1.5)
	draw_line(clock_center, clock_center + Vector2(0, -4), Color(0.2, 0.85, 1.0), 1.2)
	draw_line(clock_center, clock_center + Vector2(3, 0), Color(0.2, 0.85, 1.0), 1.2)

	var minutes: int = int(match_time) / 60
	var seconds: int = int(match_time) % 60
	var time_str := "%02d:%02d" % [minutes, seconds]
	draw_string(ThemeDB.fallback_font, Vector2(pill_x + 406.0, pill_y + 23.0), time_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.95, 1.0))

# =========================================================================
# 2. TOP-LEFT TASKS CARD
# =========================================================================
func draw_tasks_card(_vp: Vector2) -> void:
	var card_rect := Rect2(16, 14, 250, 150)
	draw_rect(card_rect, Color(0.03, 0.06, 0.12, 0.88))
	draw_rect(card_rect, Color(0.12, 0.52, 0.85, 0.9), false, 1.6)

	var spots := StationData.get_task_spots()
	var done_count: int = completed_task_ids.size()

	# Header: TASKS       X / Y
	draw_string(ThemeDB.fallback_font, Vector2(30, 36), "TASKS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.0, 0.85, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(215, 36), "%d / %d" % [done_count, mini(3, spots.size())], HORIZONTAL_ALIGNMENT_RIGHT, -1, 12, Color(0.0, 0.85, 1.0))

	# First 3 tasks displayed cleanly
	var y := 62.0
	for i in range(mini(3, spots.size())):
		var t := spots[i]
		var is_done: bool = t.id in completed_task_ids

		# Checkbox
		var box_rect := Rect2(30, y - 11, 14, 14)
		if is_done:
			draw_rect(box_rect, Color(0.1, 0.45, 0.22, 0.6))
			draw_rect(box_rect, Color(0.2, 0.95, 0.4), false, 1.8)
			draw_line(Vector2(box_rect.position.x + 3, box_rect.position.y + 7), Vector2(box_rect.position.x + 6, box_rect.position.y + 11), Color(0.2, 0.95, 0.4), 2.0)
			draw_line(Vector2(box_rect.position.x + 6, box_rect.position.y + 11), Vector2(box_rect.position.x + 11, box_rect.position.y + 3), Color(0.2, 0.95, 0.4), 2.0)
		else:
			draw_rect(box_rect, Color(0.08, 0.12, 0.18))
			draw_rect(box_rect, Color(0.3, 0.55, 0.75), false, 1.5)

		# Task Title & Room
		var title_col := Color(0.2, 0.95, 0.4) if is_done else Color(0.88, 0.92, 0.98)
		draw_string(ThemeDB.fallback_font, Vector2(52, y), t.name, HORIZONTAL_ALIGNMENT_LEFT, 200, 10, title_col)
		draw_string(ThemeDB.fallback_font, Vector2(52, y + 13), t.room_name, HORIZONTAL_ALIGNMENT_LEFT, 200, 9, Color(0.45, 0.65, 0.82))

		y += 33.0

# =========================================================================
# 3. TOP-RIGHT BLUEPRINT MINIMAP
# =========================================================================
func draw_blueprint_minimap(vp: Vector2) -> void:
	var map_w: float = 240.0
	var map_h: float = 180.0
	var map_x: float = vp.x - map_w - 16.0
	var map_y: float = 14.0
	var map_rect := Rect2(map_x, map_y, map_w, map_h)

	# Blueprint dark glass background & border
	draw_rect(map_rect, Color(0.02, 0.05, 0.10, 0.90))
	draw_rect(map_rect, Color(0.12, 0.52, 0.85, 0.9), false, 1.6)

	# North indicator & Map hint
	draw_string(ThemeDB.fallback_font, Vector2(map_rect.end.x - 24, map_rect.position.y + 16), "▲ N", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.0, 0.85, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(map_rect.position.x + 10, map_rect.position.y + 16), "STATION MAP [M]", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.4, 0.65, 0.85))

	# World coordinates (1600 x 1200) to Minimap transformation
	var sx: float = (map_w - 20.0) / 1600.0
	var sy: float = (map_h - 26.0) / 1200.0
	var ox: float = map_rect.position.x + 10.0
	var oy: float = map_rect.position.y + 18.0

	# Corridors on minimap
	for c in StationData.get_corridors():
		var cx := ox + (c.position.x * sx)
		var cy := oy + (c.position.y * sy)
		var cw := c.size.x * sx
		var ch := c.size.y * sy
		draw_rect(Rect2(cx, cy, cw, ch), Color(0.10, 0.22, 0.35, 0.6))

	# Rooms wireframe & abbreviations
	for r in StationData.get_rooms():
		var rx: float = ox + (r.rect.position.x * sx)
		var ry: float = oy + (r.rect.position.y * sy)
		var rw: float = r.rect.size.x * sx
		var rh: float = r.rect.size.y * sy
		var r_box := Rect2(rx, ry, rw, rh)

		draw_rect(r_box, Color(0.05, 0.12, 0.20, 0.7))
		draw_rect(r_box, Color(0.18, 0.55, 0.85, 0.8), false, 1.2)

		# Concise abbreviation that never overflows or collides
		var abbr := ""
		match r.id:
			"bridge": abbr = "BRIDGE"
			"medical": abbr = "MED"
			"central_hub": abbr = "HUB"
			"research": abbr = "LAB"
			"reactor": abbr = "REACTOR"
			"electrical": abbr = "ELEC"
			"storage": abbr = "STORAGE"
			"security": abbr = "SEC"
			"meeting": abbr = "MEET"
			_: abbr = r.short_name

		draw_string(ThemeDB.fallback_font, Vector2(rx, ry + (rh * 0.5) + 3), abbr, HORIZONTAL_ALIGNMENT_CENTER, int(rw), 7, Color(0.72, 0.88, 0.98))

	# Crewmate radar dots
	for ch in all_characters:
		if ch != player and ch is CharacterBody2D:
			var c_pos: Vector2 = ch.global_position
			var cx: float = ox + (c_pos.x * sx)
			var cy: float = oy + (c_pos.y * sy)
			var dot_col := Color(0.2, 0.92, 0.5)
			if ch.get("role") == GameEnums.Role.ENGINEER_FIXER:
				dot_col = Color(1.0, 0.85, 0.2)
			elif ch.get("character_state") == GameEnums.CharacterState.DEAD:
				dot_col = Color(0.65, 0.65, 0.65)
			draw_circle(Vector2(cx, cy), 2.5, dot_col)

	# Reactor sabotage flashing indicator
	if active_sabotage == GameEnums.SabotageType.REACTOR:
		var flash: float = abs(sin(match_time * 6.0))
		draw_circle(Vector2(ox + (290 * sx), oy + (775 * sy)), 5.0, Color(1.0, 0.2, 0.2, flash))

	# Player marker with vision sweep cone
	if player != null:
		var px: float = ox + (player.global_position.x * sx)
		var py: float = oy + (player.global_position.y * sy)
		var player_pt := Vector2(px, py)

		var dir_x: float = -1.0 if player.is_facing_left else 1.0
		var facing_angle := Vector2(dir_x, 0.2).angle()
		var cone_len: float = 16.0
		var p_left := player_pt + Vector2(cos(facing_angle - 0.45), sin(facing_angle - 0.45)) * cone_len
		var p_right := player_pt + Vector2(cos(facing_angle + 0.45), sin(facing_angle + 0.45)) * cone_len
		var v_pts: PackedVector2Array = [player_pt, p_left, p_right]
		draw_colored_polygon(v_pts, Color(0.0, 0.85, 1.0, 0.4))

		draw_circle(player_pt, 4.0, Color(1, 1, 1))
		draw_arc(player_pt, 5.5, 0, TAU, 16, Color(0.0, 0.85, 1.0), 1.5)

# =========================================================================
# 4. BOTTOM-LEFT REX STATUS CARD
# =========================================================================
func draw_rex_status_card(vp: Vector2) -> void:
	var card_w: float = 240.0
	var card_h: float = 88.0
	var card_x: float = 16.0
	var card_y: float = vp.y - card_h - 14.0
	var card_rect := Rect2(card_x, card_y, card_w, card_h)

	draw_rect(card_rect, Color(0.03, 0.06, 0.12, 0.90))
	draw_rect(card_rect, Color(0.12, 0.52, 0.85, 0.9), false, 1.6)

	# Avatar Portrait Box
	var port_rect := Rect2(card_x + 10, card_y + 10, 68, 68)
	draw_rect(port_rect, Color(0.04, 0.08, 0.14))
	draw_rect(port_rect, Color(0.0, 0.85, 1.0, 0.7), false, 1.5)

	var p_center := port_rect.get_center()

	# Suit Shoulders & Collar (drawn behind helmet)
	var shoulder_pts: PackedVector2Array = [
		Vector2(p_center.x - 26, p_center.y + 30),
		Vector2(p_center.x - 18, p_center.y + 14),
		Vector2(p_center.x + 18, p_center.y + 14),
		Vector2(p_center.x + 26, p_center.y + 30)
	]
	draw_colored_polygon(shoulder_pts, Color(0.85, 0.90, 0.96))
	draw_line(shoulder_pts[1], shoulder_pts[2], Color(0.0, 0.85, 1.0), 2.0, true)

	# Helmet Neck Seal
	draw_circle(p_center + Vector2(0, 11), 13.0, Color(0.12, 0.15, 0.20), true)

	# Spherical Outer Helmet Shell
	var head_center := p_center + Vector2(0, -3)
	draw_circle(head_center, 18.0, Color(0.90, 0.94, 0.98), true)
	draw_arc(head_center, 18.0, 0, TAU, 36, Color(0.06, 0.08, 0.12), 2.2, true)

	# Helmet Side Communications Earpieces
	draw_circle(Vector2(head_center.x - 17, head_center.y), 3.5, Color(0.16, 0.20, 0.26), true)
	draw_circle(Vector2(head_center.x - 17, head_center.y), 1.5, Color(0.0, 0.85, 1.0), true)
	draw_circle(Vector2(head_center.x + 17, head_center.y), 3.5, Color(0.16, 0.20, 0.26), true)
	draw_circle(Vector2(head_center.x + 17, head_center.y), 1.5, Color(0.0, 0.85, 1.0), true)

	# High-Gloss Reflective Dome Visor
	var visor_pt := head_center + Vector2(0, 1)
	draw_circle(visor_pt, 12.0, Color(0.03, 0.06, 0.14), true)
	draw_arc(visor_pt, 12.0, 0, TAU, 32, Color(0.0, 0.85, 1.0), 1.6, true)

	# Curved Specular Horizon Highlight Arc & Visor Scanline
	draw_arc(visor_pt, 9.5, -PI * 0.75, -PI * 0.25, 20, Color(1, 1, 1, 0.95), 2.0, true)
	draw_line(visor_pt + Vector2(-6, -4), visor_pt + Vector2(6, -4), Color(1, 1, 1, 0.85), 1.8, true)
	draw_line(visor_pt + Vector2(-7, 1), visor_pt + Vector2(7, 1), Color(0.0, 0.85, 1.0, 0.6), 1.4, true)

	# Name
	var disp_name: String = player_assignment.character_name if player_assignment != null else (player.player_name if player != null else "Commander Rex")
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 88, card_y + 26), disp_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1))

	# Role Badge
	var is_saboteur: bool = (player_assignment != null and player_assignment.is_saboteur) or (player != null and player.role == GameEnums.Role.SABOTEUR_IMPOSTOR)
	var role_text: String = player_assignment.role_title.to_upper() if player_assignment != null else ("SABOTEUR" if is_saboteur else "CREWMATE")
	var role_col := Color(1.0, 0.25, 0.25) if is_saboteur else Color(0.0, 0.85, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 88, card_y + 42), role_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, role_col)

	# Dual cyan vitals bars
	draw_rect(Rect2(card_x + 88, card_y + 52, 60, 5), Color(0.0, 0.85, 1.0, 0.85))
	draw_rect(Rect2(card_x + 154, card_y + 52, 50, 5), Color(0.0, 0.85, 1.0, 0.85))
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 88, card_y + 68), "SUIT NOMINAL  •  SHIELD 100%", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.45, 0.65, 0.85))

# =========================================================================
# 5. BOTTOM-CENTER CONTEXTUAL ACTION PILL & QUICK CONTROLS
# =========================================================================
func draw_contextual_action_pill(vp: Vector2) -> void:
	var key_char := "E"
	var action_text := "Use Console"

	if context_prompt.begins_with("[E]"):
		key_char = "E"
		action_text = context_prompt.substr(3).strip_edges()
	elif context_prompt.begins_with("[R]"):
		key_char = "R"
		action_text = context_prompt.substr(3).strip_edges()
	elif context_prompt.begins_with("[V]"):
		key_char = "V"
		action_text = context_prompt.substr(3).strip_edges()
	elif context_prompt.begins_with("[SPACE]"):
		key_char = "SP"
		action_text = context_prompt.substr(7).strip_edges()
	else:
		action_text = context_prompt

	var text_len: float = ThemeDB.fallback_font.get_string_size(action_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
	var pill_w: float = maxf(180.0, text_len + 65.0)
	var pill_h: float = 44.0
	var pill_x: float = (vp.x - pill_w) * 0.5
	var pill_y: float = vp.y - pill_h - 48.0
	var pill_rect := Rect2(pill_x, pill_y, pill_w, pill_h)

	# Glowing rounded action box
	draw_rect(pill_rect, Color(0.03, 0.07, 0.14, 0.92))
	var border_c := Color(0.0, 0.85, 1.0) if key_char != "R" else Color(1.0, 0.3, 0.3)
	draw_rect(pill_rect, border_c, false, 2.0)

	# Keycap square
	var key_rect := Rect2(pill_x + 8.0, pill_y + 7.0, 30.0, 30.0)
	draw_rect(key_rect, border_c)
	draw_string(ThemeDB.fallback_font, Vector2(key_rect.position.x + (8 if key_char != "SP" else 4), key_rect.position.y + 20), key_char, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.02, 0.04, 0.08))

	# Action text
	draw_string(ThemeDB.fallback_font, Vector2(pill_x + 46.0, pill_y + 27.0), action_text, HORIZONTAL_ALIGNMENT_LEFT, int(text_len + 10), 12, Color(1, 1, 1))

func draw_bottom_controls_bar(vp: Vector2) -> void:
	# Subtle navigation shortcuts strip at bottom center
	var bar_w: float = 560.0
	var bar_h: float = 24.0
	var bar_x: float = (vp.x - bar_w) * 0.5
	var bar_y: float = vp.y - bar_h - 10.0
	var bar_rect := Rect2(bar_x, bar_y, bar_w, bar_h)

	draw_rect(bar_rect, Color(0.02, 0.04, 0.08, 0.75))
	draw_rect(bar_rect, Color(0.12, 0.32, 0.52, 0.6), false, 1.0)

	var text := "WASD Move  •  [E] Interact  •  [Q] Echo Vision  •  [R] Report  •  [TAB] Evidence  •  [M] Map"
	draw_string(ThemeDB.fallback_font, Vector2(bar_x, bar_y + 16), text, HORIZONTAL_ALIGNMENT_CENTER, int(bar_w), 9, Color(0.55, 0.72, 0.88))

# =========================================================================
# 6. BOTTOM-RIGHT RECENT EVENTS FEED
# =========================================================================
func draw_recent_events_card(vp: Vector2) -> void:
	var card_w: float = 280.0
	var card_h: float = 150.0
	var card_x: float = vp.x - card_w - 16.0
	var card_y: float = vp.y - card_h - 14.0
	var card_rect := Rect2(card_x, card_y, card_w, card_h)

	draw_rect(card_rect, Color(0.03, 0.06, 0.12, 0.88))
	draw_rect(card_rect, Color(0.12, 0.52, 0.85, 0.9), false, 1.6)

	# Header: RECENT EVENTS     TAB
	var gear_pt := Vector2(card_x + 16, card_y + 18)
	draw_arc(gear_pt, 5.5, 0, TAU, 16, Color(0.0, 0.85, 1.0), 1.5)
	draw_circle(gear_pt, 2.0, Color(0.0, 0.85, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 28, card_y + 22), "RECENT EVENTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.0, 0.85, 1.0))

	# TAB badge
	var tab_rect := Rect2(card_rect.end.x - 42, card_y + 10, 32, 16)
	draw_rect(tab_rect, Color(0.08, 0.14, 0.22))
	draw_rect(tab_rect, Color(0.0, 0.85, 1.0, 0.7), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(tab_rect.position.x + 4, tab_rect.position.y + 12), "TAB", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.0, 0.85, 1.0))

	# Living Evidence Engine event entries
	if recent_events.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 16, card_y + 70), "Station sensors active.", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.45, 0.60, 0.75))
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 16, card_y + 88), "Monitoring crew telemetry...", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.35, 0.50, 0.65))
		return

	var y := card_y + 46.0
	for i in range(mini(3, recent_events.size())):
		var ev := recent_events[i]
		var badge_col := Color(0.2, 0.92, 0.5)
		if ev.event_type == GameEnums.EventType.ENTER_ROOM:
			badge_col = Color(0.2, 0.92, 0.5)
		elif ev.event_type == GameEnums.EventType.COMPLETE_TASK:
			badge_col = Color(0.0, 0.85, 1.0)
		elif ev.event_type == GameEnums.EventType.ENTER_VENT or ev.event_type == GameEnums.EventType.EXIT_VENT:
			badge_col = Color(0.8, 0.35, 0.95)
		elif ev.is_suspicious or ev.event_type == GameEnums.EventType.KILL_CREWMATE or ev.event_type == GameEnums.EventType.TRIGGER_SABOTAGE:
			badge_col = Color(1.0, 0.25, 0.25)

		# Event icon circle
		var icon_pos := Vector2(card_x + 18, y - 4)
		draw_circle(icon_pos, 6.0, badge_col.darkened(0.6))
		draw_arc(icon_pos, 6.0, 0, TAU, 16, badge_col, 1.2)

		# Timestamp
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 32, y), ev.formatted_time, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.6, 0.75, 0.9))

		# Event description (clean truncation if long)
		var desc_str := ev.description
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 72, y), desc_str, HORIZONTAL_ALIGNMENT_LEFT, 195, 9, Color(0.9, 0.94, 0.98))

		y += 33.0

func draw_sabotage_banner(vp: Vector2) -> void:
	var banner_w: float = 580.0
	var banner_h: float = 40.0
	var banner_x: float = (vp.x - banner_w) * 0.5
	var banner_y: float = 58.0
	var banner := Rect2(banner_x, banner_y, banner_w, banner_h)

	draw_rect(banner, Color(0.85, 0.08, 0.12, 0.95))
	draw_rect(banner, Color(1.0, 0.85, 0.2), false, 2.0)

	var minutes: int = int(sabotage_timer) / 60
	var seconds: int = int(sabotage_timer) % 60
	var sab_name := "REACTOR CORE OVERHEATING" if active_sabotage == GameEnums.SabotageType.REACTOR else "EMERGENCY BLACKOUT"
	var text := "ALERT: %s — %02d:%02d REMAINING!" % [sab_name, minutes, seconds]
	draw_string(ThemeDB.fallback_font, Vector2(banner_x, banner_y + 26), text, HORIZONTAL_ALIGNMENT_CENTER, int(banner_w), 13, Color(1, 1, 1))

func draw_expanded_map_modal(vp: Vector2) -> void:
	# Full-screen expanded map overlay
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.02, 0.04, 0.08, 0.90))

	var panel_w: float = 780.0
	var panel_h: float = 580.0
	var panel := Rect2((vp.x - panel_w) * 0.5, (vp.y - panel_h) * 0.5, panel_w, panel_h)
	draw_rect(panel, Color(0.04, 0.08, 0.14, 0.96))
	draw_rect(panel, Color(0.0, 0.85, 1.0), false, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(panel.position.x + 30, panel.position.y + 36), "DSS CHRONOS — EXPANDED TACTICAL BLUEPRINT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(panel.end.x - 140, panel.position.y + 36), "Press [M] to Close", HORIZONTAL_ALIGNMENT_RIGHT, -1, 11, Color(0.0, 0.85, 1.0))

	# Scaled blueprint
	var sx: float = (panel_w - 60.0) / 1600.0
	var sy: float = (panel_h - 80.0) / 1200.0
	var ox: float = panel.position.x + 30.0
	var oy: float = panel.position.y + 55.0

	for c in StationData.get_corridors():
		draw_rect(Rect2(ox + (c.position.x * sx), oy + (c.position.y * sy), c.size.x * sx, c.size.y * sy), Color(0.12, 0.25, 0.4, 0.7))

	for r in StationData.get_rooms():
		var rx := ox + (r.rect.position.x * sx)
		var ry := oy + (r.rect.position.y * sy)
		var rw := r.rect.size.x * sx
		var rh := r.rect.size.y * sy
		draw_rect(Rect2(rx, ry, rw, rh), Color(0.06, 0.14, 0.24, 0.8))
		draw_rect(Rect2(rx, ry, rw, rh), r.accent_color * Color(1, 1, 1, 0.8), false, 1.5)
		draw_string(ThemeDB.fallback_font, Vector2(rx, ry + (rh * 0.5) + 4), r.name, HORIZONTAL_ALIGNMENT_CENTER, int(rw), 10, Color(1, 1, 1))

	if player != null:
		var p_pt := Vector2(ox + (player.global_position.x * sx), oy + (player.global_position.y * sy))
		draw_circle(p_pt, 6.0, Color(1, 1, 1))
		draw_arc(p_pt, 8.0, 0, TAU, 16, Color(0.0, 0.85, 1.0), 2.0)
