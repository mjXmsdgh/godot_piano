extends Node2D

@onready var sound_player=get_node_or_null("AudioStreamPlayer2D")
@onready var reset_timer=$Timer
var original_texture_normal: Texture2D
var key_name="none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sound_player==null:
		printerr("AudioStreamPlayer2D node not found!")

	original_texture_normal=$TextureButton.texture_normal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_freq(input_freq) -> void:
	sound_player.set_freq(input_freq)

func set_keyname(input_key_name) -> void :
	key_name=input_key_name

func _on_texture_button_button_down() -> void:
	#sound_player.play_sound()
	play_sound()


func play_sound() -> void:
	if sound_player:
		sound_player.play_sound()
		print(key_name)

		$TextureButton.texture_normal=$TextureButton.texture_pressed
		reset_timer.start()
	else:
		print("sound error",name)


func _on_timer_timeout() -> void:

	$TextureButton.texture_normal=original_texture_normal

	pass # Replace with function body.
