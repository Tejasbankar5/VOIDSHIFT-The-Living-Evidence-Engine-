extends Node2D

var frames: int = 0
var main_inst: GameManager = null

func _ready() -> void:
	var main_scene := load("res://scenes/main/Main.tscn") as PackedScene
	main_inst = main_scene.instantiate() as GameManager
	add_child(main_inst)
	# Switch directly to Academic Lab mode
	main_inst.set_state(GameEnums.GameState.ACADEMIC_LAB)

func _process(_delta: float) -> void:
	frames += 1
	if frames == 25:
		var tex := get_viewport().get_texture()
		if tex:
			var img := tex.get_image()
			if img:
				var path := "C:/Users/tejas/.gemini/antigravity-ide/brain/63186ede-d23d-467e-b731-75782a7950f8/academic_lab_screenshot.png"
				img.save_png(path)
				print("[CAPTURE_SUCCESS] Saved academic lab screenshot to: " + path)
		get_tree().quit(0)
