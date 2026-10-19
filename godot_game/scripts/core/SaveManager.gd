class_name SaveManager
extends RefCounted

## Offline Persistence and User Configuration Manager for VOIDSHIFT.
## Saves and loads settings, statistics, and accessibility options to user://

const SAVE_PATH := "user://voidshift_save.json"

static func get_default_data() -> Dictionary:
	return {
		"settings": {
			"master_volume": 0.8,
			"sfx_volume": 0.8,
			"fullscreen": false,
			"screen_shake": true,
			"high_contrast_hud": false,
			"colorblind_mode": "none" # "none", "protanopia", "deuteranopia", "tritanopia"
		},
		"stats": {
			"matches_played": 0,
			"crewmate_victories": 0,
			"saboteur_victories": 0,
			"tasks_completed_lifetime": 0,
			"impostors_ejected_lifetime": 0,
			"highest_score": 0
		}
	}

static func save_game_data(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	var json_str := JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()
	return true

static func load_game_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		var defaults := get_default_data()
		save_game_data(defaults)
		return defaults

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return get_default_data()
	var json_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_err := json.parse(json_str)
	if parse_err != OK:
		return get_default_data()

	var result = json.get_data()
	if result is Dictionary:
		return result
	return get_default_data()

static func record_match_result(is_victory: bool, as_saboteur: bool, tasks_done: int) -> void:
	var data := load_game_data()
	var stats: Dictionary = data.get("stats", {})
	stats["matches_played"] = stats.get("matches_played", 0) + 1
	if is_victory:
		if as_saboteur:
			stats["saboteur_victories"] = stats.get("saboteur_victories", 0) + 1
		else:
			stats["crewmate_victories"] = stats.get("crewmate_victories", 0) + 1
	stats["tasks_completed_lifetime"] = stats.get("tasks_completed_lifetime", 0) + tasks_done
	data["stats"] = stats
	save_game_data(data)
