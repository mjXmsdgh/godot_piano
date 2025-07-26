extends Node2D


@onready var code_manager: Node = get_node_or_null("../../CodeManager")


# QuizManager: クイズの状態を管理する
enum QuizInteractionState {
	INITIAL,            # 初期状態、または問題選択前
	AWAITING_INPUT,     # 問題提示後、ユーザーの最初の入力を待っている状態
	COLLECTING_ANSWER,  # ユーザーが回答を入力（鍵盤を押下）している状態
	EVALUATING_ANSWER   # ユーザーの回答を評価（判定）している状態
}
var current_interaction_state: QuizInteractionState = QuizInteractionState.INITIAL

func is_accepting_input() -> bool:
	return current_interaction_state == QuizInteractionState.AWAITING_INPUT or \
			current_interaction_state == QuizInteractionState.COLLECTING_ANSWER


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	current_interaction_state = QuizInteractionState.INITIAL
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func transition_to_collecting() -> void:
	# ユーザーがキーを押し始めたので、回答収集中状態に遷移させる
	# is_accepting_input() ですでにチェックされているので、状態を更新するだけでOK
	current_interaction_state = QuizInteractionState.COLLECTING_ANSWER


func transition_to_evaluating() -> void:
	# 回答が揃ったので、評価状態に遷移させる
	current_interaction_state = QuizInteractionState.EVALUATING_ANSWER


func transition_to_initial() -> void:
	# 評価が完了したので、初期状態に戻す
	current_interaction_state = QuizInteractionState.INITIAL

func init() -> void:
	if not is_instance_valid(code_manager):
		push_warning("QuestionNode: CodeManager node ('../CodeManager') not found. Chord selection might fail.")

	

func _select_chord_logic() -> Array:

	current_interaction_state = QuizInteractionState.AWAITING_INPUT

	# 利用可能なコードの数を取得
	var num_chords = len(code_manager.chord_data)

	var random_number=randi() % num_chords

	return code_manager.get_chord_by_index(random_number)
