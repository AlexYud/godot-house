extends CharacterBody3D

const WALK_SPEED = 2.0
const SPRINT_SPEED = 4.0
const WALK_CAMERA_ACC = 2.0
const SPRINT_CAMERA_ACC = 5.0
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

var direction = Vector3.ZERO
var head_y_axis = 0.0
var camera_x_axis = 0.0

#bob variables
const BOB_FREQ = 4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		head_y_axis += event.relative.x * cameraSensitivity
		camera_x_axis += event.relative.y * cameraSensitivity
		camera_x_axis = clamp(camera_x_axis, -30.0, 30.0)
		
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
func _process(delta):
	direction = Input.get_axis("left", "right") * head.basis.x + Input.get_axis("up", "down") * head.basis.z
	velocity = velocity.lerp(direction * playerSpeed + velocity.y * Vector3.UP, playerAcceleration * delta)
	
	head.rotation.y = lerp(head.rotation.y, -deg_to_rad(head_y_axis), cameraAcceleration * delta)
	camera.rotation.x = lerp(camera.rotation.x, -deg_to_rad(camera_x_axis), cameraAcceleration * delta)
	
	hand.rotation.y = -deg_to_rad(head_y_axis)
	flashlight.rotation.x = -deg_to_rad(camera_x_axis)
	
	# Handle Sprint.
	if Input.is_action_pressed("sprint"):
		playerSpeed = SPRINT_SPEED
		cameraAcceleration = SPRINT_CAMERA_ACC
	else:
		playerSpeed = WALK_SPEED
		cameraAcceleration = WALK_CAMERA_ACC
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jumpForce
	else:
		velocity.y -= gravity * delta
		
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
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
