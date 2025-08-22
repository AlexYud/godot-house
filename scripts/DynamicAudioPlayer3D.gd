# DynamicAudioPlayer3D.gd
extends AudioStreamPlayer3D
class_name DynamicAudioPlayer3D

var listener_node: Node3D
var occlusion_check_rate: float = 0.1  # Check 10 times per second
var time_since_last_check: float = 0.0
var is_occluded: bool = false

func setup_occlusion_tracking(listener: Node3D):
	listener_node = listener
	# Don't check immediately - wait until we're in the tree

func _ready():
	# Start checking once we're properly added to the scene
	check_occlusion()

func _process(delta):
	if listener_node and is_inside_tree():
		time_since_last_check += delta
		if time_since_last_check >= occlusion_check_rate:
			check_occlusion()
			time_since_last_check = 0.0

func check_occlusion():
	if not listener_node or not is_inside_tree():
		return
	
	# Get the space state safely
	var world = get_world_3d()
	if not world:
		return
	
	var space_state = world.direct_space_state
	var sound_pos = global_position
	var listener_pos = listener_node.global_position
	
	# Create raycast query
	var query = PhysicsRayQueryParameters3D.create(
		listener_pos,
		sound_pos,
		1,  # Your wall collision layer
		[listener_node]  # Exclude listener
	)
	
	var result = space_state.intersect_ray(query)
	var new_occlusion = result.size() > 0
	
	# Only update if occlusion state changed
	if new_occlusion != is_occluded:
		is_occluded = new_occlusion
		update_bus_based_on_occlusion()

func update_bus_based_on_occlusion():
	if is_occluded:
		bus = "Occluded"
	else:
		bus = "Master"
