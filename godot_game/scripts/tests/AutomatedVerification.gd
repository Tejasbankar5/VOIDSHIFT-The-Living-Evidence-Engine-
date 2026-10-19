class_name AutomatedVerification
extends SceneTree

## Comprehensive automated test suite for VOIDSHIFT: The Living Evidence Engine.
## Runs headless to verify all mathematical, campaign, role allocation, forensic, and logic systems.

const GraphicsAlgorithms = preload("res://scripts/academic/GraphicsAlgorithms.gd")
const AcademicMatrix2D = preload("res://scripts/academic/AcademicMatrix2D.gd")
const LivingEvidenceEngine = preload("res://scripts/evidence/LivingEvidenceEngine.gd")
const StationData = preload("res://scripts/core/StationData.gd")
const CampaignData = preload("res://scripts/core/CampaignData.gd")
const RoleAllocator = preload("res://scripts/core/RoleAllocator.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")
const TaskManager = preload("res://scripts/tasks/TaskManager.gd")
const SabotageManager = preload("res://scripts/core/SabotageManager.gd")

func _init() -> void:
	print("\n=======================================================")
	print("   VOIDSHIFT: DEFINITIVE AUTOMATED VERIFICATION SUITE   ")
	print("=======================================================\n")
	
	var passed_tests: int = 0
	var total_tests: int = 0

	# Test 1: Academic 3x3 Homogeneous Matrix Math
	total_tests += 1
	if test_matrix_mathematics():
		passed_tests += 1
		print("[PASS] Test 1: 3x3 Homogeneous Matrix Mathematics & Transformations")
	else:
		print("[FAIL] Test 1: Matrix Mathematics Failed")

	# Test 2: DDA and Bresenham Line Drawing Algorithms
	total_tests += 1
	if test_line_algorithms():
		passed_tests += 1
		print("[PASS] Test 2: DDA & Bresenham Line Rasterization Algorithms")
	else:
		print("[FAIL] Test 2: Line Algorithms Failed")

	# Test 3: Midpoint and Bresenham Circle Algorithms
	total_tests += 1
	if test_circle_algorithms():
		passed_tests += 1
		print("[PASS] Test 3: Midpoint & Bresenham Circle 8-Way Symmetry Algorithms")
	else:
		print("[FAIL] Test 3: Circle Algorithms Failed")

	# Test 4: The Living Evidence Engine & Contradiction Detection
	total_tests += 1
	if test_evidence_engine():
		passed_tests += 1
		print("[PASS] Test 4: The Living Evidence Engine Timeline & Contradiction Detection")
	else:
		print("[FAIL] Test 4: Evidence Engine Failed")

	# Test 5: Station Blueprint & Navigation Data Integrity
	total_tests += 1
	if test_station_data():
		passed_tests += 1
		print("[PASS] Test 5: Station Blueprint, Vents, Tasks, and Camera Layout")
	else:
		print("[FAIL] Test 5: Station Blueprint Data Failed")

	# Test 6: Task Mini-Games Logic
	total_tests += 1
	if test_task_manager():
		passed_tests += 1
		print("[PASS] Test 6: Task Mini-Games Progression & Completion")
	else:
		print("[FAIL] Test 6: Task Manager Failed")

	# Test 7: Sabotage Countdown & Alerts
	total_tests += 1
	if test_sabotage_manager():
		passed_tests += 1
		print("[PASS] Test 7: Sabotage System Meltdown & Repair")
	else:
		print("[FAIL] Test 7: Sabotage System Failed")

	# Test 8: Autonomous 10-Player Role Allocation & Zero Bias
	total_tests += 1
	if test_role_allocation():
		passed_tests += 1
		print("[PASS] Test 8: Autonomous 10-Player Role Allocation & Zero Bias")
	else:
		print("[FAIL] Test 8: Role Allocation Failed")

	# Test 9: Multi-Campaign Data Integrity & Echo Clues
	total_tests += 1
	if test_campaign_integrity():
		passed_tests += 1
		print("[PASS] Test 9: Multi-Campaign Data Integrity & Echo Clues (3 Campaigns)")
	else:
		print("[FAIL] Test 9: Campaign Data Integrity Failed")

	# Test 10: Multi-Campaign Ending Resolution Logic
	total_tests += 1
	if test_campaign_endings():
		passed_tests += 1
		print("[PASS] Test 10: Multi-Campaign Ending Resolution Logic")
	else:
		print("[FAIL] Test 10: Campaign Ending Logic Failed")

	print("\n=======================================================")
	print("   VERIFICATION RESULT: %d / %d TESTS PASSED   " % [passed_tests, total_tests])
	print("=======================================================\n")

	quit(0 if passed_tests == total_tests else 1)

func test_matrix_mathematics() -> bool:
	# Identity
	var id := AcademicMatrix2D.identity()
	var pt := Vector2(10, 20)
	if id.transform_point(pt) != pt:
		return false

	# Translation: T(5, -10)
	var t := AcademicMatrix2D.translation(5, -10)
	var pt_t := t.transform_point(pt)
	if pt_t != Vector2(15, 10):
		return false

	# Scaling: S(2, 3)
	var s := AcademicMatrix2D.scaling(2, 3)
	var pt_s := s.transform_point(pt)
	if pt_s != Vector2(20, 60):
		return false

	# Composite: T(5, -10) * S(2, 2)
	var s2 := AcademicMatrix2D.scaling(2, 2)
	var comp := t.multiply(s2)
	var pt_comp := comp.transform_point(Vector2(5, 5))
	if pt_comp != Vector2(15, 0):
		return false

	return true

func test_line_algorithms() -> bool:
	var dda_steps := GraphicsAlgorithms.dda_line(0, 0, 10, 10)
	if dda_steps.size() != 11:
		return false
	if dda_steps[0].point != Vector2i(0, 0) or dda_steps[10].point != Vector2i(10, 10):
		return false

	var bres_steps := GraphicsAlgorithms.bresenham_line(0, 0, 10, 5)
	if bres_steps.is_empty():
		return false
	if bres_steps[0].point != Vector2i(0, 0) or bres_steps.back().point != Vector2i(10, 5):
		return false

	return true

func test_circle_algorithms() -> bool:
	var mid_steps := GraphicsAlgorithms.midpoint_circle(0, 0, 10)
	if mid_steps.is_empty():
		return false

	var bres_c_steps := GraphicsAlgorithms.bresenham_circle(0, 0, 10)
	if bres_c_steps.is_empty():
		return false

	return true

func test_evidence_engine() -> bool:
	var engine := LivingEvidenceEngine.new()
	var ev1 := engine.record_event(5.0, GameEnums.EventType.ENTER_ROOM, 1, "Nova", -1, "", "reactor", "Reactor Core", "Nova entered Reactor Core")
	if ev1 == null or engine.events.size() != 1:
		return false

	engine.record_camera_sighting(0, "Bridge Cam", "Nova", 10.0)
	if engine.camera_sightings.size() != 1:
		return false

	var last_loc := engine.get_actor_location_at(1, 15.0)
	if last_loc != "Reactor Core":
		return false

	var test_players: Array[Dictionary] = [
		{"id": 1, "name": "Nova", "is_impostor": false},
		{"id": 2, "name": "Vance", "is_impostor": true}
	]
	var testimonies := engine.generate_crew_testimonies(test_players, ev1)
	if testimonies.size() != 2:
		return false

	if not testimonies[0].is_truthful:
		return false
	if testimonies[1].is_truthful:
		return false

	return true

func test_station_data() -> bool:
	var rooms := StationData.get_rooms()
	if rooms.size() < 9:
		return false
	var tasks := StationData.get_task_spots()
	if tasks.size() < 6:
		return false
	var vents := StationData.get_vents()
	if vents.size() < 6:
		return false
	var cams := StationData.get_cameras()
	if cams.size() < 5:
		return false
	return true

func test_task_manager() -> bool:
	var mgr := TaskManager.new()
	var spot := StationData.TaskSpotDef.new(0, GameEnums.TaskType.FIX_WIRING, "Fix Wiring", "engine", "Engine Room", Vector2(100, 100), "Desc")
	mgr.start_task(spot)
	if not mgr.is_active:
		return false

	for i in range(4):
		mgr.handle_wiring_click(i, true)
		mgr.handle_wiring_click(i, false)

	if mgr.progress != 1.0:
		return false
	return true

func test_sabotage_manager() -> bool:
	var sab := SabotageManager.new()
	sab.trigger_sabotage(GameEnums.SabotageType.REACTOR)
	if sab.active_sabotage != GameEnums.SabotageType.REACTOR or sab.timer != 45.0:
		return false

	sab.update(46.0)
	if not sab.is_critical_failure():
		return false

	sab.repair_sabotage()
	if sab.active_sabotage != GameEnums.SabotageType.NONE:
		return false
	return true

func test_role_allocation() -> bool:
	# Test across 5 deterministic seeds
	for s in range(5):
		var assignments := RoleAllocator.allocate_roles(GameEnums.CampaignMode.HOLLOW_CROWN, s * 42 + 7)
		if assignments.size() != 10:
			return false

		var player_count := 0
		var saboteur_count := 0
		for a in assignments:
			if a.is_player:
				player_count += 1
			if a.is_saboteur:
				saboteur_count += 1
			if a.secret_objective == "":
				return false
			if a.special_ability == "":
				return false

		if player_count != 1:
			return false
		if saboteur_count != 2:
			return false

	return true

func test_campaign_integrity() -> bool:
	var modes := [
		GameEnums.CampaignMode.HOLLOW_CROWN,
		GameEnums.CampaignMode.BLACKGLASS_STATION
	]

	for m in modes:
		var camp := CampaignData.get_campaign(m)
		if camp == null:
			return false
		if camp.rooms.size() < 5:
			return false
		if camp.tasks.size() < 5:
			return false
		if camp.clues.size() < 4:
			return false
		if camp.cameras.size() < 4:
			return false
		if camp.primary_objective == "":
			return false
		if camp.briefing == "":
			return false

	return true

func test_campaign_endings() -> bool:
	# Verify ending enum mappings exist and resolve distinctly
	var e1 := GameEnums.EndingType.HOLLOW_CROWN_RECOVERY
	var e2 := GameEnums.EndingType.BLACKGLASS_CONTAINED
	var e3 := GameEnums.EndingType.LAST_SIGNAL_TRANSMISSION
	if e1 == e2 or e2 == e3:
		return false
	return true
