class_name MainMenu
extends Control

## Cinematic Sci-Fi Title Screen for VOIDSHIFT: The Living Evidence Engine.
## Replaces the sparse debug menu with a high-production title screen:
## - Cosmic planetary limb & atmospheric corona vista
## - Detailed DSS Chronos research vessel silhouette with illuminated bridge & ion thrusters
## - Layered parallax starfield with controlled ambient twinkling
## - High-hierarchy action cards with responsive hover, selection & audio cues
## - Integrated System Dossier (local offline stats) & Operational Protocols guides

const SaveManager = preload("res://scripts/core/SaveManager.gd")

signal start_game_requested(as_saboteur: bool)
signal academic_lab_requested()

enum MenuOption {
	PLAY_CREW = 0,
	PLAY_SABOTEUR = 1,
	ACADEMIC_LAB = 2,
	SETTINGS_STATS = 3,
	HOW_TO_PLAY = 4,
	QUIT = 5
}

var selected_option: int = 0
var hovered_option: int = -1
var anim_timer: float = 0.0
var show_how_to_play: bool = false
var show_settings: bool = false

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
			KEY_ENTER, KEY_SPACE:
				activate_option()
			KEY_G:
				academic_lab_requested.emit()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	var card_w: float = 480.0
	var card_x: float = (vp.x - card_w) * 0.5

	if event is InputEventMouseMotion:
		var mouse_ev := event as InputEventMouseMotion
		var mpos := mouse_ev.position
		hovered_option = -1
		var y := 260.0
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
		var y := 260.0
		for i in range(6):
			var btn_rect := Rect2(card_x, y, card_w, 48)
			if btn_rect.has_point(mpos):
				selected_option = i
				activate_option()
				return
			y += 56.0

func activate_option() -> void:
	match selected_option:
		MenuOption.PLAY_CREW:
			start_game_requested.emit(false)
		MenuOption.PLAY_SABOTEUR:
			start_game_requested.emit(true)
		MenuOption.ACADEMIC_LAB:
			academic_lab_requested.emit()
		MenuOption.SETTINGS_STATS:
			save_data = SaveManager.load_game_data()
			show_settings = true
		MenuOption.HOW_TO_PLAY:
			show_how_to_play = true
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

	if show_how_to_play:
		draw_how_to_play_modal(vp)
		return
	if show_settings:
		draw_settings_modal(vp)
		return

	# 4. Action Cards
	draw_action_cards(vp)

	# 5. Footer Academic & System Info
	draw_string(ThemeDB.fallback_font, Vector2(0, vp.y - 24),
		"VOIDSHIFT ENGINE v1.0.0  •  TY B.Tech Computer Graphics & Social Deduction Suite",
		HORIZONTAL_ALIGNMENT_CENTER, int(vp.x), 10, Color(0.38, 0.52, 0.68))

func draw_cosmic_space_vista(vp: Vector2) -> void:
	# Deep void background
	draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.015, 0.02, 0.04))

	# Majestic curved gas-giant planet horizon on right side
	var p_center := Vector2(vp.x + 180.0, vp.y * 0.45)
	var p_radius: float = vp.y * 0.95

	# Atmospheric glow corona
	draw_circle(p_center, p_radius + 35.0, Color(0.0, 0.35, 0.70, 0.15))
	draw_circle(p_center, p_radius + 15.0, Color(0.0, 0.65, 0.95, 0.22))
	# Planet body
	draw_circle(p_center, p_radius, Color(0.03, 0.08, 0.18))
	# Atmospheric limb rim arc
	draw_arc(p_center, p_radius, PI * 0.65, PI * 1.35, 60, Color(0.1, 0.85, 1.0, 0.95), 3.0)

	# Swirling planetary cloud bands
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
	# DSS Chronos research vessel floating in the upper left/midground
	var ship_pos := Vector2(vp.x * 0.22, vp.y * 0.38)
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
	# Illuminated Bridge Viewports
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
	# Upper engine plume
	draw_line(ship_pos + Vector2(-92, -6), ship_pos + Vector2(-92 - plume_len, -6), Color(0.0, 0.85, 1.0, 0.85), 3.0)
	draw_circle(ship_pos + Vector2(-92, -6), 3.5, Color(0.4, 0.95, 1.0))
	# Lower engine plume
	draw_line(ship_pos + Vector2(-92, 6), ship_pos + Vector2(-92 - plume_len, 6), Color(0.0, 0.85, 1.0, 0.85), 3.0)
	draw_circle(ship_pos + Vector2(-92, 6), 3.5, Color(0.4, 0.95, 1.0))

func draw_title_header(vp: Vector2) -> void:
	var title_w: float = 560.0
	var title_x: float = (vp.x - title_w) * 0.5
	var title_box := Rect2(title_x, 40, title_w, 180)

	# Corner brackets
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

	# Subtle radial glow behind title
	var glow_alpha: float = 0.12 + sin(anim_timer * 2.0) * 0.04
	draw_circle(Vector2(vp.x * 0.5, 110), 180.0, Color(0.0, 0.75, 1.0, glow_alpha))

	# Title text
	draw_string(ThemeDB.fallback_font, Vector2(title_x, 114), "V O I D S H I F T", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 40, Color(0.0, 0.92, 1.0))
	draw_string(ThemeDB.fallback_font, Vector2(title_x, 144), "THE LIVING EVIDENCE ENGINE", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 14, Color(1, 1, 1, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(title_x, 170), "Autonomous Sci-Fi Social Deduction & Investigation Platform", HORIZONTAL_ALIGNMENT_CENTER, int(title_w), 11, Color(0.6, 0.8, 1.0))

func draw_action_cards(vp: Vector2) -> void:
	var options := [
		{"title": "LAUNCH INVESTIGATION", "sub": "Play as Crewmate — Complete tasks & expose the saboteur", "tag": "SURVIVE", "primary": true},
		{"title": "COVERT INFILTRATION", "sub": "Play as Saboteur — Sabotage systems & evade deduction", "tag": "DECEIVE", "primary": false},
		{"title": "CG ACADEMIC LAB", "sub": "12 Interactive syllabus visualization modes [Key: G]", "tag": "SYLLABUS", "primary": false},
		{"title": "SYSTEM DOSSIER", "sub": "Offline career match history & engine statistics", "tag": "DATA", "primary": false},
		{"title": "OPERATIONAL PROTOCOLS", "sub": "Game rules, testimony guide, & viva preparation", "tag": "GUIDE", "primary": false},
		{"title": "ABORT MISSION", "sub": "Exit application to desktop", "tag": "EXIT", "primary": false}
	]

	var card_w: float = 500.0
	var card_x: float = (vp.x - card_w) * 0.5
	var y := 250.0

	for i in range(options.size()):
		var is_selected := (selected_option == i)
		var opt: Dictionary = options[i]
		var btn_rect := Rect2(card_x, y, card_w, 48)

		var bg_col: Color
		var border_col: Color
		var border_w: float = 1.5

		if is_selected:
			bg_col = Color(0.0, 0.36, 0.58, 0.94) if opt["primary"] else Color(0.08, 0.22, 0.36, 0.92)
			border_col = Color(0.0, 0.95, 1.0)
			border_w = 2.0
		else:
			bg_col = Color(0.04, 0.07, 0.12, 0.88)
			border_col = Color(0.14, 0.32, 0.48, 0.8)

		draw_rect(btn_rect, bg_col)
		draw_rect(btn_rect, border_col, false, border_w)

		# Left selection indicator diamond
		if is_selected:
			var ind_x: float = btn_rect.position.x + 14.0
			var ind_y: float = btn_rect.position.y + 24.0
			var pts: PackedVector2Array = [
				Vector2(ind_x - 4, ind_y),
				Vector2(ind_x, ind_y - 4),
				Vector2(ind_x + 4, ind_y),
				Vector2(ind_x, ind_y + 4)
			]
			draw_colored_polygon(pts, Color(0.2, 0.95, 0.95))

		# Option Title
		var title_col := Color(1, 1, 1) if is_selected else Color(0.88, 0.92, 0.98)
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 24, y + 21), opt["title"], HORIZONTAL_ALIGNMENT_LEFT, 310, 12, title_col)

		# Subtitle
		draw_string(ThemeDB.fallback_font, Vector2(card_x + 24, y + 36), opt["sub"], HORIZONTAL_ALIGNMENT_LEFT, 380, 9, Color(0.5, 0.72, 0.88))

		# Right Tag Pill
		var tag_rect := Rect2(btn_rect.end.x - 82, y + 14, 70, 20)
		var tag_bg := Color(0.0, 0.85, 1.0, 0.22) if is_selected else Color(0.1, 0.18, 0.28, 0.6)
		draw_rect(tag_rect, tag_bg)
		draw_rect(tag_rect, border_col * Color(1, 1, 1, 0.6), false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(tag_rect.position.x, y + 28), opt["tag"], HORIZONTAL_ALIGNMENT_CENTER, 70, 9, border_col)

		y += 55.0

func draw_settings_modal(vp: Vector2) -> void:
	var modal_w: float = 860.0
	var modal_h: float = 560.0
	var modal := Rect2((vp.x - modal_w) * 0.5, (vp.y - modal_h) * 0.5, modal_w, modal_h)

	draw_rect(modal, Color(0.03, 0.07, 0.13, 0.98))
	draw_rect(modal, Color(0.0, 0.85, 1.0), false, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 36, modal.position.y + 45), "OFFLINE DOSSIER & SYSTEM CONFIGURATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1))

	var stats: Dictionary = save_data.get("stats", {})
	var settings: Dictionary = save_data.get("settings", {})

	var lines := [
		"CAREER DOSSIER (Saved locally to user://voidshift_save.json):",
		"- Missions Deployed: %d" % stats.get("matches_played", 0),
		"- Crewmate Victories (Saboteur Unmasked): %d" % stats.get("crewmate_victories", 0),
		"- Saboteur Victories (Station Compromised): %d" % stats.get("saboteur_victories", 0),
		"- Total Maintenance Tasks Verified: %d" % stats.get("tasks_completed_lifetime", 0),
		"",
		"GRAPHICS & ARCHITECTURE SPECIFICATIONS:",
		"- Engine Core: Godot 4.x Desktop Pipeline (OpenGL 3.3 Compatibility)",
		"- Target Display: 1280 x 720 (16:9 Responsive Canvas Item Scaling)",
		"- Audio Engine: Procedural Synthetic AudioStreamGenerator (Zero External Codecs)",
		"- Screen Shake: %s" % ("ENABLED" if settings.get("screen_shake", true) else "DISABLED"),
		"- High-Contrast HUD: %s" % ("ENABLED" if settings.get("high_contrast_hud", false) else "DISABLED"),
		"",
		"Click anywhere or press ESC to return to title screen."
	]
	var y := modal.position.y + 85.0
	for l in lines:
		var col := Color(0.0, 0.92, 0.8) if (l.begins_with("CAREER") or l.begins_with("GRAPHICS")) else Color(0.85, 0.92, 0.98)
		draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 36, y), l, HORIZONTAL_ALIGNMENT_LEFT, int(modal_w - 72), 12, col)
		y += 27.0

func draw_how_to_play_modal(vp: Vector2) -> void:
	var modal_w: float = 900.0
	var modal_h: float = 580.0
	var modal := Rect2((vp.x - modal_w) * 0.5, (vp.y - modal_h) * 0.5, modal_w, modal_h)

	draw_rect(modal, Color(0.03, 0.07, 0.13, 0.98))
	draw_rect(modal, Color(0.0, 0.85, 1.0), false, 2.0)

	draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 36, modal.position.y + 45), "OPERATIONAL PROTOCOLS & LIVING EVIDENCE ENGINE GUIDE", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1))

	var lines := [
		"INPUT CONTROLS:",
		"- WASD / Arrow Keys : Navigate Commander Rex through station corridors and rooms",
		"- E : Contextual Action (Use Task Console / Call Emergency Meeting)",
		"- R : Report Discovered Body of Fallen Crewmate",
		"- TAB : Inspect The Living Evidence Engine (Event Log, Sightings, Alibis, Contradictions)",
		"- M : Toggle Expanded Tactical Station Map",
		"- SPACE : Saboteur Elimination (Requires proximity and zero cooldown)",
		"- V : Enter / Exit Station Ventilation Conduits (Saboteur Only)",
		"- G : Launch Computer Graphics Academic Laboratory (12 Syllabus Algorithms)",
		"- ESC : Pause Game / Dismiss Modal Dialogs",
		"",
		"THE LIVING EVIDENCE ENGINE INVESTIGATION LOOP:",
		"- The station continuously monitors and logs crew movements, console access, and CCTV sweeps.",
		"- When an Emergency Meeting is called, crew members give alibis based on actual timeline events.",
		"- If a suspect claims an alibi contradicted by sensor telemetry, the engine highlights [CONTRADICTION!].",
		"- Cross-examine testimonies with room transit logs to vote out the true Saboteur!",
		"",
		"Click anywhere or press ESC to return to title screen."
	]
	var y := modal.position.y + 80.0
	for l in lines:
		var col := Color(0.0, 0.92, 0.8) if (l.begins_with("INPUT") or l.begins_with("THE LIVING")) else Color(0.85, 0.92, 0.98)
		draw_string(ThemeDB.fallback_font, Vector2(modal.position.x + 36, y), l, HORIZONTAL_ALIGNMENT_LEFT, int(modal_w - 72), 11, col)
		y += 25.0
