extends VehicleBody3D

@export var max_steer = 0.9
@export var engine_power = 300
@onready var seat: Area3D = $seat
@onready var seat_collision: CollisionShape3D = $seat/CollisionShape3D
var current_auth
var driven = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(multiplayer.get_unique_id())


func _process(delta: float) -> void:
	
	#print($".".get_multiplayer_authority())
	if driven:
		steering = move_toward(steering, Input.get_axis("right", "left") * max_steer, delta * 10)
		engine_force = Input.get_axis("backward", "forward") * engine_power

@rpc("any_peer", "call_local")
func _on_seat_sitting(condition: bool, authority) -> void:
	if condition == true:
		driven = true
		seat_collision.disabled = true
		#print(authority)
		set_multiplayer_authority(authority)
		print(authority)
		$MultiplayerSynchronizer.set_multiplayer_authority(authority)
	else: 
		seat_collision.disabled = false
		driven = false


@rpc("any_peer", "call_local")
func handoff(node_name, auth_id):
	node_name.set_multiplayer_authority(auth_id)
