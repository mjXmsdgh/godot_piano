extends Node2D


var code_manager:Node=null
var piano_player:Node=null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#test()
	code_manager=get_node_or_null("../CodeManager")

	piano_player=get_node_or_null("../")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func test() -> void:

	var test=get_node_or_null("../")
	test.test_play()
	#print(test.name)


func _on_play_chord_pressed() -> void:
	
	#var test=get_node_or_null("../")
	#test.play_note("C4")
	#test.play_note("E4")
	#test.play_note("G4")

	var chord_to_play:String="C"


	if !code_manager.has_meta("chord_data") or !code_manager.chord_data.has(chord_to_play):
		return
	
	
	
	pass # Replace with function body.
