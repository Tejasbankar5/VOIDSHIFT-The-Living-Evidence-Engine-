class_name CampaignData
extends RefCounted

## Definitive Campaign & Story Mode Definitions for VOIDSHIFT.
## Implements the two definitive narrative mysteries:
## 1. THE HOLLOW CROWN (A Japanese-inspired mystery of moonlight, shadows, and a missing relic)
## 2. BLACKGLASS STATION (A science-fiction mystery aboard a silent spacecraft)

const GameEnums = preload("res://scripts/core/GameEnums.gd")
const StationData = preload("res://scripts/core/StationData.gd")

class EchoClueDef:
	var id: String
	var name: String
	var room_id: String
	var position: Vector2
	var evidence_type: GameEnums.EvidenceType
	var description: String
	var forensic_detail: String
	var reliability: float # 0.0 to 1.0
	var is_collected: bool = false
	var contradiction_target: String = ""

	func _init(p_id: String, p_name: String, p_room: String, p_pos: Vector2,
			   p_type: GameEnums.EvidenceType, p_desc: String, p_detail: String,
			   p_target: String = "", p_rel: float = 1.0) -> void:
		id = p_id
		name = p_name
		room_id = p_room
		position = p_pos
		evidence_type = p_type
		description = p_desc
		forensic_detail = p_detail
		contradiction_target = p_target
		reliability = p_rel
		is_collected = false

class SuspectDef:
	var id: String
	var name: String
	var title: String
	var location: String
	var position: Vector2
	var portrait_path: String
	var initial_statement: String
	var alibi: String
	var secret_motive: String
	var is_culprit: bool = false

	func _init(p_id: String, p_name: String, p_title: String, p_loc: String, p_pos: Vector2,
			   p_port: String, p_stmt: String, p_alibi: String, p_motive: String, p_culprit: bool = false) -> void:
		id = p_id
		name = p_name
		title = p_title
		location = p_loc
		position = p_pos
		portrait_path = p_port
		initial_statement = p_stmt
		alibi = p_alibi
		secret_motive = p_motive
		is_culprit = p_culprit

class CampaignDef:
	var mode: GameEnums.CampaignMode
	var id: String
	var title: String
	var subtitle: String
	var location: String
	var genre: String
	var briefing: String
	var primary_objective: String
	var bg_texture_path: String
	
	# Atmosphere & Palettes
	var primary_bg: Color
	var border_color: Color
	var accent_color: Color
	var hazard_color: Color
	var cyan_highlight: Color

	var rooms: Array[StationData.RoomDef]
	var corridors: Array[Rect2]
	var tasks: Array[StationData.TaskSpotDef]
	var vents: Array[StationData.VentDef]
	var cameras: Array[StationData.CameraDef]
	var clues: Array[EchoClueDef]
	var suspects: Array[SuspectDef]
	var checklist_tasks: Array[Dictionary]
	var emergency_button_pos: Vector2

	func _init(p_mode: GameEnums.CampaignMode, p_id: String, p_title: String, p_sub: String,
			   p_loc: String, p_genre: String, p_brief: String, p_obj: String, p_bg: String = "") -> void:
		mode = p_mode
		id = p_id
		title = p_title
		subtitle = p_sub
		location = p_loc
		genre = p_genre
		briefing = p_brief
		primary_objective = p_obj
		bg_texture_path = p_bg
		rooms = []
		corridors = []
		tasks = []
		vents = []
		cameras = []
		clues = []
		suspects = []
		checklist_tasks = []
		emergency_button_pos = Vector2(640, 500)

static func get_campaign(mode: GameEnums.CampaignMode) -> CampaignDef:
	match mode:
		GameEnums.CampaignMode.HOLLOW_CROWN:
			return create_hollow_crown_campaign()
		GameEnums.CampaignMode.BLACKGLASS_STATION:
			return create_blackglass_campaign()
		_:
			return create_hollow_crown_campaign()

# =========================================================================
# 1. CAMPAIGN ONE: THE HOLLOW CROWN (Japanese Mountain Estate Mystery)
# =========================================================================
static func create_hollow_crown_campaign() -> CampaignDef:
	var c := CampaignDef.new(
		GameEnums.CampaignMode.HOLLOW_CROWN,
		"hollow_crown",
		"THE HOLLOW CROWN",
		"A JAPANESE-INSPIRED MYSTERY OF MOONLIGHT & SHADOWS",
		"The Mountain Estate of the Sealed Order",
		"Japanese Historical Noir Mystery",
		"A secluded Japanese mountain estate once guarded an ancient ceremonial relic known as the Hollow Crown. Shortly before the midnight ceremony, the relic disappears. The inner shrine seal remains intact, yet a lantern was moved, and cherry blossoms lie crushed on an empty path. Discover who took the relic, how they bypassed the protections, and why the truth matters.",
		"Find out how the Hollow Crown disappeared without the shrine seal being broken.",
		"res://assets/environments/hollow_crown.png"
	)
	c.primary_bg = Color(0.04, 0.05, 0.08)
	c.border_color = Color(0.85, 0.70, 0.35)
	c.accent_color = Color(0.95, 0.85, 0.55)
	c.hazard_color = Color(0.95, 0.35, 0.25)
	c.cyan_highlight = Color(0.0, 0.88, 1.0)
	c.emergency_button_pos = Vector2(480, 360)

	# Rooms in 1024x576 coordinates (scaled by 1.25 in 1280x720)
	c.rooms = [
		StationData.RoomDef.new("moon_gate", "Moon Gate", "GATE", Rect2(60, 410, 240, 150),
			Color(0.08, 0.07, 0.09), Color(0.35, 0.28, 0.15, 0.35), Color(0.85, 0.65, 0.3), "gate"),
		StationData.RoomDef.new("sakura_courtyard", "Sakura Courtyard", "COURTYARD", Rect2(300, 220, 340, 260),
			Color(0.06, 0.08, 0.09), Color(0.20, 0.40, 0.30, 0.35), Color(0.30, 0.90, 0.60), "tree"),
		StationData.RoomDef.new("tea_room", "The Tea Room", "TEA ROOM", Rect2(750, 180, 260, 190),
			Color(0.10, 0.09, 0.07), Color(0.45, 0.38, 0.20, 0.35), Color(0.95, 0.80, 0.40), "tea"),
		StationData.RoomDef.new("archive", "The Archive", "ARCHIVE", Rect2(560, 390, 250, 170),
			Color(0.09, 0.08, 0.11), Color(0.35, 0.25, 0.45, 0.35), Color(0.65, 0.50, 0.85), "scroll"),
		StationData.RoomDef.new("hidden_passage", "Hidden Passage", "PASSAGE", Rect2(810, 370, 200, 190),
			Color(0.05, 0.05, 0.07), Color(0.20, 0.20, 0.25, 0.35), Color(0.50, 0.55, 0.60), "door"),
		StationData.RoomDef.new("inner_shrine", "The Inner Shrine", "SHRINE", Rect2(440, 50, 380, 170),
			Color(0.12, 0.06, 0.07), Color(0.60, 0.20, 0.15, 0.40), Color(1.0, 0.40, 0.30), "shrine")
	]

	# Checklist tasks matching the screenshot
	c.checklist_tasks = [
		{"id": "garden_path", "title": "Examine the disturbed garden path", "location": "Sakura Courtyard", "done": false},
		{"id": "ceremonial_hall", "title": "Inspect the ceremonial hall", "location": "Inner Shrine", "done": false},
		{"id": "question_attendants", "title": "Question the attendants", "location": "Tea Room", "done": false},
		{"id": "analyze_records", "title": "Analyze the estate records", "location": "Archive", "done": false}
	]

	# Forensic Clues
	c.clues = [
		EchoClueDef.new("clue_garden_path", "Crushed Sakura Petals & Footprint", "sakura_courtyard", Vector2(560, 490),
			GameEnums.EvidenceType.PHYSICAL_TRACE,
			"A trail of fresh cherry blossoms crushed into the stepping stones leading away from the tea room toward the archive wall.",
			"Footprint pattern matches traditional formal zori sandals with a worn left heel.", "kenji", 0.95),
		EchoClueDef.new("clue_inner_shrine", "Untouched Outer Shrine Seal", "inner_shrine", Vector2(980, 420),
			GameEnums.EvidenceType.ENVIRONMENTAL,
			"The ceremonial golden altar stands empty, but the sacred shimenawa rope and external wax seals show zero signs of forced entry.",
			"The thief did not enter via the courtyard steps; an internal secret entrance must exist.", "", 1.0),
		EchoClueDef.new("clue_tea_set", "Untouched Cold Tea Cup", "tea_room", Vector2(250, 460),
			GameEnums.EvidenceType.PHYSICAL_TRACE,
			"A porcelain tea cup poured at ten o'clock sits completely untouched and cold on the low table.",
			"Directly contradicts Kenji's statement that he spent the hour drinking tea with attendants.", "kenji", 0.90),
		EchoClueDef.new("clue_ancient_records", "Sealed Ancestral Clan Scroll", "archive", Vector2(460, 320),
			GameEnums.EvidenceType.PHYSICAL_TRACE,
			"An ancient document revealing the Hollow Crown was original patrimony stolen from Kenji's clan two centuries ago.",
			"Establishes a deep personal motive for reclaiming the heirloom before the sealing ceremony.", "kenji", 1.0),
		EchoClueDef.new("clue_hidden_passage", "Movable Shoji Wall Latch", "hidden_passage", Vector2(370, 380),
			GameEnums.EvidenceType.PHYSICAL_TRACE,
			"A disguised sliding panel behind the archive bookshelf opening directly into the passage beneath the shrine platform.",
			"Dust around the latch has been freshly wiped within the last half hour.", "kenji", 0.98)
	]

	# Suspects with rich authored dialogue & alibis
	c.suspects = [
		SuspectDef.new("aiko", "Aiko", "Shrine Priestess", "Inner Shrine", Vector2(930, 430),
			"res://assets/portraits/aiko.png",
			"The sanctum is peaceful, yet my heart is uneasy. The Hollow Crown is gone, but the sacred threshold was never crossed from outside.",
			"I stood vigil at the Inner Shrine steps from dusk until nine. No one passed through the grand torii gate.",
			"Wishes to protect the temple's sacred honor above all else.", false),
		SuspectDef.new("kenji", "Kenji", "Elder Archivist", "Archive", Vector2(490, 330),
			"res://assets/portraits/kenji.png",
			"I have tended these historical records for forty winters. Why disturb an old scholar when the night demands quiet reflection?",
			"I was in the Tea Room from ten o'clock until midnight studying ceremonial liturgy while Sora served tea.",
			"Believes the Hollow Crown belongs to his ancestral bloodline and sought to reclaim it before it was sealed forever.", true),
		SuspectDef.new("sora", "Sora", "Tea Attendant", "The Tea Room", Vector2(280, 470),
			"res://assets/portraits/sora.png",
			"I prepared fresh matcha for the esteemed guests as instructed. But when I brought the tray to Master Kenji at ten, his seat was vacant.",
			"I remained in the Tea Room preparing ceremonial cups throughout the ninth and tenth bells.",
			"Devoted servant who noticed the master's sudden absence.", false),
		SuspectDef.new("haru", "Haru", "Estate Guardian", "Sakura Courtyard", Vector2(740, 500),
			"res://assets/portraits/haru.png",
			"My blade has guarded this mountain pass for a decade. No stranger entered through the Moon Gate tonight. The thief sleeps under our roof.",
			"Patrolled the perimeter bridge and stone pond from nightfall. Nobody crossed the water.",
			"Fiercely vigilant; determined to expose any traitor inside the estate.", false)
	]

	# Interactive Investigation spots (matching StationData task format)
	c.tasks = [
		StationData.TaskSpotDef.new(0, GameEnums.TaskType.CLEAR_ASTEROID_DATA, "Examine Disturbed Garden Path", "sakura_courtyard", "Sakura Courtyard", Vector2(560, 490), "Inspect crushed petals and sandals prints in the garden."),
		StationData.TaskSpotDef.new(1, GameEnums.TaskType.DECIPHER_GLYPHS, "Inspect Shrine Ceremonial Altar", "inner_shrine", "Inner Shrine", Vector2(980, 420), "Examine the empty relic display and outer seals."),
		StationData.TaskSpotDef.new(2, GameEnums.TaskType.DECODE_WAVEFORM, "Examine Tea Set & Cushions", "tea_room", "The Tea Room", Vector2(250, 460), "Check the tea table and cold tea cup."),
		StationData.TaskSpotDef.new(3, GameEnums.TaskType.UPLOAD_RESEARCH_LOGS, "Analyze Estate Historical Scrolls", "archive", "The Archive", Vector2(460, 320), "Search the bookshelf for clan chronicles."),
		StationData.TaskSpotDef.new(4, GameEnums.TaskType.FIX_WIRING, "Inspect Movable Shoji Latch", "hidden_passage", "Hidden Passage", Vector2(370, 380), "Examine the concealed sliding wall mechanism.")
	]

	# Estate Sentry Observation Lanterns & Torii Overlooks
	c.cameras = [
		StationData.CameraDef.new(0, "Moon Gate Sentry Lantern", Vector2(430, 600), 0.0),
		StationData.CameraDef.new(1, "Courtyard Garden Arch", Vector2(560, 490), 1.57),
		StationData.CameraDef.new(2, "Inner Shrine Torii Overlook", Vector2(980, 420), 3.14),
		StationData.CameraDef.new(3, "Tea Room Veranda View", Vector2(250, 460), -1.57)
	]

	return c

# =========================================================================
# 2. CAMPAIGN TWO: BLACKGLASS STATION (Orbital Spacecraft Mystery)
# =========================================================================
static func create_blackglass_campaign() -> CampaignDef:
	var c := CampaignDef.new(
		GameEnums.CampaignMode.BLACKGLASS_STATION,
		"blackglass_station",
		"BLACKGLASS STATION",
		"A SCIENCE-FICTION MYSTERY ABOARD A SILENT SPACECRAFT",
		"Research Vessel Blackglass // Deck A",
		"Sci-Fi Closed-Circle Mystery & Psychological Noir",
		"The research vessel Blackglass carries a classified prototype capable of recording anomalous cosmic signatures. During a routine orbital night cycle, power abruptly cuts out. When auxiliary lights ignite, the laboratory containment chamber stands ruptured, the prototype is gone, and security access logs have been scrubbed. Reconstruct the blackout timeline and isolate the saboteur before extraction.",
		"Investigate the missing prototype & reconstruct the blackout incident.",
		"res://assets/environments/blackglass.png"
	)
	c.primary_bg = Color(0.03, 0.04, 0.07)
	c.border_color = Color(0.30, 0.55, 0.75)
	c.accent_color = Color(0.0, 0.88, 1.0)
	c.hazard_color = Color(1.0, 0.25, 0.30)
	c.cyan_highlight = Color(0.0, 0.95, 1.0)
	c.emergency_button_pos = Vector2(400, 420)

	# Rooms in 1024x576 coordinates (scaled by 1.25 in 1280x720)
	c.rooms = [
		StationData.RoomDef.new("observation_lounge", "Observation Lounge", "LOUNGE", Rect2(200, 40, 580, 180),
			Color(0.06, 0.08, 0.12), Color(0.15, 0.35, 0.55, 0.35), Color(0.0, 0.85, 1.0), "window"),
		StationData.RoomDef.new("crew_quarters", "Crew Quarters", "QUARTERS", Rect2(40, 240, 260, 160),
			Color(0.08, 0.07, 0.06), Color(0.35, 0.28, 0.15, 0.35), Color(0.85, 0.65, 0.3), "bed"),
		StationData.RoomDef.new("central_corridor", "Corridor Deck A-1", "CORRIDOR", Rect2(330, 230, 140, 310),
			Color(0.05, 0.06, 0.09), Color(0.20, 0.25, 0.35, 0.30), Color(0.50, 0.65, 0.80), "hall"),
		StationData.RoomDef.new("engineering_bay", "Engineering Bay", "ENGINEERING", Rect2(40, 410, 270, 150),
			Color(0.10, 0.06, 0.06), Color(0.55, 0.20, 0.15, 0.35), Color(1.0, 0.35, 0.25), "gear"),
		StationData.RoomDef.new("research_lab", "Research Laboratory", "LAB", Rect2(500, 230, 480, 310),
			Color(0.05, 0.08, 0.10), Color(0.10, 0.45, 0.45, 0.40), Color(0.0, 0.95, 0.85), "flask")
	]

	# Checklist tasks matching the screenshot
	c.checklist_tasks = [
		{"id": "examine_chamber", "title": "Examine the lab containment chamber", "location": "Research Lab", "done": false},
		{"id": "review_records", "title": "Review security records", "location": "Observation Deck A", "done": false},
		{"id": "talk_crew", "title": "Talk to the crew in Observation Lounge", "location": "Observation Deck A", "done": false},
		{"id": "inspect_reactor", "title": "Inspect reactor power routing", "location": "Engineering Bay", "done": false}
	]

	# Forensic Clues
	c.clues = [
		EchoClueDef.new("clue_containment_chamber", "Severed Containment Interlock", "research_lab", Vector2(720, 430),
			GameEnums.EvidenceType.PHYSICAL_TRACE,
			"The heavy cryogenic specimen cylinder is unsealed. The bypass circuit was professionally severed with a pilot's ceramic laser-cutter.",
			"Chemical residue reveals Vance's flight suit solvent and a severed security wire.", "vance", 0.98),
		EchoClueDef.new("clue_scrubbed_logs", "Scrubbed Security Access Feed", "observation_lounge", Vector2(510, 215),
			GameEnums.EvidenceType.DIGITAL_RECORD,
			"Terminal records show a 4-minute telemetry gap during the blackout. However, backup auxiliary RAM logged Vance's keycard at 21:08.",
			"Directly contradicts Vance's claim that he was asleep in his bunk cabin during the incident.", "vance", 0.95),
		EchoClueDef.new("clue_manual_surge", "Manual Circuit Surge Override", "engineering_bay", Vector2(780, 640),
			GameEnums.EvidenceType.ENVIRONMENTAL,
			"The station blackout was not caused by an external solar flare; the circuit breaker was manually tripped from an auxiliary terminal.",
			"Requires flight navigation clearance to route power away from the research lab.", "vance", 0.92),
		EchoClueDef.new("clue_flight_orders", "Encrypted Orbital Extraction Order", "crew_quarters", Vector2(310, 435),
			GameEnums.EvidenceType.DIGITAL_RECORD,
			"A personal datapad hidden beneath the bunk mattress detailing an off-station rendezvous with an unidentified extraction vessel.",
			"Confirms the prototype was targeted for private corporate espionage.", "vance", 1.0)
	]

	# Suspects with rich authored dialogue & alibis
	c.suspects = [
		SuspectDef.new("elara", "Dr. Elara", "Chief Xenologist", "Observation Lounge", Vector2(620, 435),
			"res://assets/portraits/elara.png",
			"The prototype was the culmination of five years of research. Whoever stole it knew exactly which primary conduit to short out.",
			"I was reviewing orbital telemetry with Kael here on Deck A when the lighting system plunged into total darkness.",
			"Devoted scientist devastated by the loss of the containment specimen.", false),
		SuspectDef.new("kael", "Kael", "Operations & Security Officer", "Observation Lounge", Vector2(560, 210),
			"res://assets/portraits/kael.png",
			"I've sealed all external airlocks. No one leaves this deck until we locate the prototype and cuff the perpetrator.",
			"I stood watch over the lounge panorama. I noticed the power dip immediately and ordered an internal diagnostic.",
			"Strict security officer determined to keep order on the vessel.", false),
		SuspectDef.new("vance", "Vance", "Shuttle Pilot", "Crew Quarters", Vector2(250, 435),
			"res://assets/portraits/vance.png",
			"I'm just a pilot hauling cargo across deep space. You researchers deal with the glowing artifacts; leave me out of your witch hunt.",
			"I was sound asleep in my bunk in Crew Quarters from 20:30 until the emergency sirens blared at 21:15.",
			"Cynical pilot hired by a rival syndicate to intercept the prototype during transit.", true),
		SuspectDef.new("lyra", "Lyra", "Systems & Reactor Engineer", "Engineering Bay", Vector2(320, 640),
			"res://assets/portraits/lyra.png",
			"The reactor core is stable now. But that power interruption? That was no accident. Someone intentionally redirected the secondary bus.",
			"I was locked in the lower reactor tube fixing coolant pressure when the surge occurred.",
			"Expert engineer whose diagnostics pinpoint the manual power tampering.", false)
	]

	# Interactive Investigation spots (matching StationData task format)
	c.tasks = [
		StationData.TaskSpotDef.new(0, GameEnums.TaskType.DECIPHER_GLYPHS, "Examine Containment Chamber", "research_lab", "Research Laboratory", Vector2(720, 430), "Analyze the unsealed specimen cylinder and chemical traces."),
		StationData.TaskSpotDef.new(1, GameEnums.TaskType.UPLOAD_RESEARCH_LOGS, "Review Security Access Records", "observation_lounge", "Observation Lounge", Vector2(510, 215), "Inspect auxiliary telemetry and terminal logs."),
		StationData.TaskSpotDef.new(2, GameEnums.TaskType.DIVERT_POWER, "Inspect Circuit Breaker Surge", "engineering_bay", "Engineering Bay", Vector2(780, 640), "Verify the manual circuit overload bus."),
		StationData.TaskSpotDef.new(3, GameEnums.TaskType.RUN_MEDICAL_SCAN, "Search Pilot Bunk Quarters", "crew_quarters", "Crew Quarters", Vector2(310, 435), "Search Vance's personal desk and mattress."),
		StationData.TaskSpotDef.new(4, GameEnums.TaskType.CLEAR_ASTEROID_DATA, "Calibrate Long-Range Sensors", "observation_lounge", "Observation Lounge", Vector2(760, 210), "Align the deep-space sensor array with the outer perimeter.")
	]

	# Shipboard Optical CCTV & Sensor Feeds
	c.cameras = [
		StationData.CameraDef.new(0, "Observation Lounge Cam Alpha", Vector2(510, 160), 0.0),
		StationData.CameraDef.new(1, "Observation Lounge Cam Beta", Vector2(760, 160), 1.57),
		StationData.CameraDef.new(2, "Research Lab Containment Cam", Vector2(720, 370), 3.14),
		StationData.CameraDef.new(3, "Engineering Bay Power Cam", Vector2(780, 590), -1.57)
	]

	return c
