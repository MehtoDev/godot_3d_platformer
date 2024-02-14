extends CharacterBody3D

@export var camera : Node
@onready var camera_cfg = $Camera/SpringArm3D/Camera3D
@onready var raycast = $Camera/SpringArm3D/Camera3D/RayCast3D
@onready var head = $Head
@export var Config : Node

var sensitivity = 0.05
var direction = Vector3()
var wish_jump
var wish_climb
var currently_grappled = false
var grapple_point
var grapple_root
var cable

var RAYS = []
var POINTS = []

#testing
var can_jump := true
var camera_can_move := true

func _ready():
	if is_visible_in_tree():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera_cfg.fov = Config.fov

func _physics_process(delta):
	_delete_objects(delta)
	process_input()
	process_movement(delta)
	move_and_slide()
	
	if currently_grappled:
		cable.queue_free()
		cable = Draw3d.line(global_position, grapple_point.global_position)

func process_input():
	direction = Vector3()
	
	# Movement directions
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("right"):
		direction += transform.basis.x
	if Input.is_action_just_pressed("shoot"):
		if (!currently_grappled):
			grapple()
		else:
			grapple_release()
		
	# Jumping
	wish_jump = Input.is_action_just_pressed("jump")
	wish_climb = Input.is_action_pressed("climb") and camera_can_move

func process_movement(delta):
	var wish_dir = direction.normalized()
	
	if is_on_floor():
		if currently_grappled:
			grapple_release()
		if wish_climb and can_climb():
			climb()
			wish_jump = false
		if wish_jump:
			velocity.y = Config.jump_impulse
			velocity = update_velocity_air(wish_dir, delta)
			wish_jump = false
		else:
			velocity = update_velocity_ground(wish_dir, delta)
	else:
		if(!currently_grappled):
			velocity.y -= Config.gravity * delta
			velocity = update_velocity_air(wish_dir, delta)
		else:
			grapple_root.apply_force(wish_dir * 4, Vector3.ZERO)
		if wish_climb and can_climb():
			climb()
			wish_jump = false
	
	move_and_slide()

func accelerate(wish_dir: Vector3, max_velocity: float, delta):
	# Get our current speed as a projection of velocity onto the wish_dir
	var current_speed = velocity.dot(wish_dir)
	# How much we accelerate is the difference between the max speed and the current speed
	# clamped to be between 0 and MAX_ACCELERATION which is intended to stop you from going too fast
	var add_speed = clamp(max_velocity - current_speed, 0, Config.max_acceleration * delta)
	
	return velocity + add_speed * wish_dir
	
func update_velocity_ground(wish_dir: Vector3, delta):
	# Apply friction when on the ground and then accelerate
	var speed = velocity.length()
	
	if speed != 0:
		var control = max(Config.stop_speed, speed)
		var drop = control * Config.friction * delta
		
		# Scale the velocity based on friction
		velocity *= max(speed - drop, 0) / speed
	
	return accelerate(wish_dir, Config.max_velocity_ground, delta)
	
func update_velocity_air(wish_dir: Vector3, delta):
	# Do not apply any friction
	return accelerate(wish_dir, Config.max_velocity_air, delta)

func _unhandled_input(event):
	if event is InputEventMouseMotion and camera_can_move:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
func _debug_raycast():
	var point = raycast.get_collision_point()
	RAYS.append([Draw3d.line(to_global(camera.position), point), 5.0])
	POINTS.append([Draw3d.point(point), 5.0])

func grapple():
	if raycast.is_colliding():
		var point = raycast.get_collision_point()
		
		grapple_root = Grappler.grapple_root(self, global_position, velocity)
		grapple_point = Grappler.grapple_point(grapple_root, point)
		cable = Draw3d.line(global_position, point)
		
		#get_tree().get_root().add_child(grapple_root)
		currently_grappled = true
	
func grapple_release():
	velocity = grapple_root.linear_velocity
	grapple_root.queue_free()
	grapple_point.queue_free()
	cable.queue_free()
	currently_grappled = false

func can_climb():
	if !$Head/ChestRay.get_overlapping_bodies():
		return false
	for ray in $Head/HeadRays.get_children():
		if ray.is_colliding():
			return false
	return true
	
func climb():
	velocity = Vector3.ZERO
	can_jump = false
	camera_can_move = false
	
	var v_move_time = Config.v_climb_time
	var h_move_time = Config.h_climb_time

	var vertical_movement = global_transform.origin + Vector3(0,1.85,0)
	var vm_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	vm_tween.tween_property(self, "global_transform:origin", vertical_movement, v_move_time)
	await vm_tween.finished
	
	var forward_movement = global_transform.origin + (-transform.basis.z * 1.2)
	var fm_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	fm_tween.tween_property(self, "global_transform:origin", forward_movement, h_move_time)

	can_jump = true
	camera_can_move = true

func _delete_objects(delta):
	for i in RAYS:
		i[1] = i[1] - delta
		if i[1] < 0:
			i[0].queue_free()
			RAYS.erase(i)
	for i in POINTS:
		i[1] = i[1] - delta
		if i[1] < 0:
			i[0].queue_free()
			POINTS.erase(i)
