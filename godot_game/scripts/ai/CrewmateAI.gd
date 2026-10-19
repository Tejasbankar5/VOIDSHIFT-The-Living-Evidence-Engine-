class_name CrewmateAI
extends CharacterBody2D

const CrewmateRenderer = preload("res://scripts/render/CrewmateRenderer.gd")

## AI-Controlled Crewmate / Saboteur Agent for VOIDSHIFT.
## Features multi-role state machines, autonomous navigation,
## and observation logging into the Living Evidence Engine.

signal bot_eliminated(victim: CrewmateAI, killer_name: String)
signal bot_entered_room(bot: CrewmateAI, room_name: String)

enum AIState {
	WANDERING,
	MOVING_TO_TASK,
	PERFORMING_TASK,
	STALKING_TARGET,
	PATROLLING,
	FLEEING
}

@export var bot_id: int = 1
@export var bot_name: String = "Nova"
@export var role: GameEnums.Role = GameEnums.Role.CREW_DEFAULT
@export var speed: float = 190.0
@export var kill_cooldown: float = 20.0
@export var max_kill_cooldown: float = 20.0

var character_state: GameEnums.CharacterState = GameEnums.CharacterState.ALIVE
var ai_state: AIState = AIState.WANDERING
var target_waypoint: Vector2 = Vector2.ZERO
var state_timer: float = 0.0
var task_perform_timer: float = 0.0

var is_facing_left: bool = false
var walk_time: float = 0.0
var current_room_id: String = ""
var current_room_name: String = ""

# Evidence observation timer
var observation_timer: float = 0.0

func _ready() -> void:
	state_timer = randf_range(1.0, 3.0)
	target_waypoint = global_position

func update_ai(delta: float, room_waypoints: Array[Vector2], task_positions: Array[Vector2],
			   all_characters: Array[CharacterBody2D], evidence_engine: LivingEvidenceEngine, match_time: float) -> void:
	if character_state == GameEnums.CharacterState.DEAD or character_state == GameEnums.CharacterState.IN_MEETING:
		velocity = Vector2.ZERO
		move_and_slide()
		queue_redraw()
		return

	if character_state == GameEnums.CharacterState.VENTING:
		velocity = Vector2.ZERO
		queue_redraw()
		return

	state_timer -= delta
	observation_timer += delta

	# 1. Periodically record observations of nearby characters
	if observation_timer >= 1.5:
		observation_timer = 0.0
		record_surroundings(all_characters, evidence_engine, match_time)

	# 2. Cooldown timer for Saboteur
	if is_saboteur() and kill_cooldown > 0.0:
		kill_cooldown = maxf(0.0, kill_cooldown - delta)

	# 3. State logic
	match ai_state:
		AIState.PERFORMING_TASK:
			task_perform_timer -= delta
			velocity = Vector2.ZERO
			walk_time = 0.0
			if task_perform_timer <= 0.0:
				ai_state = AIState.WANDERING
				state_timer = 0.0
			move_and_slide()
			queue_redraw()
			return

		AIState.STALKING_TARGET:
			# Saboteur stalks closest living crewmate
			var nearest_victim: CharacterBody2D = find_closest_victim(all_characters)
			if nearest_victim != null:
				target_waypoint = nearest_victim.global_position
				var dist_to_victim: float = global_position.distance_to(nearest_victim.global_position)
				# Execute kill if close, isolated, and off cooldown
				if dist_to_victim <= 48.0 and can_kill():
					execute_kill(nearest_victim, evidence_engine, match_time)
					ai_state = AIState.WANDERING
					state_timer = 4.0
			else:
				ai_state = AIState.WANDERING

		_:
			# Standard wandering or moving to task
			var dist_to_target: float = global_position.distance_to(target_waypoint)
			if dist_to_target < 24.0 or state_timer <= 0.0:
				decide_next_behavior(room_waypoints, task_positions, all_characters)

	# 4. Move toward waypoint
	var to_target: Vector2 = target_waypoint - global_position
	if to_target.length() > 8.0:
		velocity = to_target.normalized() * speed
		walk_time += delta
		is_facing_left = velocity.x < 0.0
	else:
		velocity = Vector2.ZERO
		walk_time = 0.0

	move_and_slide()
	queue_redraw()

func decide_next_behavior(room_waypoints: Array[Vector2], task_positions: Array[Vector2], all_characters: Array[CharacterBody2D]) -> void:
	state_timer = randf_range(4.0, 9.0)

	if is_saboteur():
		# If kill is ready, stalk
		if can_kill() and randf() < 0.65:
			ai_state = AIState.STALKING_TARGET
			return
		else:
			ai_state = AIState.WANDERING
			if not room_waypoints.is_empty():
				target_waypoint = room_waypoints[randi() % room_waypoints.size()]
			return

	# Crewmate Behavior
	if not task_positions.is_empty() and randf() < 0.55:
		ai_state = AIState.MOVING_TO_TASK
		target_waypoint = task_positions[randi() % task_positions.size()]
	else:
		ai_state = AIState.WANDERING
		if not room_waypoints.is_empty():
			target_waypoint = room_waypoints[randi() % room_waypoints.size()]

func find_closest_victim(all_characters: Array[CharacterBody2D]) -> CharacterBody2D:
	var closest: CharacterBody2D = null
	var min_dist: float = 99999.0

	for ch in all_characters:
		if ch == self:
			continue
		var is_alive := false
		var is_crew := false
		if ch is CrewmateAI:
			is_alive = ch.character_state == GameEnums.CharacterState.ALIVE
			is_crew = not ch.is_saboteur()
		elif ch is PlayerController:
			is_alive = ch.character_state == GameEnums.CharacterState.ALIVE
			is_crew = not ch.is_saboteur()

		if is_alive and is_crew:
			var d := global_position.distance_to(ch.global_position)
			if d < min_dist:
				min_dist = d
				closest = ch
	return closest

func is_saboteur() -> bool:
	return role == GameEnums.Role.INFILTRATOR or role == GameEnums.Role.DISRUPTOR or role == GameEnums.Role.SABOTEUR_IMPOSTOR

func can_kill() -> bool:
	return is_saboteur() and character_state == GameEnums.CharacterState.ALIVE and kill_cooldown <= 0.0

func execute_kill(victim: CharacterBody2D, evidence_engine: LivingEvidenceEngine, match_time: float) -> void:
	kill_cooldown = max_kill_cooldown
	var victim_name: String = ""
	var victim_id: int = -1

	if victim is CrewmateAI:
		victim.character_state = GameEnums.CharacterState.DEAD
		victim_name = victim.bot_name
		victim_id = victim.bot_id
		victim.bot_eliminated.emit(victim, bot_name)
	elif victim is PlayerController:
		victim.character_state = GameEnums.CharacterState.DEAD
		victim_name = victim.player_name
		victim_id = victim.player_id

	# Record in Living Evidence Engine
	evidence_engine.record_event(
		match_time,
		GameEnums.EventType.KILL_CREWMATE,
		bot_id,
		bot_name,
		victim_id,
		victim_name,
		current_room_id,
		current_room_name,
		"%s eliminated %s in %s" % [bot_name, victim_name, current_room_name],
		true
	)

func record_surroundings(all_characters: Array[CharacterBody2D], evidence_engine: LivingEvidenceEngine, match_time: float) -> void:
	for ch in all_characters:
		if ch == self:
			continue
		if global_position.distance_to(ch.global_position) <= 200.0:
			var other_name: String = ch.bot_name if ch is CrewmateAI else (ch.player_name if ch is PlayerController else "Unknown")
			var other_id: int = ch.bot_id if ch is CrewmateAI else (ch.player_id if ch is PlayerController else -1)
			evidence_engine.record_observation(bot_id, other_id, other_name, current_room_name, match_time, "Walking")

func update_room(new_room: StationData.RoomDef) -> void:
	var new_name: String = new_room.name if new_room != null else "Corridor"
	var new_id: String = new_room.id if new_room != null else "corridor"
	if new_id != current_room_id:
		current_room_id = new_id
		current_room_name = new_name
		bot_entered_room.emit(self, new_name)

func _draw() -> void:
	if character_state == GameEnums.CharacterState.VENTING:
		return
	var is_dead := (character_state == GameEnums.CharacterState.DEAD)
	CrewmateRenderer.draw_astronaut(self, Vector2.ZERO, role, is_dead, walk_time, is_facing_left, false)
	# Draw Bot Name Banner above head
	var name_color := Color(1.0, 0.35, 0.35) if (role == GameEnums.Role.SABOTEUR_IMPOSTOR and is_dead) else Color(0.85, 0.9, 1.0, 0.85)
	draw_string(ThemeDB.fallback_font, Vector2(-24, -36), bot_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, name_color)
