extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_generate_pressed() -> void:
	
	var generator=get_node_or_null("./generator")
	$generator.generate_chord()
	var test=$generator.generated_chords
	
	print(test)
