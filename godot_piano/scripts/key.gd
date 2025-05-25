# c:\Users\masuda\Documents\GitHub\godot_piano\godot_piano\scripts\key.gd
extends Node2D

const AUDIO_PLAYER_NODE_PATH := "AudioStreamPlayer2D"
const TEXTURE_BUTTON_NODE_PATH := "TextureButton"
const RESET_TIMER_NODE_PATH := "Timer"

const SIGNAL_KEY_PRESSED := "key_pressed"
const DEFAULT_KEY_NAME := "none"

@onready var sound_player: AudioStreamPlayer2D = get_node_or_null(AUDIO_PLAYER_NODE_PATH)
@onready var texture_button: TextureButton = get_node_or_null(TEXTURE_BUTTON_NODE_PATH) # TextureButtonをonready varで取得
@onready var reset_timer: Timer = get_node_or_null(RESET_TIMER_NODE_PATH)

var original_texture_normal: Texture2D
var key_name: String = DEFAULT_KEY_NAME

signal key_pressed(pressed_key_name: String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sound_player == null:
		printerr("AudioStreamPlayer2D node not found for key: ", name)

	if texture_button:
		original_texture_normal = texture_button.texture_normal
	else:
		printerr("TextureButton node not found for key: ", name, " at path: ", TEXTURE_BUTTON_NODE_PATH)

	if reset_timer == null:
		printerr("Timer node not found for key: ", name, " at path: ", RESET_TIMER_NODE_PATH)


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
	emit_signal(SIGNAL_KEY_PRESSED, key_name)


func play_sound() -> void:
	
	if not sound_player:
		printerr("Sound player not available for key: ", name, " in play_sound.")
		return
	if not texture_button:
		printerr("TextureButton not found for key: ", name, " in play_sound.")
		return
	if not reset_timer:
		printerr("Reset timer not found for key: ", name, " in play_sound.")
		return

	sound_player.play_sound()
	texture_button.texture_normal = texture_button.texture_pressed
	reset_timer.start()


func _on_timer_timeout() -> void:
	if texture_button:
		texture_button.texture_normal = original_texture_normal
	else:
		printerr("TextureButton not found on timer timeout for key: ", name)
