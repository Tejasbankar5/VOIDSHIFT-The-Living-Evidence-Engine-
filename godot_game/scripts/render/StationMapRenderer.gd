class_name StationMapRenderer
extends RefCounted

## Master Multi-Campaign Map Renderer for VOIDSHIFT: The Living Evidence Engine.
## Renders 3 completely original 2D architectural environments:
## 1. THE HOLLOW CROWN (Ancient buried alien excavation with stone masonry, runes, resonance rings & vault relic)
## 2. BLACKGLASS STATION (High-tech orbital research outpost, shattered specimen lab, CCTV wall & reactor spine)
## 3. THE LAST SIGNAL (Frigid polar sub-ice installation, snow drifts, oscilloscopes, ice shaft & crystal monolith)
## Includes dedicated ECHO VISION forensic visualization overlay.

const GameEnums = preload("res://scripts/core/GameEnums.gd")
const StationData = preload("res://scripts/core/StationData.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")

static func draw_station(canvas: CanvasItem, anim_time: float, completed_tasks: Array[int],
						 sabotage_type: int, sabotage_timer: float,
						 campaign_mode: GameEnums.CampaignMode = GameEnums.CampaignMode.HOLLOW_CROWN,
						 echo_vision_active: bool = false, clues: Array = []) -> void:

	var campaign := CampaignData.get_campaign(campaign_mode)
	var rooms := campaign.rooms
	var corridors := campaign.corridors
	var tasks := campaign.tasks
	var vents := campaign.vents
	var cameras := campaign.cameras
	var is_critical_sabotage: bool = (sabotage_type != 0 and sabotage_type != GameEnums.SabotageType.NONE)

	# -------------------------------------------------------------------------
	# 1. ATMOSPHERIC BACKDROP & SECTOR VISTA
	# -------------------------------------------------------------------------
	match campaign_mode:
		GameEnums.CampaignMode.HOLLOW_CROWN:
			draw_hollow_crown_backdrop(canvas, anim_time)
		GameEnums.CampaignMode.BLACKGLASS_STATION:
			draw_blackglass_backdrop(canvas, anim_time)
		GameEnums.CampaignMode.THE_LAST_SIGNAL:
			draw_last_signal_backdrop(canvas, anim_time)

	# -------------------------------------------------------------------------
	# 2. CORRIDOR FLOORS & RUNWAY GUIDANCE LIGHTS
	# -------------------------------------------------------------------------
	for corr in corridors:
		var corr_bg := campaign.primary_bg.lightened(0.08)
		canvas.draw_rect(corr, corr_bg)

		var is_vert: bool = corr.size.y > corr.size.x
		var c_center := corr.get_center()

		if is_vert:
			var runner_w: float = corr.size.x * 0.55
			var runner := Rect2(c_center.x - (runner_w * 0.5), corr.position.y, runner_w, corr.size.y)
			canvas.draw_rect(runner, corr_bg.lightened(0.05))
			var gy: float = corr.position.y + 8.0
			while gy < corr.end.y - 8.0:
				var lamp_color: Color = campaign.accent_color
				if is_critical_sabotage:
					var blink: float = abs(sin(anim_time * 8.0 + gy * 0.05))
					lamp_color = Color(1.0, 0.2, 0.2, blink)
				canvas.draw_circle(Vector2(c_center.x - (runner_w * 0.5) + 4, gy), 2.0, lamp_color)
				canvas.draw_circle(Vector2(c_center.x + (runner_w * 0.5) - 4, gy), 2.0, lamp_color)
				gy += 22.0
		else:
			var runner_h: float = corr.size.y * 0.55
			var runner := Rect2(corr.position.x, c_center.y - (runner_h * 0.5), corr.size.x, runner_h)
			canvas.draw_rect(runner, corr_bg.lightened(0.05))
			var gx: float = corr.position.x + 8.0
			while gx < corr.end.x - 8.0:
				var lamp_color: Color = campaign.accent_color
				if is_critical_sabotage:
					var blink: float = abs(sin(anim_time * 8.0 + gx * 0.05))
					lamp_color = Color(1.0, 0.2, 0.2, blink)
				canvas.draw_circle(Vector2(gx, c_center.y - (runner_h * 0.5) + 4), 2.0, lamp_color)
				canvas.draw_circle(Vector2(gx, c_center.y + (runner_h * 0.5) - 4), 2.0, lamp_color)
				gx += 22.0

	# -------------------------------------------------------------------------
	# 3. ROOM FLOORS & SECTOR-SPECIFIC TEXTURES
	# -------------------------------------------------------------------------
	for r in rooms:
		canvas.draw_rect(r.rect, r.floor_color)

		# Distinct Sector Flooring
		match campaign_mode:
			GameEnums.CampaignMode.HOLLOW_CROWN:
				draw_hollow_crown_room_floor(canvas, r, anim_time)
			GameEnums.CampaignMode.BLACKGLASS_STATION:
				draw_blackglass_room_floor(canvas, r, anim_time)
			GameEnums.CampaignMode.THE_LAST_SIGNAL:
				draw_last_signal_room_floor(canvas, r, anim_time)

		# Soft Ambient Room Glow
		canvas.draw_rect(r.rect, r.ambient_color)

	# -------------------------------------------------------------------------
	# 4. 2.5D WALL BULKHEADS, DROPSHADOWS & STRUCTURAL BEVELS
	# -------------------------------------------------------------------------
	var wall_thick: float = 14.0
	for r in rooms:
		draw_bulkhead_walls(canvas, r.rect, wall_thick, campaign.border_color)

	# -------------------------------------------------------------------------
	# 5. SPECIALIZED INTERACTIVE PROPS & VISUAL FOCAL POINTS
	# -------------------------------------------------------------------------
	match campaign_mode:
		GameEnums.CampaignMode.HOLLOW_CROWN:
			draw_hollow_crown_props(canvas, anim_time, completed_tasks)
		GameEnums.CampaignMode.BLACKGLASS_STATION:
			draw_blackglass_props(canvas, anim_time, completed_tasks, is_critical_sabotage)
		GameEnums.CampaignMode.THE_LAST_SIGNAL:
			draw_last_signal_props(canvas, anim_time, completed_tasks)

	# -------------------------------------------------------------------------
	# 6. STENCIL ROOM LABELS
	# -------------------------------------------------------------------------
	for r in rooms:
		var label_pos := Vector2(r.rect.position.x + 24.0, r.rect.position.y + 36.0)
		var bracket_rect := Rect2(r.rect.position.x + 14.0, r.rect.position.y + 22.0, 6.0, 18.0)
		canvas.draw_rect(bracket_rect, r.accent_color)
		canvas.draw_string(ThemeDB.fallback_font, label_pos, r.short_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, r.accent_color)

	# -------------------------------------------------------------------------
	# 7. HAZARD CORRIDOR THRESHOLDS
	# -------------------------------------------------------------------------
	draw_corridor_thresholds(canvas, corridors, campaign.hazard_color)

	# -------------------------------------------------------------------------
	# 8. TASK CONSOLES & INTERACTION POINTS
	# -------------------------------------------------------------------------
	for t in tasks:
		var is_done: bool = (t.id in completed_tasks)
		draw_task_console(canvas, t.position, t.name, is_done, anim_time, campaign.accent_color)

	# -------------------------------------------------------------------------
	# 9. VENTILATION CONDUITS & CCTV CAMERAS
	# -------------------------------------------------------------------------
	for v in vents:
		draw_ventilation_grate(canvas, v.position, anim_time)

	for cam in cameras:
		draw_surveillance_camera(canvas, cam.position, cam.look_angle, cam.sweep_angle, anim_time)

	# -------------------------------------------------------------------------
	# 10. ECHO VISION FORENSIC OVERLAY & DETECTED CLUES
	# -------------------------------------------------------------------------
	if echo_vision_active:
		draw_echo_vision_overlay(canvas, anim_time, clues)

# =========================================================================
# BACKDROP RENDERERS
# =========================================================================
static func draw_hollow_crown_backdrop(canvas: CanvasItem, anim_time: float) -> void:
	# Deep subterranean excavation cavern
	canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(0.03, 0.03, 0.04))

	# Distant stone cavern arches
	for i in range(5):
		var ax := 200.0 + (i * 300.0)
		var ay := 100.0 + (i % 2) * 80.0
		canvas.draw_arc(Vector2(ax, ay), 180.0, PI, TAU, 32, Color(0.12, 0.10, 0.08, 0.4), 8.0, true)

	# Drifting gold archaeological dust motes
	for i in range(50):
		var dx: float = fmod(i * 127.0 + anim_time * 8.0, 1600.0)
		var dy: float = fmod(i * 211.0 + sin(anim_time + i) * 20.0, 1250.0)
		var alpha: float = 0.2 + abs(sin(anim_time * 1.5 + i)) * 0.35
		canvas.draw_circle(Vector2(dx, dy), 1.5, Color(0.85, 0.70, 0.35, alpha), true)

static func draw_blackglass_backdrop(canvas: CanvasItem, anim_time: float) -> void:
	# Deep space orbital backdrop
	canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(0.015, 0.02, 0.035))

	# Distant blue Earth/gas giant atmospheric rim
	canvas.draw_arc(Vector2(800, -600), 1100.0, 0.2, PI - 0.2, 64, Color(0.0, 0.4, 0.8, 0.25), 18.0, true)
	canvas.draw_arc(Vector2(800, -600), 1090.0, 0.2, PI - 0.2, 64, Color(0.2, 0.8, 1.0, 0.4), 4.0, true)

	# Stars
	for i in range(60):
		var sx: float = fmod(i * 139.0 + anim_time * 4.0, 1600.0)
		var sy: float = fmod(i * 241.0, 1250.0)
		var b: float = 0.3 + sin(anim_time * 2.2 + i) * 0.25
		canvas.draw_circle(Vector2(sx, sy), 1.2, Color(1, 1, 1, b), true)

static func draw_last_signal_backdrop(canvas: CanvasItem, anim_time: float) -> void:
	# Sub-ice polar cavern & blowing blizzard
	canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(0.02, 0.04, 0.07))

	# Glacial ice fissures
	for i in range(6):
		var fx := 150.0 + (i * 250.0)
		var pts: PackedVector2Array = [
			Vector2(fx, 0), Vector2(fx + 40, 400), Vector2(fx - 20, 800), Vector2(fx + 30, 1250)
		]
		canvas.draw_polyline(pts, Color(0.15, 0.35, 0.55, 0.25), 3.0, true)

	# Blowing snow particles
	for i in range(80):
		var sx: float = fmod(i * 97.0 - anim_time * 80.0, 1600.0)
		if sx < 0: sx += 1600.0
		var sy: float = fmod(i * 163.0 + anim_time * 25.0, 1250.0)
		var alpha: float = 0.2 + abs(sin(anim_time * 3.0 + i)) * 0.4
		canvas.draw_circle(Vector2(sx, sy), 1.8, Color(0.9, 0.95, 1.0, alpha), true)

# =========================================================================
# ROOM FLOOR RENDERERS
# =========================================================================
static func draw_hollow_crown_room_floor(canvas: CanvasItem, r: StationData.RoomDef, anim_time: float) -> void:
	# Ancient Sandstone Masonry Slabs
	var tile_size := 48.0
	var col := Color(0.75, 0.65, 0.45, 0.08)
	var x := r.rect.position.x + tile_size
	while x < r.rect.end.x:
		canvas.draw_line(Vector2(x, r.rect.position.y), Vector2(x, r.rect.end.y), col, 1.0)
		x += tile_size
	var y := r.rect.position.y + tile_size
	while y < r.rect.end.y:
		canvas.draw_line(Vector2(r.rect.position.x, y), Vector2(r.rect.end.x, y), col, 1.0)
		y += tile_size

	# Carved Alien Runic Circles in Buried Archive & Vault
	if r.id == "hollow_vault" or r.id == "resonance_chamber" or r.id == "buried_archive":
		var c := r.rect.get_center()
		canvas.draw_arc(c, 70.0, 0, TAU, 32, Color(0.85, 0.70, 0.35, 0.15), 1.5, true)
		canvas.draw_arc(c, 110.0, 0, TAU, 48, Color(0.85, 0.70, 0.35, 0.10), 1.5, true)

static func draw_blackglass_room_floor(canvas: CanvasItem, r: StationData.RoomDef, anim_time: float) -> void:
	var tile_size := 40.0
	var col := Color(0.18, 0.25, 0.35, 0.15)
	if r.id == "research_lab":
		col = Color(0.2, 0.8, 0.7, 0.15) # Clinical lab tiles
	elif r.id == "reactor_spine":
		col = Color(0.8, 0.2, 0.2, 0.15) # Industrial hazard

	var x := r.rect.position.x + tile_size
	while x < r.rect.end.x:
		canvas.draw_line(Vector2(x, r.rect.position.y), Vector2(x, r.rect.end.y), col, 1.0)
		x += tile_size
	var y := r.rect.position.y + tile_size
	while y < r.rect.end.y:
		canvas.draw_line(Vector2(r.rect.position.x, y), Vector2(r.rect.end.x, y), col, 1.0)
		y += tile_size

static func draw_last_signal_room_floor(canvas: CanvasItem, r: StationData.RoomDef, anim_time: float) -> void:
	# Frosted Deck Plates with Snow Accumulation
	var tile_size := 44.0
	var col := Color(0.35, 0.55, 0.75, 0.12)
	var x := r.rect.position.x + tile_size
	while x < r.rect.end.x:
		canvas.draw_line(Vector2(x, r.rect.position.y), Vector2(x, r.rect.end.y), col, 1.0)
		x += tile_size
	var y := r.rect.position.y + tile_size
	while y < r.rect.end.y:
		canvas.draw_line(Vector2(r.rect.position.x, y), Vector2(r.rect.end.x, y), col, 1.0)
		y += tile_size

	# Snow drifts along room borders
	var drift_col := Color(0.85, 0.92, 1.0, 0.18)
	canvas.draw_rect(Rect2(r.rect.position.x, r.rect.position.y, r.rect.size.x, 8), drift_col)
	canvas.draw_rect(Rect2(r.rect.position.x, r.rect.end.y - 8, r.rect.size.x, 8), drift_col)

# =========================================================================
# 2.5D BULKHEAD WALLS WITH TOP BEVELS
# =========================================================================
static func draw_bulkhead_walls(canvas: CanvasItem, r: Rect2, thick: float, wall_color: Color) -> void:
	# Drop shadows
	var shadow_rect := Rect2(r.position.x - thick + 4, r.position.y - thick + 6, r.size.x + (thick * 2), r.size.y + (thick * 2))
	canvas.draw_rect(shadow_rect, Color(0, 0, 0, 0.55), false, thick)

	# Main Wall Core
	var outer := Rect2(r.position.x - thick, r.position.y - thick, r.size.x + (thick * 2), r.size.y + (thick * 2))
	canvas.draw_rect(outer, Color(0.08, 0.10, 0.14), false, thick)

	# Top Bevel Trim
	canvas.draw_rect(outer, wall_color, false, 1.8)

	# Corner Reinforcement Pillars
	var corners := [
		outer.position,
		Vector2(outer.end.x, outer.position.y),
		Vector2(outer.position.x, outer.end.y),
		outer.end
	]
	for c in corners:
		canvas.draw_circle(c, 7.0, Color(0.12, 0.16, 0.22))
		canvas.draw_circle(c, 4.0, wall_color)

# =========================================================================
# CAMPAIGN SPECIFIC PROPS
# =========================================================================

# --- 1. THE HOLLOW CROWN PROPS ---
static func draw_hollow_crown_props(canvas: CanvasItem, anim_time: float, completed: Array[int]) -> void:
	# Resonance Chamber Mechanism (Circular rotating bronze/stone plates)
	var res_center := Vector2(290, 775)
	canvas.draw_circle(res_center, 65.0, Color(0.12, 0.10, 0.08))
	canvas.draw_arc(res_center, 65.0, 0, TAU, 36, Color(0.85, 0.65, 0.30), 3.0, true)
	canvas.draw_arc(res_center, 45.0, anim_time * 0.8, anim_time * 0.8 + TAU * 0.75, 24, Color(0.95, 0.75, 0.35), 2.5, true)
	canvas.draw_arc(res_center, 25.0, -anim_time * 1.2, -anim_time * 1.2 + TAU * 0.65, 18, Color(0.0, 0.85, 1.0), 2.0, true)
	canvas.draw_circle(res_center, 12.0, Color(0.95, 0.85, 0.40))

	# The Hollow Vault: Floating Alien Artifact (The Hollow Crown)
	var vault_center := Vector2(800, 1065)
	# Dais Platform
	canvas.draw_circle(vault_center, 80.0, Color(0.08, 0.09, 0.12))
	canvas.draw_arc(vault_center, 80.0, 0, TAU, 40, Color(0.85, 0.65, 0.30), 2.5, true)
	canvas.draw_arc(vault_center, 60.0, anim_time * 0.5, anim_time * 0.5 + TAU, 32, Color(0.0, 0.85, 1.0, 0.6), 1.5, true)

	# Floating Crown Relic with levitation oscillation
	var float_y := vault_center.y + sin(anim_time * 2.5) * 6.0
	var relic_pos := Vector2(vault_center.x, float_y)
	var crown_pts: PackedVector2Array = [
		relic_pos + Vector2(0, -22),
		relic_pos + Vector2(16, -6),
		relic_pos + Vector2(10, 16),
		relic_pos + Vector2(-10, 16),
		relic_pos + Vector2(-16, -6)
	]
	canvas.draw_colored_polygon(crown_pts, Color(0.95, 0.85, 0.45))
	canvas.draw_polyline(crown_pts, Color(0.0, 0.95, 1.0), 2.5, true)
	canvas.draw_circle(relic_pos, 7.0, Color(1, 1, 1))

	# Buried Archive Tablets
	var arch_pos := Vector2(1310, 450)
	canvas.draw_rect(Rect2(arch_pos.x - 40, arch_pos.y - 30, 80, 60), Color(0.12, 0.10, 0.14))
	canvas.draw_rect(Rect2(arch_pos.x - 40, arch_pos.y - 30, 80, 60), Color(0.65, 0.50, 0.85), false, 2.0)
	# Holographic glyph beam
	var beam_alpha: float = 0.3 + sin(anim_time * 4.0) * 0.2
	canvas.draw_circle(arch_pos, 20.0, Color(0.65, 0.50, 0.85, beam_alpha))

# --- 2. BLACKGLASS STATION PROPS ---
static func draw_blackglass_props(canvas: CanvasItem, anim_time: float, completed: Array[int], is_crit: bool) -> void:
	# Incident Lab: Shattered Specimen Tank & Neon Spill
	var lab_pos := Vector2(240, 450)
	canvas.draw_rect(Rect2(lab_pos.x - 45, lab_pos.y - 30, 90, 60), Color(0.08, 0.12, 0.14))
	canvas.draw_rect(Rect2(lab_pos.x - 45, lab_pos.y - 30, 90, 60), Color(0.15, 0.85, 0.70), false, 2.0)
	# Broken glass shards & fluorescent puddle
	var puddle_pts: PackedVector2Array = [
		lab_pos + Vector2(-25, 20), lab_pos + Vector2(10, 26), lab_pos + Vector2(35, 15),
		lab_pos + Vector2(25, -5), lab_pos + Vector2(-10, 5)
	]
	canvas.draw_colored_polygon(puddle_pts, Color(0.2, 0.95, 0.65, 0.45))
	# Yellow forensic cordon tape
	canvas.draw_line(lab_pos + Vector2(-55, 35), lab_pos + Vector2(55, 35), Color(0.95, 0.85, 0.15), 3.0)

	# Reactor Spine: Colossal Singularity Core
	var r_center := Vector2(290, 775)
	canvas.draw_circle(r_center, 60.0, Color(0.12, 0.05, 0.07))
	var core_col := Color(1.0, 0.25, 0.30) if is_crit else Color(0.1, 0.85, 1.0)
	canvas.draw_circle(r_center, 30.0 + sin(anim_time * 6.0) * 5.0, core_col)
	canvas.draw_arc(r_center, 55.0, anim_time * 1.5, anim_time * 1.5 + TAU * 0.7, 24, Color.WHITE, 2.0, true)

	# Surveillance Gallery: CCTV Wall
	var sec_pos := Vector2(1310, 450)
	for row in range(2):
		for col in range(3):
			var sx: float = sec_pos.x - 40.0 + (col * 28.0)
			var sy: float = sec_pos.y - 20.0 + (row * 24.0)
			canvas.draw_rect(Rect2(sx, sy, 24, 20), Color(0.05, 0.08, 0.12))
			canvas.draw_rect(Rect2(sx, sy, 24, 20), Color(0.2, 0.6, 0.9), false, 1.2)
			var blink: float = abs(sin(anim_time * 4.0 + col + row))
			canvas.draw_circle(Vector2(sx + 4, sy + 4), 1.5, Color(0.2, 0.9, 0.3, blink))

	# Briefing Amphitheater Table
	var table_pos := Vector2(800, 1065)
	canvas.draw_circle(table_pos, 75.0, Color(0.08, 0.11, 0.15))
	canvas.draw_arc(table_pos, 75.0, 0, TAU, 36, Color(0.0, 0.85, 1.0), 2.0, true)
	canvas.draw_circle(table_pos, 15.0, Color(0.0, 0.85, 1.0, 0.5))

# --- 3. THE LAST SIGNAL PROPS ---
static func draw_last_signal_props(canvas: CanvasItem, anim_time: float, completed: Array[int]) -> void:
	# Signal Laboratory: Dual Waveform Oscilloscopes
	var scope_pos := Vector2(240, 450)
	canvas.draw_rect(Rect2(scope_pos.x - 50, scope_pos.y - 30, 100, 60), Color(0.06, 0.08, 0.12))
	canvas.draw_rect(Rect2(scope_pos.x - 50, scope_pos.y - 30, 100, 60), Color(0.0, 0.85, 1.0), false, 2.0)
	# Sinusoidal acoustic waveform trace
	var wave_pts: PackedVector2Array = []
	for px in range(80):
		var wx: float = scope_pos.x - 40.0 + px
		var wy: float = scope_pos.y + sin((px * 0.2) + (anim_time * 8.0)) * 14.0
		wave_pts.append(Vector2(wx, wy))
	canvas.draw_polyline(wave_pts, Color(0.2, 0.95, 0.85), 2.0, true)

	# Storm Landing Pad: Spinning Wind Anemometer
	var land_pos := Vector2(800, 110)
	canvas.draw_circle(land_pos, 35.0, Color(0.08, 0.10, 0.15))
	canvas.draw_arc(land_pos, 35.0, 0, TAU, 24, Color(0.65, 0.85, 1.0), 2.0, true)
	# 3 Spinning Anemometer Cups
	for i in range(3):
		var angle: float = anim_time * 6.0 + (i * TAU / 3.0)
		var cup_pos := land_pos + Vector2(cos(angle), sin(angle)) * 25.0
		canvas.draw_line(land_pos, cup_pos, Color.WHITE, 2.0)
		canvas.draw_circle(cup_pos, 5.0, Color(1.0, 0.65, 0.2))

	# Sub-Ice Resonance Well: Crystalline Monolith
	var well_center := Vector2(800, 1065)
	canvas.draw_circle(well_center, 75.0, Color(0.04, 0.07, 0.12))
	canvas.draw_arc(well_center, 75.0, 0, TAU, 36, Color(0.2, 0.85, 1.0), 2.5, true)
	# Monolith Shard
	var mono_pts: PackedVector2Array = [
		well_center + Vector2(0, -35),
		well_center + Vector2(18, -10),
		well_center + Vector2(14, 25),
		well_center + Vector2(-14, 25),
		well_center + Vector2(-18, -10)
	]
	canvas.draw_colored_polygon(mono_pts, Color(0.1, 0.35, 0.6, 0.8))
	canvas.draw_polyline(mono_pts, Color(0.4, 0.9, 1.0), 2.5, true)
	# Acoustic pulsing rings
	var p_rad: float = fmod(anim_time * 40.0, 70.0)
	canvas.draw_arc(well_center, p_rad, 0, TAU, 24, Color(0.2, 0.85, 1.0, 1.0 - (p_rad / 70.0)), 2.0, true)

# =========================================================================
# COMMON ARCHITECTURAL DETAILS
# =========================================================================
static func draw_corridor_thresholds(canvas: CanvasItem, corridors: Array[Rect2], hazard_col: Color) -> void:
	for corr in corridors:
		var is_vert: bool = corr.size.y > corr.size.x
		if is_vert:
			draw_hazard_stripe(canvas, Rect2(corr.position.x, corr.position.y, corr.size.x, 8), hazard_col)
			draw_hazard_stripe(canvas, Rect2(corr.position.x, corr.end.y - 8, corr.size.x, 8), hazard_col)
		else:
			draw_hazard_stripe(canvas, Rect2(corr.position.x, corr.position.y, 8, corr.size.y), hazard_col)
			draw_hazard_stripe(canvas, Rect2(corr.end.x - 8, corr.position.y, 8, corr.size.y), hazard_col)

static func draw_hazard_stripe(canvas: CanvasItem, box: Rect2, col: Color) -> void:
	canvas.draw_rect(box, Color(0.12, 0.12, 0.14))
	var step := 8.0
	var s: float = 0.0
	while s < maxf(box.size.x, box.size.y):
		if box.size.x > box.size.y:
			canvas.draw_line(Vector2(box.position.x + s, box.position.y), Vector2(box.position.x + s + 6, box.end.y), col, 2.0)
		else:
			canvas.draw_line(Vector2(box.position.x, box.position.y + s), Vector2(box.end.x, box.position.y + s + 6), col, 2.0)
		s += step

static func draw_task_console(canvas: CanvasItem, pos: Vector2, tname: String, is_done: bool, anim_time: float, accent_col: Color) -> void:
	var base := Rect2(pos.x - 22, pos.y - 18, 44, 36)
	canvas.draw_rect(base, Color(0.12, 0.16, 0.22))
	var border_col := Color(0.2, 0.9, 0.4) if is_done else accent_col
	canvas.draw_rect(base, border_col, false, 2.0)

	# Holographic icon screen
	var screen_rect := Rect2(pos.x - 14, pos.y - 12, 28, 16)
	canvas.draw_rect(screen_rect, Color(0.04, 0.08, 0.12))
	var pulse: float = 0.6 + sin(anim_time * 5.0) * 0.4 if not is_done else 1.0
	canvas.draw_rect(screen_rect, border_col * pulse, false, 1.2)

	# Status LED
	var led_pos := Vector2(pos.x, pos.y + 10)
	canvas.draw_circle(led_pos, 3.5, Color(0.2, 0.9, 0.4) if is_done else Color(1.0, 0.75, 0.2))

static func draw_ventilation_grate(canvas: CanvasItem, pos: Vector2, anim_time: float) -> void:
	var v_rect := Rect2(pos.x - 20, pos.y - 14, 40, 28)
	canvas.draw_rect(v_rect, Color(0.08, 0.10, 0.14))
	canvas.draw_rect(v_rect, Color(0.4, 0.5, 0.6), false, 1.5)
	for i in range(4):
		var vy: float = pos.y - 8.0 + (i * 5.0)
		canvas.draw_line(Vector2(pos.x - 14, vy), Vector2(pos.x + 14, vy), Color(0.25, 0.30, 0.38), 1.5)

static func draw_surveillance_camera(canvas: CanvasItem, pos: Vector2, angle: float, sweep: float, anim_time: float) -> void:
	canvas.draw_circle(pos, 7.0, Color(0.12, 0.15, 0.20))
	var cur_angle := angle + sin(anim_time * 1.5) * (sweep * 0.5)
	var tip := pos + Vector2(cos(cur_angle), sin(cur_angle)) * 14.0
	canvas.draw_line(pos, tip, Color(0.0, 0.85, 1.0), 3.0)
	canvas.draw_circle(tip, 2.5, Color(1.0, 0.2, 0.2))

# =========================================================================
# 10. ECHO VISION FORENSIC OVERLAY & DETECTED CLUES
# =========================================================================
static func draw_echo_vision_overlay(canvas: CanvasItem, anim_time: float, clues: Array) -> void:
	# Atmospheric Cyan Scanline Overlay
	canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(0.0, 0.15, 0.25, 0.22))

	# Tactical Forensics Millimeter Grid
	var grid_size := 60.0
	var gx: float = 0.0
	while gx < 1600.0:
		canvas.draw_line(Vector2(gx, 0), Vector2(gx, 1250), Color(0.0, 0.85, 1.0, 0.05), 1.0)
		gx += grid_size
	var gy: float = 0.0
	while gy < 1250.0:
		canvas.draw_line(Vector2(0, gy), Vector2(1600, gy), Color(0.0, 0.85, 1.0, 0.05), 1.0)
		gy += grid_size

	# Echo Scan Beam sweeping across the sector
	var sweep_y: float = fmod(anim_time * 250.0, 1250.0)
	canvas.draw_line(Vector2(0, sweep_y), Vector2(1600, sweep_y), Color(0.2, 0.95, 1.0, 0.4), 2.0)

	# Draw Forensic Clue Reticles
	for clue in clues:
		var cpos: Vector2 = clue.position
		var is_col: bool = clue.is_collected

		var reticle_col := Color(0.2, 0.9, 0.4) if is_col else Color(0.0, 0.95, 1.0)
		var rad: float = 18.0 + sin(anim_time * 6.0) * 3.0

		# Holographic Target Reticle
		canvas.draw_arc(cpos, rad, 0, TAU, 24, reticle_col, 2.0, true)
		canvas.draw_arc(cpos, rad + 6.0, anim_time * 2.0, anim_time * 2.0 + PI * 0.5, 12, reticle_col, 1.5, true)
		canvas.draw_arc(cpos, rad + 6.0, anim_time * 2.0 + PI, anim_time * 2.0 + PI * 1.5, 12, reticle_col, 1.5, true)
		canvas.draw_circle(cpos, 4.0, Color.WHITE)

		# Forensic Label Tag
		var label_str: String = "[ANALYZED] %s" % clue.name if is_col else "[ECHO TRACE: %s - PRESS E]" % clue.name
		canvas.draw_string(ThemeDB.fallback_font, Vector2(cpos.x - 80, cpos.y - 28), label_str, HORIZONTAL_ALIGNMENT_CENTER, 220, 10, reticle_col)
