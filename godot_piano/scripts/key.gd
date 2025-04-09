extends Node2D

@onready var sound_player=get_node_or_null("AudioStreamPlayer2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sound_player==null:
		printerr("AudioStreamPlayer2D node not found!")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_button_down() -> void:
	print("push button")
	
	sound_player.set_freq(440)
	sound_player.play_sound()
