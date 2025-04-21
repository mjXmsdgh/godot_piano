extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func test() -> void:

	var test=get_node_or_null("../")
	test.test_play()
	#print(test.name)


func _on_play_chord_pressed() -> void:
	
	var test=get_node_or_null("../")
	test.play_note("C4")
	test.play_note("E4")
	test.play_note("G4")
	
	
	pass # Replace with function body.
