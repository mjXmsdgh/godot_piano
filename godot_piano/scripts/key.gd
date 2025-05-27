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
var _is_properly_initialized := true # Flag to track initialization status

signal key_pressed(pressed_key_name: String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var missing_dependencies_messages: Array[String] = []

	# Check for TextureButton first, as we need it for original_texture and disabling.
	if texture_button == null:
		missing_dependencies_messages.append("TextureButton ('%s') not found." % TEXTURE_BUTTON_NODE_PATH)
		_is_properly_initialized = false
	else:
		# original_texture_normal should only be assigned if texture_button exists.
		original_texture_normal = texture_button.texture_normal

	if sound_player == null:
		missing_dependencies_messages.append("AudioStreamPlayer2D ('%s') not found." % AUDIO_PLAYER_NODE_PATH)
		_is_properly_initialized = false

	if reset_timer == null:
		missing_dependencies_messages.append("Timer ('%s') not found." % RESET_TIMER_NODE_PATH)
		_is_properly_initialized = false

	if not _is_properly_initialized:
		var error_message = "Key '%s' initialization failed. Missing dependencies: [%s]. Key functionality will be affected." \
							% [name, ", ".join(missing_dependencies_messages)]
		printerr(error_message)
		
		if texture_button: # If texture_button itself exists, disable it.
			texture_button.disabled = true
			texture_button.tooltip_text = "Key is not properly configured." # Optional: provide UI feedback
		# Optionally, make the key visually distinct to indicate it's broken
		# modulate = Color.DARK_GRAY 
		return # Stop further setup if initialization failed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# STEP 3: 現状、このキーにはフレームごとの継続的な処理はありません。
	# 将来的に、例えばキーが押されている間のアニメーションや、
	# 他の継続的な状態変化を処理する必要が出てきた場合、
	# ここにロジックを追加し、必要に応じて関数を分割することを検討します。
	pass

# --- 既存の公開/シグナル接続関数 ---

func set_freq(input_freq: float) -> void:
	if not _is_properly_initialized:
		printerr("Cannot set frequency for key '", name, "'; key is not properly initialized.")
		return
		
	if sound_player:
		sound_player.set_freq(input_freq)
	else:
		# This specific error might be redundant if sound_player missing leads to _is_properly_initialized = false
		printerr("Sound player not available to set frequency for key '", name, "', even after initial checks.")

func set_key_name(input_key_name: String) -> void:
	key_name = input_key_name

func _on_texture_button_button_down() -> void:
	play_sound()
	emit_signal(SIGNAL_KEY_PRESSED, key_name)


func play_sound() -> void:	
	if not _is_properly_initialized:
		printerr("Key '", name, "' is not properly initialized. Cannot play sound.")
		return
	# _are_playback_dependencies_met() のチェックは _is_properly_initialized でカバーされるため削除

	# 音声再生
	_execute_audio_playback()

	# 見た目変更
	_apply_pressed_visual_state()
	_initiate_visual_state_reset()

# --- STEP 3: play_soundから呼び出されるヘルパー関数群 ---

func _execute_audio_playback() -> void:
	"""音声再生を実行します。"""
	sound_player.play_sound()

func _apply_pressed_visual_state() -> void:
	"""キーが押された時の見た目に変更します。"""
	texture_button.texture_normal = texture_button.texture_pressed

func _initiate_visual_state_reset() -> void:
	"""見た目を元に戻すためのタイマーを開始します。"""
	reset_timer.start()


func _on_timer_timeout() -> void:
	if texture_button:
		texture_button.texture_normal = original_texture_normal
	else:
		printerr("TextureButton not found on timer timeout for key: ", name)
