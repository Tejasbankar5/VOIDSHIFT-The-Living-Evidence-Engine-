class_name StationMap
extends Node2D

const StationMapRenderer = preload("res://scripts/render/StationMapRenderer.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")
const StationData = preload("res://scripts/core/StationData.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")

## Multi-Campaign Station Map Controller for VOIDSHIFT.
## Handles procedural visuals, collision boundaries, and location queries across:
## 1. The Hollow Crown
## 2. Blackglass Station
## 3. The Last Signal

signal task_interacted(task_spot: StationData.TaskSpotDef)
signal emergency_button_pressed()
signal vent_interacted(vent: StationData.VentDef)
signal echo_clue_discovered(clue: CampaignData.EchoClueDef)

@export var anim_time: float = 0.0

var campaign_mode: GameEnums.CampaignMode = GameEnums.CampaignMode.HOLLOW_CROWN
var active_campaign: CampaignData.CampaignDef = null
var echo_vision_active: bool = false

var completed_tasks: Array[int] = []
var active_sabotage: GameEnums.SabotageType = GameEnums.SabotageType.NONE
var sabotage_timer: float = 0.0

var wall_rects: Array[Rect2] = []
var static_body: StaticBody2D = null

func _ready() -> void:
	set_campaign(GameEnums.CampaignMode.HOLLOW_CROWN)
	build_collision_boundaries()

func set_campaign(mode: GameEnums.CampaignMode) -> void:
	campaign_mode = mode
	active_campaign = CampaignData.get_campaign(mode)
	completed_tasks.clear()
	build_collision_boundaries()
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _draw() -> void:
	var clues: Array = active_campaign.clues if active_campaign else []
	StationMapRenderer.draw_station(
		self, anim_time, completed_tasks, active_sabotage, sabotage_timer,
		campaign_mode, echo_vision_active, clues
	)

func build_collision_boundaries() -> void:
	if static_body != null:
		static_body.queue_free()

	static_body = StaticBody2D.new()
	static_body.name = "StationWalls"
	add_child(static_body)
	wall_rects.clear()

	var blocker_walls: Array[Rect2] = [
		Rect2(0, 0, 1280, 40),      # Top screen bound
		Rect2(0, 680, 1280, 40),    # Bottom screen bound
		Rect2(0, 0, 40, 720),       # Left screen bound
		Rect2(1240, 0, 40, 720)     # Right screen bound
	]

	if campaign_mode == GameEnums.CampaignMode.HOLLOW_CROWN:
		# Koi Pond water hazard (keeps navigation on bridge and stone paths)
		blocker_walls.append(Rect2(160, 320, 150, 140))
		# Inner shrine back ceremonial altar barrier
		blocker_walls.append(Rect2(480, 45, 320, 40))
	elif campaign_mode == GameEnums.CampaignMode.BLACKGLASS_STATION:
		# Deck A observation railing (with corridor gap at x=340..460)
		blocker_walls.append(Rect2(40, 205, 300, 16))
		blocker_walls.append(Rect2(460, 205, 540, 16))
		# Lab containment tank
		blocker_walls.append(Rect2(700, 340, 90, 80))

	for w in blocker_walls:
		wall_rects.append(w)
		var col_shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = w.size
		col_shape.shape = rect_shape
		col_shape.position = w.position + (w.size * 0.5)
		static_body.add_child(col_shape)

func get_current_room(pos: Vector2) -> StationData.RoomDef:
	var rooms := active_campaign.rooms if active_campaign else StationData.get_rooms()
	for r in rooms:
		if r.rect.has_point(pos):
			return r
	return null

func get_nearby_task(pos: Vector2, max_dist: float = 55.0) -> StationData.TaskSpotDef:
	var tasks := active_campaign.tasks if active_campaign else StationData.get_task_spots()
	for t in tasks:
		if not (t.id in completed_tasks):
			if pos.distance_to(t.position) <= max_dist:
				return t
	return null

func get_nearby_echo_clue(pos: Vector2, max_dist: float = 65.0) -> CampaignData.EchoClueDef:
	if not active_campaign:
		return null
	for clue in active_campaign.clues:
		if not clue.is_collected and pos.distance_to(clue.position) <= max_dist:
			return clue
	return null

func get_nearby_vent(pos: Vector2, max_dist: float = 50.0) -> StationData.VentDef:
	var vents := active_campaign.vents if active_campaign else StationData.get_vents()
	for v in vents:
		if pos.distance_to(v.position) <= max_dist:
			return v
	return null

func is_near_emergency_button(pos: Vector2, max_dist: float = 60.0) -> bool:
	var btn_pos: Vector2 = active_campaign.emergency_button_pos if active_campaign else Vector2(800, 1060)
	return pos.distance_to(btn_pos) <= max_dist

func get_room_waypoints() -> Array[Vector2]:
	var pts: Array[Vector2] = []
	var rooms := active_campaign.rooms if active_campaign else StationData.get_rooms()
	for r in rooms:
		pts.append(r.rect.get_center())
	return pts
