extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_button_down() -> void:
	print("push")
	
	var sound_player=get_node_or_null("SoundPlayer")

	sound_player.play_c4_sound()
	
	pass # Replace with function body.
