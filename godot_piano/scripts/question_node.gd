# 音楽コード当てクイズの問題を管理するノード
extends Node2D

# CodeManagerへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")

# ピアノキーボードノードへの参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")

# 問題表示用ラベルへの参照
@onready var question_label: Label = $QuestionLabel

var target_chord="C"
var current_target_chord_name: String = ""
var current_target_chord_notes
var user_played_notes: Array = []

# クイズのインタラクション状態
enum QuizInteractionState {
	INITIAL,            # 初期状態、または問題選択前
	AWAITING_INPUT,     # 問題提示後、ユーザーの最初の入力を待っている状態
	COLLECTING_ANSWER,  # ユーザーが回答を入力（鍵盤を押下）している状態
	EVALUATING_ANSWER   # ユーザーの回答を評価（判定）している状態
}
var current_interaction_state: QuizInteractionState = QuizInteractionState.INITIAL



# 初期化処理
func _ready() -> void:
	# ピアノキーボードノード
	if not is_instance_valid(piano_keyboard_node):
		push_warning("QuestionNode: Piano keyboard node ('../kenban') not found. Key press signals will not be connected.")
		return

	# CodeManagerノード
	if not is_instance_valid(code_manager):
		push_warning("QuestionNode: CodeManager node ('../CodeManager') not found. Chord selection might fail.")
		

	# 問題表示用ラベルノード
	if not is_instance_valid(question_label):
		push_warning("QuestionNode: Question Label node ('$Question') not found. Question text will not be updated.")
		return

	current_interaction_state = QuizInteractionState.INITIAL # 明示的に初期状態を設定

	randomize() # 乱数ジェネレータを初期化

	connect_signals()

	select_chord()



# keyが押されたときのシグナルを接続する
func connect_signals() -> void:
	if not is_instance_valid(piano_keyboard_node):
		return # ピアノキーボードノードが無効なら何もしない

	# piano_keyboard_node の子ノード（個々のキー）を調べてシグナルに接続
	for key_node in piano_keyboard_node.get_children():
		# key.gd スクリプトがアタッチされたノードは "key_pressed" シグナルを持つはず
		if key_node.has_signal("key_pressed"):
			# まだ接続されていなければ接続する (重複接続を避ける)
			if not key_node.is_connected("key_pressed", Callable(self, "_on_individual_key_pressed")):
				key_node.connect("key_pressed", Callable(self, "_on_individual_key_pressed"))



# 毎フレーム呼び出される処理 (現在は未使用)
func _process(delta: float) -> void:
	pass


func _on_question_button_pressed() -> void:

	# 問題を選んで表示
	select_chord()

	# 状態を「入力待ち」に変更
	current_interaction_state = QuizInteractionState.AWAITING_INPUT


func update_label() -> void:
	question_label.text=str(current_target_chord_name)

func select_chord() -> void:

	# 利用可能なコードの数を取得
	var num_chords=len(code_manager.chord_data)

	# ランダムなindexを取得
	var random_number=randi() % num_chords

	# コードを取得
	var chord_info=code_manager.get_chord_by_index(random_number)

	current_target_chord_name=chord_info[0]
	current_target_chord_notes=chord_info[1]["notes"]

	# ラベルを更新
	update_label()

	
# 個々の鍵盤が押されたときに呼び出される関数
func _on_individual_key_pressed(note_name: String) -> void:
	if not (current_interaction_state == QuizInteractionState.AWAITING_INPUT or \
			current_interaction_state == QuizInteractionState.COLLECTING_ANSWER):
		return # 入力受付状態でない場合は何もしない

	user_played_notes.append(note_name)
	current_interaction_state = QuizInteractionState.COLLECTING_ANSWER

	if user_played_notes.size() >= 3: # 3音入力されたら評価 (ターゲットコードの音数と比較するのがより正確)
		current_interaction_state = QuizInteractionState.EVALUATING_ANSWER
		evaluate_answer()


# 回答を評価する関数
func evaluate_answer() -> void:

	# 簡単な比較ロジック (順序を問わず、構成音が一致するか)
	var is_correct = false
	if user_played_notes.size() == current_target_chord_notes.size():
		var sorted_user_notes = user_played_notes.duplicate()
		var sorted_target_notes = current_target_chord_notes.duplicate()
		sorted_user_notes.sort()
		sorted_target_notes.sort()
		if sorted_user_notes == sorted_target_notes:
			is_correct = true

	if is_correct:
		$StatusLabel.text="Correct"
	else:
		$StatusLabel.text="Incorrect. Try again."


	# 次のインタラクションの準備
	user_played_notes.clear() # 評価後、ユーザーの入力をクリア
	# current_interaction_state = QuizInteractionState.AWAITING_INPUT # すぐに次の入力を待つ場合
	current_interaction_state = QuizInteractionState.INITIAL # 問題選択に戻る場合

# 答えボタンが押されたとき
func _on_answer_pressed() -> void:

	for item in current_target_chord_notes:
		piano_keyboard_node.play_note(item)
