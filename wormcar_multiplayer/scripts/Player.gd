extends CharacterBody3D



@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
@onready var raycast: RayCast3D = $head/Camera3D/RayCast3D
@onready var pickup_goal: Marker3D = $head/Camera3D/pickup_goal

@onready var nickname: Label3D = $PlayerNick/Nickname

@export var look_sensitivity: float = 0.006
var SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _respawn_point = Vector3(0, 5, 0)
var seat: Node3D
var driving = false
var picked_object


func _enter_tree():
	$head/Camera3D.current = is_multiplayer_authority()


func _ready():
	pass
	

func _unhandled_input(event):
	if not is_multiplayer_authority():
		print("oh no")
		return
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if !driving:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				head.rotation = Vector3.ZERO
				rotate_y(-event.relative.x * look_sensitivity)
				camera_3d.rotate_x(-event.relative.y * look_sensitivity)
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	else:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				head.rotate_y(-event.relative.x * look_sensitivity)
				head.rotation.y = clamp(head.rotation.y, deg_to_rad(-90), deg_to_rad(90))
				camera_3d.rotate_x(-event.relative.y * look_sensitivity)
				camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if !driving:
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		move_and_slide()
	else:
		global_position = seat.global_position
		global_rotation = seat.global_rotation
		
	if Input.is_action_just_pressed("interact"):
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("interactable") and picked_object == null:
				var collider = raycast.get_collider()
				if collider.being_moved == true:
					pass
				else:
					picked_object = collider
					picked_object.set_goal.rpc(pickup_goal)
					picked_object.set_being_moved.rpc(true)
			elif picked_object != null or raycast.get_collider() == picked_object:
				picked_object.set_goal.rpc(null)
				picked_object.set_being_moved.rpc(false)
				picked_object = null
			if !driving:
				if raycast.get_collider().name.contains("seat"):
					seat = raycast.get_collider()
					seat.get_sat_on(true,get_multiplayer_authority())
					driving = true
			else:
				if seat != null:
					seat.get_sat_on.rpc(false, 0)
				driving = false

func freeze():
	velocity.x = 0
	velocity.z = 0
	SPEED = 0


func _check_fall_and_respawn():
	if global_transform.origin.y < -15.0:
		_respawn()
		
func _respawn():
	global_transform.origin = _respawn_point
	velocity = Vector3.ZERO
