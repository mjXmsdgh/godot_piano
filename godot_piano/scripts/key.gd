## key.gd
## 個々の鍵盤の動作を制御するスクリプト。
## TextureButton を介したユーザー入力の受付、見た目の変更、
## AudioStreamPlayer2D を使った音声再生のトリガー、および関連する状態管理を行います。
##
## 依存ノード:
## - AudioStreamPlayer2D (音声再生用)
## - TextureButton (ユーザー入力と表示用)
## - Timer (押下状態からの自動リセット用)
##
## シグナル:
## - key_pressed(key_name: String): 鍵盤が押された時に発行。
## - key_released(key_name: String): 鍵盤がタイマーによって離された状態に戻った時に発行。

extends Node2D

# ノードパスの定数
const AUDIO_PLAYER_NODE_PATH := "AudioStreamPlayer2D" # 音声再生を担当する AudioStreamPlayer2D ノードへのパス
const TEXTURE_BUTTON_NODE_PATH := "TextureButton"     # ユーザー入力と表示を担当する TextureButton ノードへのパス
const RESET_TIMER_NODE_PATH := "Timer"                # 押下状態をリセットするための Timer ノードへのパス

# シグナル名の定数
const SIGNAL_KEY_PRESSED := "key_pressed"             # 鍵盤押下時に発行されるシグナル名
const SIGNAL_KEY_RELEASED := "key_released"           # 鍵盤解放時に発行されるシグナル名 (タイマーによる)
const DEFAULT_KEY_NAME := "none"                      # 初期化時または未設定の場合のデフォルトキー名

# 必要な子ノードへの参照 (シーンツリーに追加された時点で取得)
@onready var sound_player: AudioStreamPlayer2D = get_node_or_null(AUDIO_PLAYER_NODE_PATH)
@onready var texture_button: TextureButton = get_node_or_null(TEXTURE_BUTTON_NODE_PATH)
@onready var reset_timer: Timer = get_node_or_null(RESET_TIMER_NODE_PATH)

# 鍵盤の状態
var original_texture_normal: Texture2D # TextureButton の通常状態のテクスチャを保持
var key_name: String = DEFAULT_KEY_NAME  # この鍵盤に割り当てられた名前 (例: "C4", "D#5")
var _is_properly_initialized := true   # 必須ノードが全て見つかり、初期化が正常に完了したかを示すフラグ

## 鍵盤の現在の状態を表す列挙型
enum KeyState { IDLE, PRESSED, DISABLED }
var current_state: KeyState = KeyState.IDLE # 鍵盤の現在の状態 (アイドル、押下中、無効)

## 鍵盤が押された時に発行されるシグナル。引数としてキー名を渡します。
signal key_pressed(pressed_key_name: String)
## 鍵盤がタイマーによって離された状態に戻った時に発行されるシグナル。引数としてキー名を渡します。
signal key_released(released_key_name: String)


## ノードがシーンツリーに追加された最初のフレームで呼び出されます。
## 依存関係のチェックと初期設定を行います。
func _ready() -> void:
	var missing_dependencies_messages: Array[String] = []

	# TextureButton の存在確認と初期テクスチャの保存
	if texture_button == null:
		missing_dependencies_messages.append("TextureButton ('%s') not found." % TEXTURE_BUTTON_NODE_PATH)
		_is_properly_initialized = false
	else:
		original_texture_normal = texture_button.texture_normal

	# AudioStreamPlayer2D の存在確認
	if sound_player == null:
		missing_dependencies_messages.append("AudioStreamPlayer2D ('%s') not found." % AUDIO_PLAYER_NODE_PATH)
		_is_properly_initialized = false

	# Timer の存在確認
	if reset_timer == null:
		missing_dependencies_messages.append("Timer ('%s') not found." % RESET_TIMER_NODE_PATH)
		_is_properly_initialized = false

	# 初期化に失敗した場合の処理
	if not _is_properly_initialized:
		var error_message = "Key '%s' initialization failed. Missing dependencies: [%s]. Key functionality will be affected." \
							% [name, ", ".join(missing_dependencies_messages)]
		printerr(error_message)
		current_state = KeyState.DISABLED # 鍵盤を無効状態にする
		if texture_button: # TextureButton自体は存在する場合
			texture_button.tooltip_text = "キーが正しく設定されていません。"
	else:
		# 初期化成功時の処理
		current_state = KeyState.IDLE
		if texture_button:
			texture_button.tooltip_text = "" # エラーツールチップをクリア

	_update_visuals() # 初期状態に基づいて見た目を設定

	# sound_player がこの鍵盤の key_pressed シグナルを購読するように設定します。
	# これにより、鍵盤が押されたときに sound_player 側のメソッドが呼び出されます。
	if _is_properly_initialized and sound_player:
		# sound_player にシグナルハンドラメソッド "_on_key_parent_pressed" を実装する必要があります
		var target_callable = Callable(sound_player, "_on_key_parent_pressed")
		if not self.is_connected(SIGNAL_KEY_PRESSED, target_callable):
			var err = self.connect(SIGNAL_KEY_PRESSED, target_callable)
			if err != OK:
				printerr("Key '", name, "': Failed to connect '", SIGNAL_KEY_PRESSED, "' to sound_player._on_key_parent_pressed. Error code: ", err)


## 毎フレーム呼び出されます。'delta' は前のフレームからの経過時間です。
## 現在この関数では何も処理を行っていません。
func _process(delta: float) -> void:
	pass


## 鍵盤の現在の状態 (current_state) に基づいて、TextureButton の見た目を更新します。
## 通常時、押下時、無効時でテクスチャや色、有効状態を変更します。
func _update_visuals() -> void:
	if not texture_button:
		return

	match current_state:
		KeyState.IDLE:
			if original_texture_normal:
				# 通常テクスチャに戻す
				texture_button.texture_normal = original_texture_normal
			texture_button.modulate = Color.WHITE
			texture_button.disabled = false
		KeyState.PRESSED:
			# 押下状態の見た目に変更
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
			# 無効状態の見た目に変更
			if original_texture_normal: # 通常テクスチャを表示しつつ無効を示す
				texture_button.texture_normal = original_texture_normal
			texture_button.modulate = Color.DARK_GRAY # 見た目で無効を示す
			texture_button.disabled = true


## 鍵盤に対応する音の周波数を設定します。
## この関数は sound_player (AudioStreamPlayer2D) の set_freq メソッドを呼び出します。
## @param input_freq 設定する周波数 (float)
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

## この鍵盤の名前 (識別子) を設定します。
## @param input_key_name 設定するキー名 (String)
func set_key_name(input_key_name: String) -> void:
	key_name = input_key_name

## TextureButton の "button_down" シグナルに接続されるコールバック関数。
## 鍵盤が押されたときの処理を開始します。
func _on_texture_button_button_down() -> void:
	if current_state == KeyState.DISABLED:
		return # 無効状態なら何もしない

	current_state = KeyState.PRESSED
	_update_visuals()
	play_sound() # play_sound は音声再生とタイマー開始を処理
	# SIGNAL_KEY_PRESSED シグナルは play_sound() 内で発行されます。


## TextureButton の "button_up" シグナルに接続されるコールバック関数。
## 現在の設計では、キーが物理的に離された瞬間の特別な処理は行わず、
## タイマーによって一定時間後に自動的にIDLE状態に戻しています。
func _on_texture_button_button_up() -> void:
	pass # 必要に応じて、キーが離された瞬間の処理をここに追加できます。

## 鍵盤の音を再生し、関連する処理（見た目のリセットタイマー開始、シグナル発行）を行います。
## この関数は _on_texture_button_button_down から呼び出されます。
func play_sound() -> void:
	if not _is_properly_initialized or current_state == KeyState.DISABLED:
		printerr("Key '", name, "' is not properly initialized or is disabled. Cannot play sound.")
		return

	# 見た目を元に戻すためのタイマーを開始
	_initiate_visual_state_reset()

	# 鍵盤が押されたことを示すシグナルを発行
	emit_signal(SIGNAL_KEY_PRESSED, key_name)


## 鍵盤の見た目を一定時間後に通常状態 (IDLE) に戻すためのタイマーを開始します。
func _initiate_visual_state_reset() -> void:
	if reset_timer and current_state != KeyState.DISABLED: # 無効状態でなければタイマー開始
		reset_timer.start()


## reset_timer の "timeout" シグナルに接続されるコールバック関数。
## 鍵盤の状態を IDLE に戻し、見た目を更新し、key_released シグナルを発行します。
func _on_timer_timeout() -> void:
	# DISABLED 状態に陥った後でもタイマーが作動する可能性を考慮
	if current_state == KeyState.DISABLED:
		return

	current_state = KeyState.IDLE
	_update_visuals()
	# 鍵盤が離された（タイマーによりリセットされた）ことを示すシグナルを発行
	emit_signal(SIGNAL_KEY_RELEASED, key_name)
