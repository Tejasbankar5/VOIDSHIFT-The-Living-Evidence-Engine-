class_name AcademicMatrix2D
extends RefCounted

## Academic 3x3 Matrix for 2D Homogeneous Transformations
## Implemented as part of TY B.Tech Computer Graphics curriculum.
## Corresponds to src/Matrix.h and src/Matrix.cpp from the original OpenGL engine.

var m: Array[Array] = [
	[1.0, 0.0, 0.0],
	[0.0, 1.0, 0.0],
	[0.0, 0.0, 1.0]
]

func _init() -> void:
	load_identity()

func load_identity() -> void:
	m = [
		[1.0, 0.0, 0.0],
		[0.0, 1.0, 0.0],
		[0.0, 0.0, 1.0]
	]

static func identity() -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	return mat

static func translation(tx: float, ty: float) -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[0][2] = tx
	mat.m[1][2] = ty
	return mat

static func scaling(sx: float, sy: float) -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[0][0] = sx
	mat.m[1][1] = sy
	return mat

static func rotation(radians: float) -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	var c := cos(radians)
	var s := sin(radians)
	mat.m[0][0] = c
	mat.m[0][1] = -s
	mat.m[1][0] = s
	mat.m[1][1] = c
	return mat

static func reflection_x() -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[1][1] = -1.0 # Invert Y-coordinates
	return mat

static func reflection_y() -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[0][0] = -1.0 # Invert X-coordinates
	return mat

static func reflection_origin() -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[0][0] = -1.0
	mat.m[1][1] = -1.0
	return mat

static func shear_x(shx: float) -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[0][1] = shx
	return mat

static func shear_y(shy: float) -> AcademicMatrix2D:
	var mat := AcademicMatrix2D.new()
	mat.m[1][0] = shy
	return mat

func multiply(other: AcademicMatrix2D) -> AcademicMatrix2D:
	var result := AcademicMatrix2D.new()
	for i in range(3):
		for j in range(3):
			result.m[i][j] = 0.0
			for k in range(3):
				result.m[i][j] += m[i][k] * other.m[k][j]
	return result

func transform_point(p: Vector2) -> Vector2:
	var x: float = m[0][0] * p.x + m[0][1] * p.y + m[0][2] * 1.0
	var y: float = m[1][0] * p.x + m[1][1] * p.y + m[1][2] * 1.0
	var w: float = m[2][0] * p.x + m[2][1] * p.y + m[2][2] * 1.0
	if abs(w) > 0.00001 and abs(w - 1.0) > 0.00001:
		return Vector2(x / w, y / w)
	return Vector2(x, y)

func transform_polygon(polygon: PackedVector2Array) -> PackedVector2Array:
	var transformed := PackedVector2Array()
	for pt in polygon:
		transformed.append(transform_point(pt))
	return transformed

func to_format_string() -> String:
	return "[%.2f, %.2f, %.2f]\n[%.2f, %.2f, %.2f]\n[%.2f, %.2f, %.2f]" % [
		m[0][0], m[0][1], m[0][2],
		m[1][0], m[1][1], m[1][2],
		m[2][0], m[2][1], m[2][2]
	]
