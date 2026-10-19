class_name CampaignData
extends RefCounted

## Definitive Campaign & Story Mode Definitions for VOIDSHIFT.
## Implements the three original story modes specified in the master production brief:
## 1. THE HOLLOW CROWN (Archaeological Sci-Fi Mystery)
## 2. BLACKGLASS STATION (Closed-Circle Forensic Mystery & Noir)
## 3. THE LAST SIGNAL (Polar Survival & Temporal Echo Mystery)

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

	func _init(p_id: String, p_name: String, p_room: String, p_pos: Vector2,
			   p_type: GameEnums.EvidenceType, p_desc: String, p_detail: String, p_rel: float = 1.0) -> void:
		id = p_id
		name = p_name
		room_id = p_room
		position = p_pos
		evidence_type = p_type
		description = p_desc
		forensic_detail = p_detail
		reliability = p_rel
		is_collected = false

class CampaignDef:
	var mode: GameEnums.CampaignMode
	var id: String
	var title: String
	var subtitle: String
	var location: String
	var genre: String
	var briefing: String
	var primary_objective: String
	
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
	var emergency_button_pos: Vector2

	func _init(p_mode: GameEnums.CampaignMode, p_id: String, p_title: String, p_sub: String,
			   p_loc: String, p_genre: String, p_brief: String, p_obj: String) -> void:
		mode = p_mode
		id = p_id
		title = p_title
		subtitle = p_sub
		location = p_loc
		genre = p_genre
		briefing = p_brief
		primary_objective = p_obj
		rooms = []
		corridors = []
		tasks = []
		vents = []
		cameras = []
		clues = []
		emergency_button_pos = Vector2(800, 1060)

static func get_campaign(mode: GameEnums.CampaignMode) -> CampaignDef:
	match mode:
		GameEnums.CampaignMode.HOLLOW_CROWN:
			return create_hollow_crown_campaign()
		GameEnums.CampaignMode.BLACKGLASS_STATION:
			return create_blackglass_campaign()
		GameEnums.CampaignMode.THE_LAST_SIGNAL:
			return create_last_signal_campaign()
		_:
			return create_hollow_crown_campaign()

# =========================================================================
# 1. CAMPAIGN ONE: THE HOLLOW CROWN (Archaeological Sci-Fi Mystery)
# =========================================================================
static func create_hollow_crown_campaign() -> CampaignDef:
	var c := CampaignDef.new(
		GameEnums.CampaignMode.HOLLOW_CROWN,
		"hollow_crown",
		"THE HOLLOW CROWN",
		"ANCIENT BURIED ALIEN VAULT",
		"Xeno-Excavation Sub-Sector Theta",
		"Archaeological Science-Fiction Mystery",
		"A subterranean expedition team enters a buried alien complex beneath an abandoned excavation site. Activate the three resonance mechanisms, recover the lost expedition's archives, and unseal the Hollow Vault before the saboteur collapses the sanctum.",
		"Activate 3 ancient mechanisms & recover the Hollow Crown artifact."
	)
	# Palette: Ink black, aged ivory, stone grey, antique gold, restrained cyan
	c.primary_bg = Color(0.04, 0.04, 0.06)
	c.border_color = Color(0.72, 0.60, 0.35) # Antique Gold
	c.accent_color = Color(0.85, 0.75, 0.50) # Muted Sand / Gold
	c.hazard_color = Color(0.95, 0.45, 0.15)
	c.cyan_highlight = Color(0.0, 0.85, 0.95)

	# Distinctive Ancient Complex Rooms (1600 x 1200 world coordinates)
	c.rooms = [
		StationData.RoomDef.new("arrival_shelf", "Arrival Shelf", "ARRIVAL", Rect2(580, 50, 440, 220),
			Color(0.09, 0.08, 0.07), Color(0.35, 0.28, 0.15, 0.35), Color(0.85, 0.65, 0.3), "landing"),
		StationData.RoomDef.new("inscription_gallery", "Inscription Gallery", "GALLERY", Rect2(100, 320, 380, 260),
			Color(0.10, 0.09, 0.08), Color(0.40, 0.32, 0.18, 0.35), Color(0.90, 0.70, 0.35), "stone"),
		StationData.RoomDef.new("central_nexus", "Excavation Nexus", "NEXUS", Rect2(540, 330, 520, 260),
			Color(0.08, 0.08, 0.09), Color(0.30, 0.25, 0.20, 0.30), Color(0.75, 0.65, 0.4), "pillar"),
		StationData.RoomDef.new("buried_archive", "Buried Archive", "ARCHIVE", Rect2(1120, 320, 380, 260),
			Color(0.09, 0.08, 0.11), Color(0.35, 0.25, 0.45, 0.35), Color(0.65, 0.50, 0.85), "tablet"),
		StationData.RoomDef.new("resonance_chamber", "Resonance Chamber", "RESONANCE", Rect2(100, 640, 380, 270),
			Color(0.11, 0.08, 0.07), Color(0.55, 0.25, 0.10, 0.40), Color(0.95, 0.55, 0.20), "ring"),
		StationData.RoomDef.new("power_conduits", "Sub-Power Grid", "CONDUITS", Rect2(540, 650, 240, 250),
			Color(0.10, 0.09, 0.06), Color(0.45, 0.35, 0.12, 0.35), Color(0.95, 0.80, 0.25), "bolt"),
		StationData.RoomDef.new("tool_depot", "Excavation Depot", "DEPOT", Rect2(820, 650, 240, 250),
			Color(0.08, 0.08, 0.09), Color(0.25, 0.25, 0.30, 0.25), Color(0.60, 0.65, 0.70), "tools"),
		StationData.RoomDef.new("survey_post", "Survey Command", "SURVEY", Rect2(1120, 650, 380, 250),
			Color(0.07, 0.09, 0.11), Color(0.15, 0.35, 0.45, 0.35), Color(0.20, 0.85, 0.90), "eye"),
		StationData.RoomDef.new("hollow_vault", "The Hollow Vault", "VAULT", Rect2(540, 960, 520, 210),
			Color(0.06, 0.07, 0.10), Color(0.15, 0.45, 0.65, 0.45), Color(0.0, 0.85, 1.0), "crown")
	]

	c.corridors = StationData.get_corridors()
	c.vents = StationData.get_vents()
	c.emergency_button_pos = Vector2(800, 1060)

	# Sector Tasks for Hollow Crown
	c.tasks = [
		StationData.TaskSpotDef.new(0, GameEnums.TaskType.CALIBRATE_NAVIGATION, "Align Navigational Beacon", "arrival_shelf", "Arrival Shelf", Vector2(800, 110), "Calibrate the extraction beacon transponder."),
		StationData.TaskSpotDef.new(1, GameEnums.TaskType.DECIPHER_GLYPHS, "Decipher Ancient Glyphs", "inscription_gallery", "Inscription Gallery", Vector2(240, 450), "Align glyph matrices to unlock acoustic keys."),
		StationData.TaskSpotDef.new(2, GameEnums.TaskType.DIVERT_POWER, "Recharge Power Conduits", "power_conduits", "Sub-Power Grid", Vector2(660, 770), "Divert geothermal battery cells to vault gates."),
		StationData.TaskSpotDef.new(3, GameEnums.TaskType.HARMONIZE_RESONANCE, "Harmonize Resonance Plates", "resonance_chamber", "Resonance Chamber", Vector2(290, 770), "Balance magnetic plates on the ancient mechanism."),
		StationData.TaskSpotDef.new(4, GameEnums.TaskType.UPLOAD_RESEARCH_LOGS, "Extract Archive Tablets", "buried_archive", "Buried Archive", Vector2(1310, 450), "Recover damaged audio logs left by Expedition Omega."),
		StationData.TaskSpotDef.new(5, GameEnums.TaskType.FIX_WIRING, "Repair Sensor Triangulators", "survey_post", "Survey Command", Vector2(1310, 770), "Restore seismic motion detector circuits.")
	]

	# Echo Vision Forensic Clues (Hidden until inspected with Echo Vision [Q])
	c.clues = [
		EchoClueDef.new("clue_dust", "Disturbed Sand Strata", "hollow_vault", Vector2(720, 1020), GameEnums.EvidenceType.PHYSICAL_TRACE,
			"Heavy magnetic boot tracks leading away from the central vault dais.", "Tread pattern matches standard expedition boots. Footsteps lead north toward Conduits.", 0.95),
		EchoClueDef.new("clue_chisel", "Pried Mechanism Casing", "resonance_chamber", Vector2(340, 720), GameEnums.EvidenceType.PHYSICAL_TRACE,
			"Fresh metal gouges on the resonance harmonic housing.", "Pried with an excavation crowbar within the past 15 minutes. Deliberate sabotage of the acoustic balance.", 0.90),
		EchoClueDef.new("clue_audio_omega", "Fragmented Audio Log", "buried_archive", Vector2(1250, 420), GameEnums.EvidenceType.DIGITAL_RECORD,
			"Expedition Omega last transmission: 'The second seal was opened from inside...'", "Corroborates that a previous saboteur trapped the original team inside the vault.", 0.85),
		EchoClueDef.new("clue_geothermal", "Coolant Line Siphon", "power_conduits", Vector2(700, 720), GameEnums.EvidenceType.ENVIRONMENTAL,
			"Valve #3 cracked open, dumping coolant into the lower trench.", "Intended to cause thermal overload and trigger an emergency sanctum seal.", 0.92)
	]

	c.cameras = [
		StationData.CameraDef.new(0, "Arrival Shelf Sensor", Vector2(800, 260), PI * 0.5, 1.1),
		StationData.CameraDef.new(1, "Gallery Seismic Sensor", Vector2(490, 470), PI, 1.0),
		StationData.CameraDef.new(2, "Archive Optical Sensor", Vector2(1070, 470), 0.0, 1.0),
		StationData.CameraDef.new(3, "Conduit Motion Sensor", Vector2(740, 660), PI * 0.5, 1.0),
		StationData.CameraDef.new(4, "Survey Command Array", Vector2(1200, 680), PI * 0.5, 1.0),
		StationData.CameraDef.new(5, "Vault Relic Sensor", Vector2(800, 970), PI * 0.5, 1.2)
	]

	return c

# =========================================================================
# 2. CAMPAIGN TWO: BLACKGLASS STATION (Closed-Circle Forensic Mystery)
# =========================================================================
static func create_blackglass_campaign() -> CampaignDef:
	var c := CampaignDef.new(
		GameEnums.CampaignMode.BLACKGLASS_STATION,
		"blackglass_station",
		"BLACKGLASS STATION",
		"CLOSED-CIRCLE FORENSIC INVESTIGATION",
		"DSS Chronos Deep Orbit Outpost",
		"Psychological Noir & Forensic Mystery",
		"Senior Scientist Dr. Aris Thorne is found dead in the bio-containment lab minutes before the experimental singularity drive test. Security feeds are purged. Access logs disagree with witness claims. Determine who tampered with the logs and prevent orbital meltdown.",
		"Reconstruct timeline of Dr. Thorne's death & isolate the saboteur."
	)
	# Palette: Charcoal, steel grey, cold ivory, electric cyan, rare crimson
	c.primary_bg = Color(0.03, 0.05, 0.08)
	c.border_color = Color(0.15, 0.55, 0.85) # Cold Steel / Electric Cyan
	c.accent_color = Color(0.0, 0.85, 1.0)
	c.hazard_color = Color(1.0, 0.25, 0.25) # Crimson Danger
	c.cyan_highlight = Color(0.1, 0.95, 0.85)

	c.rooms = [
		StationData.RoomDef.new("command_deck", "Command Deck", "COMMAND", Rect2(580, 50, 440, 220),
			Color(0.06, 0.09, 0.14), Color(0.10, 0.35, 0.65, 0.40), Color(0.0, 0.85, 1.0), "bridge"),
		StationData.RoomDef.new("research_lab", "Research Laboratory", "INCIDENT LAB", Rect2(100, 320, 380, 260),
			Color(0.08, 0.11, 0.14), Color(0.15, 0.50, 0.45, 0.35), Color(0.15, 0.90, 0.70), "flask"),
		StationData.RoomDef.new("central_hub", "Main Concourse", "CONCOURSE", Rect2(540, 330, 520, 260),
			Color(0.07, 0.10, 0.13), Color(0.12, 0.35, 0.55, 0.30), Color(0.0, 0.80, 1.0), "hub"),
		StationData.RoomDef.new("surveillance_gallery", "Surveillance Gallery", "SECURITY", Rect2(1120, 320, 380, 260),
			Color(0.08, 0.08, 0.14), Color(0.20, 0.30, 0.60, 0.35), Color(0.40, 0.75, 1.0), "shield"),
		StationData.RoomDef.new("reactor_spine", "Singularity Reactor Spine", "REACTOR", Rect2(100, 640, 380, 270),
			Color(0.12, 0.05, 0.08), Color(0.70, 0.15, 0.30, 0.40), Color(1.0, 0.25, 0.35), "warning"),
		StationData.RoomDef.new("electrical", "Power Distribution", "POWER", Rect2(540, 650, 240, 250),
			Color(0.11, 0.10, 0.06), Color(0.55, 0.45, 0.10, 0.35), Color(1.0, 0.85, 0.20), "bolt"),
		StationData.RoomDef.new("storage", "Cryo Storage", "STORAGE", Rect2(820, 650, 240, 250),
			Color(0.07, 0.09, 0.11), Color(0.25, 0.35, 0.45, 0.25), Color(0.50, 0.70, 0.85), "box"),
		StationData.RoomDef.new("habitation_ring", "Habitation Ring", "HABITATION", Rect2(1120, 650, 380, 250),
			Color(0.07, 0.08, 0.12), Color(0.15, 0.25, 0.45, 0.35), Color(0.35, 0.65, 0.95), "bunk"),
		StationData.RoomDef.new("meeting", "Briefing Amphitheater", "BRIEFING", Rect2(540, 960, 520, 210),
			Color(0.06, 0.09, 0.13), Color(0.15, 0.45, 0.75, 0.40), Color(0.0, 0.85, 1.0), "star")
	]

	c.corridors = StationData.get_corridors()
	c.vents = StationData.get_vents()
	c.emergency_button_pos = Vector2(800, 1060)

	c.tasks = [
		StationData.TaskSpotDef.new(0, GameEnums.TaskType.CALIBRATE_NAVIGATION, "Re-align Comms Gyro", "command_deck", "Command Deck", Vector2(800, 110), "Restore encrypted comms link to Earth Command."),
		StationData.TaskSpotDef.new(1, GameEnums.TaskType.RUN_MEDICAL_SCAN, "Inspect Lab Bio-Specimen", "research_lab", "Research Laboratory", Vector2(240, 450), "Sample toxicological traces from the incident scene."),
		StationData.TaskSpotDef.new(2, GameEnums.TaskType.DIVERT_POWER, "Fix Circuit Breakers", "electrical", "Power Distribution", Vector2(660, 770), "Reroute power away from tampered junction boxes."),
		StationData.TaskSpotDef.new(3, GameEnums.TaskType.STABILIZE_REACTOR, "Stabilize Singularity Spine", "reactor_spine", "Singularity Reactor Spine", Vector2(290, 770), "Balance magnetic flux to prevent containment leak."),
		StationData.TaskSpotDef.new(4, GameEnums.TaskType.UPLOAD_RESEARCH_LOGS, "Review Surveillance Logs", "surveillance_gallery", "Surveillance Gallery", Vector2(1310, 450), "Recover deleted CCTV frames between 03:00 and 03:15."),
		StationData.TaskSpotDef.new(5, GameEnums.TaskType.FIX_WIRING, "Service Habitation Filtration", "habitation_ring", "Habitation Ring", Vector2(1310, 770), "Flush air scrubber intake conduits.")
	]

	c.clues = [
		EchoClueDef.new("clue_dr_thorne", "Shattered Bio-Vial Residue", "research_lab", Vector2(210, 420), GameEnums.EvidenceType.PHYSICAL_TRACE,
			"Glass fragments laced with synthetic neurotoxin found next to Thorne's workstation.", "Analysis confirms rapid respiratory failure within 90 seconds. Murder weapon identified.", 0.98),
		EchoClueDef.new("clue_scrubbed_log", "Scrubbed Access Timestamp", "surveillance_gallery", Vector2(1280, 400), GameEnums.EvidenceType.DIGITAL_RECORD,
			"Security entry at 03:12 was forcefully deleted using root engineering override.", "Only an Engineer or someone with Vance's stolen maintenance credentials could execute this purge.", 0.90),
		EchoClueDef.new("clue_keycard", "Dropped Guest Keycard", "habitation_ring", Vector2(1200, 720), GameEnums.EvidenceType.PHYSICAL_TRACE,
			"Security Level 3 keycard wedged behind bunk #4.", "Fingerprint traces match Commander Rex's assistant. Indicates covert meeting held prior to murder.", 0.85),
		EchoClueDef.new("clue_reactor_override", "Reactor Bypass Jumper", "reactor_spine", Vector2(340, 720), GameEnums.EvidenceType.ENVIRONMENTAL,
			"Unauthorized hardware jumper forcing magnetic confinement to 118% load.", "Configured to trigger catastrophic meltdown if containment doors are locked.", 0.95)
	]

	c.cameras = StationData.get_cameras()
	return c

# =========================================================================
# 3. CAMPAIGN THREE: THE LAST SIGNAL (Polar Survival & Temporal Echoes)
# =========================================================================
static func create_last_signal_campaign() -> CampaignDef:
	var c := CampaignDef.new(
		GameEnums.CampaignMode.THE_LAST_SIGNAL,
		"last_signal",
		"THE LAST SIGNAL",
		"POLAR SUB-ICE TEMPORAL ANOMALY",
		"Outpost Erebus • Antarctic Sub-Glacial Well",
		"Polar Survival & Atmospheric Sci-Fi",
		"An isolated research station over a subterranean acoustic anomaly detects a repeating signal from beneath the ice shelf. Temporal echo anomalies begin manifesting. Recover signal fragments and determine whether to broadcast, contain, or destroy the signal before polar freeze.",
		"Analyze the temporal echo signal & survive polar blizzard collapse."
	)
	# Palette: Ink black, snow ivory, desaturated blue-grey, pale cyan, warning amber
	c.primary_bg = Color(0.02, 0.04, 0.07)
	c.border_color = Color(0.40, 0.65, 0.85) # Glacial Ice Blue
	c.accent_color = Color(0.65, 0.85, 0.98) # Snow Ivory
	c.hazard_color = Color(1.0, 0.65, 0.15) # Warning Amber
	c.cyan_highlight = Color(0.20, 0.90, 1.0)

	c.rooms = [
		StationData.RoomDef.new("storm_landing", "Storm Landing Pad", "LANDING", Rect2(580, 50, 440, 220),
			Color(0.06, 0.08, 0.12), Color(0.25, 0.45, 0.65, 0.40), Color(0.70, 0.90, 1.0), "wind"),
		StationData.RoomDef.new("signal_lab", "Signal Laboratory", "SIGNAL LAB", Rect2(100, 320, 380, 260),
			Color(0.05, 0.07, 0.11), Color(0.20, 0.40, 0.60, 0.35), Color(0.0, 0.85, 1.0), "wave"),
		StationData.RoomDef.new("central_hub", "Main Atrium", "ATRIUM", Rect2(540, 330, 520, 260),
			Color(0.05, 0.07, 0.10), Color(0.15, 0.30, 0.45, 0.30), Color(0.50, 0.75, 0.95), "hub"),
		StationData.RoomDef.new("ice_shaft", "Ice Gantry Shaft", "ICE SHAFT", Rect2(1120, 320, 380, 260),
			Color(0.04, 0.07, 0.11), Color(0.30, 0.55, 0.75, 0.35), Color(0.60, 0.85, 1.0), "ladder"),
		StationData.RoomDef.new("geothermal_core", "Geothermal Plant", "HEAT CORE", Rect2(100, 640, 380, 270),
			Color(0.10, 0.07, 0.05), Color(0.60, 0.35, 0.15, 0.40), Color(1.0, 0.65, 0.20), "flame"),
		StationData.RoomDef.new("thermal_conduits", "Sub-Ice Heaters", "HEATERS", Rect2(540, 650, 240, 250),
			Color(0.09, 0.08, 0.06), Color(0.50, 0.40, 0.15, 0.35), Color(0.95, 0.75, 0.20), "radiator"),
		StationData.RoomDef.new("cargo_trench", "Frozen Depot", "CARGO", Rect2(820, 650, 240, 250),
			Color(0.06, 0.07, 0.09), Color(0.20, 0.30, 0.40, 0.25), Color(0.55, 0.70, 0.85), "box"),
		StationData.RoomDef.new("habitat_module", "Crew Habitat", "HABITAT", Rect2(1120, 650, 380, 250),
			Color(0.05, 0.07, 0.10), Color(0.15, 0.30, 0.50, 0.35), Color(0.40, 0.75, 1.0), "bunk"),
		StationData.RoomDef.new("resonance_well", "Sub-Ice Resonance Well", "THE WELL", Rect2(540, 960, 520, 210),
			Color(0.03, 0.06, 0.10), Color(0.10, 0.40, 0.70, 0.45), Color(0.0, 0.85, 1.0), "crystal")
	]

	c.corridors = StationData.get_corridors()
	c.vents = StationData.get_vents()
	c.emergency_button_pos = Vector2(800, 1060)

	c.tasks = [
		StationData.TaskSpotDef.new(0, GameEnums.TaskType.CLEAR_ASTEROID_DATA, "De-ice Solar Tracking Array", "storm_landing", "Storm Landing Pad", Vector2(800, 110), "Clear frozen sleet from solar tracker servos."),
		StationData.TaskSpotDef.new(1, GameEnums.TaskType.DECODE_WAVEFORM, "Decode Acoustic Harmonic", "signal_lab", "Signal Laboratory", Vector2(240, 450), "Align spectrogram bands with the sub-ice monolith signal."),
		StationData.TaskSpotDef.new(2, GameEnums.TaskType.DIVERT_POWER, "Cycle Thermal Line Valves", "thermal_conduits", "Sub-Ice Heaters", Vector2(660, 770), "Prevent conduit fluid from freezing solid."),
		StationData.TaskSpotDef.new(3, GameEnums.TaskType.STABILIZE_REACTOR, "Stabilize Geothermal Pump", "geothermal_core", "Geothermal Plant", Vector2(290, 770), "Adjust steam turbine pressure balance."),
		StationData.TaskSpotDef.new(4, GameEnums.TaskType.DEICE_SERVO, "De-ice Gantry Winch", "ice_shaft", "Ice Gantry Shaft", Vector2(1310, 450), "Warm frozen hydraulic lift cables."),
		StationData.TaskSpotDef.new(5, GameEnums.TaskType.FIX_WIRING, "Repair Thermal Scrubbers", "habitat_module", "Crew Habitat", Vector2(1310, 770), "Reconnect frozen heating coils in living quarters.")
	]

	c.clues = [
		EchoClueDef.new("clue_temporal_tape", "Temporal Echo Recording", "signal_lab", Vector2(220, 410), GameEnums.EvidenceType.TEMPORAL_ECHO,
			"A recording of the facility's airlock alarm timestamped 20 minutes in the FUTURE.", "Proves the monolith's acoustic pulses are warping localized quantum causality.", 0.99),
		EchoClueDef.new("clue_cut_cable", "Severed Relay Cable", "storm_landing", Vector2(720, 150), GameEnums.EvidenceType.PHYSICAL_TRACE,
			"Thermal-sheared high-voltage antenna feed line.", "Cut with laser pliers from the station's own machine shop to block distress transmission.", 0.92),
		EchoClueDef.new("clue_frost_boot", "Frozen Bootprints in Restricted Trench", "ice_shaft", Vector2(1200, 420), GameEnums.EvidenceType.PHYSICAL_TRACE,
			"Solo boot tracks descending into the unmapped glacial rift.", "Prints show a limp matching crew member Silas after the storm incident.", 0.88),
		EchoClueDef.new("clue_crystal_hum", "Monolith Harmonic Vibration", "resonance_well", Vector2(750, 1040), GameEnums.EvidenceType.ENVIRONMENTAL,
			"Sub-ice crystalline monolith vibrating at 432 Hz.", "Resonance accelerates whenever human life signs approach within 8 meters.", 0.95)
	]

	c.cameras = [
		StationData.CameraDef.new(0, "Landing Wind Sensor", Vector2(800, 260), PI * 0.5, 1.1),
		StationData.CameraDef.new(1, "Signal Lab Scope Cam", Vector2(490, 470), PI, 1.0),
		StationData.CameraDef.new(2, "Ice Shaft Thermal Cam", Vector2(1070, 470), 0.0, 1.0),
		StationData.CameraDef.new(3, "Thermal Conduit Monitor", Vector2(740, 660), PI * 0.5, 1.0),
		StationData.CameraDef.new(4, "Habitat Cam", Vector2(1200, 680), PI * 0.5, 1.0),
		StationData.CameraDef.new(5, "Resonance Well Probe", Vector2(800, 970), PI * 0.5, 1.2)
	]

	return c
