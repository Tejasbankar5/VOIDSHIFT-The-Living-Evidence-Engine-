extends Node

## Helper to capture gameplay screenshot for visual verification.

var frame_count: int = 0
var main_scene: Node = null

func _ready() -> void:
	var scene_res := load("res://scenes/main/Main.tscn") as PackedScene
	main_scene = scene_res.instantiate()
	add_child(main_scene)
	# Start gameplay immediately
	var gm := main_scene as GameManager
	if gm:
		gm.start_new_match(false)

func _process(_delta: float) -> void:
	frame_count += 1
	if frame_count == 30:
		# Save screenshot
		var img := get_viewport().get_texture().get_image()
		if img != null:
			var save_path := "C:/Users/tejas/.gemini/antigravity-ide/brain/63186ede-d23d-467e-b731-75782a7950f8/actual_gameplay_screenshot.png"
			img.save_png(save_path)
			print("[SUCCESS] Screenshot saved to: " + save_path)
		get_tree().quit(0)
