class_name GameManager
extends Node2D

## Master Game Controller & Scene Orchestrator for VOIDSHIFT: The Living Evidence Engine.
## Implements the definitive multi-campaign architecture:
## - Three Original Campaigns: The Hollow Crown, Blackglass Station, The Last Signal
## - 10-Person Expedition Roster with Autonomous Randomized Role Allocation
## - Atmospheric Briefing & Confidential Role Reveal
## - Echo Vision Forensic Trace System & Clue Recovery
## - Authoritative Living Evidence Engine & Hypothesis Comparison
## - Multiple Consequential Campaign Endings & Debriefing Summaries

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")
const RoleAllocator = preload("res://scripts/core/RoleAllocator.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")
const CrewmateAI = preload("res://scripts/ai/CrewmateAI.gd")

@onready var station_map: StationMap = $StationMap
@onready var player: PlayerController = $Player
@onready var hud: GameHUD = $CanvasLayer/GameHUD
@onready var main_menu: MainMenu = $CanvasLayer/MainMenu
@onready var briefing_screen: BriefingScreen = $CanvasLayer/BriefingScreen
@onready var debrief_screen: DebriefScreen = $CanvasLayer/DebriefScreen
@onready var meeting_screen: MeetingScreen = $CanvasLayer/MeetingScreen
@onready var evidence_screen: EvidenceScreen = $CanvasLayer/EvidenceScreen
@onready var task_dialog: TaskDialog = $CanvasLayer/TaskDialog
@onready var sabotage_dialog: SabotageDialog = $CanvasLayer/SabotageDialog
@onready var academic_lab: AcademicLab = $CanvasLayer/AcademicLab
@onready var audio_synth: AudioSynthesizer = $AudioSynthesizer

var current_state: GameEnums.GameState = GameEnums.GameState.MAIN_MENU
var evidence_engine: LivingEvidenceEngine = null
var task_manager: TaskManager = null
var sabotage_manager: SabotageManager = null

var active_campaign_mode: GameEnums.CampaignMode = GameEnums.CampaignMode.HOLLOW_CROWN
var active_campaign: CampaignData.CampaignDef = null
var player_assignment: RoleAllocator.RoleAssignment = null
var all_assignments: Array[RoleAllocator.RoleAssignment] = []

var ai_crew: Array[CrewmateAI] = []
var all_characters: Array[CharacterBody2D] = []

var match_time: float = 0.0
var completed_tasks: Array[int] = []
var echo_vision_active: bool = false

# Game outcome state
var match_verdict_text: String = ""
var is_victory: bool = false

func _ready() -> void:
	evidence_engine = LivingEvidenceEngine.new()
	task_manager = TaskManager.new()
	add_child(task_manager)
	sabotage_manager = SabotageManager.new()

	# Connect Sub-system signals
	task_manager.task_completed.connect(_on_task_completed)
	sabotage_manager.critical_failure_reached.connect(_on_critical_failure)
	main_menu.campaign_selected.connect(_on_campaign_selected)
	main_menu.start_game_requested.connect(_on_start_game_requested)
	main_menu.academic_lab_requested.connect(_on_open_academic_lab)
	briefing_screen.deploy_requested.connect(_on_deploy_requested)
	briefing_screen.role_toggle_requested.connect(_on_role_toggle_requested)
	debrief_screen.restart_requested.connect(_on_restart_match)
	debrief_screen.main_menu_requested.connect(_on_return_to_main_menu)
	meeting_screen.meeting_concluded.connect(_on_meeting_concluded)
	academic_lab.exit_requested.connect(_on_exit_academic_lab)

	# Connect Dialog close signals
	task_dialog.closed.connect(_on_task_dialog_closed)
	evidence_screen.close_requested.connect(_on_evidence_screen_closed)
	sabotage_dialog.sabotage_selected.connect(_on_sabotage_selected_from_dialog)
	sabotage_dialog.closed.connect(_on_sabotage_dialog_closed)

	# Connect Player Signals
	player.task_requested.connect(_on_player_interaction_requested)
	player.report_requested.connect(_on_player_report_requested)
	player.kill_requested.connect(_on_player_kill_requested)
	player.vent_requested.connect(_on_player_vent_requested)
	player.echo_vision_toggled.connect(_on_player_echo_vision_toggled)
	player.sabotage_menu_requested.connect(_on_player_sabotage_requested)

	# Setup Dialogs
	task_dialog.setup(task_manager)
	evidence_screen.setup(evidence_engine)
	hud.setup(player)

	# Default to Hollow Crown
	active_campaign = CampaignData.get_campaign(active_campaign_mode)
	station_map.set_campaign(active_campaign_mode)
	evidence_screen.set_campaign(active_campaign)

	# Start in Main Menu
	set_state(GameEnums.GameState.MAIN_MENU)

func _process(delta: float) -> void:
	match current_state:
		GameEnums.GameState.GAMEPLAY:
			update_gameplay(delta)
		GameEnums.GameState.TASK_MINIGAME:
			update_ai_and_station(delta)

func update_gameplay(delta: float) -> void:
	match_time += delta
	sabotage_manager.update(delta)
	update_ai_and_station(delta)

	# Check Camera vision sweeps
	check_cctv_sightings()

	# Contextual HUD interaction prompt
	var prompt := get_contextual_prompt()
	var recent_evs := evidence_engine.get_recent_events(6)
	hud.update_hud(
		delta, match_time, completed_tasks, recent_evs,
		sabotage_manager.active_sabotage, sabotage_manager.timer, prompt,
		all_characters
	)

	check_win_conditions()

func update_ai_and_station(delta: float) -> void:
	# Update Player Room Location
	var p_room := station_map.get_current_room(player.global_position)
	player.update_room(p_room)

	# Update AI Crew
	var waypoints := station_map.get_room_waypoints()
	var task_locs: Array[Vector2] = []
	var tasks := active_campaign.tasks if active_campaign else StationData.get_task_spots()
	for t in tasks:
		task_locs.append(t.position)

	for bot in ai_crew:
		bot.update_ai(delta, waypoints, task_locs, all_characters, evidence_engine, match_time)
		var b_room := station_map.get_current_room(bot.global_position)
		bot.update_room(b_room)

func check_cctv_sightings() -> void:
	var cameras := active_campaign.cameras if active_campaign else StationData.get_cameras()
	for cam in cameras:
		for ch in all_characters:
			var d := cam.position.distance_to(ch.global_position)
			if d <= 130.0:
				var ch_name: String = ch.player_name if ch is PlayerController else (ch.bot_name if ch is CrewmateAI else "Unknown")
				evidence_engine.record_camera_sighting(cam.id, cam.name, ch_name, match_time)

func get_contextual_prompt() -> String:
	if player.character_state == GameEnums.CharacterState.DEAD:
		return "[GHOST OBSERVER] You are eliminated. Freely explore and observe the remaining crew."

	# 1. Nearby Undiscovered Echo Clue
	var nearby_clue := station_map.get_nearby_echo_clue(player.global_position)
	if nearby_clue != null:
		return "[E] Analyze Echo Trace: %s" % nearby_clue.name

	# 2. Check active sabotage repair
	if sabotage_manager.active_sabotage != GameEnums.SabotageType.NONE:
		var repair_pos := get_sabotage_repair_position(sabotage_manager.active_sabotage)
		if player.global_position.distance_to(repair_pos) <= 90.0:
			return "[E] REPAIR %s EMERGENCY" % get_sabotage_title(sabotage_manager.active_sabotage).to_upper()

	# 3. Fallen Crewmate (Can report with E or R)
	var nearby_body := find_nearby_dead_body(70.0)
	if nearby_body != null:
		var b_name: String = nearby_body.bot_name if nearby_body is CrewmateAI else "Crewmate"
		return "[E / R] Report Fallen %s" % b_name

	# 4. Emergency Button
	if station_map.is_near_emergency_button(player.global_position):
		return "[E] Convene Expedition Meeting"

	# 5. Sector Maintenance Task
	var nearby_task := station_map.get_nearby_task(player.global_position)
	if nearby_task != null:
		return "[E] %s" % nearby_task.name

	# 6. Saboteur Actions
	if player.is_saboteur():
		if player.character_state == GameEnums.CharacterState.VENTING:
			return "[V] Exit Sub-Conduit into %s  •  [A / D] Traverse Vents" % player.current_room_name
		var nearby_vent := station_map.get_nearby_vent(player.global_position)
		if nearby_vent != null:
			return "[V] Enter Sub-Conduit  •  [C] Sabotage System"
		if player.can_kill():
			var victim := find_nearby_kill_target(60.0)
			if victim != null:
				var v_name: String = victim.bot_name if victim is CrewmateAI else "Crewmate"
				return "[SPACE] Eliminate %s  •  [C] Sabotage System" % v_name
		return "[C] Open Tactical Sabotage Matrix"

	return ""

func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameEnums.GameState.GAMEPLAY:
		if event.is_action_pressed("toggle_evidence"):
			set_state(GameEnums.GameState.EVIDENCE_DOSSIER)
		elif event.is_action_pressed("toggle_academic_lab"):
			set_state(GameEnums.GameState.ACADEMIC_LAB)
		elif event.is_action_pressed("pause_game"):
			set_state(GameEnums.GameState.MAIN_MENU)
		elif player.character_state == GameEnums.CharacterState.VENTING:
			if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
				var vents := active_campaign.vents if active_campaign else StationData.get_vents()
				if not vents.is_empty():
					var cur_v := station_map.get_nearby_vent(player.global_position)
					var v_idx: int = 0
					for idx in range(vents.size()):
						if vents[idx].position.distance_to(player.global_position) <= 80.0:
							v_idx = idx
							break
					if event.is_action_pressed("move_right"):
						v_idx = (v_idx + 1) % vents.size()
					else:
						v_idx = (v_idx - 1 + vents.size()) % vents.size()
					player.global_position = vents[v_idx].position
					audio_synth.play_beep(340.0, 0.08)

func set_state(new_state: GameEnums.GameState) -> void:
	current_state = new_state
	main_menu.visible = (new_state == GameEnums.GameState.MAIN_MENU)
	briefing_screen.visible = (new_state == GameEnums.GameState.BRIEFING_ROLE_REVEAL)
	debrief_screen.visible = (new_state == GameEnums.GameState.DEBRIEF_ENDING)
	hud.visible = (new_state == GameEnums.GameState.GAMEPLAY or new_state == GameEnums.GameState.TASK_MINIGAME)
	academic_lab.visible = (new_state == GameEnums.GameState.ACADEMIC_LAB)
	task_dialog.visible = (new_state == GameEnums.GameState.TASK_MINIGAME)
	evidence_screen.visible = (new_state == GameEnums.GameState.EVIDENCE_DOSSIER)
	meeting_screen.visible = (new_state == GameEnums.GameState.MEETING)
	if new_state != GameEnums.GameState.GAMEPLAY and sabotage_dialog:
		sabotage_dialog.visible = false

# =========================================================================
# CAMPAIGN & MATCH INITIALIZATION (Genuinely Randomized Roles / Role Preference)
# =========================================================================
func _on_campaign_selected(mode: GameEnums.CampaignMode, role_pref: int = 0) -> void:
	active_campaign_mode = mode
	active_campaign = CampaignData.get_campaign(mode)
	station_map.set_campaign(mode)
	evidence_screen.set_campaign(active_campaign)

	# Role Allocation with optional preference (0: Random, 1: Guaranteed Imposter, 2: Guaranteed Crew)
	all_assignments = RoleAllocator.allocate_roles(mode, -1, role_pref)
	player_assignment = null
	for assign in all_assignments:
		if assign.is_player:
			player_assignment = assign
			break

	# Open Mission Briefing & Role Reveal
	briefing_screen.setup_briefing(active_campaign, player_assignment)
	set_state(GameEnums.GameState.BRIEFING_ROLE_REVEAL)
	audio_synth.play_beep(380.0, 0.12)

func _on_role_toggle_requested(as_saboteur: bool) -> void:
	all_assignments = RoleAllocator.allocate_roles(active_campaign_mode, -1, 1 if as_saboteur else 2)
	player_assignment = null
	for assign in all_assignments:
		if assign.is_player:
			player_assignment = assign
			break
	briefing_screen.setup_briefing(active_campaign, player_assignment)
	audio_synth.play_beep(650.0, 0.12)

func _on_task_dialog_closed() -> void:
	set_state(GameEnums.GameState.GAMEPLAY)

func _on_evidence_screen_closed() -> void:
	set_state(GameEnums.GameState.GAMEPLAY)

func _on_sabotage_dialog_closed() -> void:
	set_state(GameEnums.GameState.GAMEPLAY)

func _on_player_sabotage_requested() -> void:
	if current_state != GameEnums.GameState.GAMEPLAY or not player.is_saboteur():
		return
	sabotage_dialog.open(sabotage_manager.active_sabotage, sabotage_manager.timer)
	audio_synth.play_beep(600.0, 0.1)

func _on_sabotage_selected_from_dialog(type: GameEnums.SabotageType) -> void:
	trigger_sabotage_event(type, player.player_name)

func _on_ai_body_reported(reporter_name: String, victim_name: String) -> void:
	start_emergency_meeting(reporter_name, victim_name)

func _on_ai_sabotage_requested(sab_type: GameEnums.SabotageType) -> void:
	if sabotage_manager.active_sabotage == GameEnums.SabotageType.NONE:
		trigger_sabotage_event(sab_type, "Unknown Saboteur")

func trigger_sabotage_event(type: GameEnums.SabotageType, initiator: String) -> void:
	sabotage_manager.trigger_sabotage(type)
	audio_synth.play_emergency_alarm()
	evidence_engine.record_event(
		match_time,
		GameEnums.EventType.TRIGGER_SABOTAGE,
		player.player_id if initiator == player.player_name else -1,
		initiator,
		-1, "",
		"station", "Station Systems",
		"Critical Sabotage Event: %s" % get_sabotage_title(type),
		true
	)

func _on_start_game_requested(play_as_saboteur: bool) -> void:
	# Fallback legacy trigger maps to Hollow Crown
	_on_campaign_selected(GameEnums.CampaignMode.HOLLOW_CROWN)

func _on_deploy_requested() -> void:
	deploy_match()

func _on_restart_match() -> void:
	_on_campaign_selected(active_campaign_mode)

func _on_return_to_main_menu() -> void:
	set_state(GameEnums.GameState.MAIN_MENU)

func deploy_match() -> void:
	match_time = 0.0
	completed_tasks.clear()
	station_map.completed_tasks = completed_tasks
	evidence_engine.clear()
	echo_vision_active = false
	station_map.echo_vision_active = false
	hud.echo_vision_active = false

	# Configure Player from allocated assignment
	if player_assignment != null:
		player.player_id = player_assignment.character_id
		player.player_name = player_assignment.character_name
		player.role = player_assignment.role
		player.global_position = player_assignment.spawn_position
	else:
		player.player_id = 0
		player.player_name = "Commander Rex"
		player.role = GameEnums.Role.INVESTIGATOR
		player.global_position = Vector2(700, 960)

	player.character_state = GameEnums.CharacterState.ALIVE
	player.reset_kill_cooldown()

	# Clear existing AI bots
	for bot in ai_crew:
		bot.queue_free()
	ai_crew.clear()
	all_characters.clear()
	all_characters.append(player)

	# Instantiate the 9 AI bots with their respective allocated roles
	var ai_scene: PackedScene = load("res://scenes/ai/CrewmateAI.tscn")
	for assign in all_assignments:
		if assign.is_player:
			continue # Local player already in scene

		var bot := ai_scene.instantiate() as CrewmateAI
		bot.bot_id = assign.character_id
		bot.bot_name = assign.character_name
		bot.role = assign.role
		bot.global_position = assign.spawn_position
		bot.body_reported.connect(_on_ai_body_reported)
		bot.sabotage_requested.connect(_on_ai_sabotage_requested)
		add_child(bot)
		ai_crew.append(bot)
		all_characters.append(bot)

	# Setup HUD
	hud.setup_campaign(active_campaign, player_assignment)

	# Record initial mission deployment trace
	evidence_engine.record_event(
		0.0, GameEnums.EventType.ENTER_ROOM, player.player_id, player.player_name,
		-1, "", "briefing", active_campaign.title,
		"Expedition team deployed into %s" % active_campaign.location, false
	)

	set_state(GameEnums.GameState.GAMEPLAY)
	audio_synth.play_beep(520.0, 0.15)

# =========================================================================
# INTERACTION & ECHO VISION HANDLING
# =========================================================================
func _on_player_interaction_requested() -> void:
	if player.character_state == GameEnums.CharacterState.DEAD:
		return

	# 1. Check if near a fallen crewmate (E to report)
	var nearby_dead := find_nearby_dead_body(70.0)
	if nearby_dead != null:
		var victim_name: String = nearby_dead.bot_name if nearby_dead is CrewmateAI else "Crewmate"
		start_emergency_meeting(player.player_name, victim_name)
		return

	# 2. Check active sabotage repair console
	if sabotage_manager.active_sabotage != GameEnums.SabotageType.NONE:
		var rep_pos := get_sabotage_repair_position(sabotage_manager.active_sabotage)
		if player.global_position.distance_to(rep_pos) <= 90.0:
			var sab_title := get_sabotage_title(sabotage_manager.active_sabotage)
			sabotage_manager.repair_sabotage()
			audio_synth.play_task_complete()
			evidence_engine.record_event(
				match_time,
				GameEnums.EventType.REPAIR_SABOTAGE,
				player.player_id,
				player.player_name,
				-1, "",
				player.current_room_id,
				player.current_room_name,
				"Emergency sabotage resolved: %s repaired by %s" % [sab_title, player.player_name],
				false
			)
			return

	# 3. Check if near an undiscovered Echo Clue
	var nearby_clue := station_map.get_nearby_echo_clue(player.global_position)
	if nearby_clue != null:
		nearby_clue.is_collected = true
		evidence_engine.record_event(
			match_time,
			GameEnums.EventType.DISCOVER_ECHO_CLUE,
			player.player_id,
			player.player_name,
			-1, "",
			nearby_clue.room_id,
			nearby_clue.room_id.capitalize(),
			"Forensic Clue Discovered: %s (%s)" % [nearby_clue.name, nearby_clue.forensic_detail],
			false
		)
		audio_synth.play_beep(880.0, 0.20)
		station_map.queue_redraw()
		return

	# 4. Check Emergency Button
	if station_map.is_near_emergency_button(player.global_position):
		start_emergency_meeting(player.player_name, "")
		return

	# 5. Check Maintenance Task
	var nearby_task := station_map.get_nearby_task(player.global_position)
	if nearby_task != null:
		set_state(GameEnums.GameState.TASK_MINIGAME)
		task_dialog.open(nearby_task)

func _on_player_echo_vision_toggled() -> void:
	echo_vision_active = !echo_vision_active
	station_map.echo_vision_active = echo_vision_active
	hud.echo_vision_active = echo_vision_active
	audio_synth.play_beep(740.0 if echo_vision_active else 320.0, 0.08)

func _on_player_report_requested() -> void:
	var dead_body := find_nearby_dead_body(70.0)
	if dead_body != null:
		var victim_name: String = dead_body.bot_name if dead_body is CrewmateAI else "Crewmate"
		start_emergency_meeting(player.player_name, victim_name)

func _on_player_kill_requested() -> void:
	var victim := find_nearby_kill_target(60.0)
	if victim != null and victim is CrewmateAI:
		victim.character_state = GameEnums.CharacterState.DEAD
		player.reset_kill_cooldown()
		audio_synth.play_kill_sting()
		evidence_engine.record_event(
			match_time,
			GameEnums.EventType.KILL_CREWMATE,
			player.player_id,
			player.player_name,
			victim.bot_id,
			victim.bot_name,
			player.current_room_id,
			player.current_room_name,
			"Crewmate %s was eliminated in %s" % [victim.bot_name, player.current_room_name],
			true
		)

func _on_player_vent_requested() -> void:
	if player.character_state == GameEnums.CharacterState.VENTING:
		player.character_state = GameEnums.CharacterState.ALIVE
		evidence_engine.record_event(
			match_time,
			GameEnums.EventType.EXIT_VENT,
			player.player_id,
			player.player_name,
			-1, "",
			player.current_room_id,
			player.current_room_name,
			"%s emerged from ventilation conduit in %s" % [player.player_name, player.current_room_name],
			true
		)
		audio_synth.play_beep(440.0, 0.1)
	else:
		var vent := station_map.get_nearby_vent(player.global_position)
		if vent != null:
			player.character_state = GameEnums.CharacterState.VENTING
			var vents := active_campaign.vents if active_campaign else StationData.get_vents()
			if vent.connected_vent_id >= 0 and vent.connected_vent_id < vents.size():
				var target_vent := vents[vent.connected_vent_id]
				player.global_position = target_vent.position
			evidence_engine.record_event(
				match_time,
				GameEnums.EventType.ENTER_VENT,
				player.player_id,
				player.player_name,
				-1, "",
				player.current_room_id,
				player.current_room_name,
				"%s slipped into ventilation conduit in %s" % [player.player_name, player.current_room_name],
				true
			)
			audio_synth.play_beep(300.0, 0.12)

# =========================================================================
# EMERGENCY MEETINGS & CONTRADICTIONS
# =========================================================================
func start_emergency_meeting(reporter: String, victim_name: String) -> void:
	audio_synth.play_emergency_alarm()
	player.global_position = Vector2(700, 960)
	var x_offset: float = -120.0
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE:
			bot.global_position = Vector2(700 + x_offset, 960 + (randf_range(-40, 40)))
			x_offset += 40.0

	var living: Array[Dictionary] = []
	if player.character_state == GameEnums.CharacterState.ALIVE:
		living.append({
			"id": player.player_id,
			"name": player.player_name,
			"role": player.role,
			"is_impostor": player.is_saboteur()
		})
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE:
			living.append({
				"id": bot.bot_id,
				"name": bot.bot_name,
				"role": bot.role,
				"is_impostor": bot.is_saboteur()
			})

	var dead_event: LivingEvidenceEngine.TimelineEvent = null
	for ev in evidence_engine.events:
		if ev.event_type == GameEnums.EventType.KILL_CREWMATE and ev.target_name == victim_name:
			dead_event = ev
			break

	var testimonies := evidence_engine.generate_crew_testimonies(living, dead_event)
	set_state(GameEnums.GameState.MEETING)
	meeting_screen.setup_meeting(reporter, victim_name, living, testimonies, player.player_id)

func _on_meeting_concluded(ejected_id: int, is_impostor: bool) -> void:
	if ejected_id == player.player_id:
		player.character_state = GameEnums.CharacterState.DEAD
		spawn_player_corpse(player.global_position, player.role, player.player_name)
	else:
		for bot in ai_crew:
			if bot.bot_id == ejected_id:
				bot.character_state = GameEnums.CharacterState.DEAD
				break

	set_state(GameEnums.GameState.GAMEPLAY)

	# If all saboteurs were eliminated, trigger victory
	var remaining_saboteurs: int = 0
	if player.is_saboteur() and player.character_state == GameEnums.CharacterState.ALIVE:
		remaining_saboteurs += 1
	for bot in ai_crew:
		if bot.is_saboteur() and bot.character_state == GameEnums.CharacterState.ALIVE:
			remaining_saboteurs += 1

	if remaining_saboteurs == 0:
		trigger_campaign_ending(true, "All hidden saboteurs were unmasked and neutralized.")

func spawn_player_corpse(pos: Vector2, p_role: GameEnums.Role, p_name: String) -> void:
	var ai_scene: PackedScene = load("res://scenes/ai/CrewmateAI.tscn")
	var corpse := ai_scene.instantiate() as CrewmateAI
	corpse.bot_id = player.player_id
	corpse.bot_name = p_name
	corpse.role = p_role
	corpse.character_state = GameEnums.CharacterState.DEAD
	corpse.global_position = pos
	add_child(corpse)
	ai_crew.append(corpse)

func get_sabotage_repair_position(type: GameEnums.SabotageType) -> Vector2:
	match type:
		GameEnums.SabotageType.REACTOR:
			return Vector2(700, 200) # Reactor Core Console
		GameEnums.SabotageType.LIGHTS:
			return Vector2(500, 680) # Electrical Junction
		GameEnums.SabotageType.COMMUNICATIONS:
			return Vector2(1040, 160) # Communications Deck
		GameEnums.SabotageType.OXYGEN:
			return Vector2(800, 750) # Storage / Life Support
		_:
			return Vector2(700, 960)

func get_sabotage_title(type: GameEnums.SabotageType) -> String:
	match type:
		GameEnums.SabotageType.REACTOR: return "Reactor Core Overload"
		GameEnums.SabotageType.LIGHTS: return "Electrical Grid Blackout"
		GameEnums.SabotageType.COMMUNICATIONS: return "Communications Jammer"
		GameEnums.SabotageType.OXYGEN: return "Atmospheric O2 Depletion"
		_: return "System Fault"

# =========================================================================
# WIN / LOSS / DEBRIEFING CONDITIONS
# =========================================================================
func check_win_conditions() -> void:
	var total_tasks := active_campaign.tasks.size() if active_campaign else StationData.get_task_spots().size()
	if completed_tasks.size() >= total_tasks and total_tasks > 0:
		trigger_campaign_ending(true, "All critical sector maintenance objectives successfully completed.")
		return

	# Check crew vs saboteur headcount
	var living_crew: int = 0
	var living_saboteurs: int = 0

	if player.character_state == GameEnums.CharacterState.ALIVE:
		if player.is_saboteur(): living_saboteurs += 1
		else: living_crew += 1

	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE:
			if bot.is_saboteur(): living_saboteurs += 1
			else: living_crew += 1

	if living_crew <= living_saboteurs and living_crew > 0:
		trigger_campaign_ending(false, "Saboteurs reached numerical parity and overwhelmed the expedition.")

func _on_critical_failure() -> void:
	trigger_campaign_ending(false, "Critical system meltdown triggered before containment could be restored.")

func trigger_campaign_ending(p_victory: bool, reason: String) -> void:
	is_victory = p_victory
	var ending_type: GameEnums.EndingType

	match active_campaign_mode:
		GameEnums.CampaignMode.HOLLOW_CROWN:
			ending_type = GameEnums.EndingType.HOLLOW_CROWN_RECOVERY if p_victory else GameEnums.EndingType.HOLLOW_CROWN_SABOTEUR_ESCAPE
		GameEnums.CampaignMode.BLACKGLASS_STATION:
			ending_type = GameEnums.EndingType.BLACKGLASS_CONTAINED if p_victory else GameEnums.EndingType.BLACKGLASS_MELTDOWN
		GameEnums.CampaignMode.THE_LAST_SIGNAL:
			ending_type = GameEnums.EndingType.LAST_SIGNAL_CONTAINMENT if p_victory else GameEnums.EndingType.LAST_SIGNAL_FREEZE_COLLAPSE
		_:
			ending_type = GameEnums.EndingType.GENERIC_CREW_VICTORY if p_victory else GameEnums.EndingType.GENERIC_SABOTEUR_VICTORY

	var title_str := "%s // %s" % [active_campaign.title, "MISSION ACCOMPLISHED" if p_victory else "EXPEDITION FAILED"]

	var clues_found: int = 0
	var clues_total: int = active_campaign.clues.size() if active_campaign else 4
	if active_campaign:
		for c in active_campaign.clues:
			if c.is_collected: clues_found += 1

	debrief_screen.setup_debrief(
		active_campaign, player_assignment, ending_type, p_victory,
		title_str, reason, clues_found, clues_total
	)
	set_state(GameEnums.GameState.DEBRIEF_ENDING)

	# Save career record
	var save_d := SaveManager.load_game_data()
	var stats: Dictionary = save_d.get("stats", {})
	stats["matches_played"] = stats.get("matches_played", 0) + 1
	if p_victory:
		stats["crewmate_victories"] = stats.get("crewmate_victories", 0) + 1
	else:
		stats["saboteur_victories"] = stats.get("saboteur_victories", 0) + 1
	save_d["stats"] = stats
	SaveManager.save_game_data(save_d)

func _on_task_completed(task_id: int) -> void:
	if not (task_id in completed_tasks):
		completed_tasks.append(task_id)
		station_map.completed_tasks = completed_tasks
		evidence_engine.record_event(
			match_time,
			GameEnums.EventType.COMPLETE_TASK,
			player.player_id,
			player.player_name,
			-1, "",
			player.current_room_id,
			player.current_room_name,
			"Task completed in %s" % player.current_room_name,
			false
		)
		audio_synth.play_task_complete()

func _on_open_academic_lab() -> void:
	set_state(GameEnums.GameState.ACADEMIC_LAB)

func _on_exit_academic_lab() -> void:
	set_state(GameEnums.GameState.MAIN_MENU)

func find_nearby_dead_body(max_dist: float) -> CrewmateAI:
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.DEAD:
			if player.global_position.distance_to(bot.global_position) <= max_dist:
				return bot
	return null

func find_nearby_kill_target(max_dist: float) -> CrewmateAI:
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE and not bot.is_saboteur():
			if player.global_position.distance_to(bot.global_position) <= max_dist:
				return bot
	return null
