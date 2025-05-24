# c:\Users\masuda\Documents\GitHub\godot_piano\godot_piano\scripts\key.gd
extends Node2D

@onready var sound_player: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")
@onready var texture_button: TextureButton = $TextureButton # TextureButtonをonready varで取得
@onready var reset_timer: Timer = $Timer

var original_texture_normal: Texture2D
var key_name: String = "none"

signal key_pressed(pressed_key_name: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sound_player == null:
		printerr("AudioStreamPlayer2D node not found for key: ", name)

	if texture_button:
		original_texture_normal = texture_button.texture_normal
	else:
		printerr("TextureButton node not found for key: ", name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_freq(input_freq: float) -> void:
	if sound_player:
		sound_player.set_freq(input_freq)
	else:
		printerr("Sound player not available to set frequency for key: ", name)

func set_key_name(input_key_name: String) -> void:
	key_name = input_key_name

func _on_texture_button_button_down() -> void:
	play_sound()
	emit_signal("key_pressed", key_name)


func play_sound() -> void:
	if sound_player:
		sound_player.play_sound()

		if texture_button:
			texture_button.texture_normal = texture_button.texture_pressed
			reset_timer.start()
		else:
			printerr("TextureButton not found during play_sound for key: ", name)
	else:
		printerr("Sound player not available for key: ", name)


func _on_timer_timeout() -> void:
	if texture_button:
		texture_button.texture_normal = original_texture_normal
	else:
		printerr("TextureButton not found on timer timeout for key: ", name)
