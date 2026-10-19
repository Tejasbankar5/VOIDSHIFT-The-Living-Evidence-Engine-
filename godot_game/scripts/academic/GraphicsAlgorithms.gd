class_name GraphicsAlgorithms
extends RefCounted

## Academic Computer Graphics Algorithms Library
## Implements DDA Line, Bresenham Line, Midpoint Circle, and Bresenham Circle.
## Corresponds to src/GraphicsAlgorithms.cpp, src/brehsnum.cpp, src/midpoint.cpp from the original OpenGL engine.

class AlgorithmStep:
	var step_index: int = 0
	var point: Vector2i = Vector2i.ZERO
	var decision_param: float = 0.0
	var info: String = ""

	func _init(idx: int, pt: Vector2i, p: float, msg: String) -> void:
		step_index = idx
		point = pt
		decision_param = p
		info = msg

## 1. DDA (Digital Differential Analyzer) Line Algorithm
static func dda_line(x1: int, y1: int, x2: int, y2: int) -> Array[AlgorithmStep]:
	var steps: Array[AlgorithmStep] = []
	var dx: int = x2 - x1
	var dy: int = y2 - y1
	var step_count: int = maxi(absi(dx), absi(dy))
	
	if step_count == 0:
		steps.append(AlgorithmStep.new(0, Vector2i(x1, y1), 0.0, "Start/End point identical"))
		return steps
		
	var x_inc: float = float(dx) / float(step_count)
	var y_inc: float = float(dy) / float(step_count)
	
	var x: float = float(x1)
	var y: float = float(y1)
	
	for i in range(step_count + 1):
		var pt := Vector2i(roundi(x), roundi(y))
		var desc := "Step %d: x=%.2f, y=%.2f -> Plot(%d, %d)" % [i, x, y, pt.x, pt.y]
		steps.append(AlgorithmStep.new(i, pt, 0.0, desc))
		x += x_inc
		y += y_inc
		
	return steps

## 2. Bresenham's Integer Line Drawing Algorithm
static func bresenham_line(x1: int, y1: int, x2: int, y2: int) -> Array[AlgorithmStep]:
	var steps: Array[AlgorithmStep] = []
	var x: int = x1
	var y: int = y1
	var dx: int = absi(x2 - x1)
	var dy: int = absi(y2 - y1)
	var sx: int = 1 if x1 < x2 else -1
	var sy: int = 1 if y1 < y2 else -1
	var err: int = dx - dy
	var step_idx: int = 0

	while true:
		var desc := "Step %d: Plot(%d, %d), P_k=%d" % [step_idx, x, y, err]
		steps.append(AlgorithmStep.new(step_idx, Vector2i(x, y), float(err), desc))
		step_idx += 1
		
		if x == x2 and y == y2:
			break
			
		var e2: int = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy

	return steps

## 3. Midpoint Circle Algorithm (Decision Parameter P0 = 1 - r)
static func midpoint_circle(xc: int, yc: int, radius: int) -> Array[AlgorithmStep]:
	var steps: Array[AlgorithmStep] = []
	var x: int = 0
	var y: int = radius
	var p: int = 1 - radius
	var step_idx: int = 0

	while x <= y:
		var sym_points := get_8_symmetry_points(xc, yc, x, y)
		var desc := "k=%d: x=%d, y=%d, P_k=%d (8 symmetry points plotted)" % [step_idx, x, y, p]
		for pt in sym_points:
			steps.append(AlgorithmStep.new(step_idx, pt, float(p), desc))
		
		step_idx += 1
		x += 1
		if p < 0:
			p += 2 * x + 1
		else:
			y -= 1
			p += 2 * (x - y) + 1

	return steps

## 4. Bresenham's Circle Algorithm (Decision Parameter P0 = 3 - 2r)
static func bresenham_circle(xc: int, yc: int, radius: int) -> Array[AlgorithmStep]:
	var steps: Array[AlgorithmStep] = []
	var x: int = 0
	var y: int = radius
	var d: int = 3 - 2 * radius
	var step_idx: int = 0

	while x <= y:
		var sym_points := get_8_symmetry_points(xc, yc, x, y)
		var desc := "k=%d: x=%d, y=%d, D_k=%d (8 symmetry points)" % [step_idx, x, y, d]
		for pt in sym_points:
			steps.append(AlgorithmStep.new(step_idx, pt, float(d), desc))
			
		step_idx += 1
		if d < 0:
			d = d + 4 * x + 6
		else:
			d = d + 4 * (x - y) + 10
			y -= 1
		x += 1

	return steps

## Helper: 8-Fold Symmetry for Circles
static func get_8_symmetry_points(xc: int, yc: int, x: int, y: int) -> Array[Vector2i]:
	var points: Array[Vector2i] = [
		Vector2i(xc + x, yc + y),
		Vector2i(xc - x, yc + y),
		Vector2i(xc + x, yc - y),
		Vector2i(xc - x, yc - y),
		Vector2i(xc + y, yc + x),
		Vector2i(xc - y, yc + x),
		Vector2i(xc + y, yc - x),
		Vector2i(xc - y, yc - x)
	]
	return points
