class_name CrewmateRenderer
extends RefCounted

const GameEnums = preload("res://scripts/core/GameEnums.gd")

## High-Quality Stylized Sci-Fi Astronaut & Crewmate Renderer for VOIDSHIFT.
## Faithfully implements the Character Design Reference & Turnaround Sheet:
## - Full anti-aliasing across all arcs, polygons, and circles for smooth vector curves
## - Distinctive spherical helmets with deep reflective visors & curved horizon specular flares
## - Segmented armored EVA pressure suits with utility belts, shoulder pauldrons & chest vitals
## - Life-support backpacks with dual oxygen cylinders & pressure regulator valves
## - Heavy magnetic boots with tread soles & smooth walking kinematics
## - Soft forward vision flashlight with atmospheric gradient falloff
## - Distinct color palettes for all 7 crew roles (Rex, Vance, Nova, Astra, Kael, Lyra, Saboteur)

static func get_role_color(role: GameEnums.Role) -> Color:
	match role:
		GameEnums.Role.CREW_DEFAULT:
			return Color(0.90, 0.94, 0.98, 1.0) # Pearl White
		GameEnums.Role.SECURITY_DETECTIVE:
			return Color(0.22, 0.25, 0.30, 1.0) # Tactical Gunmetal Charcoal
		GameEnums.Role.ENGINEER_FIXER:
			return Color(0.98, 0.74, 0.14, 1.0) # Industrial Hazard Amber
		GameEnums.Role.SCIENTIST_ANALYST:
			return Color(0.64, 0.26, 0.88, 1.0) # Deep Xenology Violet
		GameEnums.Role.MEDIC_HEALER:
			return Color(0.94, 0.96, 0.98, 1.0) # Clinical White
		GameEnums.Role.COMMUNICATIONS_OPERATOR:
			return Color(0.98, 0.48, 0.12, 1.0) # High-Vis Solar Orange
		GameEnums.Role.SABOTEUR_IMPOSTOR:
			return Color(0.11, 0.13, 0.16, 1.0) # Void Obsidian
		_:
			return Color(0.90, 0.94, 0.98, 1.0)

static func get_role_accent(role: GameEnums.Role) -> Color:
	match role:
		GameEnums.Role.CREW_DEFAULT:
			return Color(0.0, 0.88, 1.0, 1.0) # Electric Cyan
		GameEnums.Role.SECURITY_DETECTIVE:
			return Color(1.0, 0.22, 0.25, 1.0) # Security Crimson
		GameEnums.Role.ENGINEER_FIXER:
			return Color(1.0, 0.88, 0.22, 1.0) # Hazard Yellow
		GameEnums.Role.SCIENTIST_ANALYST:
			return Color(0.90, 0.45, 1.0, 1.0) # Neon Magenta
		GameEnums.Role.MEDIC_HEALER:
			return Color(0.0, 0.92, 0.55, 1.0) # Bio-Emerald
		GameEnums.Role.COMMUNICATIONS_OPERATOR:
			return Color(1.0, 0.78, 0.20, 1.0) # Solar Gold
		GameEnums.Role.SABOTEUR_IMPOSTOR:
			return Color(1.0, 0.12, 0.22, 1.0) # Void Crimson
		_:
			return Color(0.0, 0.88, 1.0, 1.0)

static func draw_astronaut(canvas: CanvasItem, pos: Vector2, role: GameEnums.Role, is_dead: bool,
						  walk_time: float, is_facing_left: bool, is_local_player: bool = false,
						  custom_color: Color = Color.WHITE) -> void:
	var base_color: Color = custom_color if custom_color != Color.WHITE else get_role_color(role)
	var accent_color: Color = get_role_accent(role)
	var flip: float = -1.0 if is_facing_left else 1.0

	if is_dead:
		if is_local_player:
			draw_ghost_astronaut(canvas, pos, base_color, accent_color, walk_time, flip)
			return
		draw_dead_body(canvas, pos, base_color, accent_color, flip)
		return

	# Kinematics
	var is_moving: bool = (walk_time > 0.0)
	var leg_cycle: float = sin(walk_time * 11.0) if is_moving else 0.0
	var bob_y: float = abs(sin(walk_time * 11.0)) * 2.5 if is_moving else 0.0
	var center := pos - Vector2(0, bob_y)

	# -------------------------------------------------------------------------
	# 1. Soft Forward Vision Flashlight
	# -------------------------------------------------------------------------
	var facing_dir := Vector2(-1.0 if is_facing_left else 1.0, 0.20).normalized()
	var beam_origin := center + Vector2(6.0 * flip, -10.0)
	var beam_angle := facing_dir.angle()
	var beam_dist: float = 150.0
	var fov_half: float = 0.38

	# Outer soft ambient cone (antialiased)
	var p_cone_l := beam_origin + Vector2(cos(beam_angle - fov_half), sin(beam_angle - fov_half)) * beam_dist
	var p_cone_r := beam_origin + Vector2(cos(beam_angle + fov_half), sin(beam_angle + fov_half)) * beam_dist
	var outer_cone: PackedVector2Array = [beam_origin, p_cone_l, p_cone_r]
	var cone_alpha: float = 0.12 if is_local_player else 0.05
	canvas.draw_colored_polygon(outer_cone, Color(0.10, 0.85, 1.0, cone_alpha))

	# Inner focused beam core
	var p_core_l := beam_origin + Vector2(cos(beam_angle - fov_half * 0.45), sin(beam_angle - fov_half * 0.45)) * (beam_dist * 0.88)
	var p_core_r := beam_origin + Vector2(cos(beam_angle + fov_half * 0.45), sin(beam_angle + fov_half * 0.45)) * (beam_dist * 0.88)
	var core_cone: PackedVector2Array = [beam_origin, p_core_l, p_core_r]
	var core_alpha: float = 0.20 if is_local_player else 0.08
	canvas.draw_colored_polygon(core_cone, Color(0.35, 0.95, 1.0, core_alpha))

	# Flashlight emitter lens glow
	canvas.draw_circle(beam_origin, 4.0, Color(0.4, 0.95, 1.0, 0.6), true)
	canvas.draw_circle(beam_origin, 2.0, Color(1, 1, 1, 0.95), true)

	# -------------------------------------------------------------------------
	# 2. Smooth Ground Drop Shadow
	# -------------------------------------------------------------------------
	canvas.draw_circle(pos + Vector2(0, 16), 20.0, Color(0.01, 0.02, 0.04, 0.25), true)
	canvas.draw_circle(pos + Vector2(0, 16), 14.0, Color(0.01, 0.02, 0.04, 0.35), true)

	# -------------------------------------------------------------------------
	# 3. Life-Support Backpack (behind suit)
	# -------------------------------------------------------------------------
	var pack_x := center.x - (16.0 * flip)
	var pack_y := center.y - 12.0
	var pack_rect := Rect2(pack_x - 6.0, pack_y, 12.0, 24.0)

	canvas.draw_rect(pack_rect, base_color.darkened(0.42))
	canvas.draw_rect(pack_rect, Color(0.06, 0.08, 0.12), false, 2.0)

	# Dual oxygen tanks
	var t1_x := pack_x - (2.5 * flip)
	var t2_x := pack_x + (2.5 * flip)
	canvas.draw_line(Vector2(t1_x, pack_y + 3), Vector2(t1_x, pack_y + 19), Color(0.72, 0.78, 0.86), 3.0, true)
	canvas.draw_line(Vector2(t2_x, pack_y + 3), Vector2(t2_x, pack_y + 19), Color(0.72, 0.78, 0.86), 3.0, true)
	canvas.draw_circle(Vector2(t1_x, pack_y + 1), 2.5, Color(0.9, 0.92, 0.96), true)
	canvas.draw_circle(Vector2(t2_x, pack_y + 1), 2.5, Color(0.9, 0.92, 0.96), true)

	# Status LED
	var led_col := accent_color if role != GameEnums.Role.SABOTEUR_IMPOSTOR else Color(1.0, 0.15, 0.2)
	canvas.draw_circle(Vector2(pack_x, pack_y + 21), 2.2, led_col, true)

	# -------------------------------------------------------------------------
	# 4. Legs & Armored Magnetic Boots
	# -------------------------------------------------------------------------
	var leg_l_y := center.y + 11.0 + (leg_cycle * 5.0)
	var leg_r_y := center.y + 11.0 - (leg_cycle * 5.0)

	var boot_l_rect := Rect2(center.x - 11.0, leg_l_y, 9.5, 12.0)
	var boot_r_rect := Rect2(center.x + 1.5, leg_r_y, 9.5, 12.0)

	# Dark under-suit knee flexors
	canvas.draw_rect(Rect2(center.x - 10.0, center.y + 7.0, 7.5, 6.0), Color(0.10, 0.12, 0.16))
	canvas.draw_rect(Rect2(center.x + 2.5, center.y + 7.0, 7.5, 6.0), Color(0.10, 0.12, 0.16))

	# Heavy boots
	canvas.draw_rect(boot_l_rect, base_color.darkened(0.2))
	canvas.draw_rect(boot_r_rect, base_color.darkened(0.2))
	canvas.draw_rect(boot_l_rect, Color(0.06, 0.08, 0.12), false, 1.8)
	canvas.draw_rect(boot_r_rect, Color(0.06, 0.08, 0.12), false, 1.8)

	# Magnetic tread sole rim
	canvas.draw_line(Vector2(boot_l_rect.position.x, boot_l_rect.end.y), Vector2(boot_l_rect.end.x, boot_l_rect.end.y), Color(0.06, 0.08, 0.12), 3.0, true)
	canvas.draw_line(Vector2(boot_r_rect.position.x, boot_r_rect.end.y), Vector2(boot_r_rect.end.x, boot_r_rect.end.y), Color(0.06, 0.08, 0.12), 3.0, true)

	# Toe cap accent
	canvas.draw_line(Vector2(boot_l_rect.position.x + 1, boot_l_rect.end.y - 3), Vector2(boot_l_rect.end.x - 1, boot_l_rect.end.y - 3), accent_color, 1.5, true)
	canvas.draw_line(Vector2(boot_r_rect.position.x + 1, boot_r_rect.end.y - 3), Vector2(boot_r_rect.end.x - 1, boot_r_rect.end.y - 3), accent_color, 1.5, true)

	# -------------------------------------------------------------------------
	# 5. Armored Torso & Segmented EVA Suit
	# -------------------------------------------------------------------------
	var torso_rect := Rect2(center.x - 14.0, center.y - 10.0, 28.0, 23.0)
	canvas.draw_rect(torso_rect, base_color)
	canvas.draw_rect(torso_rect, Color(0.06, 0.08, 0.12), false, 2.2)

	# Shoulder Pauldron
	var pauldron_x := center.x - (16.0 if is_facing_left else -6.0)
	var pauldron_rect := Rect2(pauldron_x, center.y - 11.0, 10.0, 11.0)
	canvas.draw_rect(pauldron_rect, base_color.lightened(0.12))
	canvas.draw_rect(pauldron_rect, Color(0.06, 0.08, 0.12), false, 1.5)
	canvas.draw_line(Vector2(pauldron_rect.position.x + 2, pauldron_rect.position.y + 2),
					 Vector2(pauldron_rect.end.x - 2, pauldron_rect.position.y + 2), accent_color, 2.0, true)

	# Utility Belt
	var belt_y := center.y + 9.0
	canvas.draw_line(Vector2(torso_rect.position.x, belt_y), Vector2(torso_rect.end.x, belt_y), Color(0.10, 0.12, 0.16), 4.0, true)
	canvas.draw_rect(Rect2(center.x - 4.0, belt_y - 3.0, 8.0, 6.0), Color(0.42, 0.48, 0.56))
	canvas.draw_rect(Rect2(center.x - 4.0, belt_y - 3.0, 8.0, 6.0), Color(0.06, 0.08, 0.12), false, 1.0)

	# Chest Module & Vitals Readout
	var chest_x := center.x - 6.0 + (3.0 * flip)
	var chest_box := Rect2(chest_x, center.y - 5.0, 12.0, 11.0)
	canvas.draw_rect(chest_box, Color(0.06, 0.10, 0.16))
	canvas.draw_rect(chest_box, accent_color, false, 1.4)

	# ECG Vitals pulse line
	var ecg_y := chest_box.position.y + 4.5
	canvas.draw_line(Vector2(chest_box.position.x + 2, ecg_y), Vector2(chest_box.position.x + 5, ecg_y), Color(0.0, 0.95, 0.8), 1.5, true)
	canvas.draw_line(Vector2(chest_box.position.x + 5, ecg_y), Vector2(chest_box.position.x + 7, ecg_y - 2.5), Color(0.0, 0.95, 0.8), 1.5, true)
	canvas.draw_line(Vector2(chest_box.position.x + 7, ecg_y - 2.5), Vector2(chest_box.position.x + 8.5, ecg_y + 2.0), Color(0.0, 0.95, 0.8), 1.5, true)
	canvas.draw_line(Vector2(chest_box.position.x + 8.5, ecg_y + 2.0), Vector2(chest_box.end.x - 2, ecg_y), Color(0.0, 0.95, 0.8), 1.5, true)

	# Medic Red Cross insignia
	if role == GameEnums.Role.MEDIC_HEALER:
		var mc_x := center.x - (8.0 * flip)
		var mc_y := center.y - 1.0
		canvas.draw_rect(Rect2(mc_x - 3, mc_y - 1, 6, 2), Color(0.95, 0.2, 0.2))
		canvas.draw_rect(Rect2(mc_x - 1, mc_y - 3, 2, 6), Color(0.95, 0.2, 0.2))

	# -------------------------------------------------------------------------
	# 6. Spherical Helmet & High-Gloss Reflective Dome Visor
	# -------------------------------------------------------------------------
	var head_center := center + Vector2(2.5 * flip, -16.0)

	# Neck rebreather seal ring
	canvas.draw_circle(head_center + Vector2(0, 11), 10.0, Color(0.14, 0.17, 0.22), true)

	# Outer Helmet Shell (Antialiased)
	canvas.draw_circle(head_center, 16.5, base_color, true)
	canvas.draw_arc(head_center, 16.5, 0, TAU, 36, Color(0.06, 0.08, 0.12), 2.2, true)

	# Helmet Side Communications Earpiece
	var ear_x := head_center.x - (16.0 * flip)
	canvas.draw_circle(Vector2(ear_x, head_center.y), 3.5, Color(0.15, 0.19, 0.25), true)
	canvas.draw_circle(Vector2(ear_x, head_center.y), 1.5, accent_color, true)

	# Reflective Glass Visor Dome
	var visor_center := head_center + Vector2(6.5 * flip, 1.0)
	canvas.draw_circle(visor_center, 10.5, Color(0.03, 0.06, 0.14, 0.98), true)
	canvas.draw_arc(visor_center, 10.5, 0, TAU, 32, accent_color, 1.6, true)

	# Curved Specular Horizon Reflection Arc (Antialiased)
	var arc_start := -PI * 0.75 if flip > 0 else -PI * 0.25
	var arc_end := -PI * 0.25 if flip > 0 else PI * 0.25
	canvas.draw_arc(visor_center, 8.0, arc_start, arc_end, 20, Color(1, 1, 1, 0.95), 2.0, true)
	canvas.draw_line(visor_center + Vector2(-3.0 * flip, -4.0), visor_center + Vector2(4.0 * flip, -4.0), Color(1, 1, 1, 0.85), 2.0, true)
	# Emissive cybernetic HUD scanline
	canvas.draw_line(visor_center + Vector2(-5.0 * flip, 0.0), visor_center + Vector2(5.0 * flip, 0.0), accent_color * Color(1, 1, 1, 0.65), 1.5, true)

	# -------------------------------------------------------------------------
	# 7. Local Player Rex Floating Diamond Marker
	# -------------------------------------------------------------------------
	if is_local_player:
		var marker_y: float = center.y - 36.0 + sin(walk_time * 5.0) * 2.5
		var pts: PackedVector2Array = [
			Vector2(center.x, marker_y - 6.0),
			Vector2(center.x + 5.5, marker_y),
			Vector2(center.x, marker_y + 6.0),
			Vector2(center.x - 5.5, marker_y)
		]
		canvas.draw_colored_polygon(pts, Color(0.0, 0.95, 1.0, 0.95))
		canvas.draw_line(pts[0], pts[1], Color(1, 1, 1, 0.9), 1.5, true)
		canvas.draw_line(pts[1], pts[2], Color(1, 1, 1, 0.9), 1.5, true)

static func draw_dead_body(canvas: CanvasItem, pos: Vector2, color: Color, accent: Color, flip: float) -> void:
	# Fluid / bio-leak pool on floor
	canvas.draw_circle(pos + Vector2(0, 4), 22.0, Color(0.65, 0.05, 0.12, 0.65), true)
	canvas.draw_circle(pos + Vector2(6.0 * flip, 8.0), 14.0, Color(0.5, 0.02, 0.08, 0.5), true)

	# Lower suit / severed waist
	var lower_half := Rect2(pos.x - 14.0, pos.y - 5.0, 28.0, 18.0)
	canvas.draw_rect(lower_half, color)
	canvas.draw_rect(lower_half, Color(0.06, 0.08, 0.12), false, 2.5)

	# Severed structural spine conduit / bone
	canvas.draw_circle(pos + Vector2(0, -5), 5.5, Color(0.88, 0.90, 0.95), true)
	canvas.draw_line(pos + Vector2(0, -5), pos + Vector2(0, -14), Color(0.95, 0.95, 1.0), 3.5, true)

	# Sparking severed wire conduits
	canvas.draw_line(pos + Vector2(-6, -3), pos + Vector2(-11, -8), accent, 1.8, true)
	canvas.draw_line(pos + Vector2(6, -3), pos + Vector2(10, -9), Color(0.95, 0.8, 0.1), 1.8, true)

static func draw_ghost_astronaut(canvas: CanvasItem, pos: Vector2, color: Color, accent: Color, walk_time: float, flip: float) -> void:
	var float_bob := sin(walk_time * 6.0) * 3.5
	var center := pos + Vector2(0, float_bob)

	# Ethereal aura
	canvas.draw_circle(center, 22.0, Color(0.0, 0.85, 1.0, 0.15), true)

	# Floating Ghost Bodysuit / Trailing wisps
	var ghost_pts: PackedVector2Array = [
		center + Vector2(-12.0 * flip, -8.0),
		center + Vector2(12.0 * flip, -8.0),
		center + Vector2(10.0 * flip, 14.0),
		center + Vector2(4.0 * flip, 10.0),
		center + Vector2(0.0, 16.0),
		center + Vector2(-6.0 * flip, 10.0),
		center + Vector2(-12.0 * flip, 14.0)
	]
	canvas.draw_colored_polygon(ghost_pts, Color(0.05, 0.85, 1.0, 0.45))
	canvas.draw_polyline(ghost_pts, Color(0.4, 0.95, 1.0, 0.8), 1.5, true)

	# Ghost Helmet Shell
	var head_center := center + Vector2(0, -18)
	canvas.draw_circle(head_center, 13.0, Color(0.08, 0.88, 1.0, 0.5), true)
	canvas.draw_arc(head_center, 13.0, 0, TAU, 24, Color(0.5, 0.95, 1.0, 0.85), 1.5, true)

	# Ghost Reflective Visor
	var visor_pt := head_center + Vector2(4.0 * flip, 1.0)
	canvas.draw_circle(visor_pt, 7.5, Color(0.02, 0.2, 0.35, 0.7), true)
	canvas.draw_arc(visor_pt, 7.5, 0, TAU, 18, Color(0.0, 0.95, 1.0, 0.9), 1.2, true)

static func draw_crewmate_portrait(canvas: CanvasItem, pos: Vector2, role: GameEnums.Role, scale_fac: float = 1.0) -> void:
	var role_color := get_role_color(role)
	var accent_color := get_role_accent(role)

	# Suit Shoulders & Collar
	var shoulder_pts: PackedVector2Array = [
		pos + Vector2(-26 * scale_fac, 26 * scale_fac),
		pos + Vector2(-16 * scale_fac, 12 * scale_fac),
		pos + Vector2(16 * scale_fac, 12 * scale_fac),
		pos + Vector2(26 * scale_fac, 26 * scale_fac)
	]
	canvas.draw_colored_polygon(shoulder_pts, role_color)
	canvas.draw_line(shoulder_pts[1], shoulder_pts[2], accent_color, 2.0 * scale_fac, true)

	# Neck Seal
	canvas.draw_circle(pos + Vector2(0, 10 * scale_fac), 12.0 * scale_fac, Color(0.12, 0.15, 0.20), true)

	# Outer Helmet Shell
	var head_center := pos + Vector2(0, -4 * scale_fac)
	canvas.draw_circle(head_center, 18.0 * scale_fac, Color(0.90, 0.94, 0.98), true)
	canvas.draw_arc(head_center, 18.0 * scale_fac, 0, TAU, 36, Color(0.06, 0.08, 0.12), 2.0 * scale_fac, true)

	# Communications Earpieces
	var ear_x: float = 17.0 * scale_fac
	canvas.draw_circle(Vector2(head_center.x - ear_x, head_center.y), 3.5 * scale_fac, Color(0.16, 0.20, 0.26), true)
	canvas.draw_circle(Vector2(head_center.x - ear_x, head_center.y), 1.5 * scale_fac, accent_color, true)
	canvas.draw_circle(Vector2(head_center.x + ear_x, head_center.y), 3.5 * scale_fac, Color(0.16, 0.20, 0.26), true)
	canvas.draw_circle(Vector2(head_center.x + ear_x, head_center.y), 1.5 * scale_fac, accent_color, true)

	# High-Gloss Reflective Dome Visor
	var visor_pt := head_center + Vector2(0, 1.0 * scale_fac)
	canvas.draw_circle(visor_pt, 12.0 * scale_fac, Color(0.03, 0.06, 0.14), true)
	canvas.draw_arc(visor_pt, 12.0 * scale_fac, 0, TAU, 32, accent_color, 1.6 * scale_fac, true)

	# Specular Horizon Highlight Arc & Scanline
	canvas.draw_arc(visor_pt, 9.5 * scale_fac, -PI * 0.75, -PI * 0.25, 20, Color(1, 1, 1, 0.95), 2.0 * scale_fac, true)
	canvas.draw_line(visor_pt + Vector2(-6 * scale_fac, -4 * scale_fac), visor_pt + Vector2(6 * scale_fac, -4 * scale_fac), Color(1, 1, 1, 0.85), 1.8 * scale_fac, true)
	canvas.draw_line(visor_pt + Vector2(-7 * scale_fac, 1 * scale_fac), visor_pt + Vector2(7 * scale_fac, 1 * scale_fac), accent_color * Color(1, 1, 1, 0.6), 1.4 * scale_fac, true)

