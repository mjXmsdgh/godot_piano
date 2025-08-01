# 音楽コード当てクイズの問題を管理するノード
extends Node2D


# QuizUI: UI要素への参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")

# QuizUI: UI要素への参照
@onready var question_label: Label = $QuestionLabel

# QuizManager: 外部のロジックコンポーネントへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")

@onready var question_logic: Node = get_node_or_null("./Question_Logic")


# Controller: UIとManagerの初期化処理を呼び出す
func _ready() -> void:

	# UIコンポーネントの存在を検証する
	if not _initialize_ui_components():
		return # UIの初期化に失敗した場合は処理を中断
	
	# ロジックコンポーネントと状態を初期化する
	question_logic.init()

	randomize()
	
	# signalをつなぐ
	connect_signals()

	_start_new_question()


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


# どちらにも属さない (未使用)
func _process(delta: float) -> void:
	pass


# QuizUI: ボタンが押された、というイベントを受け取る。ロジックは _start_new_question に委譲
func _on_question_button_pressed() -> void:
	_start_new_question()


# QuizManager: 新しい問題を開始し、クイズの状態を更新する
func _start_new_question() -> void:
	# 問題を選んで表示
	question_logic.select_new_chord()

	# UI要素であるラベルのテキストを更新する
	question_label.text = question_logic.get_current_chord_name()


# QuizUI: 鍵盤が押された、というイベントを受け取る。ロジックは _handle_key_input に委譲
func _on_individual_key_pressed(note_name: String) -> void:

	if not question_logic.is_accepting_input():
		return

	# ロジックコントローラーに入力を渡す
	question_logic.add_user_note(note_name)

	# ターゲットコードと同じ数の音が入力されたら評価
	if question_logic.is_answer_ready():
		var is_correct: bool = question_logic.evaluate_answer()
		_update_feedback_ui(is_correct)


func _update_feedback_ui(is_correct: bool) -> void:
	if is_correct:
		$StatusLabel.text = "Correct"
	else:
		$StatusLabel.text = "Incorrect. Try again."


# QuizUI: UIイベントのハンドラ。UI要素(ピアノ)を操作して音を鳴らす
func _on_answer_pressed() -> void:
	# 正解の音を鳴らす機能。ロジックから正解データを取得する必要がある
	var correct_notes = question_logic.current_target_chord_notes
	for item in correct_notes:
		piano_keyboard_node.play_note(item)
