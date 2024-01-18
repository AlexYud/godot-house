class_name Interactable
extends StaticBody3D

@export var prompt_message = "Interagir"
@export var prompt_action = "interact"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_prompt():
	return prompt_message + "\n[E]"
	
func interact():
	return {
		"text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eget ligula eu lectus lobortis condimentum. Aliquam nonummy auctor massa. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla at risus. Quisque purus magna, auctor et, sagittis ac, posuere eu, lectus. Nam mattis, felis ut adipiscing.",
		"subtitle": "Alguns comentários do protagonista..."
	}
