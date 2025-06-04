# 音楽コード当てクイズの問題を管理するノード
extends Node2D

# CodeManagerへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")
# 現在の問題となっているコード名 (例: "CMaj7")
var current_question_chord_name: String = ""
# 現在の問題となっているコードの構成音 (例: ["C", "E", "G", "B"])
var target_chord_notes: Array[String] = []
# プレイヤーが押したキーのバッファ
var played_notes_buffer: Array[String] = []

# ピアノキーボードノードへの参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")

# 問題表示用ラベルへの参照
@onready var question_label: Label = $Question

var _is_code_manager_initialized_successfully: bool = false # CodeManagerが正常に初期化されたかのフラグ

# 初期化処理
func _ready() -> void:
	# ピアノキーボードノード
	if not is_instance_valid(piano_keyboard_node):
		push_warning("QuestionNode: Piano keyboard node ('../kenban') not found. Key press signals will not be connected.")
		return

	# CodeManagerノード
	if not is_instance_valid(code_manager):
		push_warning("QuestionNode: CodeManager node ('../CodeManager') not found. Chord selection might fail.")
		_is_code_manager_initialized_successfully = false
	else:
		_is_code_manager_initialized_successfully = true

	# 問題表示用ラベルノード
	if not is_instance_valid(question_label):
		push_warning("QuestionNode: Question Label node ('$Question') not found. Question text will not be updated.")
		return

	randomize() # 乱数ジェネレータを初期化


# 毎フレーム呼び出される処理 (現在は未使用)
func _process(delta: float) -> void:
	pass


# 利用可能なコードの総数を取得する
func get_chord_count() -> int:
	if not is_instance_valid(code_manager):
		return 0
	# TODO: 将来的にはCodeManagerから動的に取得する
	return 24 #現在は固定値

# コード選択に関する状態をリセットする
func _reset_chord_selection_state() -> void:
	# 現在の問題のコード名を空文字列にリセットする。
	current_question_chord_name = ""
	# 現在の問題のターゲットコードの構成音の配列を空にする。
	target_chord_notes.clear() # 配列は clear() で空にするのが一般的

func select_chord() -> void:

	# 利用可能なコードの総数に基づいてランダムなインデックスを生成する。
	var random_index: int = randi() % get_chord_count() 

	# CodeManagerからランダムなインデックスに対応するコードデータを取得する。
	# chord_data_pair は [コード名, コード詳細の辞書] という形式のVariant。
	var chord_data_pair: Variant = code_manager.get_chord_by_index(random_index)

	# コードデータのペアからコード詳細の辞書を取得する。
	var chord_details: Dictionary = chord_data_pair[1]

	# コードデータのペアからコード名を取得し、現在の問題のコード名として設定する。
	current_question_chord_name = chord_data_pair[0]
	
	# コード詳細の辞書から "notes" キーで構成音の配列を取得する。
	var notes_variant: Array = chord_details["notes"]

	# 以前のターゲットコードの構成音をクリアする。
	target_chord_notes.clear()

	# 取得した構成音の配列をループし、各音をターゲットコードの構成音として追加する。
	# 型安全のため、要素がString型であることを確認する。
	for note_item: Variant in notes_variant:
		if note_item is String:
			target_chord_notes.append(note_item)

# 「問題表示」ボタンが押されたときの処理
func _on_button_pressed() -> void:
	
	# 新しいコードを選択して問題として設定する。
	select_chord()

	# 問題表示ラベルに現在の問題のコード名を表示する。
	question_label.text = current_question_chord_name

# 「答え表示」ボタンが押されたときの処理
func _on_answer_pressed() -> void:

	# ターゲットコードの構成音を順番に取得する。
	for item: String in target_chord_notes:
		# 各構成音をピアノキーボードで再生する。
		piano_keyboard_node.play_note(item)
