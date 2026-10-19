class_name LivingEvidenceEngine
extends RefCounted

## The Living Evidence Engine for VOIDSHIFT.
## Tracks objective game history, individual character observations, camera logs,
## and computes logical contradictions for single-player social deduction.

class TimelineEvent:
	var id: int
	var timestamp_seconds: float
	var formatted_time: String
	var event_type: GameEnums.EventType
	var actor_id: int
	var actor_name: String
	var target_id: int
	var target_name: String
	var room_id: String
	var room_name: String
	var description: String
	var is_suspicious: bool

	func _init(p_id: int, p_time: float, p_type: GameEnums.EventType, p_actor_id: int, p_actor_name: String,
			   p_target_id: int = -1, p_target_name: String = "", p_room_id: String = "", p_room_name: String = "",
			   p_desc: String = "", p_suspicious: bool = false) -> void:
		id = p_id
		timestamp_seconds = p_time
		var minutes: int = int(p_time) / 60
		var seconds: int = int(p_time) % 60
		formatted_time = "%02d:%02d" % [minutes, seconds]
		event_type = p_type
		actor_id = p_actor_id
		actor_name = p_actor_name
		target_id = p_target_id
		target_name = p_target_name
		room_id = p_room_id
		room_name = p_room_name
		description = p_desc
		is_suspicious = p_suspicious

class CharacterObservation:
	var observer_id: int
	var subject_id: int
	var subject_name: String
	var room_id: String
	var timestamp: float
	var action_observed: String

	func _init(p_obs_id: int, p_sub_id: int, p_sub_name: String, p_room: String, p_time: float, p_action: String) -> void:
		observer_id = p_obs_id
		subject_id = p_sub_id
		subject_name = p_sub_name
		room_id = p_room
		timestamp = p_time
		action_observed = p_action

class TestimonyStatement:
	var speaker_id: int
	var speaker_name: String
	var claimed_room: String
	var claimed_time: float
	var claimed_activity: String
	var mentioned_actors: Array[String] = []
	var is_truthful: bool = true
	var contradiction_reason: String = ""

# Storage
var events: Array[TimelineEvent] = []
var observations: Array[CharacterObservation] = []
var camera_sightings: Array[Dictionary] = [] # {cam_id, cam_name, actor_name, time}
var event_counter: int = 0

func clear() -> void:
	events.clear()
	observations.clear()
	camera_sightings.clear()
	event_counter = 0

func record_event(time_sec: float, type: GameEnums.EventType, actor_id: int, actor_name: String,
				 target_id: int = -1, target_name: String = "", room_id: String = "", room_name: String = "",
				 desc: String = "", suspicious: bool = false) -> TimelineEvent:
	event_counter += 1
	var ev := TimelineEvent.new(event_counter, time_sec, type, actor_id, actor_name, target_id, target_name, room_id, room_name, desc, suspicious)
	events.append(ev)
	return ev

func record_observation(observer_id: int, subject_id: int, subject_name: String, room_id: String, time_sec: float, action: String) -> void:
	# Avoid redundant duplicate observations within 3 seconds
	for obs in observations:
		if obs.observer_id == observer_id and obs.subject_id == subject_id and obs.room_id == room_id:
			if abs(obs.timestamp - time_sec) < 3.0:
				return
	observations.append(CharacterObservation.new(observer_id, subject_id, subject_name, room_id, time_sec, action))

func record_camera_sighting(cam_id: int, cam_name: String, actor_name: String, time_sec: float) -> void:
	for s in camera_sightings:
		if s["cam_id"] == cam_id and s["actor_name"] == actor_name and abs(s["time"] - time_sec) < 5.0:
			return
	var minutes: int = int(time_sec) / 60
	var seconds: int = int(time_sec) % 60
	camera_sightings.append({
		"cam_id": cam_id,
		"cam_name": cam_name,
		"actor_name": actor_name,
		"time": time_sec,
		"formatted": "%02d:%02d" % [minutes, seconds]
	})

func get_recent_events(limit: int = 8) -> Array[TimelineEvent]:
	var result: Array[TimelineEvent] = []
	var start_idx: int = maxi(0, events.size() - limit)
	for i in range(events.size() - 1, start_idx - 1, -1):
		result.append(events[i])
	return result

func get_actor_location_at(actor_id: int, time_sec: float) -> String:
	# Trace back room movements for this actor prior to time_sec
	var last_room: String = "Unknown"
	for ev in events:
		if ev.actor_id == actor_id and ev.timestamp_seconds <= time_sec:
			if ev.event_type == GameEnums.EventType.ENTER_ROOM:
				last_room = ev.room_name
	return last_room

## Builds natural language testimonies for the Meeting phase
func generate_crew_testimonies(alive_players: Array[Dictionary], dead_body_event: TimelineEvent) -> Array[TestimonyStatement]:
	var testimonies: Array[TestimonyStatement] = []
	var death_time: float = dead_body_event.timestamp_seconds if dead_body_event != null else 0.0

	for p in alive_players:
		var stmt := TestimonyStatement.new()
		stmt.speaker_id = p["id"]
		stmt.speaker_name = p["name"]
		var is_impostor: bool = p.get("is_impostor", false)

		if is_impostor:
			# Impostor fabricates an alibi or shifts blame
			stmt.claimed_room = "Research Lab" if dead_body_event and dead_body_event.room_name == "Reactor Core" else "Storage"
			stmt.claimed_time = death_time
			stmt.claimed_activity = "Running diagnostic tasks"
			stmt.is_truthful = false
			
			# Check if camera or witness saw the impostor elsewhere
			var true_location: String = get_actor_location_at(p["id"], death_time)
			if true_location != "Unknown" and true_location != stmt.claimed_room:
				stmt.contradiction_reason = "Contradiction: %s claimed to be in %s, but station logs recorded them at %s around %02d:%02d!" % [
					p["name"], stmt.claimed_room, true_location, int(death_time)/60, int(death_time)%60
				]
		else:
			# Honest crewmate reports what they actually did and saw
			var true_room: String = get_actor_location_at(p["id"], death_time)
			stmt.claimed_room = true_room if true_room != "Unknown" else "Central Hub"
			stmt.claimed_time = death_time
			stmt.claimed_activity = "Completing assigned station maintenance"
			stmt.is_truthful = true

			# Check if they observed anyone
			for obs in observations:
				if obs.observer_id == p["id"] and abs(obs.timestamp - death_time) < 30.0:
					stmt.mentioned_actors.append("%s in %s" % [obs.subject_name, obs.room_id])

		testimonies.append(stmt)

	return testimonies
