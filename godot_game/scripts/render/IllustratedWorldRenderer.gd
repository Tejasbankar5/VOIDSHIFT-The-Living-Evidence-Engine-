class_name IllustratedWorldRenderer
extends Node2D

const GameEnums = preload("res://scripts/core/GameEnums.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")

var current_campaign: CampaignData.CampaignDef = null
var bg_texture: Texture2D = null

# Animation & Particle Variables
var anim_timer: float = 0.0

# Falling Sakura Petals for The Hollow Crown
var sakura_petals: Array[Dictionary] = []
const NUM_PETALS: int = 40

func _ready() -> void:
	init_sakura_petals()

func init_sakura_petals() -> void:
	sakura_petals.clear()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(NUM_PETALS):
		sakura_petals.append({
			"pos": Vector2(rng.randf_range(-100, 1380), rng.randf_range(-50, 750)),
			"speed": Vector2(rng.randf_range(25, 60), rng.randf_range(30, 75)),
			"size": rng.randf_range(3.0, 6.5),
			"rotation": rng.randf_range(0, TAU),
			"rot_speed": rng.randf_range(-1.5, 1.5),
			"alpha": rng.randf_range(0.5, 0.85)
		})

func set_campaign(campaign: CampaignData.CampaignDef) -> void:
	current_campaign = campaign
	if campaign != null and not campaign.bg_texture_path.is_empty():
		if ResourceLoader.exists(campaign.bg_texture_path):
			bg_texture = load(campaign.bg_texture_path)
		elif ResourceLoader.exists("res://assets/environments/hollow_crown.png"):
			bg_texture = load("res://assets/environments/hollow_crown.png")
	queue_redraw()

func _process(delta: float) -> void:
	anim_timer += delta

	# Update sakura petals drift
	if current_campaign != null and current_campaign.mode == GameEnums.CampaignMode.HOLLOW_CROWN:
		for p in sakura_petals:
			p["pos"] += (p["speed"] + Vector2(sin(anim_timer * 2.0 + p["pos"].y * 0.05) * 15.0, 0)) * delta
			p["rotation"] += p["rot_speed"] * delta
			if p["pos"].y > 740:
				p["pos"].y = -20
				p["pos"].x = randf_range(0, 1280)
			if p["pos"].x > 1300:
				p["pos"].x = -20

	queue_redraw()

func _draw() -> void:
	var vp := get_viewport_rect().size
	if vp.x <= 0: vp.x = 1280.0
	if vp.y <= 0: vp.y = 720.0

	# 1. Base Illustrated Environment
	if bg_texture != null:
		draw_texture_rect(bg_texture, Rect2(0, 0, vp.x, vp.y), false)
	else:
		draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0.04, 0.05, 0.08))

	if current_campaign == null:
		return

	# 2. Campaign-Specific Atmospheric Effects
	if current_campaign.mode == GameEnums.CampaignMode.HOLLOW_CROWN:
		draw_hollow_crown_atmosphere(vp)
	elif current_campaign.mode == GameEnums.CampaignMode.BLACKGLASS_STATION:
		draw_blackglass_atmosphere(vp)

	# 3. Interactive Clue Reticles
	draw_clue_reticles()

func draw_hollow_crown_atmosphere(_vp: Vector2) -> void:
	# Subtle lantern glows with soft flickering
	var lantern_glow: float = 0.45 + sin(anim_timer * 3.5) * 0.08
	var lantern_positions: Array[Vector2] = [
		Vector2(140, 500), # Moon Gate lantern
		Vector2(450, 450), # Courtyard stone lantern
		Vector2(380, 270), # Pond stone lantern
		Vector2(530, 230), # Shrine terrace lantern
		Vector2(650, 230), # Shrine right lantern
		Vector2(775, 430), # Archive entrance lantern
		Vector2(850, 440)  # Tea room veranda lantern
	]
	for l_pos in lantern_positions:
		draw_circle(l_pos, 45.0, Color(1.0, 0.85, 0.4, 0.05 * lantern_glow))
		draw_circle(l_pos, 22.0, Color(1.0, 0.88, 0.5, 0.12 * lantern_glow))

	# Koi pond gentle water ripples
	var pond_center := Vector2(330, 360)
	var ripple_r := fmod(anim_timer * 20.0, 40.0)
	draw_arc(pond_center, ripple_r, 0, TAU, 24, Color(0.2, 0.6, 0.8, 0.15 * (1.0 - ripple_r / 40.0)), 1.2)

	# Falling Sakura Petals
	for p in sakura_petals:
		var col := Color(1.0, 0.78, 0.85, p["alpha"])
		var pts: PackedVector2Array = [
			p["pos"] + Vector2(-p["size"], 0).rotated(p["rotation"]),
			p["pos"] + Vector2(0, -p["size"] * 1.6).rotated(p["rotation"]),
			p["pos"] + Vector2(p["size"], 0).rotated(p["rotation"]),
			p["pos"] + Vector2(0, p["size"] * 0.8).rotated(p["rotation"])
		]
		draw_colored_polygon(pts, col)

func draw_blackglass_atmosphere(_vp: Vector2) -> void:
	# Containment Cylinder Volumetric Cyan Pulse (Research Lab)
	var lab_cyl_pos := Vector2(925, 475)
	var pulse := 0.6 + sin(anim_timer * 3.0) * 0.25
	draw_circle(lab_cyl_pos, 65.0, Color(0.0, 0.88, 1.0, 0.06 * pulse))
	draw_circle(lab_cyl_pos, 35.0, Color(0.0, 0.95, 1.0, 0.15 * pulse))

	# Reactor Core Amber/Red Warning Light (Engineering Bay)
	var reactor_pos := Vector2(245, 590)
	var red_pulse := 0.5 + sin(anim_timer * 4.5) * 0.3
	draw_circle(reactor_pos, 50.0, Color(1.0, 0.2, 0.25, 0.08 * red_pulse))
	draw_circle(reactor_pos, 25.0, Color(1.0, 0.35, 0.2, 0.18 * red_pulse))

	# Observation Window Stars gentle twinkle
	var stars: Array[Vector2] = [
		Vector2(450, 70), Vector2(520, 110), Vector2(620, 50),
		Vector2(710, 85), Vector2(810, 130), Vector2(890, 60)
	]
	for s in stars:
		var st_alpha := 0.4 + sin(anim_timer * 2.0 + s.x) * 0.3
		draw_circle(s, 1.5, Color(1, 1, 1, st_alpha))

func draw_clue_reticles() -> void:
	if current_campaign == null:
		return

	var pulse_r := 12.0 + sin(anim_timer * 4.0) * 3.0
	for clue in current_campaign.clues:
		# Scale clue position to 1280x720 (1.25x)
		var c_pos: Vector2 = clue.position * 1.25

		var ring_col := Color(0.0, 0.85, 1.0, 0.85) if not clue.is_collected else Color(0.3, 0.9, 0.5, 0.7)
		draw_arc(c_pos, pulse_r, 0, TAU, 28, ring_col, 1.8, true)
		draw_circle(c_pos, 4.0, ring_col, true)
