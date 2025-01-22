extends RigidBody3D

var goal
var being_moved: bool = false
var pull_power = 8
# Called when the node enters the scene tree for the first time.
@rpc("any_peer", "call_local")
func set_goal(new_goal):
	goal = new_goal

@rpc("any_peer", "call_local")
func set_being_moved(condition: bool):
	being_moved = condition
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if being_moved == true:
		print("im being picked up")
	if goal != null:
		var a = global_transform.origin
		var b = goal.global_transform.origin
		linear_velocity = (b - a) * pull_power
