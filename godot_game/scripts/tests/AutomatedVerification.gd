class_name AutomatedVerification
extends SceneTree

## Comprehensive automated test suite for VOIDSHIFT and Academic CG Algorithms.
## Runs headless to verify all systems, mathematics, evidence logic, and gameplay rules.

const GraphicsAlgorithms = preload("res://scripts/academic/GraphicsAlgorithms.gd")
const AcademicMatrix2D = preload("res://scripts/academic/AcademicMatrix2D.gd")
const LivingEvidenceEngine = preload("res://scripts/evidence/LivingEvidenceEngine.gd")
const StationData = preload("res://scripts/core/StationData.gd")
const GameEnums = preload("res://scripts/core/GameEnums.gd")
const TaskManager = preload("res://scripts/tasks/TaskManager.gd")
const SabotageManager = preload("res://scripts/core/SabotageManager.gd")

func _init() -> void:
	print("\n=======================================================")
	print("   VOIDSHIFT: AUTOMATED VERIFICATION SUITE STARTING   ")
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
	# S(2, 2) * (5, 5) = (10, 10); T(5, -10) * (10, 10) = (15, 0)
	if pt_comp != Vector2(15, 0):
		return false

	return true

func test_line_algorithms() -> bool:
	# DDA Line
	var dda_steps := GraphicsAlgorithms.dda_line(0, 0, 10, 10)
	if dda_steps.size() != 11:
		return false
	if dda_steps[0].point != Vector2i(0, 0) or dda_steps[10].point != Vector2i(10, 10):
		return false

	# Bresenham Line
	var bres_steps := GraphicsAlgorithms.bresenham_line(0, 0, 10, 5)
	if bres_steps.is_empty():
		return false
	if bres_steps[0].point != Vector2i(0, 0) or bres_steps.back().point != Vector2i(10, 5):
		return false

	return true

func test_circle_algorithms() -> bool:
	var mid_steps := GraphicsAlgorithms.midpoint_circle(0, 0, 20)
	if mid_steps.is_empty():
		return false
	# Points must lie near radius 20
	var first_pt := mid_steps[0].point
	var dist := sqrt(float(first_pt.x * first_pt.x + first_pt.y * first_pt.y))
	if abs(dist - 20.0) > 1.5:
		return false

	var bres_steps := GraphicsAlgorithms.bresenham_circle(0, 0, 25)
	if bres_steps.is_empty():
		return false

	return true

func test_evidence_engine() -> bool:
	var engine := LivingEvidenceEngine.new()
	# Record move event
	var ev1 := engine.record_event(30.0, GameEnums.EventType.ENTER_ROOM, 1, "Nova", -1, "", "reactor", "Reactor Core", "Nova entered Reactor Core")
	if ev1.actor_name != "Nova" or ev1.formatted_time != "00:30":
		return false

	# Record observation
	engine.record_observation(2, 1, "Nova", "Reactor Core", 32.0, "Near Console")
	if engine.observations.is_empty():
		return false

	# Record Camera Sighting
	engine.record_camera_sighting(1, "Reactor Corridor Cam", "Nova", 31.0)
	if engine.camera_sightings.is_empty():
		return false

	# Generate testimonies and test contradiction
	var living: Array[Dictionary] = [
		{"id": 1, "name": "Nova", "is_impostor": true},
		{"id": 2, "name": "Astra", "is_impostor": false}
	]
	var testims := engine.generate_crew_testimonies(living, ev1)
	if testims.size() != 2:
		return false

	# Nova is impostor and claimed false alibi while true room was Reactor Core
	var nova_stmt: LivingEvidenceEngine.TestimonyStatement = testims[0]
	if nova_stmt.is_truthful or nova_stmt.contradiction_reason == "":
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

	# Connect 4 wires
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
