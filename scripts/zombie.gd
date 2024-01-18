extends Node3D

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		animation_player.play("Armature|Running_Crawl")
		$".".visible = true

func _on_animation_player_animation_finished(anim_name):
	queue_free()
