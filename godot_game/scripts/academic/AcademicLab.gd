class_name AcademicLab
extends Control

## Interactive Academic Laboratory & Computer Graphics Algorithm Visualizer
## Developed for TY B.Tech Computer Graphics and Gaming assessment.
## Provides real-time rendering, step calculations, matrix displays, and interactive controls.

const GraphicsAlgorithms = preload("res://scripts/academic/GraphicsAlgorithms.gd")
const AcademicMatrix2D = preload("res://scripts/academic/AcademicMatrix2D.gd")

signal exit_requested()

enum Mode {
	DDA_LINE = 1,
	BRESENHAM_LINE = 2,
	MIDPOINT_CIRCLE = 3,
	BRESENHAM_CIRCLE = 4,
	TRANSLATION = 5,
	SCALING = 6,
	ROTATION = 7,
	REFLECTION = 8,
	SHEARING = 9,
	COMPOSITE_TRANSFORM = 10,
	COORDINATE_SYSTEM = 11,
	COLOR_MODELS = 12
}

var current_mode: Mode = Mode.DDA_LINE

# Transformation Parameters
var trans_x: float = 0.0
var trans_y: float = 0.0
var scale_x: float = 1.0
var scale_y: float = 1.0
var rot_angle: float = 0.0
var shear_x: float = 0.0
var shear_y: float = 0.0
var reflect_x: bool = false
var reflect_y: bool = false

# Academic sample shape (Rocket / Spaceship polygon)
var base_polygon: PackedVector2Array = [
	Vector2(0, -50),
	Vector2(30, 30),
	Vector2(15, 20),
	Vector2(15, 50),
	Vector2(-15, 50),
	Vector2(-15, 20),
	Vector2(-30, 30)
]

# Color model parameters
var color_r: float = 0.9
var color_g: float = 0.4
var color_b: float = 0.2

var anim_timer: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(1280, 720)

func _process(delta: float) -> void:
	anim_timer += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		var key_ev := event as InputEventKey
		var keycode: Key = key_ev.keycode
		if keycode >= KEY_1 and keycode <= KEY_9:
			current_mode = (int(keycode) - int(KEY_0)) as Mode
			reset_transforms()
		elif keycode == KEY_0:
			current_mode = Mode.COMPOSITE_TRANSFORM
			reset_transforms()
		elif keycode == KEY_C:
			current_mode = Mode.COORDINATE_SYSTEM
		elif keycode == KEY_K:
			current_mode = Mode.COLOR_MODELS
		elif keycode == KEY_ESCAPE:
			exit_requested.emit()
		elif keycode == KEY_R:
			reset_transforms()

		# Interactive transformation controls
		match current_mode:
			Mode.TRANSLATION:
				if keycode == KEY_W: trans_y -= 15.0
				elif keycode == KEY_S: trans_y += 15.0
				elif keycode == KEY_A: trans_x -= 15.0
				elif keycode == KEY_D: trans_x += 15.0
			Mode.SCALING:
				if keycode == KEY_W: scale_y += 0.15
				elif keycode == KEY_S: scale_y = maxf(0.2, scale_y - 0.15)
				elif keycode == KEY_A: scale_x = maxf(0.2, scale_x - 0.15)
				elif keycode == KEY_D: scale_x += 0.15
			Mode.ROTATION:
				if keycode == KEY_A: rot_angle -= 0.2
				elif keycode == KEY_D: rot_angle += 0.2
			Mode.REFLECTION:
				if keycode == KEY_X: reflect_x = not reflect_x
				elif keycode == KEY_Y: reflect_y = not reflect_y
			Mode.SHEARING:
				if keycode == KEY_W: shear_x += 0.15
				elif keycode == KEY_S: shear_x -= 0.15
				elif keycode == KEY_A: shear_y -= 0.15
				elif keycode == KEY_D: shear_y += 0.15
			Mode.COLOR_MODELS:
				if keycode == KEY_U: color_r = fmod(color_r + 0.15, 1.0)
				elif keycode == KEY_I: color_g = fmod(color_g + 0.15, 1.0)
				elif keycode == KEY_O: color_b = fmod(color_b + 0.15, 1.0)

func reset_transforms() -> void:
	trans_x = 0.0
	trans_y = 0.0
	scale_x = 1.0
	scale_y = 1.0
	rot_angle = 0.0
	shear_x = 0.0
	shear_y = 0.0
	reflect_x = false
	reflect_y = false

func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.04, 0.06, 0.10))

	# Top Header Bar
	draw_rect(Rect2(20, 15, 1240, 75), Color(0.08, 0.12, 0.18, 0.95))
	draw_rect(Rect2(20, 15, 1240, 75), Color(0.3, 0.6, 0.9), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(40, 42), "TY B.TECH COMPUTER GRAPHICS & GAMING — ACADEMIC ALGORITHM LAB", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1))
	draw_string(ThemeDB.fallback_font, Vector2(40, 70), "[1]DDA  [2]BresLine  [3]MidCircle  [4]BresCircle | [5]Trans  [6]Scale  [7]Rot  [8]Reflect  [9]Shear  [0]Composite | [C]Coord [K]RGB | ESC=Back", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.95, 0.9, 0.3))

	# Left Theory & Math Panel
	draw_rect(Rect2(20, 105, 420, 595), Color(0.07, 0.10, 0.15, 0.95))
	draw_rect(Rect2(20, 105, 420, 595), Color(0.25, 0.45, 0.65), false, 2.0)

	# Right Canvas Viewport
	var canvas_rect := Rect2(460, 105, 800, 595)
	draw_rect(canvas_rect, Color(0.02, 0.03, 0.05))
	draw_rect(canvas_rect, Color(0.2, 0.5, 0.8), false, 2.0)

	# Grid in viewport
	var center := canvas_rect.get_center()
	draw_line(Vector2(canvas_rect.position.x, center.y), Vector2(canvas_rect.end.x, center.y), Color(0.2, 0.35, 0.5, 0.4), 1.0)
	draw_line(Vector2(center.x, canvas_rect.position.y), Vector2(center.x, canvas_rect.end.y), Color(0.2, 0.35, 0.5, 0.4), 1.0)

	# Render Mode Contents
	match current_mode:
		Mode.DDA_LINE:
			render_dda_mode(center)
		Mode.BRESENHAM_LINE:
			render_bresenham_line_mode(center)
		Mode.MIDPOINT_CIRCLE:
			render_midpoint_circle_mode(center)
		Mode.BRESENHAM_CIRCLE:
			render_bresenham_circle_mode(center)
		Mode.TRANSLATION:
			render_translation_mode(center)
		Mode.SCALING:
			render_scaling_mode(center)
		Mode.ROTATION:
			render_rotation_mode(center)
		Mode.REFLECTION:
			render_reflection_mode(center)
		Mode.SHEARING:
			render_shearing_mode(center)
		Mode.COMPOSITE_TRANSFORM:
			render_composite_mode(center)
		Mode.COORDINATE_SYSTEM:
			render_coordinate_mode(center)
		Mode.COLOR_MODELS:
			render_color_mode(center)

func render_dda_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "ALGORITHM: DDA LINE DRAWING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.3, 0.95, 0.4))
	var lines := [
		"Mathematical Formulation:",
		"dx = x2 - x1,  dy = y2 - y1",
		"steps = max(|dx|, |dy|)",
		"x_inc = dx / steps",
		"y_inc = dy / steps",
		"Plot(round(x), round(y)) at each step.",
		"",
		"Key Viva Points:",
		"- Uses floating-point arithmetic (division).",
		"- Rounding error accumulates over long lines.",
		"- Simpler than Bresenham but slower on hardware.",
		"",
		"Calculated Sample Run:",
		"Line from (-180, -120) to (180, 120)"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	# Plot actual points
	var steps: Array[GraphicsAlgorithms.AlgorithmStep] = GraphicsAlgorithms.dda_line(int(center.x - 220), int(center.y - 140), int(center.x + 220), int(center.y + 140))
	for s in steps:
		draw_circle(Vector2(s.point), 3.0, Color(0.2, 0.95, 0.4))
	# Draw line connector
	draw_line(center - Vector2(220, 140), center + Vector2(220, 140), Color(0.2, 0.95, 0.4, 0.3), 1.0)

func render_bresenham_line_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "ALGORITHM: BRESENHAM LINE DRAWING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.6, 0.2))
	var lines := [
		"Mathematical Formulation:",
		"dx = |x2 - x1|,  dy = |y2 - y1|",
		"Initial Decision Parameter: P0 = 2*dy - dx",
		"If P_k < 0: P_{k+1} = P_k + 2*dy",
		"If P_k >= 0: P_{k+1} = P_k + 2*dy - 2*dx,  y++",
		"",
		"Key Viva Points:",
		"- Pure integer arithmetic — extremely fast!",
		"- No floating-point rounding errors.",
		"- Uses incremental decision parameter.",
		"- Standard baseline for raster displays."
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var steps: Array[GraphicsAlgorithms.AlgorithmStep] = GraphicsAlgorithms.bresenham_line(int(center.x - 220), int(center.y - 140), int(center.x + 220), int(center.y + 140))
	for s in steps:
		draw_circle(Vector2(s.point), 3.0, Color(1.0, 0.6, 0.2))

func render_midpoint_circle_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "ALGORITHM: MIDPOINT CIRCLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.2, 0.85, 1.0))
	var lines := [
		"Mathematical Formulation:",
		"Initial Point: (0, r)",
		"Initial Parameter: P0 = 1 - r",
		"If P_k < 0: P_{k+1} = P_k + 2*x + 1",
		"If P_k >= 0: P_{k+1} = P_k + 2*(x - y) + 1,  y--",
		"",
		"Key Viva Points:",
		"- Uses 8-Way (Octant) Symmetry.",
		"- For each (x, y) point calculated in 1 octant,",
		"  7 other symmetrical points are plotted.",
		"- Evaluates midpoint of circle function f(x, y)."
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var radius: int = 140
	var steps: Array[GraphicsAlgorithms.AlgorithmStep] = GraphicsAlgorithms.midpoint_circle(int(center.x), int(center.y), radius)
	for s in steps:
		draw_circle(Vector2(s.point), 2.5, Color(0.2, 0.85, 1.0))

func render_bresenham_circle_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "ALGORITHM: BRESENHAM CIRCLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.3, 0.8))
	var lines := [
		"Mathematical Formulation:",
		"Initial Decision: D0 = 3 - 2*r",
		"If D_k < 0: D_{k+1} = D_k + 4*x + 6",
		"If D_k >= 0: D_{k+1} = D_k + 4*(x - y) + 10, y--",
		"",
		"Key Viva Points:",
		"- Minimizes radial distance error.",
		"- Integer addition/subtraction only.",
		"- Generates exact rasterized perimeter."
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var radius: int = 140
	var steps: Array[GraphicsAlgorithms.AlgorithmStep] = GraphicsAlgorithms.bresenham_circle(int(center.x), int(center.y), radius)
	for s in steps:
		draw_circle(Vector2(s.point), 2.5, Color(1.0, 0.3, 0.8))

func render_translation_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "2D TRANSFORMATION: TRANSLATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.9, 0.8, 0.2))
	var mat: AcademicMatrix2D = AcademicMatrix2D.translation(trans_x, trans_y)
	var lines := [
		"Matrix Formulation (Homogeneous 3x3):",
		"[ 1   0   tx ]   [ x ]   [ x + tx ]",
		"[ 0   1   ty ] * [ y ] = [ y + ty ]",
		"[ 0   0   1  ]   [ 1 ]   [   1    ]",
		"",
		"Current Translation Values:",
		"tx = %.1f,  ty = %.1f" % [trans_x, trans_y],
		"",
		"Current Matrix:\n" + mat.to_format_string(),
		"",
		"Controls: [W/A/S/D] Translate, [R] Reset"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	# Transformed Shape
	var transformed: PackedVector2Array = mat.transform_polygon(base_polygon)
	var screen_pts := PackedVector2Array()
	for p in transformed:
		screen_pts.append(center + p)
	screen_pts.append(screen_pts[0]) # Close loop
	draw_colored_polygon(screen_pts, Color(0.9, 0.8, 0.2, 0.4))
	draw_polyline(screen_pts, Color(0.9, 0.8, 0.2), 2.5)

func render_scaling_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "2D TRANSFORMATION: SCALING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.3, 0.9, 0.7))
	var mat: AcademicMatrix2D = AcademicMatrix2D.scaling(scale_x, scale_y)
	var lines := [
		"Matrix Formulation:",
		"[ sx  0   0 ]   [ x ]   [ sx * x ]",
		"[ 0   sy  0 ] * [ y ] = [ sy * y ]",
		"[ 0   0   1 ]   [ 1 ]   [   1    ]",
		"",
		"Current Scale Factors:",
		"sx = %.2f,  sy = %.2f" % [scale_x, scale_y],
		"",
		"Current Matrix:\n" + mat.to_format_string(),
		"",
		"Controls: [W/S] Scale Y, [A/D] Scale X, [R] Reset"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var transformed: PackedVector2Array = mat.transform_polygon(base_polygon)
	var screen_pts := PackedVector2Array()
	for p in transformed:
		screen_pts.append(center + p)
	screen_pts.append(screen_pts[0])
	draw_colored_polygon(screen_pts, Color(0.3, 0.9, 0.7, 0.4))
	draw_polyline(screen_pts, Color(0.3, 0.9, 0.7), 2.5)

func render_rotation_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "2D TRANSFORMATION: ROTATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.9, 0.4, 0.9))
	var mat: AcademicMatrix2D = AcademicMatrix2D.rotation(rot_angle)
	var deg := rad_to_deg(rot_angle)
	var lines := [
		"Matrix Formulation (Angle theta):",
		"[ cos(th)  -sin(th)  0 ]   [ x ]",
		"[ sin(th)   cos(th)  0 ] * [ y ]",
		"[    0         0     1 ]   [ 1 ]",
		"",
		"Current Angle: %.1f deg (%.2f rad)" % [deg, rot_angle],
		"",
		"Current Matrix:\n" + mat.to_format_string(),
		"",
		"Controls: [A/D] Rotate, [R] Reset"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var transformed: PackedVector2Array = mat.transform_polygon(base_polygon)
	var screen_pts := PackedVector2Array()
	for p in transformed:
		screen_pts.append(center + p)
	screen_pts.append(screen_pts[0])
	draw_colored_polygon(screen_pts, Color(0.9, 0.4, 0.9, 0.4))
	draw_polyline(screen_pts, Color(0.9, 0.4, 0.9), 2.5)

func render_reflection_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "2D TRANSFORMATION: REFLECTION", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.4, 0.7, 1.0))
	var mat: AcademicMatrix2D = AcademicMatrix2D.identity()
	if reflect_x:
		mat = mat.multiply(AcademicMatrix2D.reflection_x())
	if reflect_y:
		mat = mat.multiply(AcademicMatrix2D.reflection_y())

	var lines := [
		"Reflection Types:",
		"About X-axis: y' = -y",
		"About Y-axis: x' = -x",
		"About Origin: x' = -x, y' = -y",
		"",
		"Active Reflections:",
		"X-axis (Flip Y): %s" % ("YES" if reflect_x else "NO"),
		"Y-axis (Flip X): %s" % ("YES" if reflect_y else "NO"),
		"",
		"Current Matrix:\n" + mat.to_format_string(),
		"",
		"Controls: [X] Toggle Flip Y, [Y] Toggle Flip X, [R] Reset"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var transformed: PackedVector2Array = mat.transform_polygon(base_polygon)
	var screen_pts := PackedVector2Array()
	for p in transformed:
		screen_pts.append(center + p)
	screen_pts.append(screen_pts[0])
	draw_colored_polygon(screen_pts, Color(0.4, 0.7, 1.0, 0.4))
	draw_polyline(screen_pts, Color(0.4, 0.7, 1.0), 2.5)

func render_shearing_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "2D TRANSFORMATION: SHEARING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.5, 0.4))
	var mat: AcademicMatrix2D = AcademicMatrix2D.shear_x(shear_x).multiply(AcademicMatrix2D.shear_y(shear_y))
	var lines := [
		"Matrix Formulation:",
		"X-Shear: x' = x + shx*y, y' = y",
		"Y-Shear: x' = x, y' = shy*x + y",
		"",
		"Current Shear Factors:",
		"shx = %.2f,  shy = %.2f" % [shear_x, shear_y],
		"",
		"Current Matrix:\n" + mat.to_format_string(),
		"",
		"Controls: [W/S] Shear X, [A/D] Shear Y, [R] Reset"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var transformed: PackedVector2Array = mat.transform_polygon(base_polygon)
	var screen_pts := PackedVector2Array()
	for p in transformed:
		screen_pts.append(center + p)
	screen_pts.append(screen_pts[0])
	draw_colored_polygon(screen_pts, Color(1.0, 0.5, 0.4, 0.4))
	draw_polyline(screen_pts, Color(1.0, 0.5, 0.4), 2.5)

func render_composite_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "COMPOSITE TRANSFORMATIONS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.95, 0.3))
	var t: AcademicMatrix2D = AcademicMatrix2D.translation(sin(anim_timer * 2.0) * 80.0, 0.0)
	var r: AcademicMatrix2D = AcademicMatrix2D.rotation(anim_timer * 1.5)
	var s: AcademicMatrix2D = AcademicMatrix2D.scaling(1.2 + sin(anim_timer * 3.0) * 0.3, 1.2 + sin(anim_timer * 3.0) * 0.3)
	var m: AcademicMatrix2D = t.multiply(r).multiply(s)

	var lines := [
		"Mathematical Concept:",
		"Matrix Multiplication is Non-Commutative:",
		"A * B != B * A in general.",
		"",
		"Order of operations applied:",
		"M = Translation * Rotation * Scale",
		"",
		"Composite Matrix M:\n" + m.to_format_string(),
		"",
		"Key Viva Points:",
		"- Allows combining multiple transforms into a single",
		"  3x3 matrix multiplication per vertex."
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	var transformed: PackedVector2Array = m.transform_polygon(base_polygon)
	var screen_pts := PackedVector2Array()
	for p in transformed:
		screen_pts.append(center + p)
	screen_pts.append(screen_pts[0])
	draw_colored_polygon(screen_pts, Color(1.0, 0.95, 0.3, 0.4))
	draw_polyline(screen_pts, Color(1.0, 0.95, 0.3), 2.5)

func render_coordinate_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "COORDINATE SYSTEMS & VIEWING", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.5, 0.8, 1.0))
	var lines := [
		"Coordinate Spaces:",
		"1. Object / Model Space (local origins)",
		"2. World Space (space station map coordinates)",
		"3. Viewing / Camera Space (player centered)",
		"4. Normalized Device Coordinates (NDC)",
		"5. Screen / Viewport Space (1280x720 pixels)",
		"",
		"Mapping Formula:",
		"x_screen = (x_world - cam_x) * zoom + screen_w / 2",
		"y_screen = (y_world - cam_y) * zoom + screen_h / 2"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	for i in range(-4, 5):
		draw_line(center + Vector2(i * 40, -160), center + Vector2(i * 40, 160), Color(0.3, 0.5, 0.7, 0.3), 1.0)
		draw_line(center + Vector2(-160, i * 40), center + Vector2(160, i * 40), Color(0.3, 0.5, 0.7, 0.3), 1.0)
	draw_circle(center, 6.0, Color(1, 0.3, 0.3))
	draw_string(ThemeDB.fallback_font, center + Vector2(10, -10), "Camera Origin (0, 0)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 0.3, 0.3))

func render_color_mode(center: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(40, 140), "COLOR MODELS: RGB & HSV", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.7, 0.3))
	var col := Color(color_r, color_g, color_b)
	var lines := [
		"RGB Model (Additive Color):",
		"Primary Red, Green, Blue components [0.0 to 1.0]",
		"R = %.2f, G = %.2f, B = %.2f" % [col.r, col.g, col.b],
		"",
		"HSV Model (Perceptual):",
		"Hue = %.1f deg" % [col.h * 360.0],
		"Saturation = %.1f %%" % [col.s * 100.0],
		"Value = %.1f %%" % [col.v * 100.0],
		"",
		"Controls:",
		"[U] Cycle Red, [I] Cycle Green, [O] Cycle Blue"
	]
	var y := 175.0
	for l in lines:
		draw_string(ThemeDB.fallback_font, Vector2(40, y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.9))
		y += 24.0

	draw_rect(Rect2(center.x - 120, center.y - 120, 240, 240), col)
	draw_rect(Rect2(center.x - 120, center.y - 120, 240, 240), Color.WHITE, false, 3.0)
