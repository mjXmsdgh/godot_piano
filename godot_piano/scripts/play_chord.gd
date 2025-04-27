extends Node2D


var code_manager:Node=null
var piano_player:Node=null
var chord_option_button=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#test()
	code_manager=get_node_or_null("../CodeManager")
	piano_player=get_node_or_null("../")
	chord_option_button=get_node_or_null("../chord_OptionButton")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func test() -> void:

	var test=get_node_or_null("../")
	test.test_play()
	#print(test.name)


func _on_play_chord_pressed() -> void:

	var chord_to_play=chord_option_button.get_chord()

	#var chord_to_play:String="C"
	var chord_data=code_manager.chord_data
	var chord_info=chord_data[chord_to_play]

	var notes_array=chord_info["notes"]

	for note in notes_array:

		piano_player.play_note(note)
