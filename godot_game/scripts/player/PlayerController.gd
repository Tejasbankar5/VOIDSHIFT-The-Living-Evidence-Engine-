class_name PlayerController
extends CharacterBody2D

const CrewmateRenderer = preload("res://scripts/render/CrewmateRenderer.gd")

## Player Controller for VOIDSHIFT.
## Handles smooth top-down physics movement, collisions, visual rendering, and inputs.

signal room_changed(old_room: String, new_room: String)
signal task_requested()
signal emergency_requested()
signal report_requested()
signal kill_requested()
signal vent_requested()
signal echo_vision_toggled()

@export var player_id: int = 0
@export var player_name: String = "Commander Rex (You)"
@export var role: GameEnums.Role = GameEnums.Role.CREW_DEFAULT
@export var speed: float = 230.0
@export var kill_cooldown: float = 15.0
@export var max_kill_cooldown: float = 15.0

var character_state: GameEnums.CharacterState = GameEnums.CharacterState.ALIVE
var is_facing_left: bool = false
var walk_time: float = 0.0
var current_room_id: String = ""
var current_room_name: String = ""

func _ready() -> void:
	name = "Player"

func _physics_process(delta: float) -> void:
	if character_state == GameEnums.CharacterState.DEAD or character_state == GameEnums.CharacterState.IN_MEETING:
		velocity = Vector2.ZERO
		move_and_slide()
		queue_redraw()
		return

	if character_state == GameEnums.CharacterState.VENTING:
		velocity = Vector2.ZERO
		queue_redraw()
		return

	# Handle cooldowns
	if is_saboteur() and kill_cooldown > 0.0:
		kill_cooldown = maxf(0.0, kill_cooldown - delta)

	# Movement vector from input map
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
		walk_time += delta
		if input_vector.x < -0.1:
			is_facing_left = true
		elif input_vector.x > 0.1:
			is_facing_left = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 8.0 * delta)
		walk_time = 0.0

	move_and_slide()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if character_state == GameEnums.CharacterState.DEAD or character_state == GameEnums.CharacterState.IN_MEETING:
		return

	if event.is_action_pressed("interact"):
		task_requested.emit()
	elif event.is_action_pressed("report"):
		report_requested.emit()
	elif event.is_action_pressed("action_kill") and can_kill():
		kill_requested.emit()
	elif event.is_action_pressed("action_vent") and is_saboteur():
		vent_requested.emit()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_Q or event.keycode == KEY_F):
		echo_vision_toggled.emit()

func _draw() -> void:
	if character_state == GameEnums.CharacterState.VENTING:
		return
	var is_dead := (character_state == GameEnums.CharacterState.DEAD)
	CrewmateRenderer.draw_character(self, Vector2.ZERO, player_name, role, is_dead, walk_time, is_facing_left, true)

func is_saboteur() -> bool:
	return role == GameEnums.Role.INFILTRATOR or role == GameEnums.Role.DISRUPTOR or role == GameEnums.Role.SABOTEUR_IMPOSTOR

func can_kill() -> bool:
	return is_saboteur() and character_state == GameEnums.CharacterState.ALIVE and kill_cooldown <= 0.0

func reset_kill_cooldown() -> void:
	kill_cooldown = max_kill_cooldown

func update_room(new_room: StationData.RoomDef) -> void:
	var new_name: String = new_room.name if new_room != null else "Corridor"
	var new_id: String = new_room.id if new_room != null else "corridor"
	if new_id != current_room_id:
		var old_name := current_room_name
		current_room_id = new_id
		current_room_name = new_name
		room_changed.emit(old_name, new_name)
