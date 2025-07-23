# 音楽コード当てクイズの問題を管理するノード
extends Node2D


# QuizUI: UI要素への参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")

# QuizUI: UI要素への参照
@onready var question_label: Label = $QuestionLabel

# QuizManager: 外部のロジックコンポーネントへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")

@onready var question_logic: Node = get_node_or_null("./Question_Logic")


# QuizManager: クイズの正解データ
var current_target_chord_name: String = ""
var current_target_chord_notes

# QuizManager: ユーザーの回答データ
var user_played_notes: Array = []

# QuizManager: クイズの状態を管理する
enum QuizInteractionState {
	INITIAL,            # 初期状態、または問題選択前
	AWAITING_INPUT,     # 問題提示後、ユーザーの最初の入力を待っている状態
	COLLECTING_ANSWER,  # ユーザーが回答を入力（鍵盤を押下）している状態
	EVALUATING_ANSWER   # ユーザーの回答を評価（判定）している状態
}
var current_interaction_state: QuizInteractionState = QuizInteractionState.INITIAL

# Controller: UIとManagerの初期化処理を呼び出す
func _ready() -> void:

	# UIコンポーネントの存在を検証する
	if not _initialize_ui_components():
		return # UIの初期化に失敗した場合は処理を中断
	
	# ロジックコンポーネントと状態を初期化する
	question_logic.init()

	current_interaction_state = QuizInteractionState.INITIAL
	randomize()
	
	# signalをつなぐ
	connect_signals()

	select_chord()


# QuizUI: UIコンポーネントの存在を検証する
func _initialize_ui_components() -> bool:
	if not is_instance_valid(piano_keyboard_node):
		push_warning("QuestionNode: Piano keyboard node ('../kenban') not found. Key press signals will not be connected.")
		return false
	if not is_instance_valid(question_label):
		push_warning("QuestionNode: Question Label node ('$Question') not found. Question text will not be updated.")
		return false
	return true


# Controller: UIイベントとManagerロジックを接続する
func connect_signals() -> void:
	var key_nodes: Array = _get_all_key_nodes()

	for key_node in key_nodes:
		# key.gd スクリプトがアタッチされたノードは "key_pressed" シグナルを持つはず
		if key_node.has_signal("key_pressed"):
			# まだ接続されていなければ接続する (重複接続を避ける)
			if not key_node.is_connected("key_pressed", Callable(self, "_on_individual_key_pressed")):
				key_node.connect("key_pressed", Callable(self, "_on_individual_key_pressed"))


# QuizUI: 接続対象となる全てのキーノードを取得する
func _get_all_key_nodes() -> Array:
	if not is_instance_valid(piano_keyboard_node):
		push_warning("QuestionNode: Cannot get key nodes because piano_keyboard_node is invalid.")
		return []

	# piano_keyboard_node の子ノード（個々のキー）を返す
	# この実装は、piano_keyboard_nodeの内部構造に依存している
	return piano_keyboard_node.get_children()


# 混在: ロジックとUI更新が混ざっている
# QuizManager: コード選択ロジックを呼び出し、UI更新をトリガー
func select_chord() -> void:
	var chord_info=question_logic._select_chord_logic()
	current_target_chord_name = chord_info[0]
	current_target_chord_notes = chord_info[1]["notes"]


# どちらにも属さない (未使用)
func _process(delta: float) -> void:
	pass


# QuizUI: ボタンが押された、というイベントを受け取る。ロジックは _start_new_question に委譲
func _on_question_button_pressed() -> void:
	_start_new_question()

	# 状態を「入力待ち」に変更
	current_interaction_state = QuizInteractionState.AWAITING_INPUT

# QuizManager: 新しい問題を開始し、クイズの状態を更新する
func _start_new_question() -> void:

	# 問題を選んで表示
	select_chord()

	update_label()




# QuizUI: UI要素であるラベルのテキストを更新する
func update_label() -> void:
	question_label.text=str(current_target_chord_name)



# QuizUI: 鍵盤が押された、というイベントを受け取る。ロジックは _handle_key_input に委譲
func _on_individual_key_pressed(note_name: String) -> void:
	if not (current_interaction_state == QuizInteractionState.AWAITING_INPUT or \
			current_interaction_state == QuizInteractionState.COLLECTING_ANSWER):
		return # 入力受付状態でない場合は何もしない

	user_played_notes.append(note_name)

	current_interaction_state = QuizInteractionState.COLLECTING_ANSWER

	# ターゲットコードと同じ数の音が入力されたら評価
	if user_played_notes.size() >= current_target_chord_notes.size():
		current_interaction_state = QuizInteractionState.EVALUATING_ANSWER
		evaluate_answer()
		user_played_notes.clear() # 評価後、ユーザーの入力をクリア
		# current_interaction_state = QuizInteractionState.AWAITING_INPUT # すぐに次の入力を待つ場合
		current_interaction_state = QuizInteractionState.INITIAL # 問題選択に戻る場合


func evaluate_answer() -> void:
	var is_correct: bool = _check_answer_logic()
	_update_feedback_ui(is_correct)


func _check_answer_logic() -> bool:

	if user_played_notes.size() != current_target_chord_notes.size():
		return false

	var sorted_user_notes = user_played_notes.duplicate()
	var sorted_target_notes = current_target_chord_notes.duplicate()
	sorted_user_notes.sort()
	sorted_target_notes.sort()

	return sorted_user_notes == sorted_target_notes


func _update_feedback_ui(is_correct: bool) -> void:
	if is_correct:
		$StatusLabel.text = "Correct"
	else:
		$StatusLabel.text = "Incorrect. Try again."


# QuizUI: UIイベントのハンドラ。UI要素(ピアノ)を操作して音を鳴らす
func _on_answer_pressed() -> void:

	for item in current_target_chord_notes:
		piano_keyboard_node.play_note(item)
