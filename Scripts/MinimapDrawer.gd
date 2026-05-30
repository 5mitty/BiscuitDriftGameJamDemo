extends Control

var player: Node3D
var flag_groups: Array = []

const WORLD_SCALE := 0.7

func _process(_delta):
	var parent := get_parent_control()
	if parent:
		var s: float = max(min(parent.size.x, parent.size.y), 120.0)
		size = Vector2(s, s)
		position = (parent.size - size) / 2.0
	queue_redraw()

func _draw():
	if not player:
		return

	var center := size / 2.0
	var r: float = min(size.x, size.y) / 2.0

	draw_circle(center, r, Color(0.0, 0.0, 0.0, 0.65))
	draw_arc(center, r, 0.0, TAU, 64, Color(0.85, 0.85, 0.85, 0.9), 2.0)

	var yaw := player.global_rotation.y + PI
	var phase := _get_phase()
	var group: Array = flag_groups[phase] if phase < flag_groups.size() else []

	for flag in group:
		if not is_instance_valid(flag):
			continue
		var flag_node := flag as Node3D
		if flag_node == null:
			continue
		var rel: Vector3 = flag_node.global_position - player.global_position
		var mx: float = rel.x * cos(yaw) - rel.z * sin(yaw)
		var mz: float = rel.x * sin(yaw) + rel.z * cos(yaw)
		var dot := center + Vector2(mx, mz) * WORLD_SCALE
		var to_dot := dot - center
		if to_dot.length() > r - 7.0:
			dot = center + to_dot.normalized() * (r - 7.0)
		draw_circle(dot, 5.5, _phase_color(phase))
		draw_arc(dot, 5.5, 0.0, TAU, 16, Color.WHITE, 1.0)

	draw_circle(center, 5.0, Color.WHITE)
	draw_line(center, center + Vector2(0.0, -12.0), Color.WHITE, 2.0)

func _get_phase() -> int:
	if not player:
		return 0
	if player.packages_delivered >= 3:
		return 3
	if player.flags_grabbed >= 3:
		return 2
	if player.orders_placed >= 3:
		return 1
	return 0

func _phase_color(phase: int) -> Color:
	match phase:
		0: return Color(1.0, 0.9, 0.1)    # yellow — orders
		1: return Color(0.2, 1.0, 0.45)   # green — pickups
		2: return Color(1.0, 0.35, 0.3)   # red — deliveries
		3: return Color(0.4, 0.9, 1.0)    # cyan — depot
	return Color.WHITE
