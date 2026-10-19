class_name GameHUD
extends Node2D

## Definitive In-Game HUD for VOIDSHIFT.
## Faithfully implements the Master UI Reference (The Hollow Crown & Blackglass Station):
## - Top-left Objective Card with amber/cyan header, large narrative title & checklist
## - Top-right Sector Minimap with compass, room schematics, and objective markers
## - Bottom-left Rex Character Dossier with anime portrait, role info & vitals
## - Bottom-center Floating Action Bar Dock ([M] Map, [E] Interact, [Q] Evidence, [R] Report, [TAB] Records)
## - Bottom-right Recent Events live terminal feed with colored status dots & timestamps

const CampaignData = preload("res://scripts/core/CampaignData.gd")
const RoleAllocator = preload("res://scripts/core/RoleAllocator.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")
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

# Assets
var rex_portrait: Texture2D = null

func _ready() -> void:
	var path := "res://assets/portraits/rex.png"
	var gpath := ProjectSettings.globalize_path(path)
	var img := Image.load_from_file(gpath)
	if img != null and not img.is_empty():
		rex_portrait = ImageTexture.create_from_image(img)
	elif ResourceLoader.exists(path):
		rex_portrait = load(path)

func setup(p_player: PlayerController) -> void:
	player = p_player

func setup_campaign(p_campaign: CampaignData.CampaignDef, p_assign: RoleAllocator.RoleAssignment) -> void:
	campaign_def = p_campaign
	player_assignment = p_assign
	queue_redraw()

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

	draw_objective_card(vp)
	draw_minimap_card(vp)
	draw_dossier_card(vp)
	draw_action_dock(vp)
	draw_recent_events_card(vp)

	if not context_prompt.is_empty():
		draw_floating_prompt(vp)

# =========================================================================
# 1. TOP-LEFT OBJECTIVE CARD
# =========================================================================
func draw_objective_card(vp: Vector2) -> void:
	var card_rect := Rect2(18, 18, 310, 160)
	# Dark glass panel
	draw_rect(card_rect, Color(0.04, 0.07, 0.12, 0.88))
	draw_rect(card_rect, Color(0.12, 0.45, 0.70, 0.85), false, 1.5)

	# Amber warning exclamation circle icon
	var icon_center := Vector2(36, 36)
	draw_circle(icon_center, 9.0, Color(0.95, 0.70, 0.15))
	draw_string(ThemeDB.fallback_font, Vector2(icon_center.x - 2.5, icon_center.y + 4.0), "!", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.05, 0.05, 0.05))

	draw_string(ThemeDB.fallback_font, Vector2(52, 33), "CURRENT OBJECTIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.75, 0.20))

	# Narrative title
	var obj_title: String = campaign_def.primary_objective if campaign_def != null else "Find out what happened to the relic"
	draw_string(ThemeDB.fallback_font, Vector2(32, 54), obj_title, HORIZONTAL_ALIGNMENT_LEFT, 280, 12, Color(1, 1, 1))

	# Checklist tasks
	var tasks: Array[Dictionary] = []
	if campaign_def != null and campaign_def.checklist_tasks.size() > 0:
		tasks = campaign_def.checklist_tasks
	else:
		tasks = [
			{"title": "Examine the disturbed garden path", "location": "Sakura Courtyard", "done": false},
			{"title": "Inspect the ceremonial hall", "location": "Inner Shrine", "done": false},
			{"title": "Question the attendants", "location": "Tea Room", "done": false},
			{"title": "Analyze the estate records", "location": "Archive", "done": false}
		]

	var item_y: float = 78.0
	for i in range(mini(tasks.size(), 4)):
		var t: Dictionary = tasks[i]
		var is_done: bool = completed_task_ids.has(i) or t.get("done", false)

		# Checkbox
		var box_rect := Rect2(32, item_y - 10, 12, 12)
		draw_rect(box_rect, Color(0.08, 0.12, 0.18))
		draw_rect(box_rect, Color(0.0, 0.85, 1.0, 0.8) if not is_done else Color(0.2, 0.9, 0.4), false, 1.2)
		if is_done:
			draw_line(Vector2(box_rect.position.x + 2, box_rect.position.y + 6), Vector2(box_rect.position.x + 5, box_rect.position.y + 10), Color(0.2, 0.9, 0.4), 1.5)
			draw_line(Vector2(box_rect.position.x + 5, box_rect.position.y + 10), Vector2(box_rect.position.x + 10, box_rect.position.y + 2), Color(0.2, 0.9, 0.4), 1.5)

		# Task Title & Location
		var text_col: Color = Color(0.7, 0.95, 0.8) if is_done else Color(0.9, 0.95, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(52, item_y), t["title"], HORIZONTAL_ALIGNMENT_LEFT, 260, 10, text_col)
		draw_string(ThemeDB.fallback_font, Vector2(52, item_y + 12), t["location"], HORIZONTAL_ALIGNMENT_LEFT, 260, 8, Color(0.4, 0.7, 0.9))

		item_y += 24.0

# =========================================================================
# 2. TOP-RIGHT SECTOR MINIMAP
# =========================================================================
func draw_minimap_card(vp: Vector2) -> void:
	var map_w: float = 230.0
	var map_h: float = 145.0
	var map_x: float = vp.x - map_w - 18.0
	var map_y: float = 18.0
	var map_rect := Rect2(map_x, map_y, map_w, map_h)

	draw_rect(map_rect, Color(0.04, 0.07, 0.12, 0.88))
	draw_rect(map_rect, Color(0.12, 0.45, 0.70, 0.85), false, 1.5)

	# Title & compass
	var title_str := "THE HOLLOW CROWN" if (campaign_def == null or campaign_def.mode == GameEnums.CampaignMode.HOLLOW_CROWN) else "BLACKGLASS STATION"
	draw_string(ThemeDB.fallback_font, Vector2(map_x + 12, map_y + 18), title_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.7, 0.85, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(map_x + map_w - 36, map_y + 18), "[M]", HORIZONTAL_ALIGNMENT_RIGHT, -1, 8, Color(0.0, 0.85, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(map_x + map_w - 16, map_y + 18), "N", HORIZONTAL_ALIGNMENT_RIGHT, -1, 9, Color(0.0, 0.85, 1.0))

	# Schematic Rooms
	var center := Vector2(map_x + map_w * 0.5, map_y + map_h * 0.55)
	if campaign_def == null or campaign_def.mode == GameEnums.CampaignMode.HOLLOW_CROWN:
		# Hollow Crown Layout
		var r_shrine := Rect2(center.x - 25, center.y - 45, 50, 22)
		var r_court := Rect2(center.x - 35, center.y - 18, 70, 30)
		var r_tea := Rect2(center.x + 40, center.y - 25, 45, 24)
		var r_archive := Rect2(center.x + 25, center.y + 16, 45, 22)
		var r_gate := Rect2(center.x - 85, center.y + 12, 40, 24)

		draw_rect(r_shrine, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_shrine, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_court, Color(0.12, 0.20, 0.30, 0.85)); draw_rect(r_court, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_tea, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_tea, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_archive, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_archive, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_gate, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_gate, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)

		# Labels
		draw_string(ThemeDB.fallback_font, Vector2(r_shrine.position.x + 8, r_shrine.position.y + 14), "Shrine", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(r_court.position.x + 12, r_court.position.y + 18), "Garden", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(r_tea.position.x + 6, r_tea.position.y + 15), "Tea Room", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(r_archive.position.x + 6, r_archive.position.y + 14), "Archive", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(r_gate.position.x + 8, r_gate.position.y + 15), "Gate", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))

		# Objective Yellow Exclamation Icons
		draw_circle(Vector2(r_shrine.position.x + 42, r_shrine.position.y + 7), 3.5, Color(0.95, 0.75, 0.2))
		draw_circle(Vector2(r_tea.position.x + 38, r_tea.position.y + 7), 3.5, Color(0.95, 0.75, 0.2))
		draw_circle(Vector2(r_archive.position.x + 38, r_archive.position.y + 7), 3.5, Color(0.95, 0.75, 0.2))
	else:
		# Blackglass Station Layout
		var r_obs := Rect2(center.x - 60, center.y - 45, 120, 24)
		var r_quarters := Rect2(center.x - 70, center.y - 15, 55, 24)
		var r_corridor := Rect2(center.x - 10, center.y - 15, 20, 55)
		var r_lab := Rect2(center.x + 15, center.y - 15, 65, 30)
		var r_eng := Rect2(center.x - 70, center.y + 15, 55, 25)

		draw_rect(r_obs, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_obs, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_quarters, Color(0.12, 0.20, 0.30, 0.85)); draw_rect(r_quarters, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_corridor, Color(0.08, 0.12, 0.20, 0.85)); draw_rect(r_corridor, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_lab, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_lab, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
		draw_rect(r_eng, Color(0.15, 0.25, 0.35, 0.85)); draw_rect(r_eng, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)

		draw_string(ThemeDB.fallback_font, Vector2(r_obs.position.x + 18, r_obs.position.y + 16), "Observation Deck A", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))
		draw_string(ThemeDB.fallback_font, Vector2(r_lab.position.x + 12, r_lab.position.y + 18), "Research Lab", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1, 1, 1))

	# Player position dot
	var p_norm := Vector2(0.5, 0.5)
	if player != null:
		p_norm = Vector2(clampf(player.global_position.x / 1280.0, 0.1, 0.9), clampf(player.global_position.y / 720.0, 0.1, 0.9))
	var p_dot := Vector2(map_x + 30 + p_norm.x * 170.0, map_y + 30 + p_norm.y * 95.0)
	draw_circle(p_dot, 3.5, Color(0.0, 0.95, 1.0))
	draw_arc(p_dot, 6.0, 0, TAU, 16, Color(1, 1, 1, 0.8), 1.0)

# =========================================================================
# 3. BOTTOM-LEFT DOSSIER CARD
# =========================================================================
func draw_dossier_card(vp: Vector2) -> void:
	var card_w: float = 240.0
	var card_h: float = 88.0
	var card_x: float = 18.0
	var card_y: float = vp.y - card_h - 18.0
	var card_rect := Rect2(card_x, card_y, card_w, card_h)

	draw_rect(card_rect, Color(0.04, 0.07, 0.12, 0.88))
	draw_rect(card_rect, Color(0.12, 0.45, 0.70, 0.85), false, 1.5)

	# Portrait Box
	var port_rect := Rect2(card_x + 8, card_y + 8, 56, 72)
	draw_rect(port_rect, Color(0.02, 0.04, 0.07))
	draw_rect(port_rect, Color(0.0, 0.85, 1.0, 0.8), false, 1.2)
	if rex_portrait != null:
		draw_texture_rect(rex_portrait, port_rect, false)

	# Identity
	var p_name: String = player_assignment.character_name if player_assignment != null else "Rex"
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 72, card_y + 24), p_name + " (You)", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1))

	var role_title: String = player_assignment.role_title if player_assignment != null else "???"
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 72, card_y + 40), "Role: " + role_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.85, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 72, card_y + 54), "Find the truth. Stay alive.", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.5, 0.65, 0.75))

	# Dual Vitals Bars
	var bar1 := Rect2(card_x + 72, card_y + 64, 150, 4)
	var bar2 := Rect2(card_x + 72, card_y + 72, 105, 4)
	draw_rect(bar1, Color(0.0, 0.88, 1.0))
	draw_rect(bar2, Color(0.15, 0.55, 0.95))

# =========================================================================
# 4. BOTTOM-CENTER FLOATING ACTION DOCK
# =========================================================================
func draw_action_dock(vp: Vector2) -> void:
	var dock_w: float = 380.0
	var dock_h: float = 46.0
	var dock_x: float = (vp.x - dock_w) * 0.5
	var dock_y: float = vp.y - dock_h - 18.0
	var dock_rect := Rect2(dock_x, dock_y, dock_w, dock_h)

	# Dark glass capsule
	draw_rect(dock_rect, Color(0.04, 0.07, 0.12, 0.92))
	draw_rect(dock_rect, Color(0.12, 0.45, 0.70, 0.85), false, 1.5)

	var btn_w: float = dock_w / 5.0
	var buttons := [
		{"key": "[M]", "label": "Map"},
		{"key": "[E]", "label": "Interact"},
		{"key": "[Q]", "label": "Evidence", "badge": true},
		{"key": "[R]", "label": "Report"},
		{"key": "[TAB]", "label": "Records"}
	]

	for i in range(buttons.size()):
		var b: Dictionary = buttons[i]
		var bx: float = dock_x + i * btn_w
		var by: float = dock_y

		# Separator
		if i > 0:
			draw_line(Vector2(bx, by + 10), Vector2(bx, by + dock_h - 10), Color(0.2, 0.3, 0.4, 0.5), 1.0)

		# Label
		draw_string(ThemeDB.fallback_font, Vector2(bx + 12, by + 22), b["key"], HORIZONTAL_ALIGNMENT_CENTER, int(btn_w - 24), 9, Color(0.0, 0.85, 1.0))
		draw_string(ThemeDB.fallback_font, Vector2(bx + 10, by + 36), b["label"], HORIZONTAL_ALIGNMENT_CENTER, int(btn_w - 20), 8, Color(0.9, 0.95, 1.0))

		# Red Notification Badge for Evidence
		if b.get("badge", false):
			var badge_pt := Vector2(bx + btn_w * 0.5 + 16, by + 12)
			draw_circle(badge_pt, 4.0, Color(0.95, 0.25, 0.25))

# =========================================================================
# 5. BOTTOM-RIGHT RECENT EVENTS CARD
# =========================================================================
func draw_recent_events_card(vp: Vector2) -> void:
	var card_w: float = 240.0
	var card_h: float = 125.0
	var card_x: float = vp.x - card_w - 18.0
	var card_y: float = vp.y - card_h - 18.0
	var card_rect := Rect2(card_x, card_y, card_w, card_h)

	draw_rect(card_rect, Color(0.04, 0.07, 0.12, 0.88))
	draw_rect(card_rect, Color(0.12, 0.45, 0.70, 0.85), false, 1.5)

	# Header
	draw_string(ThemeDB.fallback_font, Vector2(card_x + 12, card_y + 18), "Recent Events", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.0, 0.85, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(card_x + card_w - 38, card_y + 18), "TAB", HORIZONTAL_ALIGNMENT_RIGHT, -1, 8, Color(0.5, 0.7, 0.9))

	var events_list: Array[Dictionary] = []
	if campaign_def == null or campaign_def.mode == GameEnums.CampaignMode.HOLLOW_CROWN:
		events_list = [
			{"time": "10:24", "text": "Aiko entered Inner Shrine", "col": Color(0.2, 0.9, 0.4)},
			{"time": "10:21", "text": "Door opened (Archive)", "col": Color(0.0, 0.85, 1.0)},
			{"time": "10:18", "text": "Unknown footprint discovered", "col": Color(0.95, 0.75, 0.2)},
			{"time": "10:14", "text": "Lantern moved (Courtyard)", "col": Color(0.95, 0.75, 0.2)},
			{"time": "10:12", "text": "Kenji was seen near Archive", "col": Color(0.2, 0.9, 0.4)}
		]
	else:
		events_list = [
			{"time": "21:14", "text": "Power fluctuation detected (Lab)", "col": Color(1.0, 0.25, 0.25)},
			{"time": "21:12", "text": "Vance entered Engineering Bay", "col": Color(0.2, 0.9, 0.4)},
			{"time": "21:10", "text": "Kael seen in Observation Lounge", "col": Color(0.2, 0.9, 0.4)},
			{"time": "21:08", "text": "Containment chamber opened", "col": Color(0.0, 0.85, 1.0)}
		]

	var ev_y: float = card_y + 36.0
	for i in range(mini(events_list.size(), 4)):
		var ev: Dictionary = events_list[i]
		# Dot
		draw_circle(Vector2(card_x + 16, ev_y - 3), 3.0, ev["col"])
		# Time
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 26, ev_y), ev["time"], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.65, 0.80, 0.95))
		# Desc
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 58, ev_y), ev["text"], HORIZONTAL_ALIGNMENT_LEFT, 175, 8, Color(0.90, 0.95, 1.0))
		ev_y += 20.0

# =========================================================================
# 6. FLOATING IN-WORLD ACTION PROMPT
# =========================================================================
func draw_floating_prompt(vp: Vector2) -> void:
	var prompt_w: float = 260.0
	var prompt_h: float = 38.0
	var prompt_x: float = (vp.x - prompt_w) * 0.5
	var prompt_y: float = vp.y - 125.0
	var p_rect := Rect2(prompt_x, prompt_y, prompt_w, prompt_h)

	draw_rect(p_rect, Color(0.03, 0.06, 0.12, 0.92))
	draw_rect(p_rect, Color(0.0, 0.85, 1.0, 0.9), false, 1.5)

	# Key Badge
	var key_box := Rect2(prompt_x + 8, prompt_y + 8, 22, 22)
	draw_rect(key_box, Color(0.0, 0.85, 1.0, 0.25))
	draw_rect(key_box, Color(0.0, 0.85, 1.0), false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(key_box.position.x + 6, key_box.position.y + 16), "E", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1))

	# Prompt text
	draw_string(ThemeDB.fallback_font, Vector2(prompt_x + 40, prompt_y + 24), context_prompt, HORIZONTAL_ALIGNMENT_LEFT, int(prompt_w - 48), 11, Color(1, 1, 1))
