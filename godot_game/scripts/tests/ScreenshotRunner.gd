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
		# 1. Capture 3-Campaign Selection Main Menu
		save_frame_as("main_menu_overhaul.png", "main_menu.png")

		# Select Campaign 1: The Hollow Crown & Show Briefing
		if main_inst != null:
			main_inst._on_campaign_selected(GameEnums.CampaignMode.HOLLOW_CROWN)

	elif frames == 30:
		# 2. Capture Mission Briefing & Role Reveal
		save_frame_as("hollow_crown_briefing.png", "briefing_reveal.png")

		# Deploy to sector
		if main_inst != null:
			main_inst._on_deploy_requested()
			main_inst.player.global_position = Vector2(750, 1050)
			main_inst.player.is_facing_left = false
			# Position crew members across rooms
			if main_inst.ai_crew.size() >= 4:
				main_inst.ai_crew[0].global_position = Vector2(1250, 420)
				main_inst.ai_crew[1].global_position = Vector2(240, 420)
				main_inst.ai_crew[2].global_position = Vector2(660, 720)
				main_inst.ai_crew[3].global_position = Vector2(1280, 720)
			# Toggle Echo Vision ON
			main_inst._on_player_echo_vision_toggled()
			# Record initial clues & events
			main_inst.evidence_engine.record_event(
				0.5, GameEnums.EventType.ENTER_ROOM, 1, "Nova", -1, "", "gallery", "Inscription Gallery", "Nova deciphered glyphs"
			)
			main_inst.evidence_engine.record_event(
				1.2, GameEnums.EventType.ENTER_ROOM, 2, "Astra", -1, "", "archive", "Buried Archive", "Astra accessed tablets"
			)

	elif frames == 60:
		# 3. Capture The Hollow Crown Gameplay with Echo Vision
		save_frame_as("actual_gameplay_screenshot.png", "gameplay.png")
		save_frame_as("hollow_crown_gameplay.png", "hollow_crown.png")

		# Switch to Campaign 2: Blackglass Station
		if main_inst != null:
			main_inst._on_campaign_selected(GameEnums.CampaignMode.BLACKGLASS_STATION)
			main_inst._on_deploy_requested()
			main_inst.player.global_position = Vector2(750, 1050)

	elif frames == 90:
		# 4. Capture Blackglass Station Gameplay
		save_frame_as("blackglass_gameplay.png", "blackglass.png")

		# Switch to Campaign 3: The Last Signal
		if main_inst != null:
			main_inst._on_campaign_selected(GameEnums.CampaignMode.THE_LAST_SIGNAL)
			main_inst._on_deploy_requested()
			main_inst.player.global_position = Vector2(750, 1050)

	elif frames == 120:
		# 5. Capture The Last Signal Gameplay
		save_frame_as("last_signal_gameplay.png", "last_signal.png")
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
