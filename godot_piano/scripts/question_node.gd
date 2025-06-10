# 音楽コード当てクイズの問題を管理するノード
extends Node2D

# CodeManagerへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")

# ピアノキーボードノードへの参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")

# 問題表示用ラベルへの参照
@onready var question_label: Label = $Question

var target_chord="C"

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


# 毎フレーム呼び出される処理 (現在は未使用)
func _process(delta: float) -> void:
	pass


func _on_question_button_pressed() -> void:

	# 問題を選んで表示
	select_chord()

	# 状態を「入力待ち」に変更
	current_interaction_state = QuizInteractionState.AWAITING_INPUT


func update_label() -> void:
	question_label.text=str(target_chord)

func select_chord() -> void:

	# 利用可能なコードの数を取得
	var num_chords=len(code_manager.chord_data)

	# ランダムなindexを取得
	var random_number=randi() % num_chords

	# コードを取得
	target_chord=code_manager.get_chord_by_index(random_number)

	# ラベルを更新
	update_label()


	
	
	