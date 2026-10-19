class_name RoleAllocator
extends RefCounted

## Autonomous & Randomized Role Allocation System for VOIDSHIFT.
## Fulfills Part V (Pillar C & Section 14) of the Master Game Production Specification:
## - Manages a full 10-person expedition roster (1 local human player + 9 AI crew)
## - Genuinely shuffles and assigns roles with zero manual player preference
## - Generates tailored secret objectives for Crew Specialists and Saboteurs
## - Supports deterministic seeds for unit tests and reproducible QA runs

const GameEnums = preload("res://scripts/core/GameEnums.gd")

class RoleAssignment:
	var character_id: int
	var character_name: String
	var is_player: bool
	var role: GameEnums.Role
	var role_title: String
	var role_badge: String
	var role_description: String
	var is_saboteur: bool
	var secret_objective: String
	var special_ability: String
	var spawn_position: Vector2

	func _init(p_id: int, p_name: String, p_is_player: bool, p_role: GameEnums.Role,
			   p_title: String, p_badge: String, p_desc: String, p_is_sab: bool,
			   p_obj: String, p_ability: String, p_pos: Vector2) -> void:
		character_id = p_id
		character_name = p_name
		is_player = p_is_player
		role = p_role
		role_title = p_title
		role_badge = p_badge
		role_description = p_desc
		is_saboteur = p_is_sab
		secret_objective = p_obj
		special_ability = p_ability
		spawn_position = p_pos

static func allocate_roles(campaign_mode: GameEnums.CampaignMode, seed_val: int = -1) -> Array[RoleAssignment]:
	var rng := RandomNumberGenerator.new()
	if seed_val >= 0:
		rng.seed = seed_val
	else:
		rng.randomize()

	# 1. Ten Expedition Members Roster (tailored to selected campaign)
	var roster: Array[Dictionary] = []
	if campaign_mode == GameEnums.CampaignMode.HOLLOW_CROWN:
		roster = [
			{"name": "Rex", "title": "Guest Investigator", "pos": Vector2(560, 480)},
			{"name": "Aiko", "title": "Shrine Priestess", "pos": Vector2(930, 430)},
			{"name": "Kenji", "title": "Elder Archivist", "pos": Vector2(490, 330)},
			{"name": "Sora", "title": "Tea Attendant", "pos": Vector2(280, 470)},
			{"name": "Haru", "title": "Estate Guardian", "pos": Vector2(740, 500)},
			{"name": "Ren", "title": "Senior Protector", "pos": Vector2(380, 590)},
			{"name": "Chiyo", "title": "Estate Herbalist", "pos": Vector2(620, 450)},
			{"name": "Kaede", "title": "Ritual Specialist", "pos": Vector2(880, 410)},
			{"name": "Daiki", "title": "Groundskeeper", "pos": Vector2(520, 530)},
			{"name": "Yuki", "title": "Estate Scribe", "pos": Vector2(410, 340)}
		]
	else:
		roster = [
			{"name": "Rex", "title": "Chief Investigator", "pos": Vector2(450, 435)},
			{"name": "Elara", "title": "Chief Xenologist", "pos": Vector2(620, 435)},
			{"name": "Kael", "title": "Operations Officer", "pos": Vector2(560, 210)},
			{"name": "Lyra", "title": "Systems Engineer", "pos": Vector2(320, 640)},
			{"name": "Vance", "title": "Shuttle Pilot", "pos": Vector2(250, 435)},
			{"name": "Thorne", "title": "Science Officer", "pos": Vector2(810, 435)},
			{"name": "Silas", "title": "Data Analyst", "pos": Vector2(480, 210)},
			{"name": "Vesper", "title": "Flight Medic", "pos": Vector2(360, 435)},
			{"name": "Orion", "title": "Communications Tech", "pos": Vector2(700, 210)},
			{"name": "Novak", "title": "Maintenance Tech", "pos": Vector2(880, 640)}
		]

	# 2. Pool of 10 Roles: Exactly 2 Saboteurs (Infiltrator, Disruptor) and 8 Crew Specialists
	var role_pool: Array[GameEnums.Role] = [
		GameEnums.Role.INFILTRATOR,           # Saboteur 1
		GameEnums.Role.DISRUPTOR,             # Saboteur 2
		GameEnums.Role.INVESTIGATOR,          # Crew 1
		GameEnums.Role.ENGINEER,              # Crew 2
		GameEnums.Role.ARCHIVIST,             # Crew 3
		GameEnums.Role.FIELD_MEDIC,           # Crew 4
		GameEnums.Role.SECURITY_SPECIALIST,   # Crew 5
		GameEnums.Role.INVESTIGATOR,          # Crew 6
		GameEnums.Role.ENGINEER,              # Crew 7
		GameEnums.Role.CREW_SPECIALIST        # Crew 8
	]

	# Shuffle role pool using Fisher-Yates
	for i in range(role_pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := role_pool[i]
		role_pool[i] = role_pool[j]
		role_pool[j] = tmp

	# 3. Randomly determine which roster slot is assigned to the local human player (0 to 9)
	# Guarantees the player can be ANY of the 10 roles without bias or manual choice
	var player_slot: int = rng.randi_range(0, roster.size() - 1)

	var assignments: Array[RoleAssignment] = []

	for i in range(roster.size()):
		var char_info: Dictionary = roster[i]
		var is_local_player := (i == player_slot)
		var assigned_role: GameEnums.Role = role_pool[i]
		var is_sab: bool = (assigned_role == GameEnums.Role.INFILTRATOR or assigned_role == GameEnums.Role.DISRUPTOR)

		var title := get_role_title(assigned_role)
		var badge := "SABOTEUR" if is_sab else "CREWMATE"
		var desc := get_role_description(assigned_role)
		var obj := get_secret_objective(assigned_role, campaign_mode)
		var ability := get_special_ability(assigned_role)

		var assignment := RoleAssignment.new(
			i, char_info["name"], is_local_player, assigned_role,
			title, badge, desc, is_sab, obj, ability, char_info["pos"]
		)
		assignments.append(assignment)

	return assignments

static func get_role_title(role: GameEnums.Role) -> String:
	match role:
		GameEnums.Role.INVESTIGATOR: return "Forensic Investigator"
		GameEnums.Role.ENGINEER: return "Systems Engineer"
		GameEnums.Role.ARCHIVIST: return "Expedition Archivist"
		GameEnums.Role.FIELD_MEDIC: return "Field Medic"
		GameEnums.Role.SECURITY_SPECIALIST: return "Security Officer"
		GameEnums.Role.CREW_SPECIALIST: return "Mission Specialist"
		GameEnums.Role.INFILTRATOR: return "Covert Infiltrator"
		GameEnums.Role.DISRUPTOR: return "System Disruptor"
		_: return "Expedition Specialist"

static func get_role_description(role: GameEnums.Role) -> String:
	match role:
		GameEnums.Role.INVESTIGATOR:
			return "Expert in spatial analysis. Can detect forensic micro-traces and cross-reference witness timelines."
		GameEnums.Role.ENGINEER:
			return "Understands the station's core mechanisms. Can repair saboteurs' damage and bypass frozen conduits."
		GameEnums.Role.ARCHIVIST:
			return "Decodes ancient carvings and encrypted logs. Can recover deleted or corrupted evidence frames."
		GameEnums.Role.FIELD_MEDIC:
			return "Analyzes biological vitals and incident marks. Can determine exact causes and time of casualties."
		GameEnums.Role.SECURITY_SPECIALIST:
			return "Authorizes security checkpoints and reviews CCTV logs. Accesses restricted surveillance banks."
		GameEnums.Role.CREW_SPECIALIST:
			return "Maintains expedition life support and equipment. Crucial to fulfilling mission objectives."
		GameEnums.Role.INFILTRATOR:
			return "Secret operative. Eliminate crew members covertly, manipulate digital records, and frame innocents."
		GameEnums.Role.DISRUPTOR:
			return "Specialist in sabotage. Overload reactor power, create chaos, and prevent the crew from escaping."
		_:
			return "Expedition crew member dedicated to mission completion."

static func get_secret_objective(role: GameEnums.Role, campaign: GameEnums.CampaignMode) -> String:
	match role:
		GameEnums.Role.INVESTIGATOR:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Discover who bypassed the shrine seal, find the hidden passage, and recover the Hollow Crown."
			else:
				return "Reconstruct the blackout timeline, analyze the containment residue, and identify the thief."
		GameEnums.Role.ENGINEER:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Inspect the estate's mechanical lanterns and find the hidden passage wall latch."
			else:
				return "Trace the manual circuit breaker surge in Engineering Bay and stabilize reactor output."
		GameEnums.Role.ARCHIVIST:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Analyze ancient clan scrolls in the Archive and uncover the historical motive for the theft."
			else:
				return "Recover the scrubbed CCTV security telemetry logs from the auxiliary terminal."
		GameEnums.Role.FIELD_MEDIC:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Inspect the crushed petals and footwear indentations across the stone courtyard."
			else:
				return "Analyze biological solvent traces left on the ruptured cryogenic containment cylinder."
		GameEnums.Role.SECURITY_SPECIALIST:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Verify the integrity of the Moon Gate perimeter and cross-reference attendee alibis."
			else:
				return "Cross-reference keycard access timestamps against witness statements during the blackout."
		GameEnums.Role.CREW_SPECIALIST:
			return "Complete your assigned station investigation tasks and maintain security protocols."
		GameEnums.Role.INFILTRATOR:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Ensure the Hollow Crown escapes through the Moon Gate. Conceal the hidden passage and frame an attendant."
			else:
				return "Prepare the observation lock for extraction. Purge terminal logs and avoid suspicion."
		GameEnums.Role.DISRUPTOR:
			if campaign == GameEnums.CampaignMode.HOLLOW_CROWN:
				return "Extinguish estate lanterns, create false petal tracks, and keep the guardians searching outside."
			else:
				return "Trigger auxiliary power overloads, tamper with door locks, and delay the forensic team."
		_:
			return "Investigate the incident, survive the night, and protect the mission truth."

static func get_special_ability(role: GameEnums.Role) -> String:
	match role:
		GameEnums.Role.INVESTIGATOR: return "Echo Vision [Q]: Reveals hidden forensic traces in the environment."
		GameEnums.Role.ENGINEER: return "Rapid Override: Halves repair time during active sabotages."
		GameEnums.Role.ARCHIVIST: return "Chronos Recovery: Deciphers corrupted logs with 100% accuracy."
		GameEnums.Role.FIELD_MEDIC: return "Autopsy Scanner: Pinpoints exact time of death and weapon used."
		GameEnums.Role.SECURITY_SPECIALIST: return "CCTV Sweep: Grants extended surveillance radius on minimap."
		GameEnums.Role.INFILTRATOR: return "Elimination [SPACE]: Covert kill & Ventilation access [V]."
		GameEnums.Role.DISRUPTOR: return "Core Sabotage [F]: Trigger cascading system overload."
		_: return "Standard Expedition Equipment"
