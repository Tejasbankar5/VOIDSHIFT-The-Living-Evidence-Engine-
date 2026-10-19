extends Node2D

const GameManager = preload("res://scripts/core/GameManager.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")

var frames: int = 0
var main_inst: GameManager = null
var artifact_dir := "C:/Users/tejas/.gemini/antigravity-ide/brain/6ed7e447-af34-425b-8a50-028e1d46a662"
var docs_dir := "c:/Users/tejas/OneDrive/Apps/Desktop/Zigbee/docs/screenshots"

func _ready() -> void:
	var main_scene := load("res://scenes/main/Main.tscn") as PackedScene
	main_inst = main_scene.instantiate() as GameManager
	add_child(main_inst)

func _process(_delta: float) -> void:
	frames += 1

	if frames == 15:
		# 1. Capture 2-Story Definitive Campaign Main Menu
		save_frame_as("main_menu_overhaul.png", "main_menu.png")

		# Select Campaign 1: The Hollow Crown & Show Briefing
		if main_inst != null:
			main_inst._on_campaign_selected(GameEnums.CampaignMode.HOLLOW_CROWN)

	elif frames == 30:
		# 2. Capture Mission Briefing & Role Reveal
		save_frame_as("hollow_crown_briefing.png", "briefing_reveal.png")

		# Deploy to Hollow Crown Mountain Estate
		if main_inst != null:
			main_inst._on_deploy_requested()
			# Authoritative character positions in 1280x720 illustrated scene
			main_inst.player.global_position = Vector2(480, 360) # Rex (You) in Courtyard
			main_inst.player.is_facing_left = false

			# Position all characters naturally in their respective story locations
			main_inst.player.global_position = Vector2(560, 480) # Rex (You) in Courtyard
			main_inst.player.is_facing_left = false

			var hc_positions := [
				{"name": "Haru", "pos": Vector2(740, 500)},     # Pond & Bridge
				{"name": "Aiko", "pos": Vector2(930, 430)},     # Inner Shrine
				{"name": "Kenji", "pos": Vector2(490, 330)},    # Archive
				{"name": "Sora", "pos": Vector2(280, 470)},     # Tea Room
				{"name": "Ren", "pos": Vector2(380, 590)},      # Moon Gate
				{"name": "Chiyo", "pos": Vector2(620, 450)},    # Sakura Courtyard
				{"name": "Kaede", "pos": Vector2(880, 410)},    # Shrine Torii
				{"name": "Daiki", "pos": Vector2(520, 530)},    # Garden Path
				{"name": "Yuki", "pos": Vector2(410, 340)}      # Archive Scribe
			]
			for idx in range(mini(main_inst.ai_crew.size(), hc_positions.size())):
				main_inst.ai_crew[idx].bot_name = hc_positions[idx]["name"]
				main_inst.ai_crew[idx].global_position = hc_positions[idx]["pos"]

			# Seed authentic recent investigation events
			main_inst.evidence_engine.record_event(
				0.2, GameEnums.EventType.ENTER_ROOM, 0, "Rex", -1, "", "courtyard", "Sakura Courtyard", "Rex arrived at the estate courtyard", false
			)
			main_inst.evidence_engine.record_event(
				0.8, GameEnums.EventType.DISCOVER_ECHO_CLUE, 0, "Rex", -1, "", "courtyard", "Sakura Courtyard", "Crushed cherry blossoms & sandal prints found near tea room", false
			)

	elif frames == 55:
		# 3. Capture The Hollow Crown Gameplay
		save_frame_as("actual_gameplay_screenshot.png", "gameplay.png")
		save_frame_as("hollow_crown_gameplay.png", "hollow_crown.png")

		# Open Interrogation Dialog with Aiko
		if main_inst != null and main_inst.active_campaign != null and main_inst.active_campaign.suspects.size() > 0:
			var aiko = main_inst.active_campaign.suspects[0]
			main_inst.interrogation_dialog.open_interrogation(aiko, main_inst.active_campaign, main_inst.evidence_engine)

	elif frames == 75:
		# 4. Capture Interrogation Dialog
		save_frame_as("interrogation_dialog.png", "interrogation.png")

		# Close Interrogation & Switch to Campaign 2: Blackglass Station
		if main_inst != null:
			main_inst.interrogation_dialog.close_dialogue()
			main_inst._on_campaign_selected(GameEnums.CampaignMode.BLACKGLASS_STATION)
			main_inst._on_deploy_requested()

			# Authoritative character positions aboard Blackglass Station
			main_inst.player.global_position = Vector2(450, 435) # Rex in Corridor Deck A-1
			main_inst.player.is_facing_left = false

			var bg_positions := [
				{"name": "Elara", "pos": Vector2(620, 435)},   # Research Lab Terminal
				{"name": "Kael", "pos": Vector2(560, 210)},    # Observation Lounge
				{"name": "Vance", "pos": Vector2(250, 435)},   # Crew Quarters
				{"name": "Lyra", "pos": Vector2(320, 640)},    # Engineering Bay
				{"name": "Thorne", "pos": Vector2(810, 435)},  # Research Lab
				{"name": "Silas", "pos": Vector2(480, 210)},   # Lounge Terminal
				{"name": "Vesper", "pos": Vector2(360, 435)},  # Quarters Desk
				{"name": "Orion", "pos": Vector2(700, 210)},   # Lounge Window
				{"name": "Novak", "pos": Vector2(880, 640)}    # Engineering Turbine
			]
			for idx in range(mini(main_inst.ai_crew.size(), bg_positions.size())):
				main_inst.ai_crew[idx].bot_name = bg_positions[idx]["name"]
				main_inst.ai_crew[idx].global_position = bg_positions[idx]["pos"]

			# Seed authentic Blackglass Station forensic events
			main_inst.evidence_engine.record_event(
				0.2, GameEnums.EventType.ENTER_ROOM, 0, "Rex", -1, "", "corridor", "Corridor Deck A-1", "Rex initiated blackout telemetry recovery", false
			)
			main_inst.evidence_engine.record_event(
				0.6, GameEnums.EventType.DISCOVER_ECHO_CLUE, 0, "Rex", -1, "", "lab", "Research Lab", "Containment chamber opened; bypass circuit severed", true
			)

	elif frames == 100:
		# 5. Capture Blackglass Station Gameplay
		save_frame_as("blackglass_gameplay.png", "blackglass.png")
		get_tree().quit(0)

func save_frame_as(filename_artifact: String, filename_docs: String) -> void:
	var tex := get_viewport().get_texture()
	if tex:
		var img := tex.get_image()
		if img:
			var path_art := artifact_dir + "/" + filename_artifact
			var path_doc := docs_dir + "/" + filename_docs
			img.save_png(path_art)
			img.save_png(path_doc)
			print("[CAPTURE_SUCCESS] Saved: " + filename_artifact + " & " + filename_docs)
