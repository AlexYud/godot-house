extends CharacterBody3D

# Movement constants
const WALK_SPEED = 2.0
const SPRINT_SPEED = 4.0
const WALK_CAMERA_ACC = 2.0
const SPRINT_CAMERA_ACC = 5.0

# Crouch constants
const CROUCH_SPEED = 1.0
const CROUCH_HEIGHT = -0.5     
const CROUCH_ACC = 8.0         
const STAND_HEIGHT = 2.0
const CROUCH_COLLIDER_HEIGHT = 1.2

@export var playerSpeed = 2.0
@export var playerAcceleration = 5.0
@export var cameraSensitivity = 0.15
@export var cameraAcceleration = 2.0
@export var jumpForce = 3.0
@export var gravity = 10.0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hand = $Hand
@onready var flashlight = $Hand/SpotLight3D
@onready var collider = $CollisionShape3D  

var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0
var isHudVisible = true

# Bob variables
const BOB_FREQ = 4
const BOB_AMP = 0.1
var t_bob = 0.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Crouch state
var is_crouching = false
var crouch_offset = 0.0 
var crouch_target = 0.0

# Store original positions
var original_camera_position = Vector3.ZERO
var original_hand_position = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Store original positions
	original_camera_position = camera.transform.origin
	original_hand_position = hand.transform.origin

func _input(event):
	if event is InputEventMouseMotion:
		head_y_axis += event.relative.x * cameraSensitivity
		camera_x_axis += event.relative.y * cameraSensitivity
		camera_x_axis = clamp(camera_x_axis, -35.0, 35.0)
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
func _process(delta):
	if !isHudVisible:
		# Movement input
		direction = Input.get_axis("left", "right") * head.basis.x + Input.get_axis("up", "down") * head.basis.z

		# Normalize to prevent diagonal speed boost
		if direction.length() > 0:
			direction = direction.normalized()

		velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)

		
		# Camera rotation
		head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
		camera.rotation.x = lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta)
		
		hand.rotation.y = -deg_to_rad(head_y_axis)
		flashlight.rotation.x = -deg_to_rad(camera_x_axis)
		
		# Handle Sprint
		if Input.is_action_pressed("sprint") and !is_crouching:
			playerSpeed = SPRINT_SPEED
			cameraAcceleration = SPRINT_CAMERA_ACC
		else:
			playerSpeed = WALK_SPEED
			cameraAcceleration = WALK_CAMERA_ACC
		
		# Handle Crouch - only change the target
		if Input.is_action_pressed("crouch"):
			is_crouching = true
			playerSpeed = CROUCH_SPEED
			crouch_target = CROUCH_HEIGHT
		else:
			is_crouching = false
			crouch_target = 0.0
		
		# Smooth crouch transition
		var previous_crouch_offset = crouch_offset
		crouch_offset = lerp(crouch_offset, crouch_target, delta * CROUCH_ACC)
		
		# Smoothly interpolate collider height based on crouch progress
		if collider and collider.shape is CapsuleShape3D:
			# Calculate how far we are into the crouch (0 to 1)
			var crouch_progress = 0.0
			if crouch_target == CROUCH_HEIGHT: # Crouching down
				crouch_progress = 1.0 - (crouch_offset - CROUCH_HEIGHT) / -CROUCH_HEIGHT
			else: # Standing up
				crouch_progress = crouch_offset / CROUCH_HEIGHT
			
			crouch_progress = clamp(crouch_progress, 0.0, 1.0)
			
			# Smoothly interpolate collider height
			var target_collider_height = lerp(STAND_HEIGHT, CROUCH_COLLIDER_HEIGHT, crouch_progress)
			collider.shape.height = lerp(collider.shape.height, target_collider_height, delta * CROUCH_ACC * 1.5)
		
		# Handle Jump
		if Input.is_action_just_pressed("jump") and is_on_floor() and !is_crouching:
			velocity.y += jumpForce
		else:
			velocity.y -= gravity * delta
		
		# --- CAMERA POSITION (CROUCH + BOB COMBINED) ---
		var final_offset = Vector3(0, crouch_offset, 0)
		if direction.length() > 0.01:
			t_bob += delta * velocity.length() * float(is_on_floor())
			final_offset += _headbob(t_bob)
		
		# Smoothly apply the combined offset to BOTH camera and hand
		camera.transform.origin = lerp(camera.transform.origin, final_offset, delta * 10.0)
		hand.transform.origin = lerp(hand.transform.origin, original_hand_position + final_offset, 10.0 * delta)
		
		# FOV
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
			
		move_and_slide()
		

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _on_canvas_layer_visibility_changed():
	isHudVisible = !isHudVisible
