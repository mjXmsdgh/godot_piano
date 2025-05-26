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
	# STEP 3: 現状、このキーにはフレームごとの継続的な処理はありません。
	# 将来的に、例えばキーが押されている間のアニメーションや、
	# 他の継続的な状態変化を処理する必要が出てきた場合、
	# ここにロジックを追加し、必要に応じて関数を分割することを検討します。
	pass

# --- 既存の公開/シグナル接続関数 ---

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
	if not _are_playback_dependencies_met():
		return

	# 音声再生
	_execute_audio_playback()

	# 見た目変更
	_apply_pressed_visual_state()
	_initiate_visual_state_reset()

# --- STEP 3: play_soundから呼び出されるヘルパー関数群 ---

func _are_playback_dependencies_met() -> bool:
	"""再生に必要なノードが揃っているかを確認します。"""
	if not sound_player:
		printerr("Sound player not available for key: ", name, " in play_sound.")
		return false
	if not texture_button:
		printerr("TextureButton not found for key: ", name, " in play_sound.")
		return false
	if not reset_timer:
		printerr("Reset timer not found for key: ", name, " in play_sound.")
		return false
	return true

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
