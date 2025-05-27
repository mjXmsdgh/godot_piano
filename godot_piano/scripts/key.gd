# c:\Users\masuda\Documents\GitHub\godot_piano\godot_piano\scripts\key.gd
extends Node2D

const AUDIO_PLAYER_NODE_PATH := "AudioStreamPlayer2D"
const TEXTURE_BUTTON_NODE_PATH := "TextureButton"
const RESET_TIMER_NODE_PATH := "Timer"

const SIGNAL_KEY_PRESSED := "key_pressed"
const SIGNAL_KEY_RELEASED := "key_released" # STEP 5 で正式導入予定だが、ここで使用
const DEFAULT_KEY_NAME := "none"

@onready var sound_player: AudioStreamPlayer2D = get_node_or_null(AUDIO_PLAYER_NODE_PATH)
@onready var texture_button: TextureButton = get_node_or_null(TEXTURE_BUTTON_NODE_PATH)
@onready var reset_timer: Timer = get_node_or_null(RESET_TIMER_NODE_PATH)

var original_texture_normal: Texture2D
var key_name: String = DEFAULT_KEY_NAME
var _is_properly_initialized := true # 基盤となる初期化が成功したかのフラグ

enum KeyState { IDLE, PRESSED, DISABLED }
var current_state: KeyState = KeyState.IDLE

signal key_pressed(pressed_key_name: String)
signal key_released(released_key_name: String) # タイマーリセット時に使用


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var missing_dependencies_messages: Array[String] = []

	if texture_button == null:
		missing_dependencies_messages.append("TextureButton ('%s') not found." % TEXTURE_BUTTON_NODE_PATH)
		_is_properly_initialized = false
	else:
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
		current_state = KeyState.DISABLED
		if texture_button: # TextureButton自体は存在する場合
			texture_button.tooltip_text = "キーが正しく設定されていません。"
	else:
		current_state = KeyState.IDLE
		if texture_button:
			texture_button.tooltip_text = "" # エラーツールチップをクリア

	_update_visuals() # 初期状態に基づいて見た目を設定


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# --- 状態と見た目を管理するヘルパー関数 ---
func _update_visuals() -> void:
	if not texture_button:
		return

	match current_state:
		KeyState.IDLE:
			if original_texture_normal:
				texture_button.texture_normal = original_texture_normal
			texture_button.modulate = Color.WHITE
			texture_button.disabled = false
		KeyState.PRESSED:
			# TextureButton の texture_pressed はマウスダウン時に自動で使用される。
			# タイマーでリセットされるまで「押された」見た目を維持するために、
			# texture_normal を手動で pressed テクスチャに設定する。
			if texture_button.texture_pressed:
				texture_button.texture_normal = texture_button.texture_pressed
			elif original_texture_normal: # pressed テクスチャがない場合のフォールバック
				texture_button.texture_normal = original_texture_normal
				# 必要であれば、特定のテクスチャがない場合に押下状態を示すために modulate する
				# texture_button.modulate = Color(0.85, 0.85, 0.85)
			texture_button.disabled = false
		KeyState.DISABLED:
			if original_texture_normal: # 通常テクスチャを表示しつつ無効を示す
				texture_button.texture_normal = original_texture_normal
			texture_button.modulate = Color.DARK_GRAY # 見た目で無効を示す
			texture_button.disabled = true


# --- 既存の公開/シグナル接続関数 ---

func set_freq(input_freq: float) -> void:
	if not _is_properly_initialized: # 初期化失敗時は設定不可
		printerr("Cannot set frequency for key '", name, "'; key is not properly initialized.")
		return
	if current_state == KeyState.DISABLED: # 無効状態でも設定不可
		printerr("Cannot set frequency for key '", name, "'; key is disabled.")
		return
		
	if sound_player:
		sound_player.set_freq(input_freq)
	else:
		# このエラーは _is_properly_initialized チェックでカバーされるはず
		printerr("Sound player not available to set frequency for key '", name, "', even after initial checks.")

func set_key_name(input_key_name: String) -> void:
	key_name = input_key_name

func _on_texture_button_button_down() -> void:
	if current_state == KeyState.DISABLED:
		return # 無効状態なら何もしない

	current_state = KeyState.PRESSED
	_update_visuals()
	play_sound() # play_sound は音声再生とタイマー開始を処理
	# SIGNAL_KEY_PRESSED は play_sound 内で emit されるように変更 (またはここで維持)
	# emit_signal(SIGNAL_KEY_PRESSED, key_name) # play_sound に移動させた方が責務分担として良い場合もある


func _on_texture_button_button_up() -> void:
	# キーが物理的に離された瞬間の処理が必要な場合はここに記述。
	# 現在の設計ではタイマーで一定時間後にIDLE状態に戻している。
	pass

func play_sound() -> void:	
	if not _is_properly_initialized or current_state == KeyState.DISABLED:
		printerr("Key '", name, "' is not properly initialized or is disabled. Cannot play sound.")
		return

	# 音声再生
	_execute_audio_playback()

	# 見た目の変更は状態遷移と _update_visuals() で処理されるため、
	# _apply_pressed_visual_state() の直接呼び出しは不要になった。
	# _apply_pressed_visual_state() 

	# 見た目を元に戻すためのタイマーを開始
	_initiate_visual_state_reset()

	emit_signal(SIGNAL_KEY_PRESSED, key_name)


# --- play_soundから呼び出されるヘルパー関数群 ---

func _execute_audio_playback() -> void:
	"""音声再生を実行します。"""
	if sound_player: # sound_player の存在は _is_properly_initialized で保証される前提
		sound_player.play_sound()

func _apply_pressed_visual_state() -> void:
	"""キーが押された時の見た目に変更します。(現在は _update_visuals で処理)"""
	# この関数のロジックは _update_visuals に統合されました。
	# 呼び出し箇所も整理されたため、将来的には削除を検討できます。
	# if texture_button and texture_button.texture_pressed:
	# 	texture_button.texture_normal = texture_button.texture_pressed
	pass


func _initiate_visual_state_reset() -> void:
	"""見た目を元に戻すためのタイマーを開始します。"""
	if reset_timer and current_state != KeyState.DISABLED: # 無効状態でなければタイマー開始
		reset_timer.start()


func _on_timer_timeout() -> void:
	# DISABLED 状態に陥った後でもタイマーが作動する可能性を考慮
	if current_state == KeyState.DISABLED:
		return

	current_state = KeyState.IDLE
	_update_visuals()
	emit_signal(SIGNAL_KEY_RELEASED, key_name)
