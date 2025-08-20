extends RayCast3D

@onready var prompt = $Prompt
@onready var subtitle = $Subtitle
@onready var hud = $"../../CanvasLayer"
@onready var label = $"../../CanvasLayer/Control/Panel/MarginContainer/Label"

# Called when the node enters the scene tree for the first time.
func _ready():
	hud.visible = false
	subtitle.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !hud.visible:
		prompt.text = ""
		if is_colliding():
			var detected = get_collider()
			if detected is Interactable:
				prompt.text = detected.get_prompt()
				if Input.is_action_just_pressed("interact"):
					startInteraction(detected)
	else:
		if Input.is_action_just_pressed("interact"):
			hud.visible = false


func startInteraction(detected):
	prompt.text = ""
	hud.visible = true
	var interactionResponse = detected.interact()
	subtitle.text = interactionResponse.subtitle
	label.text = interactionResponse.text
