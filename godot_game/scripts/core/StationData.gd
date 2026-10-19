class_name StationData
extends RefCounted

## Station blueprint data for DSS Chronos (Voidshift research vessel).
## Structured for 2.5D top-down layout matching reference blueprints.

class RoomDef:
	var id: String
	var name: String
	var short_name: String
	var rect: Rect2
	var floor_color: Color
	var ambient_color: Color
	var accent_color: Color
	var icon: String

	func _init(p_id: String, p_name: String, p_short: String, p_rect: Rect2, p_floor: Color,
			   p_ambient: Color, p_accent: Color, p_icon: String = "") -> void:
		id = p_id
		name = p_name
		short_name = p_short
		rect = p_rect
		floor_color = p_floor
		ambient_color = p_ambient
		accent_color = p_accent
		icon = p_icon

class VentDef:
	var id: int
	var room_id: String
	var position: Vector2
	var connected_vent_id: int

	func _init(p_id: int, p_room: String, p_pos: Vector2, p_conn: int) -> void:
		id = p_id
		room_id = p_room
		position = p_pos
		connected_vent_id = p_conn

class TaskSpotDef:
	var id: int
	var task_type: int
	var name: String
	var room_id: String
	var room_name: String
	var position: Vector2
	var description: String

	func _init(p_id: int, p_type: int, p_name: String, p_room_id: String, p_room_name: String, p_pos: Vector2, p_desc: String) -> void:
		id = p_id
		task_type = p_type
		name = p_name
		room_id = p_room_id
		room_name = p_room_name
		position = p_pos
		description = p_desc

class CameraDef:
	var id: int
	var name: String
	var position: Vector2
	var look_angle: float # Radians
	var sweep_angle: float # Field of view sweep

	func _init(p_id: int, p_name: String, p_pos: Vector2, p_angle: float, p_sweep: float = 0.8) -> void:
		id = p_id
		name = p_name
		position = p_pos
		look_angle = p_angle
		sweep_angle = p_sweep

static func get_rooms() -> Array[RoomDef]:
	# Coherent 1600 x 1200 Station Blueprint
	var r: Array[RoomDef] = [
		RoomDef.new("bridge", "Bridge", "BRIDGE", Rect2(580, 50, 440, 220),
			Color(0.08, 0.12, 0.18), Color(0.1, 0.35, 0.7, 0.4), Color(0.0, 0.85, 1.0), "bridge"),
		RoomDef.new("medical", "Medical Bay", "MEDICAL BAY", Rect2(100, 320, 380, 260),
			Color(0.09, 0.16, 0.18), Color(0.1, 0.6, 0.5, 0.35), Color(0.2, 0.95, 0.75), "cross"),
		RoomDef.new("central_hub", "Central Hub", "CENTRAL HUB", Rect2(540, 330, 520, 260),
			Color(0.09, 0.12, 0.16), Color(0.15, 0.4, 0.6, 0.3), Color(0.0, 0.8, 1.0), "hub"),
		RoomDef.new("research", "Research Lab", "RESEARCH LAB", Rect2(1120, 320, 380, 260),
			Color(0.12, 0.10, 0.18), Color(0.5, 0.2, 0.7, 0.35), Color(0.8, 0.3, 1.0), "flask"),
		RoomDef.new("reactor", "Reactor Core", "REACTOR", Rect2(100, 640, 380, 270),
			Color(0.16, 0.08, 0.14), Color(0.7, 0.15, 0.5, 0.4), Color(0.9, 0.2, 0.8), "warning"),
		RoomDef.new("electrical", "Electrical", "ELECTRICAL", Rect2(540, 650, 240, 250),
			Color(0.16, 0.14, 0.08), Color(0.8, 0.6, 0.1, 0.35), Color(1.0, 0.85, 0.2), "bolt"),
		RoomDef.new("storage", "Storage", "STORAGE", Rect2(820, 650, 240, 250),
			Color(0.11, 0.12, 0.15), Color(0.4, 0.45, 0.55, 0.25), Color(0.6, 0.7, 0.8), "box"),
		RoomDef.new("security", "Security Station", "SECURITY", Rect2(1120, 650, 380, 250),
			Color(0.08, 0.14, 0.18), Color(0.1, 0.55, 0.7, 0.35), Color(0.0, 0.9, 1.0), "shield"),
		RoomDef.new("meeting", "Meeting Room", "MEETING", Rect2(540, 960, 520, 210),
			Color(0.09, 0.13, 0.19), Color(0.2, 0.6, 0.9, 0.4), Color(0.0, 0.85, 1.0), "star")
	]
	return r

static func get_corridors() -> Array[Rect2]:
	# Corridors interconnecting rooms cleanly without overlaps
	var c: Array[Rect2] = [
		Rect2(740, 270, 120, 60),   # Bridge <-> Central Hub
		Rect2(480, 420, 60, 100),   # Medical Bay <-> Central Hub
		Rect2(1060, 420, 60, 100),  # Central Hub <-> Research Lab
		Rect2(240, 580, 100, 60),   # Medical Bay <-> Reactor Core
		Rect2(740, 590, 120, 60),   # Central Hub <-> Electrical / Storage
		Rect2(780, 740, 40, 80),    # Electrical <-> Storage Doorway
		Rect2(1060, 740, 60, 80),   # Storage <-> Security
		Rect2(620, 900, 80, 60),    # Electrical <-> Meeting Room
		Rect2(900, 900, 80, 60)     # Storage <-> Meeting Room
	]
	return c

static func get_task_spots() -> Array[TaskSpotDef]:
	# 0: Fix Wiring, 1: Stabilize Reactor, 2: Calibrate Nav, 3: Divert Power, 4: Medical Scan, 5: Upload Logs, 6: Clear Asteroids
	var t: Array[TaskSpotDef] = [
		TaskSpotDef.new(0, 2, "Calibrate Navigation Console", "bridge", "Bridge", Vector2(800, 110), "Align navigational thruster gyro vectors."),
		TaskSpotDef.new(1, 4, "Run Medical Biometric Scan", "medical", "Medical Bay", Vector2(240, 450), "Verify crew cellular DNA integrity."),
		TaskSpotDef.new(2, 3, "Fix Power Junction", "electrical", "Electrical", Vector2(660, 770), "Re-route breaker circuits to defensive grids."),
		TaskSpotDef.new(3, 1, "Stabilize Reactor Core", "reactor", "Reactor", Vector2(290, 770), "Balance magnetic containment flow coils."),
		TaskSpotDef.new(4, 5, "Upload Research Logs", "research", "Research Lab", Vector2(1310, 450), "Transmit xenobiology logs to orbital relay."),
		TaskSpotDef.new(5, 0, "Fix Wiring Conduits", "security", "Security", Vector2(1310, 770), "Repair high-voltage conduit relays.")
	]
	return t

static func get_vents() -> Array[VentDef]:
	var v: Array[VentDef] = [
		VentDef.new(0, "reactor", Vector2(160, 700), 1),
		VentDef.new(1, "medical", Vector2(160, 380), 0),
		VentDef.new(2, "electrical", Vector2(590, 700), 3),
		VentDef.new(3, "storage", Vector2(980, 700), 2),
		VentDef.new(4, "security", Vector2(1420, 700), 5),
		VentDef.new(5, "research", Vector2(1420, 380), 4)
	]
	return v

static func get_cameras() -> Array[CameraDef]:
	var cams: Array[CameraDef] = [
		CameraDef.new(0, "Bridge Access Cam", Vector2(800, 260), PI * 0.5, 1.1),
		CameraDef.new(1, "Medical Corridor Cam", Vector2(490, 470), PI, 1.0),
		CameraDef.new(2, "Research Corridor Cam", Vector2(1070, 470), 0.0, 1.0),
		CameraDef.new(3, "Electrical Access Cam", Vector2(740, 660), PI * 0.5, 1.0),
		CameraDef.new(4, "Security Cam", Vector2(1200, 680), PI * 0.5, 1.0),
		CameraDef.new(5, "Meeting Table Cam", Vector2(800, 970), PI * 0.5, 1.2)
	]
	return cams

static func get_emergency_button_pos() -> Vector2:
	return Vector2(800, 1060) # Center of Cafeteria/Meeting Hologram Table
