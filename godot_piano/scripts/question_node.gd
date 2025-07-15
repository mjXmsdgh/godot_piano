# 音楽コード当てクイズの問題を管理するノード
extends Node2D


# QuizUI: UI要素への参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")

# QuizUI: UI要素への参照
@onready var question_label: Label = $QuestionLabel

# QuizManager: 外部のロジックコンポーネントへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")

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

# 混在: UIの準備とロジックの準備が混ざっている
# QuizUI: is_instance_validでUIノードの存在を確認
# QuizManager: 状態の初期化、乱数初期化、ロジックの開始(select_chord)
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

# 混在: UI要素(キー)のシグナルを接続する処理
# QuizUI: 自身の管理するUI要素(キー)をループしてシグナル接続を行う
# QuizManager: シグナルの接続先(_on_individual_key_pressed)がロジックを含んでいる
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

# どちらにも属さない (未使用)
func _process(delta: float) -> void:
	pass

# 混在: UIイベントのハンドラだが、直接ロジックを呼び出している
# QuizUI: ボタンが押された、というイベントを受け取る
# QuizManager: select_chord()や状態変更といったロジックを実行する
func _on_question_button_pressed() -> void:

	# 問題を選んで表示
	select_chord()

	# 状態を「入力待ち」に変更
	current_interaction_state = QuizInteractionState.AWAITING_INPUT

# QuizUI: UI要素であるラベルのテキストを更新する
func update_label() -> void:
	question_label.text=str(current_target_chord_name)

# 混在: ロジックとUI更新が混ざっている
# QuizManager: コード選択ロジックを呼び出し、UI更新をトリガー
func select_chord() -> void:
	var chord_info = _select_chord_logic()
	current_target_chord_name = chord_info[0]
	current_target_chord_notes = chord_info[1]["notes"]
	update_label()

# QuizManager: CodeManagerからコード情報を取得するロジック
func _select_chord_logic() -> Array:

	# 利用可能なコードの数を取得
	var num_chords = len(code_manager.chord_data)

	# ランダムなindexを取得
	var random_number = randi() % num_chords

	# コードを取得
	return code_manager.get_chord_by_index(random_number)

# QuizUI: 鍵盤が押された、というイベントを受け取る。ロジックは _handle_key_input に委譲
func _on_individual_key_pressed(note_name: String) -> void:
	_handle_key_input(note_name)


# QuizManager: ユーザーのキー入力を処理し、クイズの状態を更新する
func _handle_key_input(note_name: String) -> void:
	if not (current_interaction_state == QuizInteractionState.AWAITING_INPUT or \
			current_interaction_state == QuizInteractionState.COLLECTING_ANSWER):
		return # 入力受付状態でない場合は何もしない

	user_played_notes.append(note_name)
	current_interaction_state = QuizInteractionState.COLLECTING_ANSWER

	# ターゲットコードと同じ数の音が入力されたら評価
	if user_played_notes.size() >= current_target_chord_notes.size():
		current_interaction_state = QuizInteractionState.EVALUATING_ANSWER
		evaluate_answer()

func evaluate_answer() -> void:
	var is_correct: bool = _check_answer_logic()
	_update_feedback_ui(is_correct)
	_reset_quiz_state()


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


func _reset_quiz_state() -> void:
	# 次のインタラクションの準備
	user_played_notes.clear() # 評価後、ユーザーの入力をクリア
	# current_interaction_state = QuizInteractionState.AWAITING_INPUT # すぐに次の入力を待つ場合
	current_interaction_state = QuizInteractionState.INITIAL # 問題選択に戻る場合


# QuizUI: UIイベントのハンドラ。UI要素(ピアノ)を操作して音を鳴らす
func _on_answer_pressed() -> void:

	for item in current_target_chord_notes:
		piano_keyboard_node.play_note(item)
