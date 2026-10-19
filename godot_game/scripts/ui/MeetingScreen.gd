class_name MeetingScreen
extends Control

const CrewmateRenderer = preload("res://scripts/render/CrewmateRenderer.gd")

## Emergency Meeting & Evidence Interrogation Interface for VOIDSHIFT.
## Displays crew statements, live contradiction analysis, and voting mechanisms.

signal meeting_concluded(ejected_character_id: int, is_impostor: bool)

enum MeetingPhase {
	DISCUSSION,
	VOTING,
	EJECTION,
	CONCLUDED
}

var current_phase: MeetingPhase = MeetingPhase.DISCUSSION
var phase_timer: float = 6.0
var reporter_name: String = ""
var reported_body_name: String = ""

var alive_characters: Array[Dictionary] = []
var testimonies: Array[LivingEvidenceEngine.TestimonyStatement] = []
var votes: Dictionary = {} # voter_id -> target_id (-1 for skip)

var ejected_id: int = -2
var ejected_name: String = ""
var ejected_is_impostor: bool = false

var anim_timer: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)

func setup_meeting(p_reporter: String, p_victim: String,
				  chars: Array[Dictionary], testims: Array[LivingEvidenceEngine.TestimonyStatement]) -> void:
	reporter_name = p_reporter
	reported_body_name = p_victim
	alive_characters = chars
	testimonies = testims
	votes.clear()
	current_phase = MeetingPhase.DISCUSSION
	phase_timer = 6.0
	ejected_id = -2
	anim_timer = 0.0
	visible = true

func _process(delta: float) -> void:
	if not visible:
		return

	anim_timer += delta
	phase_timer -= delta

	match current_phase:
		MeetingPhase.DISCUSSION:
			if phase_timer <= 0.0:
				current_phase = MeetingPhase.VOTING
				phase_timer = 12.0
				process_ai_votes()
		MeetingPhase.VOTING:
			if phase_timer <= 0.0 or votes.size() >= alive_characters.size():
				tally_votes()
				current_phase = MeetingPhase.EJECTION
				phase_timer = 5.0
		MeetingPhase.EJECTION:
			if phase_timer <= 0.0:
				current_phase = MeetingPhase.CONCLUDED
				visible = false
				meeting_concluded.emit(ejected_id, ejected_is_impostor)

	queue_redraw()

func process_ai_votes() -> void:
	# AI casts votes based on evidence contradictions
	for c in alive_characters:
		var c_id: int = c["id"]
		if c_id == 0:
			continue # Local human player votes manually
		if c_id in votes:
			continue

		var target: int = -1 # Default skip
		# Check if anyone has an active contradiction
		for t in testimonies:
			if not t.is_truthful and t.contradiction_reason != "":
				target = t.speaker_id
				break
		if target == -1 and randf() < 0.6 and not alive_characters.is_empty():
			var rand_c = alive_characters[randi() % alive_characters.size()]
			if rand_c["id"] != c_id:
				target = rand_c["id"]
		votes[c_id] = target

func tally_votes() -> void:
	var counts: Dictionary = {}
	for v in votes.values():
		counts[v] = counts.get(v, 0) + 1

	var max_v: int = 0
	var winner_id: int = -1
	var is_tie: bool = false

	for target in counts.keys():
		if counts[target] > max_v:
			max_v = counts[target]
			winner_id = target
			is_tie = false
		elif counts[target] == max_v:
			is_tie = true

	if is_tie or winner_id == -1:
		ejected_id = -1
		ejected_name = "Nobody"
		ejected_is_impostor = false
	else:
		ejected_id = winner_id
		for c in alive_characters:
			if c["id"] == winner_id:
				ejected_name = c["name"]
				ejected_is_impostor = c.get("is_impostor", false)
				break

func _gui_input(event: InputEvent) -> void:
	if current_phase != MeetingPhase.VOTING:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_ev := event as InputEventMouseButton
		var mpos: Vector2 = mouse_ev.position
		# Check card vote buttons
		var y := 180.0
		for i in range(alive_characters.size()):
			var btn_rect := Rect2(820, y - 6, 80, 34)
			if btn_rect.has_point(mpos):
				votes[0] = alive_characters[i]["id"]
				return
			y += 54.0

		# Skip button
		var skip_rect := Rect2(920, 580, 160, 40)
		if skip_rect.has_point(mpos):
			votes[0] = -1

func _draw() -> void:
	if current_phase == MeetingPhase.EJECTION:
		draw_ejection_scene()
		return

	# Overlay Backdrop
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.04, 0.06, 0.10, 0.94))

	# Main Meeting Panel
	var panel := Rect2(160, 40, 960, 640)
	draw_rect(panel, Color(0.08, 0.12, 0.18, 0.96))
	draw_rect(panel, Color(0.2, 0.5, 0.8), false, 2.0)

	# Title Banner
	var title_str := "EMERGENCY MEETING — LIVING EVIDENCE REVIEW" if reported_body_name == "" else "DEAD BODY REPORTED BY %s!" % reporter_name.to_upper()
	draw_string(ThemeDB.fallback_font, Vector2(200, 80), title_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 0.35, 0.35))
	var phase_str := "PHASE: DISCUSSION (%ds)" % int(phase_timer) if current_phase == MeetingPhase.DISCUSSION else "PHASE: CAST YOUR VOTE (%ds)" % int(phase_timer)
	draw_string(ThemeDB.fallback_font, Vector2(200, 105), phase_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.9, 0.85, 0.2))

	# Player Testimonies & Cards List
	var y := 150.0
	for i in range(alive_characters.size()):
		var c := alive_characters[i]
		var c_id: int = c["id"]
		var card_rect := Rect2(200, y, 720, 48)
		draw_rect(card_rect, Color(0.12, 0.16, 0.24))
		draw_rect(card_rect, Color(0.25, 0.45, 0.65), false, 1.5)

		# Role icon / color dot
		var role_col: Color = CrewmateRenderer.get_role_color(c.get("role", GameEnums.Role.CREW_DEFAULT))
		draw_circle(Vector2(225, y + 24), 12.0, role_col)

		draw_string(ThemeDB.fallback_font, Vector2(250, y + 22), c["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1))

		# Show testimony statement
		for t in testimonies:
			if t.speaker_id == c_id:
				var stmt_text := "\"I was at %s (%s)\"" % [t.claimed_room, t.claimed_activity]
				draw_string(ThemeDB.fallback_font, Vector2(250, y + 40), stmt_text, HORIZONTAL_ALIGNMENT_LEFT, 460, 10, Color(0.7, 0.85, 0.95))
				# Contradiction Alert Badge
				if not t.is_truthful and t.contradiction_reason != "":
					draw_rect(Rect2(640, y + 6, 170, 22), Color(0.85, 0.1, 0.2, 0.9))
					draw_string(ThemeDB.fallback_font, Vector2(645, y + 21), "[CONTRADICTION!]", HORIZONTAL_ALIGNMENT_CENTER, 160, 10, Color(1, 1, 1))
				break

		# Vote Button for local player during voting phase
		if current_phase == MeetingPhase.VOTING and (not (0 in votes)):
			var btn_rect := Rect2(820, y + 8, 80, 32)
			draw_rect(btn_rect, Color(0.0, 0.7, 0.5))
			draw_string(ThemeDB.fallback_font, Vector2(835, y + 28), "VOTE", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(1, 1, 1))
		elif c_id in votes:
			draw_string(ThemeDB.fallback_font, Vector2(830, y + 28), "[VOTED]", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.3, 0.9, 0.4))

		y += 56.0

	# Skip Vote Button
	if current_phase == MeetingPhase.VOTING:
		var skip_btn := Rect2(920, 580, 160, 40)
		draw_rect(skip_btn, Color(0.3, 0.35, 0.45))
		draw_rect(skip_btn, Color(0.6, 0.7, 0.8), false, 1.5)
		draw_string(ThemeDB.fallback_font, Vector2(940, 605), "SKIP VOTE", HORIZONTAL_ALIGNMENT_CENTER, 120, 12, Color(1, 1, 1))

func draw_ejection_scene() -> void:
	# Space ejection cutscene
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.06))

	# Stars
	for i in range(40):
		var sx: float = fmod(i * 137.0 + anim_timer * 15.0, 1280.0)
		var sy: float = fmod(i * 257.0, 720.0)
		draw_circle(Vector2(sx, sy), 1.5, Color(1, 1, 1, 0.7))

	if ejected_id == -1:
		draw_string(ThemeDB.fallback_font, Vector2(460, 360), "No one was ejected. (Tie / Skipped)", HORIZONTAL_ALIGNMENT_CENTER, 360, 18, Color(1, 1, 1))
	else:
		# Floating rotating astronaut
		var float_x := 1280.0 * (1.0 - (phase_timer / 5.0))
		var float_pos := Vector2(float_x, 340.0)
		CrewmateRenderer.draw_astronaut(self, float_pos, GameEnums.Role.SABOTEUR_IMPOSTOR if ejected_is_impostor else GameEnums.Role.CREW_DEFAULT, false, anim_timer * 4.0, false, false)

		var verdict := "%s was %s." % [ejected_name, "AN IMPOSTOR" if ejected_is_impostor else "NOT An Impostor"]
		var verdict_col := Color(1.0, 0.3, 0.3) if ejected_is_impostor else Color(0.4, 0.9, 0.6)
		draw_string(ThemeDB.fallback_font, Vector2(400, 420), verdict, HORIZONTAL_ALIGNMENT_CENTER, 480, 20, verdict_col)
