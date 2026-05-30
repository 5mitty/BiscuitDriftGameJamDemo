extends Control

var player: Node3D
var flag_groups: Array = []

const HALF_FOV := PI * 0.5
const OPACITY_NEAR := 30.0
const OPACITY_FAR  := 100.0

func _process(_delta):
	var parent := get_parent_control()
	if parent:
		size = parent.size
		position = Vector2.ZERO
	queue_redraw()

func _draw():
	if not player:
		return

	var w := size.x
	var h := size.y

	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.0, 0.0, 0.0, 0.6))
	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.8, 0.8, 0.8, 0.85), false, 1.5)
	draw_line(Vector2(w * 0.5, 2.0), Vector2(w * 0.5, h - 2.0),
			Color(1.0, 1.0, 1.0, 0.4), 1.0)

	var yaw := player.global_rotation.y + PI
	var phase := _get_phase()
	var col := _phase_color(phase)
	var group: Array = flag_groups[phase] if phase < flag_groups.size() else []

	for flag in group:
		if not is_instance_valid(flag):
			continue
		var flag_node := flag as Node3D
		if flag_node == null:
			continue
		var rel: Vector3 = flag_node.global_position - player.global_position
		var dist: float = rel.length()

		var right_comp: float = rel.x * cos(yaw) - rel.z * sin(yaw)
		var fwd_comp: float = -(rel.x * sin(yaw) + rel.z * cos(yaw))
		var rel_b: float = atan2(right_comp, fwd_comp)

		var pinned: bool = abs(rel_b) > HALF_FOV
		var clamped: float = clamp(rel_b, -HALF_FOV, HALF_FOV)
		var x: float = w * 0.5 + (clamped / HALF_FOV) * (w * 0.5)

		var t: float = clamp(1.0 - (dist - OPACITY_NEAR) / (OPACITY_FAR - OPACITY_NEAR), 0.0, 1.0)
		var alpha: float = lerp(0.8, 1.0, t)

		var draw_col: Color = col.darkened(0.35) if pinned else col
		draw_col.a = alpha

		var tip := Vector2(x, h - 4.0)
		var bl  := Vector2(x - 7.0, 4.0)
		var br  := Vector2(x + 7.0, 4.0)
		draw_colored_polygon(PackedVector2Array([tip, bl, br]), draw_col)


func _get_phase() -> int:
	if not player:
		return 0
	return player.current_game_phase

func _phase_color(phase: int) -> Color:
	match phase:
		0: return Color(1.0, 0.9, 0.1)
		1: return Color(0.2, 1.0, 0.45)
		2: return Color(1.0, 0.35, 0.3)
		3: return Color(0.4, 0.9, 1.0)
	return Color.WHITE
