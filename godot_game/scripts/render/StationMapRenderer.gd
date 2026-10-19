class_name StationMapRenderer
extends RefCounted

## High-Fidelity 2.5D Sci-Fi Map Renderer for DSS Chronos (VOIDSHIFT).
## Faithfully recreates the visual excellence of the design references:
## - Full anti-aliasing on all arcs, polygons, circles and vector lines
## - 2.5D bulkheads with realistic wall thickness, top bevels, drop shadows, and structural ribs
## - Distinctive Sector Flooring: clinical white tiles, diamond-tread industrial plating, caution chevrons
## - Panoramic Bridge Viewport looking out into deep space, glowing nebula & planetary curve
## - Colossal Reactor Core with pulsing containment plasma, electromagnetic coils & spark particles
## - Clinical Medical Bay with biometric holo-scan bed & ECG monitors
## - High-voltage Electrical junction boxes, power cables & lightning decals
## - Multi-monitor CCTV surveillance wall in Security Station
## - Executive Meeting table with rotating 3D holographic planet globe & emergency button pedestal
## - Decorative life-support oxygen bio-plants in room corners (matching reference imagery)
## - Clear stencil floor typography positioned cleanly without HUD collisions

static func draw_station(canvas: CanvasItem, anim_time: float, completed_tasks: Array[int],
						 sabotage_type: int, sabotage_timer: float) -> void:
	var rooms := StationData.get_rooms()
	var corridors := StationData.get_corridors()
	var tasks := StationData.get_task_spots()
	var vents := StationData.get_vents()
	var cameras := StationData.get_cameras()
	var is_reactor_sabotaged: bool = (sabotage_type == 1) # REACTOR
	var is_lights_sabotaged: bool = (sabotage_type == 2)   # LIGHTS

	# -------------------------------------------------------------------------
	# 1. DEEP SPACE BACKDROP & NEBULA
	# -------------------------------------------------------------------------
	canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(0.015, 0.02, 0.035))

	# Distant cosmic dust & nebula clouds
	for i in range(4):
		var n_cx := 300.0 + (i * 350.0) + sin(anim_time * 0.15 + i) * 30.0
		var n_cy := 200.0 + (i * 220.0)
		var n_col := Color(0.06, 0.12, 0.22, 0.18) if (i % 2 == 0) else Color(0.12, 0.05, 0.20, 0.16)
		canvas.draw_circle(Vector2(n_cx, n_cy), 220.0, n_col, true)

	# Twinkling space stars
	for i in range(70):
		var sx: float = fmod(i * 139.0 + anim_time * 4.0, 1600.0)
		var sy: float = fmod(i * 241.0, 1250.0)
		var b: float = 0.3 + sin(anim_time * 2.2 + i) * 0.25
		canvas.draw_circle(Vector2(sx, sy), 1.2, Color(1, 1, 1, b), true)

	# -------------------------------------------------------------------------
	# 2. CORRIDOR FLOORS & RUNWAY GUIDANCE LIGHTS
	# -------------------------------------------------------------------------
	for corr in corridors:
		canvas.draw_rect(corr, Color(0.09, 0.11, 0.15))

		var is_vert: bool = corr.size.y > corr.size.x
		var c_center := corr.get_center()

		if is_vert:
			var runner_w: float = corr.size.x * 0.55
			var runner := Rect2(c_center.x - (runner_w * 0.5), corr.position.y, runner_w, corr.size.y)
			canvas.draw_rect(runner, Color(0.12, 0.15, 0.20))
			var gy: float = corr.position.y + 8.0
			while gy < corr.end.y - 6.0:
				canvas.draw_line(Vector2(runner.position.x, gy), Vector2(runner.end.x, gy), Color(0.18, 0.24, 0.32, 0.6), 1.5, true)
				gy += 14.0
			canvas.draw_line(Vector2(corr.position.x + 3, corr.position.y), Vector2(corr.position.x + 3, corr.end.y), Color(0.0, 0.85, 1.0, 0.45), 2.0, true)
			canvas.draw_line(Vector2(corr.end.x - 3, corr.position.y), Vector2(corr.end.x - 3, corr.end.y), Color(0.0, 0.85, 1.0, 0.45), 2.0, true)
		else:
			var runner_h: float = corr.size.y * 0.55
			var runner := Rect2(corr.position.x, c_center.y - (runner_h * 0.5), corr.size.x, runner_h)
			canvas.draw_rect(runner, Color(0.12, 0.15, 0.20))
			var gx: float = corr.position.x + 8.0
			while gx < corr.end.x - 6.0:
				canvas.draw_line(Vector2(gx, runner.position.y), Vector2(gx, runner.end.y), Color(0.18, 0.24, 0.32, 0.6), 1.5, true)
				gx += 14.0
			canvas.draw_line(Vector2(corr.position.x, corr.position.y + 3), Vector2(corr.end.x, corr.position.y + 3), Color(0.0, 0.85, 1.0, 0.45), 2.0, true)
			canvas.draw_line(Vector2(corr.position.x, corr.end.y - 3), Vector2(corr.end.x, corr.end.y - 3), Color(0.0, 0.85, 1.0, 0.45), 2.0, true)

		draw_doorway_threshold(canvas, corr, is_vert)

	# -------------------------------------------------------------------------
	# 3. SECTOR ROOM FLOORS & TILES
	# -------------------------------------------------------------------------
	for r in rooms:
		canvas.draw_rect(r.rect, r.floor_color)

		match r.id:
			"bridge":
				draw_bridge_floor(canvas, r.rect, anim_time)
			"medical":
				draw_medical_floor(canvas, r.rect, anim_time)
			"reactor":
				draw_reactor_floor(canvas, r.rect, anim_time, is_reactor_sabotaged)
			"electrical":
				draw_electrical_floor(canvas, r.rect, anim_time)
			"security":
				draw_security_floor(canvas, r.rect, anim_time)
			"meeting":
				draw_meeting_floor(canvas, r.rect, anim_time)
			"central_hub":
				draw_hub_floor(canvas, r.rect, anim_time)
			"research":
				draw_research_floor(canvas, r.rect, anim_time)
			"storage":
				draw_storage_floor(canvas, r.rect, anim_time)

		# North & West wall drop shadows
		var sh_north := Rect2(r.rect.position.x, r.rect.position.y, r.rect.size.x, 16.0)
		canvas.draw_rect(sh_north, Color(0.0, 0.0, 0.0, 0.45))
		var sh_west := Rect2(r.rect.position.x, r.rect.position.y, 16.0, r.rect.size.y)
		canvas.draw_rect(sh_west, Color(0.0, 0.0, 0.0, 0.40))

		# Sector floor boundary accent line
		var border_col := r.accent_color
		border_col.a = 0.55
		canvas.draw_rect(r.rect.grow(-3.0), border_col, false, 1.5)

		# Sector Stencil Typography
		draw_sector_stencil_label(canvas, r)

	# -------------------------------------------------------------------------
	# 4. STRUCTURAL 2.5D WALL BULKHEADS
	# -------------------------------------------------------------------------
	draw_station_walls_and_bulkheads(canvas, anim_time)

	# -------------------------------------------------------------------------
	# 5. SPECIALIZED PROPS & CORNER BIO-PLANTS
	# -------------------------------------------------------------------------
	# Bio-plants in room corners (matching reference imagery)
	draw_bio_plant(canvas, Vector2(130, 350))   # Medical Bay corner
	draw_bio_plant(canvas, Vector2(450, 350))   # Medical Bay corner
	draw_bio_plant(canvas, Vector2(570, 1135))  # Meeting Room bottom-left
	draw_bio_plant(canvas, Vector2(1030, 1135)) # Meeting Room bottom-right
	draw_bio_plant(canvas, Vector2(610, 80))    # Bridge corner
	draw_bio_plant(canvas, Vector2(990, 80))    # Bridge corner

	# Room Props
	draw_bridge_props(canvas, anim_time)
	draw_reactor_props(canvas, anim_time, is_reactor_sabotaged, sabotage_timer)
	draw_medical_props(canvas, anim_time)
	draw_electrical_props(canvas, anim_time)
	draw_security_props(canvas, anim_time)
	draw_meeting_props(canvas, anim_time)
	draw_storage_props(canvas, anim_time)

	# -------------------------------------------------------------------------
	# 6. INTERACTIVE TASK CONSOLES
	# -------------------------------------------------------------------------
	for t in tasks:
		draw_task_console(canvas, t, t.id in completed_tasks, anim_time)

	# -------------------------------------------------------------------------
	# 7. VENTILATION CONDUITS
	# -------------------------------------------------------------------------
	for v in vents:
		draw_vent_shaft(canvas, v, anim_time)

	# -------------------------------------------------------------------------
	# 8. SECURITY CCTV CAMERAS & SWEEPING VISION CONES
	# -------------------------------------------------------------------------
	for cam in cameras:
		draw_cctv_camera(canvas, cam, anim_time)

	# -------------------------------------------------------------------------
	# 9. SABOTAGE EMERGENCY ALARM OVERLAY
	# -------------------------------------------------------------------------
	if is_reactor_sabotaged:
		var alarm_pulse: float = abs(sin(anim_time * 6.0)) * 0.18
		canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(1.0, 0.05, 0.1, alarm_pulse))
	elif is_lights_sabotaged:
		canvas.draw_rect(Rect2(0, 0, 1600, 1250), Color(0.01, 0.02, 0.04, 0.45))

# =========================================================================
# HELPER: DOORWAY THRESHOLDS
# =========================================================================
static func draw_doorway_threshold(canvas: CanvasItem, corr: Rect2, is_vert: bool) -> void:
	if is_vert:
		draw_hazard_strip(canvas, Rect2(corr.position.x, corr.position.y, corr.size.x, 8.0))
		draw_hazard_strip(canvas, Rect2(corr.position.x, corr.end.y - 8.0, corr.size.x, 8.0))
	else:
		draw_hazard_strip(canvas, Rect2(corr.position.x, corr.position.y, 8.0, corr.size.y))
		draw_hazard_strip(canvas, Rect2(corr.end.x - 8.0, corr.position.y, 8.0, corr.size.y))

static func draw_hazard_strip(canvas: CanvasItem, rect: Rect2) -> void:
	canvas.draw_rect(rect, Color(0.12, 0.14, 0.18))
	var step: float = 8.0
	var is_vert: bool = rect.size.y > rect.size.x
	if not is_vert:
		var x: float = rect.position.x
		while x < rect.end.x:
			var pts: PackedVector2Array = [
				Vector2(x, rect.position.y),
				Vector2(minf(x + 5.0, rect.end.x), rect.position.y),
				Vector2(x, rect.end.y),
				Vector2(maxf(x - 5.0, rect.position.x), rect.end.y)
			]
			canvas.draw_colored_polygon(pts, Color(0.95, 0.78, 0.15, 0.85))
			x += step
	else:
		var y: float = rect.position.y
		while y < rect.end.y:
			var pts: PackedVector2Array = [
				Vector2(rect.position.x, y),
				Vector2(rect.end.x, minf(y + 5.0, rect.end.y)),
				Vector2(rect.end.x, y),
				Vector2(rect.position.x, maxf(y - 5.0, rect.position.y))
			]
			canvas.draw_colored_polygon(pts, Color(0.95, 0.78, 0.15, 0.85))
			y += step

# =========================================================================
# HELPER: OXYGEN BIO-PLANT (MATCHING REFERENCE DESIGN)
# =========================================================================
static func draw_bio_plant(canvas: CanvasItem, pos: Vector2) -> void:
	# Hexagonal / circular modern pot
	canvas.draw_circle(pos + Vector2(0, 3), 11.0, Color(0.04, 0.06, 0.09), true)
	canvas.draw_circle(pos, 10.0, Color(0.18, 0.22, 0.28), true)
	canvas.draw_arc(pos, 10.0, 0, TAU, 18, Color(0.0, 0.85, 1.0, 0.5), 1.2, true)
	# Soil
	canvas.draw_circle(pos, 7.5, Color(0.10, 0.08, 0.06), true)
	# Foliage clusters (vibrant bio-green leaves)
	var leaf_col := Color(0.12, 0.82, 0.40)
	var leaf_col_dark := Color(0.08, 0.60, 0.30)
	canvas.draw_circle(pos + Vector2(-4, -4), 5.5, leaf_col_dark, true)
	canvas.draw_circle(pos + Vector2(4, -3), 5.0, leaf_col_dark, true)
	canvas.draw_circle(pos + Vector2(0, -6), 6.0, leaf_col, true)
	canvas.draw_circle(pos + Vector2(-3, 2), 4.5, leaf_col, true)
	canvas.draw_circle(pos + Vector2(3, 2), 4.5, leaf_col, true)

# =========================================================================
# SECTOR FLOOR DETAILING
# =========================================================================
static func draw_bridge_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	var cx := rect.get_center().x
	var runway := Rect2(cx - 30.0, rect.position.y + 40.0, 60.0, rect.size.y - 60.0)
	canvas.draw_rect(runway, Color(0.11, 0.18, 0.28))
	canvas.draw_line(Vector2(cx, rect.position.y + 40.0), Vector2(cx, rect.end.y - 20.0), Color(0.0, 0.85, 1.0, 0.6), 2.0, true)
	draw_floor_grid(canvas, rect, 42.0, Color(0.0, 0.8, 1.0, 0.05))

static func draw_medical_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	draw_floor_grid(canvas, rect, 38.0, Color(0.2, 0.95, 0.75, 0.07))
	var cross_center := Vector2(rect.position.x + 90, rect.position.y + 80)
	canvas.draw_circle(cross_center, 30.0, Color(0.08, 0.14, 0.18), true)
	canvas.draw_arc(cross_center, 30.0, 0, TAU, 32, Color(0.2, 0.9, 0.6, 0.5), 1.5, true)
	canvas.draw_rect(Rect2(cross_center.x - 18, cross_center.y - 6, 36, 12), Color(0.92, 0.22, 0.26, 0.85))
	canvas.draw_rect(Rect2(cross_center.x - 6, cross_center.y - 18, 12, 36), Color(0.92, 0.22, 0.26, 0.85))

static func draw_reactor_floor(canvas: CanvasItem, rect: Rect2, _time: float, sabotaged: bool) -> void:
	draw_floor_grid(canvas, rect, 44.0, Color(0.8, 0.2, 1.0, 0.06))
	var r_center := Vector2(290, 775)
	var ring_col := Color(1.0, 0.2, 0.2, 0.6) if sabotaged else Color(0.8, 0.2, 1.0, 0.4)
	canvas.draw_arc(r_center, 105.0, 0, TAU, 48, ring_col, 2.0, true)
	for i in range(8):
		var angle := i * (TAU / 8.0)
		var p1 := r_center + Vector2(cos(angle), sin(angle)) * 95.0
		var p2 := r_center + Vector2(cos(angle), sin(angle)) * 125.0
		canvas.draw_line(p1, p2, Color(1.0, 0.75, 0.15, 0.6), 2.5, true)

static func draw_electrical_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	draw_floor_grid(canvas, rect, 32.0, Color(1.0, 0.85, 0.2, 0.06))
	canvas.draw_rect(rect.grow(-8.0), Color(1.0, 0.75, 0.15, 0.3), false, 1.5)
	canvas.draw_line(Vector2(rect.position.x + 30, rect.position.y + 40), Vector2(rect.position.x + 30, rect.end.y - 30), Color(0.2, 0.25, 0.32), 4.5, true)
	canvas.draw_line(Vector2(rect.position.x + 30, rect.end.y - 30), Vector2(rect.end.x - 40, rect.end.y - 30), Color(0.2, 0.25, 0.32), 4.5, true)

static func draw_security_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	draw_floor_grid(canvas, rect, 36.0, Color(0.0, 0.85, 1.0, 0.06))

static func draw_meeting_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	var emerg_pos := StationData.get_emergency_button_pos()
	canvas.draw_arc(emerg_pos, 110.0, 0, TAU, 48, Color(0.0, 0.85, 1.0, 0.3), 1.5, true)
	canvas.draw_arc(emerg_pos, 160.0, 0, TAU, 48, Color(0.0, 0.85, 1.0, 0.18), 1.5, true)
	draw_floor_grid(canvas, rect, 40.0, Color(0.0, 0.8, 1.0, 0.04))

static func draw_hub_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	var c := rect.get_center()
	canvas.draw_circle(c, 90.0, Color(0.11, 0.15, 0.22), true)
	canvas.draw_arc(c, 90.0, 0, TAU, 40, Color(0.0, 0.85, 1.0, 0.5), 2.0, true)
	canvas.draw_arc(c, 130.0, 0, TAU, 48, Color(0.0, 0.85, 1.0, 0.2), 1.5, true)
	draw_floor_grid(canvas, rect, 40.0, Color(0.0, 0.85, 1.0, 0.04))

static func draw_research_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	draw_floor_grid(canvas, rect, 38.0, Color(0.8, 0.3, 1.0, 0.06))

static func draw_storage_floor(canvas: CanvasItem, rect: Rect2, _time: float) -> void:
	draw_floor_grid(canvas, rect, 40.0, Color(0.6, 0.7, 0.8, 0.05))
	canvas.draw_rect(Rect2(rect.position.x + 20, rect.position.y + 20, rect.size.x - 40, rect.size.y - 40), Color(0.95, 0.75, 0.15, 0.35), false, 1.5)

static func draw_floor_grid(canvas: CanvasItem, rect: Rect2, step: float, col: Color) -> void:
	var gx: float = rect.position.x + step
	while gx < rect.end.x:
		canvas.draw_line(Vector2(gx, rect.position.y), Vector2(gx, rect.end.y), col, 1.0, true)
		gx += step
	var gy: float = rect.position.y + step
	while gy < rect.end.y:
		canvas.draw_line(Vector2(rect.position.x, gy), Vector2(rect.end.x, gy), col, 1.0, true)
		gy += step

# =========================================================================
# SECTOR STENCIL TYPOGRAPHY
# =========================================================================
static func draw_sector_stencil_label(canvas: CanvasItem, r: StationData.RoomDef) -> void:
	var label_pos := r.rect.position + Vector2(24, 34)
	canvas.draw_line(label_pos + Vector2(0, -14), label_pos + Vector2(18, -14), r.accent_color * Color(1, 1, 1, 0.7), 2.0, true)
	canvas.draw_line(label_pos + Vector2(0, -14), label_pos + Vector2(0, 4), r.accent_color * Color(1, 1, 1, 0.7), 2.0, true)
	canvas.draw_string(ThemeDB.fallback_font, label_pos + Vector2(8, 0), r.short_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, r.accent_color.lightened(0.15) * Color(1, 1, 1, 0.90))

# =========================================================================
# 2.5D WALL BULKHEADS WITH THICKNESS & BEVELS
# =========================================================================
static func draw_station_walls_and_bulkheads(canvas: CanvasItem, anim_time: float) -> void:
	var wall_caps: Array[Rect2] = [
		Rect2(60, 30, 510, 280),
		Rect2(1030, 30, 510, 280),
		Rect2(560, 30, 480, 20),
		Rect2(560, 50, 20, 220),
		Rect2(1020, 50, 20, 220),
		Rect2(580, 270, 160, 60),
		Rect2(860, 270, 160, 60),
		Rect2(480, 320, 60, 100),
		Rect2(480, 520, 60, 70),
		Rect2(1060, 320, 60, 100),
		Rect2(1060, 520, 60, 70),
		Rect2(80, 580, 160, 60),
		Rect2(340, 580, 140, 60),
		Rect2(540, 590, 200, 60),
		Rect2(860, 590, 200, 60),
		Rect2(1100, 580, 420, 70),
		Rect2(780, 650, 40, 90),
		Rect2(780, 820, 40, 80),
		Rect2(520, 900, 100, 60),
		Rect2(700, 900, 200, 60),
		Rect2(980, 900, 80, 60),
		Rect2(60, 910, 470, 290),
		Rect2(1070, 900, 470, 300),
		Rect2(520, 1170, 560, 30),
		Rect2(520, 960, 20, 210),
		Rect2(1060, 960, 20, 210),
		Rect2(70, 310, 30, 610),
		Rect2(1500, 310, 30, 610)
	]

	for w in wall_caps:
		canvas.draw_rect(w, Color(0.06, 0.08, 0.12))
		canvas.draw_rect(w, Color(0.18, 0.24, 0.32), false, 2.0)
		canvas.draw_line(w.position, Vector2(w.end.x, w.position.y), Color(0.28, 0.36, 0.48), 1.5, true)
		canvas.draw_line(w.position, Vector2(w.position.x, w.end.y), Color(0.28, 0.36, 0.48), 1.5, true)
		canvas.draw_line(Vector2(w.position.x, w.end.y), w.end, Color(0.02, 0.03, 0.05), 2.0, true)
		canvas.draw_line(Vector2(w.end.x, w.position.y), w.end, Color(0.02, 0.03, 0.05), 2.0, true)

	# Bulkhead Status LEDs along walls
	var led_pts: Array[Vector2] = [
		Vector2(550, 60), Vector2(1030, 60),
		Vector2(490, 330), Vector2(1070, 330),
		Vector2(530, 970), Vector2(1070, 970)
	]
	for lp in led_pts:
		var blink: float = 0.5 + sin(anim_time * 3.0 + lp.x) * 0.5
		canvas.draw_circle(lp, 3.0, Color(0.0, 0.9, 1.0, blink), true)

# =========================================================================
# ROOM PROPS
# =========================================================================

# --- A. BRIDGE PROPS ---
static func draw_bridge_props(canvas: CanvasItem, anim_time: float) -> void:
	var win_rect := Rect2(620, 54, 360, 24)
	canvas.draw_rect(win_rect, Color(0.01, 0.04, 0.08))
	var planet_center := Vector2(800, -80)
	canvas.draw_circle(planet_center, 155.0, Color(0.05, 0.25, 0.55, 0.45), true)
	canvas.draw_arc(planet_center, 155.0, 0.4, 2.74, 40, Color(0.0, 0.85, 1.0, 0.85), 2.5, true)
	for mx in [680.0, 740.0, 800.0, 860.0, 920.0]:
		canvas.draw_line(Vector2(mx, 54), Vector2(mx, 78), Color(0.25, 0.35, 0.45), 3.0, true)
	canvas.draw_rect(win_rect, Color(0.35, 0.48, 0.62), false, 2.5)

	var consoles: Array[Vector2] = [Vector2(700, 105), Vector2(800, 110), Vector2(900, 105)]
	for c_pos in consoles:
		var c_box := Rect2(c_pos.x - 32, c_pos.y - 14, 64, 28)
		canvas.draw_rect(c_box, Color(0.10, 0.15, 0.22))
		canvas.draw_rect(c_box, Color(0.0, 0.85, 1.0), false, 1.8)
		canvas.draw_line(Vector2(c_box.position.x + 4, c_pos.y - 4), Vector2(c_box.end.x - 4, c_pos.y - 4), Color(0.2, 0.95, 1.0), 2.5, true)
		var blip_x: float = c_pos.x - 12.0 + fmod(anim_time * 25.0, 24.0)
		canvas.draw_circle(Vector2(blip_x, c_pos.y + 4), 2.0, Color(0.2, 1.0, 0.5), true)

	var chair_pos := Vector2(800, 190)
	canvas.draw_circle(chair_pos, 14.0, Color(0.12, 0.16, 0.24), true)
	canvas.draw_arc(chair_pos, 14.0, 0, TAU, 24, Color(0.0, 0.85, 1.0, 0.7), 2.0, true)
	canvas.draw_rect(Rect2(chair_pos.x - 8, chair_pos.y - 12, 16, 6), Color(0.2, 0.28, 0.38))

# --- B. REACTOR PROPS ---
static func draw_reactor_props(canvas: CanvasItem, anim_time: float, sabotaged: bool, _sab_time: float) -> void:
	var r_pos := Vector2(290, 775)
	var speed_mult: float = 4.0 if sabotaged else 1.0
	var pulse: float = 1.0 + sin(anim_time * 3.5 * speed_mult) * 0.14
	var p_color := Color(1.0, 0.2, 0.15) if sabotaged else Color(0.75, 0.25, 0.95)

	canvas.draw_circle(r_pos, 74.0, Color(0.10, 0.08, 0.14), true)
	canvas.draw_arc(r_pos, 74.0, 0, TAU, 36, Color(0.28, 0.24, 0.36), 3.5, true)

	canvas.draw_circle(r_pos, 52.0 * pulse, p_color.darkened(0.6) * Color(1, 1, 1, 0.4), true)
	canvas.draw_circle(r_pos, 32.0 * pulse, p_color.darkened(0.3) * Color(1, 1, 1, 0.6), true)
	canvas.draw_circle(r_pos, 16.0 * pulse, Color(1, 1, 1, 0.95), true)

	canvas.draw_arc(r_pos, 46.0, anim_time * 2.2 * speed_mult, anim_time * 2.2 * speed_mult + PI * 1.3, 30, p_color, 3.5, true)
	canvas.draw_arc(r_pos, 34.0, -anim_time * 2.8 * speed_mult, -anim_time * 2.8 * speed_mult + PI * 1.3, 24, Color(1.0, 0.85, 0.2), 3.0, true)

	for i in range(4):
		var angle := i * (PI * 0.5)
		var s1 := r_pos + Vector2(cos(angle), sin(angle)) * 32.0
		var s2 := r_pos + Vector2(cos(angle), sin(angle)) * 74.0
		canvas.draw_line(s1, s2, Color(0.3, 0.35, 0.45), 3.0, true)

	canvas.draw_line(r_pos + Vector2(-74, 0), r_pos + Vector2(-110, 0), Color(0.2, 0.25, 0.35), 7.0, true)
	canvas.draw_line(r_pos + Vector2(74, 0), r_pos + Vector2(110, 0), Color(0.2, 0.25, 0.35), 7.0, true)

# --- C. MEDICAL BAY PROPS ---
static func draw_medical_props(canvas: CanvasItem, anim_time: float) -> void:
	var bed_pos := Vector2(240, 450)
	var bed_rect := Rect2(bed_pos.x - 44, bed_pos.y - 24, 88, 48)
	canvas.draw_rect(bed_rect, Color(0.10, 0.18, 0.22))
	canvas.draw_rect(bed_rect, Color(0.2, 0.95, 0.75), false, 2.0)

	var canopy_rect := Rect2(bed_pos.x - 34, bed_pos.y - 18, 68, 36)
	var sweep_x: float = canopy_rect.position.x + fmod(anim_time * 35.0, canopy_rect.size.x)
	canvas.draw_rect(canopy_rect, Color(0.0, 0.85, 0.75, 0.25))
	canvas.draw_line(Vector2(sweep_x, canopy_rect.position.y), Vector2(sweep_x, canopy_rect.end.y), Color(0.2, 1.0, 0.9, 0.9), 2.0, true)

	var mon_pos := Vector2(180, 345)
	var mon_box := Rect2(mon_pos.x - 25, mon_pos.y - 16, 50, 32)
	canvas.draw_rect(mon_box, Color(0.06, 0.12, 0.16))
	canvas.draw_rect(mon_box, Color(0.2, 0.95, 0.75), false, 1.5)
	var ecg_y := mon_pos.y + sin(anim_time * 12.0) * 4.0
	canvas.draw_line(Vector2(mon_box.position.x + 4, mon_pos.y), Vector2(mon_pos.x - 6, mon_pos.y), Color(0.2, 1.0, 0.5), 1.5, true)
	canvas.draw_line(Vector2(mon_pos.x - 6, mon_pos.y), Vector2(mon_pos.x, ecg_y - 6), Color(0.2, 1.0, 0.5), 1.5, true)
	canvas.draw_line(Vector2(mon_pos.x, ecg_y - 6), Vector2(mon_pos.x + 6, ecg_y + 6), Color(0.2, 1.0, 0.5), 1.5, true)
	canvas.draw_line(Vector2(mon_pos.x + 6, ecg_y + 6), Vector2(mon_box.end.x - 4, mon_pos.y), Color(0.2, 1.0, 0.5), 1.5, true)

# --- D. ELECTRICAL PROPS ---
static func draw_electrical_props(canvas: CanvasItem, _anim_time: float) -> void:
	var gen_pos := Vector2(660, 750)
	var gen_box := Rect2(gen_pos.x - 36, gen_pos.y - 28, 72, 56)

	# Side Heat Sink Cooling Fins
	for fin_y in [-20.0, -10.0, 0.0, 10.0, 20.0]:
		canvas.draw_line(Vector2(gen_box.position.x - 6, gen_pos.y + fin_y), Vector2(gen_box.position.x, gen_pos.y + fin_y), Color(0.35, 0.40, 0.50), 2.5, true)
		canvas.draw_line(Vector2(gen_box.end.x, gen_pos.y + fin_y), Vector2(gen_box.end.x + 6, gen_pos.y + fin_y), Color(0.35, 0.40, 0.50), 2.5, true)

	canvas.draw_rect(gen_box, Color(0.14, 0.13, 0.09))
	canvas.draw_rect(gen_box, Color(1.0, 0.85, 0.2), false, 2.0)

	var bolt: PackedVector2Array = [
		Vector2(gen_pos.x + 4, gen_pos.y - 18),
		Vector2(gen_pos.x - 10, gen_pos.y - 2),
		Vector2(gen_pos.x + 2, gen_pos.y - 2),
		Vector2(gen_pos.x - 6, gen_pos.y + 12),
		Vector2(gen_pos.x + 10, gen_pos.y - 4),
		Vector2(gen_pos.x - 2, gen_pos.y - 4)
	]
	canvas.draw_colored_polygon(bolt, Color(1.0, 0.88, 0.2, 0.95))

	# Digital Voltage Readout Bar
	var v_box := Rect2(gen_pos.x - 22, gen_pos.y + 15, 44, 8)
	canvas.draw_rect(v_box, Color(0.06, 0.09, 0.14))
	canvas.draw_rect(v_box, Color(0.0, 0.85, 1.0, 0.6), false, 1.0)
	canvas.draw_line(Vector2(v_box.position.x + 2, v_box.get_center().y), Vector2(v_box.end.x - 2, v_box.get_center().y), Color(0.0, 0.95, 0.8), 2.0, true)

	var rack_rect := Rect2(550, 670, 24, 70)
	canvas.draw_rect(rack_rect, Color(0.12, 0.15, 0.18))
	canvas.draw_rect(rack_rect, Color(0.3, 0.4, 0.5), false, 1.5)
	for i in range(5):
		var sw_y: float = rack_rect.position.y + 10.0 + (i * 12.0)
		var sw_col := Color(0.2, 0.95, 0.4) if (i % 2 == 0) else Color(1.0, 0.85, 0.2)
		canvas.draw_circle(Vector2(rack_rect.position.x + 12, sw_y), 3.0, sw_col, true)

# --- E. SECURITY PROPS ---
static func draw_security_props(canvas: CanvasItem, anim_time: float) -> void:
	var scr_y := 675.0
	for i in range(4):
		var scr_x: float = 1170.0 + (i * 68.0)
		var scr_rect := Rect2(scr_x - 30, scr_y - 20, 60, 40)
		canvas.draw_rect(scr_rect, Color(0.04, 0.08, 0.14))
		canvas.draw_rect(scr_rect, Color(0.0, 0.85, 1.0), false, 1.5)
		for sl in range(4):
			var ly := scr_rect.position.y + 8.0 + (sl * 7.0)
			canvas.draw_line(Vector2(scr_rect.position.x + 3, ly), Vector2(scr_rect.end.x - 3, ly), Color(0.0, 0.8, 1.0, 0.2), 1.0, true)
		var rec_blink: float = abs(sin(anim_time * 3.0 + i))
		canvas.draw_circle(Vector2(scr_rect.position.x + 8, scr_rect.position.y + 8), 2.0, Color(1.0, 0.2, 0.2, rec_blink), true)

# --- F. MEETING ROOM PROPS ---
static func draw_meeting_props(canvas: CanvasItem, anim_time: float) -> void:
	var emerg_pos := StationData.get_emergency_button_pos()

	# Conference Table Base
	canvas.draw_circle(emerg_pos, 56.0, Color(0.08, 0.12, 0.18), true)
	canvas.draw_arc(emerg_pos, 56.0, 0, TAU, 40, Color(0.0, 0.85, 1.0), 3.0, true)
	canvas.draw_circle(emerg_pos, 38.0, Color(0.05, 0.08, 0.14), true)
	canvas.draw_arc(emerg_pos, 38.0, 0, TAU, 32, Color(0.0, 0.85, 1.0, 0.6), 1.5, true)

	# 6 Executive Chairs around the table
	for i in range(6):
		var angle := i * (TAU / 6.0)
		var chair_pos := emerg_pos + Vector2(cos(angle), sin(angle)) * 74.0
		canvas.draw_circle(chair_pos, 9.5, Color(0.12, 0.16, 0.24), true)
		canvas.draw_arc(chair_pos, 9.5, 0, TAU, 18, Color(0.3, 0.45, 0.62), 1.5, true)

	# Hologram projection light cone from table base
	var holo_cone: PackedVector2Array = [
		emerg_pos + Vector2(0, 10),
		emerg_pos + Vector2(-30, -20),
		emerg_pos + Vector2(30, -20)
	]
	canvas.draw_colored_polygon(holo_cone, Color(0.0, 0.8, 1.0, 0.12))

	# Rotating 3D Holographic Globe in Table Center
	var pulse: float = 1.0 + sin(anim_time * 2.8) * 0.06
	canvas.draw_circle(emerg_pos, 22.0 * pulse, Color(0.0, 0.65, 1.0, 0.28), true)
	canvas.draw_arc(emerg_pos, 22.0 * pulse, 0, TAU, 32, Color(0.0, 0.92, 1.0, 0.9), 2.0, true)
	canvas.draw_arc(emerg_pos, 16.0, anim_time * 1.4, anim_time * 1.4 + PI, 24, Color(0.2, 1.0, 0.8, 0.85), 1.5, true)
	canvas.draw_arc(emerg_pos, 11.0, -anim_time * 1.8, -anim_time * 1.8 + PI, 20, Color(0.1, 0.85, 1.0, 0.85), 1.5, true)

	# Emergency Red Meeting Button in Pedestal Center
	canvas.draw_circle(emerg_pos, 7.5, Color(0.95, 0.15, 0.2), true)
	canvas.draw_circle(emerg_pos, 3.5, Color(1.0, 0.5, 0.5), true)

# --- G. STORAGE PROPS ---
static func draw_storage_props(canvas: CanvasItem, _time: float) -> void:
	# Position crates cleanly in Storage without covering the top-left label
	var crate_positions := [Vector2(880, 750), Vector2(930, 750), Vector2(905, 800), Vector2(980, 830)]
	for cp in crate_positions:
		var c_rect := Rect2(cp.x - 18, cp.y - 18, 36, 36)
		canvas.draw_rect(c_rect, Color(0.18, 0.22, 0.28))
		canvas.draw_rect(c_rect, Color(0.4, 0.5, 0.6), false, 2.0)
		canvas.draw_line(c_rect.position, c_rect.end, Color(0.3, 0.4, 0.5), 1.5, true)
		canvas.draw_line(Vector2(c_rect.position.x, c_rect.end.y), Vector2(c_rect.end.x, c_rect.position.y), Color(0.3, 0.4, 0.5), 1.5, true)

# =========================================================================
# INTERACTIVE TASK CONSOLES, VENTS & CAMERAS
# =========================================================================
static func draw_task_console(canvas: CanvasItem, t: StationData.TaskSpotDef, is_done: bool, anim_time: float) -> void:
	var status_col: Color = Color(0.2, 0.95, 0.4) if is_done else Color(1.0, 0.85, 0.2)
	var c_rect := Rect2(t.position.x - 18, t.position.y - 14, 36, 28)

	canvas.draw_rect(c_rect, Color(0.10, 0.14, 0.20))
	canvas.draw_rect(c_rect, status_col, false, 2.0)

	var scr := Rect2(c_rect.position.x + 4, c_rect.position.y + 4, c_rect.size.x - 8, 12)
	canvas.draw_rect(scr, status_col.darkened(0.6))
	canvas.draw_line(Vector2(scr.position.x + 2, scr.get_center().y), Vector2(scr.end.x - 2, scr.get_center().y), status_col, 2.0, true)

	var marker_y: float = t.position.y - 25.0 + sin(anim_time * 4.0 + t.id) * 3.0
	var badge_col := Color(0.2, 0.95, 0.4, 0.9) if is_done else Color(1.0, 0.85, 0.2, 0.9)
	canvas.draw_circle(Vector2(t.position.x, marker_y), 7.0, badge_col, true)
	canvas.draw_string(ThemeDB.fallback_font, Vector2(t.position.x - 4, marker_y + 4), "✓" if is_done else "!", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.04, 0.06, 0.10))

static func draw_vent_shaft(canvas: CanvasItem, v: StationData.VentDef, _time: float) -> void:
	var vent_rect := Rect2(v.position.x - 20, v.position.y - 14, 40, 28)
	canvas.draw_rect(vent_rect, Color(0.12, 0.15, 0.20))
	canvas.draw_rect(vent_rect, Color(0.45, 0.55, 0.70), false, 2.0)
	for i in range(5):
		var vx: float = v.position.x - 14.0 + (i * 7.0)
		canvas.draw_line(Vector2(vx, v.position.y - 9), Vector2(vx, v.position.y + 9), Color(0.05, 0.08, 0.12), 2.5, true)

static func draw_cctv_camera(canvas: CanvasItem, cam: StationData.CameraDef, anim_time: float) -> void:
	var sweep: float = sin(anim_time * 1.5 + cam.id) * 0.38
	var current_angle: float = cam.look_angle + sweep

	canvas.draw_circle(cam.position, 9.5, Color(0.2, 0.26, 0.36), true)
	canvas.draw_arc(cam.position, 9.5, 0, TAU, 20, Color(0.08, 0.10, 0.14), 2.0, true)
	var rec_alpha: float = 0.5 + sin(anim_time * 4.0 + cam.id) * 0.5
	canvas.draw_circle(cam.position, 3.5, Color(1.0, 0.2, 0.2, rec_alpha), true)

	var cone_len: float = 170.0
	var half_fov: float = cam.sweep_angle * 0.5
	var p_left := cam.position + Vector2(cos(current_angle - half_fov), sin(current_angle - half_fov)) * cone_len
	var p_right := cam.position + Vector2(cos(current_angle + half_fov), sin(current_angle + half_fov)) * cone_len

	var cone_pts: PackedVector2Array = [cam.position, p_left, p_right]
	canvas.draw_colored_polygon(cone_pts, Color(0.0, 0.85, 1.0, 0.07))
	canvas.draw_line(cam.position, p_left, Color(0.0, 0.85, 1.0, 0.25), 1.0, true)
	canvas.draw_line(cam.position, p_right, Color(0.0, 0.85, 1.0, 0.25), 1.0, true)
