extends Node2D


var key_nodes: Dictionary={ }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$kenban/Key_A3._on_texture_button_button_down()
	
	key_nodes["C4"]=$kenban/Key_C4
	key_nodes["D4"]=$kenban/Key_D4

	play_note("C4")
	await get_tree().create_timer(1).timeout
	play_note("D4")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	pass



func play_note(note_name: String) -> void:

	var key_node=key_nodes[note_name]

	key_node.play_sound()
