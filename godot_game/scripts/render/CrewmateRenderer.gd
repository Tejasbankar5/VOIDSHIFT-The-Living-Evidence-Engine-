class_name CrewmateRenderer
extends RefCounted

const GameEnums = preload("res://scripts/core/GameEnums.gd")

## Master 2D Illustrated Character Renderer for VOIDSHIFT: The Living Evidence Engine.
## Replaces generic spacesuits with handcrafted, original anime/illustrated silhouettes:
## - Distinctive Japanese historical clothing (kimono, haori, hakama, obi, zori) for The Hollow Crown
## - Sleek tech-noir uniforms (lab coats, tactical vests, flight suits, engineer gear) for Blackglass Station
## - Handcrafted hairstyles, skin tones, accessories (katanas, datapads, scrolls, harnesses)
## - Realistic walking kinematics (leg strides, arm counter-swings, torso bob, drop shadows)
## - Overhead identity tags: "Rex (You) ▼" for the player, "● Name" for NPCs

static func get_role_color(role: GameEnums.Role) -> Color:
	match role:
		GameEnums.Role.CREW_DEFAULT:
			return Color(0.92, 0.94, 0.96) # Pearl Ivory
		GameEnums.Role.SECURITY_DETECTIVE:
			return Color(0.22, 0.28, 0.38) # Deep Tactical Blue
		GameEnums.Role.ENGINEER_FIXER:
			return Color(0.95, 0.72, 0.18) # Amber Hazard
		GameEnums.Role.SCIENTIST_ANALYST:
			return Color(0.25, 0.65, 0.85) # Laboratory Cyan
		GameEnums.Role.MEDIC_HEALER:
			return Color(0.85, 0.25, 0.35) # Miko Crimson
		GameEnums.Role.COMMUNICATIONS_OPERATOR:
			return Color(0.35, 0.75, 0.55) # Sage Green
		GameEnums.Role.SABOTEUR_IMPOSTOR, GameEnums.Role.INFILTRATOR, GameEnums.Role.DISRUPTOR:
			return Color(0.18, 0.16, 0.22) # Charcoal Shadow
		_:
			return Color(0.90, 0.92, 0.95)

static func get_role_accent(role: GameEnums.Role) -> Color:
	match role:
		GameEnums.Role.CREW_DEFAULT:
			return Color(0.0, 0.88, 1.0)
		GameEnums.Role.SECURITY_DETECTIVE:
			return Color(1.0, 0.35, 0.25)
		GameEnums.Role.ENGINEER_FIXER:
			return Color(1.0, 0.85, 0.2)
		GameEnums.Role.SCIENTIST_ANALYST:
			return Color(0.0, 0.95, 0.85)
		GameEnums.Role.MEDIC_HEALER:
			return Color(1.0, 0.3, 0.4)
		GameEnums.Role.COMMUNICATIONS_OPERATOR:
			return Color(0.4, 0.95, 0.6)
		GameEnums.Role.SABOTEUR_IMPOSTOR, GameEnums.Role.INFILTRATOR, GameEnums.Role.DISRUPTOR:
			return Color(0.95, 0.2, 0.3)
		_:
			return Color(0.0, 0.88, 1.0)

# Backward-compatible entry point
static func draw_astronaut(canvas: CanvasItem, pos: Vector2, role: GameEnums.Role, is_dead: bool,
						  walk_time: float, is_facing_left: bool, is_local_player: bool = false,
						  custom_color: Color = Color.WHITE) -> void:
	var name_tag: String = "Rex (You)" if is_local_player else "Crewmate"
	draw_character(canvas, pos, name_tag, role, is_dead, walk_time, is_facing_left, is_local_player)

## Master character drawing entry point with distinct silhouette styling
static func draw_character(canvas: CanvasItem, pos: Vector2, char_name: String, role: GameEnums.Role,
						  is_dead: bool, walk_time: float, is_facing_left: bool,
						  is_local_player: bool = false, campaign_mode: int = 0) -> void:
	var flip: float = -1.0 if is_facing_left else 1.0
	var clean_name: String = char_name.to_lower()

	# Dead body representation
	if is_dead:
		draw_fallen_investigator(canvas, pos, clean_name, flip)
		return

	# Kinematics
	var is_moving: bool = (walk_time > 0.0)
	var stride: float = sin(walk_time * 10.0) if is_moving else 0.0
	var bob_y: float = abs(sin(walk_time * 10.0)) * 2.2 if is_moving else 0.0
	var center := pos - Vector2(0, bob_y)

	# 1. Soft Ground Drop Shadow
	canvas.draw_circle(pos + Vector2(0, 16), 14.0, Color(0.02, 0.03, 0.05, 0.38), true)
	canvas.draw_circle(pos + Vector2(0, 16), 9.0, Color(0.02, 0.03, 0.05, 0.25), true)

	# 2. Render Specific Character Silhouettes
	if clean_name.contains("aiko"):
		draw_aiko_miko(canvas, center, stride, flip)
	elif clean_name.contains("kenji"):
		draw_kenji_scholar(canvas, center, stride, flip)
	elif clean_name.contains("sora"):
		draw_sora_attendant(canvas, center, stride, flip)
	elif clean_name.contains("haru"):
		draw_haru_guardian(canvas, center, stride, flip)
	elif clean_name.contains("elara"):
		draw_elara_scientist(canvas, center, stride, flip)
	elif clean_name.contains("kael"):
		draw_kael_security(canvas, center, stride, flip)
	elif clean_name.contains("vance"):
		draw_vance_pilot(canvas, center, stride, flip)
	elif clean_name.contains("lyra"):
		draw_lyra_engineer(canvas, center, stride, flip)
	else:
		# Rex (You) or Generic Character
		if campaign_mode == 0 or clean_name.contains("rex"):
			draw_rex_investigator(canvas, center, stride, flip)
		else:
			draw_scifi_officer(canvas, center, stride, flip, role)

	# 3. Overhead Name & Indicator Badge
	draw_overhead_badge(canvas, center, char_name, is_local_player)

# =========================================================================
# CHARACTER SILHOUETTES: THE HOLLOW CROWN (Japanese Mountain Estate)
# =========================================================================

## Rex — Chief Investigator / Traveler
static func draw_rex_investigator(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Legs / Trousers & Boots
	var leg_l := center + Vector2(-4.5, 9.0 + stride * 4.0)
	var leg_r := center + Vector2(4.5, 9.0 - stride * 4.0)
	canvas.draw_line(center + Vector2(-3, 6), leg_l, Color(0.12, 0.14, 0.18), 4.5, true)
	canvas.draw_line(center + Vector2(3, 6), leg_r, Color(0.12, 0.14, 0.18), 4.5, true)
	canvas.draw_circle(leg_l + Vector2(0, 5), 3.0, Color(0.22, 0.18, 0.15), true)
	canvas.draw_circle(leg_r + Vector2(0, 5), 3.0, Color(0.22, 0.18, 0.15), true)

	# Explorer Coat / Haori (Ivory & Tan with harness)
	var coat_rect := Rect2(center.x - 9.0, center.y - 8.0, 18.0, 17.0)
	canvas.draw_rect(coat_rect, Color(0.88, 0.85, 0.78))
	canvas.draw_rect(coat_rect, Color(0.18, 0.16, 0.15), false, 1.5)
	# Cross shoulder straps
	canvas.draw_line(Vector2(coat_rect.position.x + 3, coat_rect.position.y), Vector2(coat_rect.end.x - 3, coat_rect.end.y), Color(0.35, 0.25, 0.18), 1.8, true)
	canvas.draw_line(Vector2(coat_rect.end.x - 3, coat_rect.position.y), Vector2(coat_rect.position.x + 3, coat_rect.end.y), Color(0.35, 0.25, 0.18), 1.8, true)
	# Waist belt
	canvas.draw_line(Vector2(coat_rect.position.x, center.y + 6), Vector2(coat_rect.end.x, center.y + 6), Color(0.22, 0.16, 0.12), 2.5, true)

	# Arms with walking swing
	var arm_l := center + Vector2(-10.0 * flip, -1.0 - stride * 3.0)
	var arm_r := center + Vector2(10.0 * flip, -1.0 + stride * 3.0)
	canvas.draw_line(center + Vector2(-7.0 * flip, -6), arm_l, Color(0.85, 0.82, 0.75), 3.5, true)
	canvas.draw_line(center + Vector2(7.0 * flip, -6), arm_r, Color(0.85, 0.82, 0.75), 3.5, true)

	# Head & Dark Spiky Hair
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.5, Color(0.96, 0.85, 0.76), true) # Skin
	# Spiky Anime Hair
	var hair_pts: PackedVector2Array = [
		head_pos + Vector2(-8, -1),
		head_pos + Vector2(-9, -9),
		head_pos + Vector2(-4, -13),
		head_pos + Vector2(1, -14),
		head_pos + Vector2(6, -11),
		head_pos + Vector2(9, -7),
		head_pos + Vector2(8, -1),
		head_pos + Vector2(4 * flip, -4),
		head_pos + Vector2(-2 * flip, -5)
	]
	canvas.draw_colored_polygon(hair_pts, Color(0.10, 0.11, 0.14))

## Aiko — Shrine Priestess (White Kimono & Vermilion Red Hakama)
static func draw_aiko_miko(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Vermilion Red Hakama Skirt
	var skirt_pts: PackedVector2Array = [
		center + Vector2(-6, 4),
		center + Vector2(6, 4),
		center + Vector2(11 + stride * 2.0, 16),
		center + Vector2(-11 - stride * 2.0, 16)
	]
	canvas.draw_colored_polygon(skirt_pts, Color(0.88, 0.22, 0.18))
	canvas.draw_polyline(skirt_pts, Color(0.55, 0.10, 0.08), 1.2)

	# White Miko Robe Top
	var top_rect := Rect2(center.x - 8.0, center.y - 8.0, 16.0, 13.0)
	canvas.draw_rect(top_rect, Color(0.96, 0.96, 0.98))
	canvas.draw_rect(top_rect, Color(0.80, 0.20, 0.18), false, 1.2)
	# Red collar cross
	canvas.draw_line(Vector2(top_rect.position.x + 4, top_rect.position.y), Vector2(center.x, center.y + 2), Color(0.85, 0.20, 0.18), 1.5, true)
	canvas.draw_line(Vector2(top_rect.end.x - 4, top_rect.position.y), Vector2(center.x, center.y + 2), Color(0.85, 0.20, 0.18), 1.5, true)

	# Flowing Wide Kimono Sleeves
	canvas.draw_circle(center + Vector2(-9.0 * flip, -1), 4.5, Color(0.96, 0.96, 0.98), true)
	canvas.draw_circle(center + Vector2(9.0 * flip, -1), 4.5, Color(0.96, 0.96, 0.98), true)

	# Head, Long Dark Hair with Red Ribbon
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.0, Color(0.98, 0.88, 0.80), true) # Skin
	# Long dark hair
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.5, Color(0.10, 0.08, 0.10), true)
	canvas.draw_line(head_pos + Vector2(-6, 0), head_pos + Vector2(-6, 12), Color(0.10, 0.08, 0.10), 3.0, true)
	canvas.draw_line(head_pos + Vector2(6, 0), head_pos + Vector2(6, 12), Color(0.10, 0.08, 0.10), 3.0, true)
	# Red Priestess Ribbon
	canvas.draw_circle(head_pos + Vector2(0, -9), 3.0, Color(0.90, 0.18, 0.16), true)

## Kenji — Elder Archivist (Charcoal Robes & White Hair)
static func draw_kenji_scholar(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Long Slate-Grey Scholar Robes
	var robe_pts: PackedVector2Array = [
		center + Vector2(-7, -6),
		center + Vector2(7, -6),
		center + Vector2(10 + stride * 2.0, 16),
		center + Vector2(-10 - stride * 2.0, 16)
	]
	canvas.draw_colored_polygon(robe_pts, Color(0.24, 0.26, 0.30))
	canvas.draw_polyline(robe_pts, Color(0.14, 0.15, 0.18), 1.2)
	# Ivory Obi Sash
	canvas.draw_line(Vector2(center.x - 7, center.y + 4), Vector2(center.x + 7, center.y + 4), Color(0.88, 0.85, 0.78), 2.5, true)

	# Sleeves & Ancient Scroll in Hand
	canvas.draw_circle(center + Vector2(-9.0 * flip, 1), 4.5, Color(0.24, 0.26, 0.30), true)
	canvas.draw_circle(center + Vector2(9.0 * flip, 1), 4.5, Color(0.24, 0.26, 0.30), true)
	canvas.draw_line(center + Vector2(8.0 * flip, 1), center + Vector2(12.0 * flip, 5), Color(0.85, 0.78, 0.55), 3.0, true) # Scroll

	# Head & Dignified White / Silver Hair
	var head_pos := center + Vector2(0, -15.0)
	canvas.draw_circle(head_pos, 7.0, Color(0.94, 0.84, 0.74), true) # Skin
	# Silver hair
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.5, Color(0.82, 0.84, 0.88), true)
	canvas.draw_circle(head_pos + Vector2(0, -8), 4.0, Color(0.82, 0.84, 0.88), true) # Topknot

## Sora — Tea Attendant (Sage-Green Kimono & Hair Bun)
static func draw_sora_attendant(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Sage-Green Kimono Dress
	var kimono_pts: PackedVector2Array = [
		center + Vector2(-6, -7),
		center + Vector2(6, -7),
		center + Vector2(9 + stride * 2.0, 16),
		center + Vector2(-9 - stride * 2.0, 16)
	]
	canvas.draw_colored_polygon(kimono_pts, Color(0.38, 0.58, 0.44))
	canvas.draw_polyline(kimono_pts, Color(0.22, 0.38, 0.28), 1.2)
	# Brown Obi Sash
	canvas.draw_line(Vector2(center.x - 6, center.y + 3), Vector2(center.x + 6, center.y + 3), Color(0.42, 0.28, 0.18), 3.0, true)

	# Tea Tray
	canvas.draw_line(center + Vector2(5.0 * flip, 2), center + Vector2(13.0 * flip, 2), Color(0.65, 0.45, 0.25), 2.5, true)
	canvas.draw_circle(center + Vector2(9.0 * flip, 0), 2.0, Color(0.95, 0.95, 0.95), true) # Tea bowl

	# Head & High Hair Bun
	var head_pos := center + Vector2(0, -15.0)
	canvas.draw_circle(head_pos, 7.0, Color(0.96, 0.86, 0.78), true) # Skin
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.2, Color(0.12, 0.10, 0.12), true)
	canvas.draw_circle(head_pos + Vector2(0, -9), 4.5, Color(0.12, 0.10, 0.12), true) # Bun
	canvas.draw_line(head_pos + Vector2(-3, -9), head_pos + Vector2(3, -9), Color(0.85, 0.65, 0.3), 1.5, true) # Comb

## Haru — Estate Guardian (Indigo Samurai Haori & Katana)
static func draw_haru_guardian(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Dark Hakama & Tabi
	var leg_l := center + Vector2(-4.5, 9.0 + stride * 4.0)
	var leg_r := center + Vector2(4.5, 9.0 - stride * 4.0)
	canvas.draw_line(center + Vector2(-3, 6), leg_l, Color(0.10, 0.12, 0.18), 4.5, true)
	canvas.draw_line(center + Vector2(3, 6), leg_r, Color(0.10, 0.12, 0.18), 4.5, true)

	# Deep Indigo Samurai Haori
	var haori_rect := Rect2(center.x - 9.0, center.y - 8.0, 18.0, 16.0)
	canvas.draw_rect(haori_rect, Color(0.16, 0.24, 0.42))
	canvas.draw_rect(haori_rect, Color(0.85, 0.88, 0.95), false, 1.2)

	# Katana Sheath at Hip
	var sword_start := center + Vector2(-8.0 * flip, 4.0)
	var sword_end := center + Vector2(-15.0 * flip, 13.0)
	canvas.draw_line(sword_start, sword_end, Color(0.12, 0.12, 0.14), 2.5, true) # Scabbard
	canvas.draw_circle(sword_start, 2.0, Color(0.85, 0.75, 0.35), true) # Tsuba guard

	# Head & Samurai Ponytail
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.5, Color(0.94, 0.84, 0.74), true) # Skin
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.5, Color(0.10, 0.10, 0.12), true)
	canvas.draw_line(head_pos + Vector2(-2 * flip, -8), head_pos + Vector2(-8 * flip, -14), Color(0.10, 0.10, 0.12), 3.0, true) # Ponytail

# =========================================================================
# CHARACTER SILHOUETTES: BLACKGLASS STATION (Orbital Spacecraft)
# =========================================================================

## Dr. Elara — Chief Xenologist (White Lab Coat & Teal Datapad)
static func draw_elara_scientist(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Dark Trousers
	canvas.draw_line(center + Vector2(-3, 8), center + Vector2(-4, 15 + stride * 3.0), Color(0.15, 0.18, 0.22), 4.0, true)
	canvas.draw_line(center + Vector2(3, 8), center + Vector2(4, 15 - stride * 3.0), Color(0.15, 0.18, 0.22), 4.0, true)

	# Long White Laboratory Coat
	var coat_pts: PackedVector2Array = [
		center + Vector2(-8, -8),
		center + Vector2(8, -8),
		center + Vector2(9 + stride * 1.5, 12),
		center + Vector2(-9 - stride * 1.5, 12)
	]
	canvas.draw_colored_polygon(coat_pts, Color(0.94, 0.96, 0.98))
	canvas.draw_polyline(coat_pts, Color(0.20, 0.50, 0.65), 1.2)
	# Teal inner shirt
	canvas.draw_rect(Rect2(center.x - 3, center.y - 7, 6, 8), Color(0.10, 0.55, 0.65))

	# Glowing Diagnostic Datapad in hand
	var pad_pos := center + Vector2(8.0 * flip, 0)
	canvas.draw_rect(Rect2(pad_pos.x - 2, pad_pos.y - 3, 5, 7), Color(0.0, 0.85, 1.0))
	canvas.draw_rect(Rect2(pad_pos.x - 2, pad_pos.y - 3, 5, 7), Color(1, 1, 1), false, 1.0)

	# Head & Dark Bob Haircut
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.0, Color(0.96, 0.86, 0.78), true)
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.5, Color(0.12, 0.10, 0.14), true)
	canvas.draw_line(head_pos + Vector2(-6, -2), head_pos + Vector2(-6, 6), Color(0.12, 0.10, 0.14), 3.0, true)
	canvas.draw_line(head_pos + Vector2(6, -2), head_pos + Vector2(6, 6), Color(0.12, 0.10, 0.14), 3.0, true)

## Kael — Security & Operations (Black & Crimson Tactical Suit)
static func draw_kael_security(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Heavy Tactical Combat Pants
	canvas.draw_line(center + Vector2(-3, 8), center + Vector2(-4, 15 + stride * 3.5), Color(0.10, 0.12, 0.14), 4.5, true)
	canvas.draw_line(center + Vector2(3, 8), center + Vector2(4, 15 - stride * 3.5), Color(0.10, 0.12, 0.14), 4.5, true)

	# Tactical Armored Vest (Black with Crimson Trim)
	var vest_rect := Rect2(center.x - 9.0, center.y - 8.0, 18.0, 16.0)
	canvas.draw_rect(vest_rect, Color(0.14, 0.16, 0.18))
	canvas.draw_rect(vest_rect, Color(0.85, 0.18, 0.22), false, 1.5)
	# Crimson Epaulets & Chest Insignia
	canvas.draw_line(Vector2(vest_rect.position.x, vest_rect.position.y + 1), Vector2(vest_rect.end.x, vest_rect.position.y + 1), Color(0.90, 0.20, 0.25), 2.5, true)
	canvas.draw_circle(center + Vector2(0, -1), 2.5, Color(0.95, 0.85, 0.2), true) # Gold badge

	# Head & Military Crew Cut
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.5, Color(0.92, 0.82, 0.72), true)
	canvas.draw_circle(head_pos + Vector2(0, -4), 7.0, Color(0.14, 0.12, 0.14), true)

## Vance — Shuttle Pilot (Navy Flight Jumpsuit & Orange Straps)
static func draw_vance_pilot(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Flight Jumpsuit Legs
	canvas.draw_line(center + Vector2(-3, 8), center + Vector2(-4, 15 + stride * 3.5), Color(0.14, 0.18, 0.25), 4.5, true)
	canvas.draw_line(center + Vector2(3, 8), center + Vector2(4, 15 - stride * 3.5), Color(0.14, 0.18, 0.25), 4.5, true)

	# Navy Flight Suit with Orange Ejection Harness
	var suit_rect := Rect2(center.x - 8.5, center.y - 8.0, 17.0, 16.0)
	canvas.draw_rect(suit_rect, Color(0.16, 0.20, 0.28))
	canvas.draw_rect(suit_rect, Color(0.08, 0.10, 0.14), false, 1.5)
	# High-vis orange straps
	canvas.draw_line(Vector2(suit_rect.position.x + 3, suit_rect.position.y), Vector2(suit_rect.position.x + 3, suit_rect.end.y), Color(0.98, 0.45, 0.12), 1.8, true)
	canvas.draw_line(Vector2(suit_rect.end.x - 3, suit_rect.position.y), Vector2(suit_rect.end.x - 3, suit_rect.end.y), Color(0.98, 0.45, 0.12), 1.8, true)

	# Head & Wavy Pilot Hair
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.5, Color(0.94, 0.82, 0.72), true)
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.5, Color(0.35, 0.22, 0.15), true)

## Lyra — Systems & Reactor Engineer (Coveralls & Glowing Conduits)
static func draw_lyra_engineer(canvas: CanvasItem, center: Vector2, stride: float, flip: float) -> void:
	# Heavy Industrial Coverall Legs
	canvas.draw_line(center + Vector2(-3, 8), center + Vector2(-4, 15 + stride * 3.5), Color(0.18, 0.20, 0.24), 4.5, true)
	canvas.draw_line(center + Vector2(3, 8), center + Vector2(4, 15 - stride * 3.5), Color(0.18, 0.20, 0.24), 4.5, true)

	# Dark Engineer Coveralls
	var suit_rect := Rect2(center.x - 9.0, center.y - 8.0, 18.0, 16.0)
	canvas.draw_rect(suit_rect, Color(0.16, 0.18, 0.22))
	canvas.draw_rect(suit_rect, Color(0.95, 0.75, 0.18), false, 1.2) # Hazard trim
	# Glowing Cyan Conduits
	canvas.draw_line(Vector2(suit_rect.position.x + 2, center.y), Vector2(suit_rect.end.x - 2, center.y), Color(0.0, 0.92, 1.0), 1.8, true)

	# Head & Silver/Lilac Ponytail
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.0, Color(0.96, 0.86, 0.80), true)
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.5, Color(0.75, 0.72, 0.85), true) # Lilac hair
	canvas.draw_line(head_pos + Vector2(-2 * flip, -7), head_pos + Vector2(-7 * flip, -12), Color(0.75, 0.72, 0.85), 3.0, true)

## Generic Sci-Fi Crewmate
static func draw_scifi_officer(canvas: CanvasItem, center: Vector2, stride: float, flip: float, role: GameEnums.Role) -> void:
	var role_col := get_role_color(role)
	var accent_col := get_role_accent(role)
	canvas.draw_line(center + Vector2(-3, 8), center + Vector2(-4, 15 + stride * 3.5), Color(0.12, 0.14, 0.18), 4.0, true)
	canvas.draw_line(center + Vector2(3, 8), center + Vector2(4, 15 - stride * 3.5), Color(0.12, 0.14, 0.18), 4.0, true)
	var body_rect := Rect2(center.x - 8.0, center.y - 8.0, 16.0, 16.0)
	canvas.draw_rect(body_rect, role_col)
	canvas.draw_rect(body_rect, accent_col, false, 1.5)
	var head_pos := center + Vector2(0, -16.0)
	canvas.draw_circle(head_pos, 7.0, Color(0.94, 0.84, 0.74), true)
	canvas.draw_circle(head_pos + Vector2(0, -3), 7.2, Color(0.15, 0.15, 0.18), true)

# =========================================================================
# OVERHEAD BADGES & FALLEN BODIES
# =========================================================================

static func draw_overhead_badge(canvas: CanvasItem, center: Vector2, char_name: String, is_local_player: bool) -> void:
	if is_local_player:
		# Rex (You) with electric cyan down arrow
		var tag_y: float = center.y - 36.0
		var label_str := "Rex (You)"
		var font_size: int = 11
		var text_sz := ThemeDB.fallback_font.get_string_size(label_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var lx: float = center.x - (text_sz.x * 0.5)

		canvas.draw_string(ThemeDB.fallback_font, Vector2(lx, tag_y), label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.0, 0.92, 1.0))
		# Cyan down arrow
		var arrow_pts: PackedVector2Array = [
			Vector2(center.x - 4, tag_y + 4),
			Vector2(center.x + 4, tag_y + 4),
			Vector2(center.x, tag_y + 9)
		]
		canvas.draw_colored_polygon(arrow_pts, Color(0.0, 0.92, 1.0))
	else:
		# NPC Name Tag with circular indicator dot
		var tag_y: float = center.y - 34.0
		var font_size: int = 11
		var text_sz := ThemeDB.fallback_font.get_string_size(char_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var lx: float = center.x - (text_sz.x * 0.5)

		# Small indicator circle
		canvas.draw_circle(Vector2(center.x, tag_y - 4), 3.0, Color(0.0, 0.85, 1.0, 0.9))
		canvas.draw_string(ThemeDB.fallback_font, Vector2(lx, tag_y + 10), char_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.88, 0.92, 0.98))

static func draw_fallen_investigator(canvas: CanvasItem, pos: Vector2, char_name: String, flip: float) -> void:
	# Crime scene chalk/evidence circle
	canvas.draw_circle(pos + Vector2(0, 4), 22.0, Color(0.7, 0.1, 0.15, 0.35), true)
	canvas.draw_arc(pos + Vector2(0, 4), 22.0, 0, TAU, 24, Color(1.0, 0.3, 0.3, 0.8), 1.5, true)

	# Fallen character body silhouette
	var body_rect := Rect2(pos.x - 16.0, pos.y - 4.0, 32.0, 12.0)
	canvas.draw_rect(body_rect, Color(0.2, 0.22, 0.26))
	canvas.draw_rect(body_rect, Color(0.1, 0.12, 0.14), false, 1.5)

	# Head
	canvas.draw_circle(pos + Vector2(-16.0 * flip, 2.0), 6.5, Color(0.88, 0.78, 0.70), true)

	# Crime Scene Marker Flag [!]
	var flag_pos := pos + Vector2(16, -14)
	canvas.draw_line(flag_pos, flag_pos + Vector2(0, 16), Color(1.0, 0.85, 0.2), 2.0, true)
	var flag_poly: PackedVector2Array = [flag_pos, flag_pos + Vector2(8, 4), flag_pos + Vector2(0, 8)]
	canvas.draw_colored_polygon(flag_poly, Color(1.0, 0.3, 0.2))

static var _cached_rex_portrait: Texture2D = null

static func draw_crewmate_portrait(canvas: CanvasItem, pos: Vector2, role: GameEnums.Role, scale_fac: float = 1.0) -> void:
	if _cached_rex_portrait == null:
		var path := "res://assets/portraits/rex.png"
		var gpath := ProjectSettings.globalize_path(path)
		var img := Image.load_from_file(gpath)
		if img != null and not img.is_empty():
			_cached_rex_portrait = ImageTexture.create_from_image(img)
		elif ResourceLoader.exists(path):
			_cached_rex_portrait = load(path)

	if _cached_rex_portrait != null:
		var w: float = 80.0 * scale_fac
		var h: float = 80.0 * scale_fac
		canvas.draw_texture_rect(_cached_rex_portrait, Rect2(pos.x - w * 0.5, pos.y - h * 0.5, w, h), false)
		return

	# Fallback stylized bust
	var role_color := get_role_color(role)
	var accent_color := get_role_accent(role)
	var head_center := pos + Vector2(0, -6 * scale_fac)
	canvas.draw_circle(head_center, 18.0 * scale_fac, Color(0.96, 0.86, 0.78), true)
	canvas.draw_circle(head_center + Vector2(0, -6 * scale_fac), 16.0 * scale_fac, Color(0.12, 0.14, 0.18), true)
	canvas.draw_rect(Rect2(pos.x - 24 * scale_fac, pos.y + 10 * scale_fac, 48 * scale_fac, 30 * scale_fac), role_color)
	canvas.draw_rect(Rect2(pos.x - 24 * scale_fac, pos.y + 10 * scale_fac, 48 * scale_fac, 30 * scale_fac), accent_color, false, 1.5)

