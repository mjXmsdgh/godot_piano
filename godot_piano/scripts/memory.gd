extends Node2D

var memory_chord_notes=[]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_memory_pressed() -> void:
	print("memory")
	
	var test=get_node_or_null("../")

	var temp=test.current_chord_notes

	print(temp)
