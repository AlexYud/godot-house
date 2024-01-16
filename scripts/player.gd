extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var camera_3d = $camera_mount/Camera3D
@onready var animation_player = $"visuals/Root Scene/AnimationPlayer"
@onready var visuals = $visuals

const WALK_SPEED = 2.25
const SPRINT_SPEED = 4.5
#const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.002

var speed
var is_running = false

#bob variables
const BOB_FREQ = 4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera_mount.rotate_x(-event.relative.y * SENSITIVITY)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		is_running = true
		speed = SPRINT_SPEED
	else:
		is_running = false
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if is_on_wall() && animation_player.current_animation != "CharacterArmature|Idle":
			animation_player.play("CharacterArmature|Idle")
		else :
			# Head bob
			t_bob += delta * velocity.length() * float(is_on_floor())
			camera_3d.transform.origin = _headbob(t_bob)
			
			# FOV
			var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
			var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
			camera_3d.fov = lerp(camera_3d.fov, target_fov, delta * 8.0)
			if is_running:
				if input_dir.y < 0 && animation_player.current_animation != "CharacterArmature|Run":
					animation_player.play("CharacterArmature|Run")
				if input_dir.y > 0 && animation_player.current_animation != "CharacterArmature|Run_Back":
					animation_player.play("CharacterArmature|Run_Back") 
				if input_dir.x > 0 && animation_player.current_animation != "CharacterArmature|Run_Right":
					animation_player.play("CharacterArmature|Run_Right")
				if input_dir.x < 0 && animation_player.current_animation != "CharacterArmature|Run_Left":
					animation_player.play("CharacterArmature|Run_Left")
			else: 
				if animation_player.current_animation != "CharacterArmature|Walk":
					animation_player.play("CharacterArmature|Walk")
		
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		if animation_player.current_animation != "CharacterArmature|Idle":
			animation_player.play("CharacterArmature|Idle")
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = camera_3d.position
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
