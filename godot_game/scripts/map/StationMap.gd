class_name StationMap
extends Node2D

const StationMapRenderer = preload("res://scripts/render/StationMapRenderer.gd")

## Station Map Node for DSS Chronos.
## Handles procedural visuals, collision boundaries, and location queries.

signal task_interacted(task_spot: StationData.TaskSpotDef)
signal emergency_button_pressed()
signal vent_interacted(vent: StationData.VentDef)

@export var anim_time: float = 0.0

var completed_tasks: Array[int] = []
var active_sabotage: GameEnums.SabotageType = GameEnums.SabotageType.NONE
var sabotage_timer: float = 0.0

# Wall bounds for mathematical collision & navigation verification
var wall_rects: Array[Rect2] = []

func _ready() -> void:
	build_collision_boundaries()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _draw() -> void:
	StationMapRenderer.draw_station(self, anim_time, completed_tasks, active_sabotage, sabotage_timer)

func build_collision_boundaries() -> void:
	# Build hull boundaries and void blockers to enclose walkable rooms & corridors
	var static_body := StaticBody2D.new()
	static_body.name = "StationWalls"
	add_child(static_body)

	# Solid blocker rects for void spaces between rooms and station exterior
	var blocker_walls: Array[Rect2] = [
		# Top voids flanking Bridge
		Rect2(60, 30, 510, 280),      # Top-left void (above Medical)
		Rect2(1030, 30, 510, 280),    # Top-right void (above Research)
		Rect2(560, 30, 480, 20),      # Bridge top hull wall
		Rect2(560, 50, 20, 220),      # Bridge left wall
		Rect2(1020, 50, 20, 220),     # Bridge right wall
		# Flanking Bridge-to-Hub corridor (x: 740..860, y: 270..330)
		Rect2(580, 270, 160, 60),     # Left of Bridge-Hub corridor
		Rect2(860, 270, 160, 60),     # Right of Bridge-Hub corridor
		# Flanking Medical-to-Hub corridor (x: 480..540, y: 420..520)
		Rect2(480, 320, 60, 100),     # Above Med-Hub corridor
		Rect2(480, 520, 60, 70),      # Below Med-Hub corridor
		# Flanking Hub-to-Research corridor (x: 1060..1120, y: 420..520)
		Rect2(1060, 320, 60, 100),    # Above Hub-Research corridor
		Rect2(1060, 520, 60, 70),     # Below Hub-Research corridor
		# Flanking Medical-to-Reactor corridor (x: 240..340, y: 580..640)
		Rect2(80, 580, 160, 60),      # Left of Med-Reactor corridor
		Rect2(340, 580, 140, 60),     # Right of Med-Reactor corridor
		# Flanking Hub-to-Electrical/Storage corridor (x: 740..860, y: 590..650)
		Rect2(540, 590, 200, 60),     # Left of Hub-Lower corridor
		Rect2(860, 590, 200, 60),     # Right of Hub-Lower corridor
		# Void between Research and Security
		Rect2(1100, 580, 420, 70),
		# Electrical-Storage dividing wall (except doorway at y: 740..820)
		Rect2(780, 650, 40, 90),      # Upper dividing wall
		Rect2(780, 820, 40, 80),      # Lower dividing wall
		# Flanking Electrical/Storage-to-Meeting corridors
		Rect2(520, 900, 100, 60),     # Left of Elec-Meeting corridor (620..700)
		Rect2(700, 900, 200, 60),     # Between Elec-Meeting & Storage-Meeting
		Rect2(980, 900, 80, 60),      # Right of Storage-Meeting (900..980)
		# Bottom voids flanking Meeting Room
		Rect2(60, 910, 470, 290),     # Bottom-left void (below Reactor)
		Rect2(1070, 900, 470, 300),   # Bottom-right void (below Security)
		# Meeting Room bottom hull wall
		Rect2(520, 1170, 560, 30),
		Rect2(520, 960, 20, 210),     # Meeting left wall
		Rect2(1060, 960, 20, 210),    # Meeting right wall
		# Left outer hull walls
		Rect2(70, 310, 30, 610),
		# Right outer hull walls
		Rect2(1500, 310, 30, 610)
	]

	for w in blocker_walls:
		wall_rects.append(w)
		var col_shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = w.size
		col_shape.shape = rect_shape
		col_shape.position = w.position + (w.size * 0.5)
		static_body.add_child(col_shape)

func get_current_room(pos: Vector2) -> StationData.RoomDef:
	for r in StationData.get_rooms():
		if r.rect.has_point(pos):
			return r
	return null

func get_nearby_task(pos: Vector2, max_dist: float = 55.0) -> StationData.TaskSpotDef:
	for t in StationData.get_task_spots():
		if not (t.id in completed_tasks):
			if pos.distance_to(t.position) <= max_dist:
				return t
	return null

func get_nearby_vent(pos: Vector2, max_dist: float = 50.0) -> StationData.VentDef:
	for v in StationData.get_vents():
		if pos.distance_to(v.position) <= max_dist:
			return v
	return null

func is_near_emergency_button(pos: Vector2, max_dist: float = 60.0) -> bool:
	return pos.distance_to(StationData.get_emergency_button_pos()) <= max_dist

func get_room_waypoints() -> Array[Vector2]:
	var pts: Array[Vector2] = []
	for r in StationData.get_rooms():
		pts.append(r.rect.get_center())
	return pts
