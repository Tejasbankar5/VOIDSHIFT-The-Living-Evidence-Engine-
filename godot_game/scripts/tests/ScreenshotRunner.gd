extends Node2D

var frames: int = 0
var main_inst: GameManager = null

func _ready() -> void:
	var main_scene := load("res://scenes/main/Main.tscn") as PackedScene
	main_inst = main_scene.instantiate() as GameManager
	add_child(main_inst)

func _process(_delta: float) -> void:
	frames += 1

	if frames == 15:
		# Capture Overhauled Main Menu Title Screen
		var tex := get_viewport().get_texture()
		if tex:
			var img := tex.get_image()
			if img:
				var path_curr := "C:/Users/tejas/.gemini/antigravity-ide/brain/6ed7e447-af34-425b-8a50-028e1d46a662/main_menu_overhaul.png"
				var path_prev := "C:/Users/tejas/.gemini/antigravity-ide/brain/63186ede-d23d-467e-b731-75782a7950f8/main_menu_overhaul.png"
				img.save_png(path_curr)
				img.save_png(path_prev)
				print("[CAPTURE_SUCCESS] Saved menu screenshot to: " + path_curr)

		# Now start match and position player near the meeting console
		if main_inst != null:
			main_inst.start_new_match(false)
			main_inst.player.global_position = Vector2(750, 1050)
			main_inst.player.is_facing_left = false
			# Keep AI characters in their respective sectors so they don't overlap Rex
			if main_inst.ai_crew.size() >= 4:
				main_inst.ai_crew[0].global_position = Vector2(1250, 420) # Nova in Lab
				main_inst.ai_crew[1].global_position = Vector2(240, 420)  # Astra in Medical
				main_inst.ai_crew[2].global_position = Vector2(660, 720)  # Vance in Electrical
				main_inst.ai_crew[3].global_position = Vector2(1280, 720) # Kael in Security
			# Add realistic timeline events so the feed is populated immediately
			main_inst.evidence_engine.record_event(
				0.5, GameEnums.EventType.ENTER_ROOM, 1, "Nova", -1, "", "electrical", "Electrical", "Nova entered Electrical"
			)
			main_inst.evidence_engine.record_event(
				1.2, GameEnums.EventType.ENTER_ROOM, 2, "Astra", -1, "", "medical", "Medical Bay", "Astra left Medical Bay"
			)
			main_inst.evidence_engine.record_event(
				2.0, GameEnums.EventType.TRIGGER_SABOTAGE, 3, "Vance", 1, "Reactor", "reactor", "Reactor Core", "Door opened (Reactor)"
			)

	elif frames == 45:
		# Capture Overhauled Live Gameplay Screen
		var tex := get_viewport().get_texture()
		if tex:
			var img := tex.get_image()
			if img:
				var path_curr := "C:/Users/tejas/.gemini/antigravity-ide/brain/6ed7e447-af34-425b-8a50-028e1d46a662/actual_gameplay_screenshot.png"
				var path_prev := "C:/Users/tejas/.gemini/antigravity-ide/brain/63186ede-d23d-467e-b731-75782a7950f8/actual_gameplay_screenshot.png"
				img.save_png(path_curr)
				img.save_png(path_prev)
				print("[CAPTURE_SUCCESS] Saved gameplay screenshot to: " + path_curr)
		get_tree().quit(0)
