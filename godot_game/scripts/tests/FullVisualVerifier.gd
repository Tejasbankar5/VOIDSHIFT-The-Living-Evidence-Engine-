extends Node

## Comprehensive Visual Verification Runner.
## Launches VOIDSHIFT, renders Main Menu, simulates input to enter gameplay,
## moves Rex into view of consoles, and captures high-res PNG screenshots.

var frame_count: int = 0
var main_scene: Node = null
var gm: GameManager = null

func _ready() -> void:
	var scene_res := load("res://scenes/main/Main.tscn") as PackedScene
	main_scene = scene_res.instantiate()
	add_child(main_scene)
	gm = main_scene as GameManager

func _process(_delta: float) -> void:
	frame_count += 1

	if frame_count == 20:
		# Capture Main Menu
		var img_menu := get_viewport().get_texture().get_image()
		if img_menu != null:
			var path_menu := "C:/Users/tejas/.gemini/antigravity-ide/brain/63186ede-d23d-467e-b731-75782a7950f8/main_menu_overhaul.png"
			img_menu.save_png(path_menu)
			print("[SUCCESS] Menu Screenshot saved to: " + path_menu)

		# Transition into Gameplay
		if gm != null:
			gm.start_new_match(false)
			# Move Rex near the meeting table and consoles for optimal framing
			gm.player.global_position = Vector2(800, 1010)

	elif frame_count == 50:
		# Capture Gameplay with new HUD, vision cones, props, and Rex
		var img_game := get_viewport().get_texture().get_image()
		if img_game != null:
			var path_game := "C:/Users/tejas/.gemini/antigravity-ide/brain/63186ede-d23d-467e-b731-75782a7950f8/actual_gameplay_screenshot.png"
			img_game.save_png(path_game)
			print("[SUCCESS] Gameplay Screenshot saved to: " + path_game)
		get_tree().quit(0)
