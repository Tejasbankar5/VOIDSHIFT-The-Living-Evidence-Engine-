class_name GameManager
extends Node2D

## Master Game Controller & Scene Orchestrator for VOIDSHIFT.

@onready var station_map: StationMap = $StationMap
@onready var player: PlayerController = $Player
@onready var hud: GameHUD = $CanvasLayer/GameHUD
@onready var main_menu: MainMenu = $CanvasLayer/MainMenu
@onready var meeting_screen: MeetingScreen = $CanvasLayer/MeetingScreen
@onready var evidence_screen: EvidenceScreen = $CanvasLayer/EvidenceScreen
@onready var task_dialog: TaskDialog = $CanvasLayer/TaskDialog
@onready var academic_lab: AcademicLab = $CanvasLayer/AcademicLab
@onready var audio_synth: AudioSynthesizer = $AudioSynthesizer
const SaveManager = preload("res://scripts/core/SaveManager.gd")

var current_state: GameEnums.GameState = GameEnums.GameState.MAIN_MENU
var evidence_engine: LivingEvidenceEngine = null
var task_manager: TaskManager = null
var sabotage_manager: SabotageManager = null

var ai_crew: Array[CrewmateAI] = []
var all_characters: Array[CharacterBody2D] = []

var match_time: float = 0.0
var completed_tasks: Array[int] = []

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
	main_menu.start_game_requested.connect(_on_start_game_requested)
	main_menu.academic_lab_requested.connect(_on_open_academic_lab)
	meeting_screen.meeting_concluded.connect(_on_meeting_concluded)
	academic_lab.exit_requested.connect(_on_exit_academic_lab)

	# Connect Player Signals
	player.task_requested.connect(_on_player_task_requested)
	player.report_requested.connect(_on_player_report_requested)
	player.kill_requested.connect(_on_player_kill_requested)
	player.vent_requested.connect(_on_player_vent_requested)

	# Setup Dialogs
	task_dialog.setup(task_manager)
	evidence_screen.setup(evidence_engine)
	hud.setup(player)

	# Start in Main Menu
	set_state(GameEnums.GameState.MAIN_MENU)

func _process(delta: float) -> void:
	match current_state:
		GameEnums.GameState.GAMEPLAY:
			update_gameplay(delta)
		GameEnums.GameState.TASK_MINIGAME:
			# Background station still ticks
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
	for t in StationData.get_task_spots():
		task_locs.append(t.position)

	for bot in ai_crew:
		bot.update_ai(delta, waypoints, task_locs, all_characters, evidence_engine, match_time)
		var b_room := station_map.get_current_room(bot.global_position)
		bot.update_room(b_room)

func check_cctv_sightings() -> void:
	var cameras := StationData.get_cameras()
	for cam in cameras:
		for ch in all_characters:
			var d := cam.position.distance_to(ch.global_position)
			if d <= 130.0:
				var ch_name: String = ch.player_name if ch is PlayerController else (ch.bot_name if ch is CrewmateAI else "Unknown")
				evidence_engine.record_camera_sighting(cam.id, cam.name, ch_name, match_time)

func get_contextual_prompt() -> String:
	if player.character_state == GameEnums.CharacterState.DEAD:
		return "[DEAD] You are wandering as a ghost observer."

	if station_map.is_near_emergency_button(player.global_position):
		return "[E] Press Emergency Meeting Button"

	var nearby_task := station_map.get_nearby_task(player.global_position)
	if nearby_task != null:
		return "[E] %s" % nearby_task.name

	var nearby_body := find_nearby_dead_body(60.0)
	if nearby_body != null:
		var b_name: String = nearby_body.bot_name if nearby_body is CrewmateAI else "Crewmate"
		return "[R] Report Discovered Body of %s" % b_name

	if player.role == GameEnums.Role.SABOTEUR_IMPOSTOR:
		var nearby_vent := station_map.get_nearby_vent(player.global_position)
		if nearby_vent != null:
			return "[V] Enter Ventilation Conduit"
		if player.can_kill():
			var victim := find_nearby_kill_target(60.0)
			if victim != null:
				var v_name: String = victim.bot_name if victim is CrewmateAI else "Crewmate"
				return "[SPACE] Eliminate %s" % v_name

	return ""

func _unhandled_input(event: InputEvent) -> void:
	if current_state == GameEnums.GameState.GAMEPLAY:
		if event.is_action_pressed("toggle_evidence"):
			set_state(GameEnums.GameState.MEETING)
			evidence_screen.visible = true
		elif event.is_action_pressed("toggle_academic_lab"):
			set_state(GameEnums.GameState.ACADEMIC_LAB)
		elif event.is_action_pressed("pause_game"):
			set_state(GameEnums.GameState.MAIN_MENU)

func set_state(new_state: GameEnums.GameState) -> void:
	current_state = new_state
	main_menu.visible = (new_state == GameEnums.GameState.MAIN_MENU)
	hud.visible = (new_state == GameEnums.GameState.GAMEPLAY or new_state == GameEnums.GameState.TASK_MINIGAME)
	academic_lab.visible = (new_state == GameEnums.GameState.ACADEMIC_LAB)
	task_dialog.visible = (new_state == GameEnums.GameState.TASK_MINIGAME)
	meeting_screen.visible = (new_state == GameEnums.GameState.MEETING and not evidence_screen.visible)
	
	if new_state == GameEnums.GameState.GAMEPLAY:
		evidence_screen.visible = false

func start_new_match(play_as_saboteur: bool) -> void:
	match_time = 0.0
	completed_tasks.clear()
	station_map.completed_tasks = completed_tasks
	evidence_engine.clear()

	# Setup Player
	player.global_position = Vector2(700, 960) # Cafeteria Meeting Room
	player.role = GameEnums.Role.SABOTEUR_IMPOSTOR if play_as_saboteur else GameEnums.Role.CREW_DEFAULT
	player.character_state = GameEnums.CharacterState.ALIVE
	player.reset_kill_cooldown()

	# Clear existing AI bots
	for bot in ai_crew:
		bot.queue_free()
	ai_crew.clear()
	all_characters.clear()
	all_characters.append(player)

	# Spawn AI Crew with roles
	var bot_configs := [
		{"name": "Nova", "role": GameEnums.Role.SCIENTIST_ANALYST, "pos": Vector2(1040, 420)},
		{"name": "Astra", "role": GameEnums.Role.MEDIC_HEALER, "pos": Vector2(1400, 420)},
		{"name": "Vance", "role": GameEnums.Role.ENGINEER_FIXER, "pos": Vector2(500, 680)},
		{"name": "Kael", "role": GameEnums.Role.SECURITY_DETECTIVE, "pos": Vector2(1060, 700)},
		{"name": "Lyra", "role": GameEnums.Role.COMMUNICATIONS_OPERATOR, "pos": Vector2(1040, 160)},
		{"name": "Orion", "role": GameEnums.Role.CREW_DEFAULT, "pos": Vector2(260, 200)}
	]

	# If player is Crewmate, select 1 random AI to be the secret Saboteur
	var secret_saboteur_idx := -1
	if not play_as_saboteur:
		secret_saboteur_idx = randi() % bot_configs.size()

	var ai_scene: PackedScene = load("res://scenes/ai/CrewmateAI.tscn")
	for i in range(bot_configs.size()):
		var cfg: Dictionary = bot_configs[i]
		var bot := ai_scene.instantiate() as CrewmateAI
		bot.bot_id = i + 1
		bot.bot_name = cfg["name"]
		bot.role = GameEnums.Role.SABOTEUR_IMPOSTOR if (i == secret_saboteur_idx) else cfg["role"]
		bot.global_position = cfg["pos"]
		add_child(bot)
		ai_crew.append(bot)
		all_characters.append(bot)

	set_state(GameEnums.GameState.GAMEPLAY)
	audio_synth.play_beep(440.0, 0.15)

func _on_player_task_requested() -> void:
	if station_map.is_near_emergency_button(player.global_position):
		start_emergency_meeting(player.player_name, "")
		return

	var nearby_task := station_map.get_nearby_task(player.global_position)
	if nearby_task != null:
		set_state(GameEnums.GameState.TASK_MINIGAME)
		task_dialog.open(nearby_task)

func _on_player_report_requested() -> void:
	var dead_body := find_nearby_dead_body(60.0)
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
	var vent := station_map.get_nearby_vent(player.global_position)
	if vent != null:
		if player.character_state == GameEnums.CharacterState.VENTING:
			player.character_state = GameEnums.CharacterState.ALIVE
		else:
			player.character_state = GameEnums.CharacterState.VENTING
			if vent.connected_vent_id >= 0 and vent.connected_vent_id < StationData.get_vents().size():
				var target_vent := StationData.get_vents()[vent.connected_vent_id]
				player.global_position = target_vent.position
		audio_synth.play_beep(300.0, 0.08)

func start_emergency_meeting(reporter: String, victim_name: String) -> void:
	audio_synth.play_emergency_alarm()
	# Gathers all characters in Cafeteria
	player.global_position = Vector2(700, 960)
	var x_offset: float = -120.0
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE:
			bot.global_position = Vector2(700 + x_offset, 960 + (randf_range(-40, 40)))
			x_offset += 40.0

	# Gather living characters list for meeting UI
	var living: Array[Dictionary] = []
	if player.character_state == GameEnums.CharacterState.ALIVE:
		living.append({
			"id": player.player_id,
			"name": player.player_name,
			"role": player.role,
			"is_impostor": player.role == GameEnums.Role.SABOTEUR_IMPOSTOR
		})
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE:
			living.append({
				"id": bot.bot_id,
				"name": bot.bot_name,
				"role": bot.role,
				"is_impostor": bot.role == GameEnums.Role.SABOTEUR_IMPOSTOR
			})

	# Generate testimonies via Living Evidence Engine
	var dead_event: LivingEvidenceEngine.TimelineEvent = null
	for ev in evidence_engine.events:
		if ev.event_type == GameEnums.EventType.KILL_CREWMATE and ev.target_name == victim_name:
			dead_event = ev
			break

	var testimonies := evidence_engine.generate_crew_testimonies(living, dead_event)
	set_state(GameEnums.GameState.MEETING)
	meeting_screen.setup_meeting(reporter, victim_name, living, testimonies)

func _on_meeting_concluded(ejected_id: int, is_impostor: bool) -> void:
	if ejected_id == 0:
		player.character_state = GameEnums.CharacterState.DEAD
	else:
		for bot in ai_crew:
			if bot.bot_id == ejected_id:
				bot.character_state = GameEnums.CharacterState.DEAD
				break

	set_state(GameEnums.GameState.GAMEPLAY)
	check_win_conditions()

func _on_task_completed(task_id: int, task_name: String) -> void:
	if not (task_id in completed_tasks):
		completed_tasks.append(task_id)
		station_map.completed_tasks = completed_tasks
		audio_synth.play_task_success()
		evidence_engine.record_event(
			match_time,
			GameEnums.EventType.COMPLETE_TASK,
			player.player_id,
			player.player_name,
			task_id,
			task_name,
			player.current_room_id,
			player.current_room_name,
			"%s completed maintenance task '%s' in %s" % [player.player_name, task_name, player.current_room_name]
		)
		set_state(GameEnums.GameState.GAMEPLAY)

func _on_critical_failure() -> void:
	match_verdict_text = "CRITICAL FAILURE: REACTOR MELTDOWN DESTROYED THE STATION!"
	is_victory = false
	SaveManager.record_match_result(false, player.role == GameEnums.Role.SABOTEUR_IMPOSTOR, completed_tasks.size())
	set_state(GameEnums.GameState.MAIN_MENU)

func check_win_conditions() -> void:
	var total_tasks := StationData.get_task_spots().size()
	if completed_tasks.size() >= total_tasks and total_tasks > 0:
		match_verdict_text = "MISSION SUCCESS: ALL CRITICAL STATION TASKS COMPLETED!"
		is_victory = true
		SaveManager.record_match_result(true, player.role == GameEnums.Role.SABOTEUR_IMPOSTOR, completed_tasks.size())
		set_state(GameEnums.GameState.MAIN_MENU)
		return

	var alive_crew: int = 0
	var alive_impostors: int = 0

	if player.character_state == GameEnums.CharacterState.ALIVE:
		if player.role == GameEnums.Role.SABOTEUR_IMPOSTOR:
			alive_impostors += 1
		else:
			alive_crew += 1

	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE:
			if bot.role == GameEnums.Role.SABOTEUR_IMPOSTOR:
				alive_impostors += 1
			else:
				alive_crew += 1

	if alive_impostors == 0:
		match_verdict_text = "CREW VICTORY: THE SABOTEUR HAS BEEN DISCOVERED AND EJECTED!"
		is_victory = true
		SaveManager.record_match_result(true, player.role == GameEnums.Role.SABOTEUR_IMPOSTOR, completed_tasks.size())
		set_state(GameEnums.GameState.MAIN_MENU)
	elif alive_impostors >= alive_crew:
		match_verdict_text = "SABOTEUR VICTORY: CREW INTEGRITY COMPROMISED!"
		is_victory = false
		SaveManager.record_match_result(false, player.role == GameEnums.Role.SABOTEUR_IMPOSTOR, completed_tasks.size())
		set_state(GameEnums.GameState.MAIN_MENU)

func find_nearby_dead_body(max_dist: float) -> CharacterBody2D:
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.DEAD:
			if player.global_position.distance_to(bot.global_position) <= max_dist:
				return bot
	return null

func find_nearby_kill_target(max_dist: float) -> CharacterBody2D:
	for bot in ai_crew:
		if bot.character_state == GameEnums.CharacterState.ALIVE and bot.role != GameEnums.Role.SABOTEUR_IMPOSTOR:
			if player.global_position.distance_to(bot.global_position) <= max_dist:
				return bot
	return null

func _on_start_game_requested(as_saboteur: bool) -> void:
	start_new_match(as_saboteur)

func _on_open_academic_lab() -> void:
	set_state(GameEnums.GameState.ACADEMIC_LAB)

func _on_exit_academic_lab() -> void:
	set_state(GameEnums.GameState.MAIN_MENU)
