class_name MainMenu
extends Control

## Cinematic Sci-Fi Title Screen for VOIDSHIFT: The Living Evidence Engine.
## Implements the Three Story Campaigns Selection specified in the Master Brief:
## 1. THE HOLLOW CROWN (Buried alien excavation site)
## 2. BLACKGLASS STATION (Failing orbital research outpost)
## 3. THE LAST SIGNAL (Polar sub-ice acoustic anomaly)
## Plus CG Academic Lab, System Dossier, and Exit.

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")

signal campaign_selected(mode: GameEnums.CampaignMode, role_pref: int)
signal start_game_requested(as_saboteur: bool)
signal academic_lab_requested()

enum MenuOption {
	CAMPAIGN_HOLLOW_CROWN = 0,
	CAMPAIGN_BLACKGLASS = 1,
	CAMPAIGN_LAST_SIGNAL = 2,
	ACADEMIC_LAB = 3,
	SETTINGS_STATS = 4,
	QUIT = 5
}

var selected_option: int = 0
var hovered_option: int = -1
var anim_timer: float = 0.0
var show_how_to_play: bool = false
var show_settings: bool = false

var role_preference: int = 0 # 0: Random (20%), 1: Guaranteed Imposter (100%), 2: Guaranteed Crew Specialist
var save_data: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)
	save_data = SaveManager.load_game_data()

func _process(delta: float) -> void:
	if visible:
		anim_timer += delta
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		if show_how_to_play or show_settings:
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
				show_how_to_play = false
				show_settings = false
			return

		match event.keycode:
			KEY_W, KEY_UP:
				selected_option = (selected_option - 1 + 6) % 6
			KEY_S, KEY_DOWN:
				selected_option = (selected_option + 1) % 6
			KEY_T:
				cycle_role_preference()
			KEY_ENTER, KEY_SPACE:
				activate_option()
			KEY_G:
				academic_lab_requested.emit()

func cycle_role_preference() -> void:
	role_preference = (role_preference + 1) % 3
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	var card_w: float = 520.0
	var card_x: float = (vp.x - card_w) * 0.5

	if event is InputEventMouseMotion:
		var mouse_ev := event as InputEventMouseMotion
		var mpos := mouse_ev.position
		hovered_option = -1
		var y := 245.0
		for i in range(6):
			var btn_rect := Rect2(card_x, y, card_w, 48)
			if btn_rect.has_point(mpos):
				hovered_option = i
				selected_option = i
				break
			y += 56.0

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if show_how_to_play or show_settings:
			show_how_to_play = false
			show_settings = false
			return
		var mouse_ev := event as InputEventMouseButton
		var mpos := mouse_ev.position

		# Check role preference toggle click
		var role_rect := Rect2(card_x, 196, card_w, 34)
		if role_rect.has_point(mpos):
			cycle_role_preference()
			return

		var y := 245.0
		for i in range(6):
			var btn_rect := Rect2(card_x, y, card_w, 48)
			if btn_rect.has_point(mpos):
				selected_option = i
				activate_option()
				return
			y += 56.0

func activate_option() -> void:
	match selected_option:
		MenuOption.CAMPAIGN_HOLLOW_CROWN:
			campaign_selected.emit(GameEnums.CampaignMode.HOLLOW_CROWN, role_preference)
			start_game_requested.emit(role_preference == 1)
		MenuOption.CAMPAIGN_BLACKGLASS:
			campaign_selected.emit(GameEnums.CampaignMode.BLACKGLASS_STATION, role_preference)
			start_game_requested.emit(role_preference == 1)
		MenuOption.CAMPAIGN_LAST_SIGNAL:
			campaign_selected.emit(GameEnums.CampaignMode.THE_LAST_SIGNAL, role_preference)
			start_game_requested.emit(role_preference == 1)
		MenuOption.ACADEMIC_LAB:
			academic_lab_requested.emit()
		MenuOption.SETTINGS_STATS:
			save_data = SaveManager.load_game_data()
			show_settings = true
		MenuOption.QUIT:
			get_tree().quit()

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0 or vp.y <= 0:
		vp = Vector2(1280, 720)

	# 1. Cosmic Deep-Space Vista & Planetary Limb
	draw_cosmic_space_vista(vp)

	# 2. DSS Chronos Orbital Vessel Silhouette
	draw_dss_chronos_starship(vp)

	# 3. Main Title & Living Evidence Engine Header
	draw_title_header(vp)
	draw_role_preference_pill(vp)

	if show_how_to_play:
		draw_how_to_play_modal(vp)
		return
	if show_settings:
		draw_settings_modal(vp)
		return

	# 4. Action Cards
	draw_action_cards(vp)

	# 5. Footer Academic & System Info
	draw_string(ThemeDB.fallback_font, Vector2(0, vp.y - 20),
		"VOIDSHIFT ENGINE v2.0  •  THE LIVING EVIDENCE ENGINE  •  THREE ORIGINAL NARRATIVE CAMPAIGNS",
		HORIZONTAL_ALIGNMENT_CENTER, int(vp.x), 10, Color(0.38, 0.52, 0.68))

func draw_cosmic_space_vista(vp: Vector2) -> void:
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.015, 0.025, 0.045))

	# Majestic curved gas-giant planet horizon on right side
	var p_center := Vector2(vp.x + 180.0, vp.y * 0.45)
	var p_radius: float = vp.y * 0.95

	draw_circle(p_center, p_radius + 35.0, Color(0.0, 0.35, 0.70, 0.15))
	draw_circle(p_center, p_radius + 15.0, Color(0.0, 0.65, 0.95, 0.22))
	draw_circle(p_center, p_radius, Color(0.03, 0.08, 0.18))
	draw_arc(p_center, p_radius, PI * 0.65, PI * 1.35, 60, Color(0.1, 0.85, 1.0, 0.95), 3.0)

	draw_arc(p_center, p_radius - 40.0, PI * 0.75, PI * 1.25, 48, Color(0.06, 0.16, 0.32, 0.4), 14.0)
	draw_arc(p_center, p_radius - 120.0, PI * 0.72, PI * 1.28, 48, Color(0.08, 0.20, 0.38, 0.35), 18.0)

	# Cosmic Nebulae clouds
	var neb_x: float = vp.x * 0.25 + sin(anim_timer * 0.1) * 30.0
	draw_circle(Vector2(neb_x, vp.y * 0.3), 280.0, Color(0.10, 0.04, 0.18, 0.22))
	draw_circle(Vector2(neb_x + 100, vp.y * 0.7), 240.0, Color(0.03, 0.12, 0.22, 0.20))

	# Twinkling Stars
	for i in range(85):
		var sx: float = fmod(i * 151.0 + anim_timer * 5.0, vp.x)
		var sy: float = fmod(i * 257.0, vp.y)
		var b: float = 0.3 + sin(anim_timer * 2.5 + i) * 0.25
		draw_circle(Vector2(sx, sy), 1.2, Color(1, 1, 1, b))

func draw_dss_chronos_starship(vp: Vector2) -> void:
	var ship_pos := Vector2(vp.x * 0.20, vp.y * 0.36)
	var float_y: float = sin(anim_timer * 1.2) * 6.0
	ship_pos.y += float_y

	# Main Hull Spine
	draw_line(ship_pos + Vector2(-90, 0), ship_pos + Vector2(90, 0), Color(0.18, 0.25, 0.35), 7.0)
	draw_line(ship_pos + Vector2(-90, 0), ship_pos + Vector2(90, 0), Color(0.08, 0.12, 0.18), 5.0)

	# Forward Bridge Command Pod
	var bridge_pts: PackedVector2Array = [
		ship_pos + Vector2(90, -10),
		ship_pos + Vector2(130, -4),
		ship_pos + Vector2(130, 4),
		ship_pos + Vector2(90, 10)
	]
	draw_colored_polygon(bridge_pts, Color(0.20, 0.28, 0.40))
	draw_line(ship_pos + Vector2(100, -2), ship_pos + Vector2(125, -2), Color(0.0, 0.95, 1.0), 2.5)

	# Rotating Habitat Ring
	var ring_rx: float = 24.0
	var ring_ry: float = 54.0
	var ring_pulse: float = 1.0 + sin(anim_timer * 2.0) * 0.04
	draw_arc(ship_pos + Vector2(10, 0), ring_ry * ring_pulse, -PI * 0.5, PI * 0.5, 24, Color(0.15, 0.35, 0.55, 0.7), 2.5)
	draw_arc(ship_pos + Vector2(10, 0), ring_ry * ring_pulse, PI * 0.5, PI * 1.5, 24, Color(0.10, 0.22, 0.35, 0.5), 1.5)

	# Solar Radiator Array Wings
	for wx in [-50.0, -20.0, 40.0]:
		draw_line(ship_pos + Vector2(wx, -42), ship_pos + Vector2(wx, 42), Color(0.2, 0.38, 0.55, 0.75), 2.0)
		draw_rect(Rect2(ship_pos.x + wx - 8, ship_pos.y - 38, 16, 18), Color(0.08, 0.22, 0.38, 0.5))
		draw_rect(Rect2(ship_pos.x + wx - 8, ship_pos.y + 20, 16, 18), Color(0.08, 0.22, 0.38, 0.5))

	# Stern Ion Propulsion Engines & Twin Cyan Thruster Plumes
	var plume_len: float = 38.0 + sin(anim_timer * 12.0) * 8.0
	draw_line(ship_pos + Vector2(-92, -6), ship_pos + Vector2(-92 - plume_len, -6), Color(0.0, 0.85, 1.0, 0.85), 3.0)
	draw_circle(ship_pos + Vector2(-92, -6), 3.5, Color(0.4, 0.95, 1.0))
	draw_line(ship_pos + Vector2(-92, 6), ship_pos + Vector2(-92 - plume_len, 6), Color(0.0, 0.85, 1.0, 0.85), 3.0)
	draw_circle(ship_pos + Vector2(-92, 6), 3.5, Color(0.4, 0.95, 1.0))

func draw_title_header(vp: Vector2) -> void:
	var title_w: float = 620.0
	var title_x: float = (vp.x - title_w) * 0.5
	var title_box := Rect2(title_x, 30, title_w, 190)

	var bracket_len: float = 24.0
	var c_col := Color(0.0, 0.85, 1.0, 0.75)
	draw_line(title_box.position, title_box.position + Vector2(bracket_len, 0), c_col, 2.0)
	draw_line(title_box.position, title_box.position + Vector2(0, bracket_len), c_col, 2.0)
	draw_line(Vector2(title_box.end.x, title_box.position.y), Vector2(title_box.end.x - bracket_len, title_box.position.y), c_col, 2.0)
	draw_line(Vector2(title_box.end.x, title_box.position.y), Vector2(title_box.end.x, title_box.position.y + bracket_len), c_col, 2.0)
	draw_line(Vector2(title_box.position.x, title_box.end.y), Vector2(title_box.position.x + bracket_len, title_box.end.y), c_col, 2.0)
	draw_line(Vector2(title_box.position.x, title_box.end.y), Vector2(title_box.position.x, title_box.end.y - bracket_len), c_col, 2.0)
	draw_line(title_box.end, title_box.end - Vector2(bracket_len, 0), c_col, 2.0)
	draw_line(title_box.end, title_box.end - Vector2(0, bracket_len), c_col, 2.0)

	var glow_alpha: float = 0.12 + sin(anim_timer * 2.0) * 0.04
	draw_circle(Vector2(vp.x * 0.5, 105), 180.0, Color(0.0, 0.75, 1.0, glow_alpha))

	draw_string(ThemeDB.fallback_font, Vector2(title_x, 102), "V O I D S H I F T", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 40, Color(0.0, 0.92, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(title_x, 132), "THE LIVING EVIDENCE ENGINE", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 14, Color(1, 1, 1, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(title_x, 156), "EVERY WITNESS HAS A STORY. EVERY STORY LEAVES A TRACE.", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 11, Color(0.85, 0.75, 0.40))
	draw_string(ThemeDB.fallback_font, Vector2(title_x, 178), "Autonomous 2D Sci-Fi Social Deduction & Forensic Investigation Suite", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 10, Color(0.55, 0.75, 0.95))

func draw_role_preference_pill(vp: Vector2) -> void:
	var card_w: float = 520.0
	var card_x: float = (vp.x - card_w) * 0.5
	var pill_rect := Rect2(card_x, 196, card_w, 34)

	var p_col: Color
	var p_text: String
	var p_tag: String
	match role_preference:
		0:
			p_col = Color(0.95, 0.75, 0.25)
			p_text = "ROLE: RANDOM UNCERTAINTY (20% SABOTEUR)"
			p_tag = "DEFAULT"
		1:
			p_col = Color(1.0, 0.25, 0.35)
			p_text = "ROLE: SHADOW PROTOCOL (100% GUARANTEED IMPOSTOR)"
			p_tag = "IMPOSTOR"
		2:
			p_col = Color(0.0, 0.88, 1.0)
			p_text = "ROLE: CREW SPECIALIST (0% SABOTEUR)"
			p_tag = "CREW"

	# Glow for shadow protocol
	if role_preference == 1:
		var glow_pulse: float = 0.85 + sin(anim_timer * 4.0) * 0.15
		draw_rect(pill_rect, Color(0.20, 0.04, 0.08, 0.90))
		draw_rect(pill_rect, p_col * glow_pulse, false, 2.0)
	else:
		draw_rect(pill_rect, Color(0.04, 0.08, 0.14, 0.85))
		draw_rect(pill_rect, p_col * 0.7, false, 1.4)

	# Tag badge on right
	var tag_rect := Rect2(pill_rect.end.x - 84, pill_rect.position.y + 7, 74, 20)
	draw_rect(tag_rect, p_col * 0.25)
	draw_rect(tag_rect, p_col * 0.8, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(tag_rect.position.x, tag_rect.position.y + 14), p_tag, HORIZONTAL_ALIGNMENT_CENTER, int(tag_rect.size.x), 9, p_col)

	# Main Label
	draw_string(ThemeDB.fallback_font, Vector2(pill_rect.position.x + 14, pill_rect.position.y + 22), "[T / CLICK TO CYCLE]  " + p_text, HORIZONTAL_ALIGNMENT_LEFT, int(card_w - 96), 10, p_col)

func draw_action_cards(vp: Vector2) -> void:
	var options := [
		{"title": "1. THE HOLLOW CROWN", "sub": "Archaeological Sci-Fi Mystery — Buried Alien Complex", "tag": "CAMPAIGN I", "primary": true, "accent": Color(0.9, 0.75, 0.35)},
		{"title": "2. BLACKGLASS STATION", "sub": "Forensic Noir Mystery — Failing Orbital Outpost", "tag": "CAMPAIGN II", "primary": true, "accent": Color(0.0, 0.85, 1.0)},
		{"title": "3. THE LAST SIGNAL", "sub": "Polar Survival Mystery — Sub-Ice Temporal Anomaly", "tag": "CAMPAIGN III", "primary": true, "accent": Color(0.6, 0.85, 1.0)},
		{"title": "CG ACADEMIC LAB", "sub": "12 Interactive syllabus visualization modes [Key: G]", "tag": "SYLLABUS", "primary": false, "accent": Color(0.2, 0.9, 0.6)},
		{"title": "SYSTEM DOSSIER & PROTOCOLS", "sub": "Offline career match history, forensic rules & guide", "tag": "DOSSIER", "primary": false, "accent": Color(0.7, 0.6, 0.9)},
		{"title": "ABORT MISSION", "sub": "Exit application to desktop", "tag": "EXIT", "primary": false, "accent": Color(0.8, 0.3, 0.3)}
	]

	var card_w: float = 520.0
	var card_x: float = (vp.x - card_w) * 0.5
	var y := 240.0

	for i in range(options.size()):
		var is_selected := (selected_option == i)
		var opt: Dictionary = options[i]
		var btn_rect := Rect2(card_x, y, card_w, 48)

		var bg_col: Color
		var border_col: Color = opt["accent"]
		var border_w: float = 1.5

		if is_selected:
			bg_col = Color(0.04, 0.20, 0.35, 0.95) if opt["primary"] else Color(0.08, 0.16, 0.28, 0.92)
			border_w = 2.0
		else:
			bg_col = Color(0.03, 0.06, 0.11, 0.88)
			border_col = opt["accent"] * Color(1, 1, 1, 0.6)

		draw_rect(btn_rect, bg_col)
		draw_rect(btn_rect, border_col, false, border_w)

		if is_selected:
			var ind_x: float = btn_rect.position.x + 14.0
			var ind_y: float = btn_rect.position.y + 24.0
			var pts: PackedVector2Array = [
				Vector2(ind_x - 4, ind_y),
				Vector2(ind_x, ind_y - 4),
				Vector2(ind_x + 4, ind_y),
				Vector2(ind_x, ind_y + 4)
			]
			draw_colored_polygon(pts, border_col)

		var title_col := Color(1, 1, 1) if is_selected else Color(0.88, 0.92, 0.98)
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 24, y + 21), opt["title"], HORIZONTAL_ALIGNMENT_LEFT, 320, 12, title_col)
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 24, y + 36), opt["sub"], HORIZONTAL_ALIGNMENT_LEFT, 390, 9, Color(0.5, 0.72, 0.88))

		# Tag pill
		var tag_rect := Rect2(btn_rect.end.x - 90, y + 14, 80, 20)
		var tag_bg := border_col * Color(1, 1, 1, 0.2) if is_selected else Color(0.08, 0.14, 0.22, 0.6)
		draw_rect(tag_rect, tag_bg)
		draw_rect(tag_rect, border_col, false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(tag_rect.position.x, y + 28), opt["tag"], HORIZONTAL_ALIGNMENT_CENTER, 80, 9, border_col)

		y += 55.0

func draw_settings_modal(vp: Vector2) -> void:
	var modal_w: float = 880.0
	var modal_h: float = 580.0
	var modal := Rect2((vp.x - modal_w) * 0.5, (vp.y - modal_h) * 0.5, modal_w, modal_h)

	draw_rect(modal, Color(0.03, 0.07, 0.13, 0.98))
	draw_rect(modal, Color(0.0, 0.85, 1.0), false, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 36, modal.position.y + 42), "SYSTEM DOSSIER & OPERATIONAL PROTOCOLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1))

	var stats: Dictionary = save_data.get("stats", {})
	var lines := [
		"EXPEDITION DOSSIER (Saved locally to user://voidshift_save.json):",
		"- Missions Deployed: %d" % stats.get("matches_played", 0),
		"- Crewmate Victories (Saboteur Unmasked): %d" % stats.get("crewmate_victories", 0),
		"- Saboteur Victories (Station Compromised): %d" % stats.get("saboteur_victories", 0),
		"- Total Maintenance Tasks Verified: %d" % stats.get("tasks_completed_lifetime", 0),
		"",
		"THREE NARRATIVE CAMPAIGNS:",
		"- THE HOLLOW CROWN: Subterranean alien ruins. Recover the Hollow Crown before containment collapse.",
		"- BLACKGLASS STATION: Forensic murder mystery. Examine shattered neurotoxin vials & scrubbed CCTV logs.",
		"- THE LAST SIGNAL: Sub-ice polar facility. Decode repeating acoustic waves & resolve temporal echo anomalies.",
		"",
		"CONTROLS: WASD = Move | E = Contextual Interact | Q = Echo Vision | TAB = Evidence Workstation | ESC = Back",
		"",
		"Click anywhere or press ESC to return to title screen."
	]
	var y := modal.position.y + 80.0
	for l in lines:
		var col := Color(0.0, 0.92, 0.8) if (l.begins_with("EXPEDITION") or l.begins_with("THREE") or l.begins_with("CONTROLS")) else Color(0.85, 0.92, 0.98)
		draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 36, y), l, HORIZONTAL_ALIGNMENT_LEFT, int(modal_w - 72), 11, col)
		y += 26.0

func draw_how_to_play_modal(vp: Vector2) -> void:
	draw_settings_modal(vp)
