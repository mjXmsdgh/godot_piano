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

# クイズの状態データ
var current_target_chord_name: String = ""
var current_target_chord_notes: Array = []
var user_played_notes: Array = []


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


func select_new_chord() -> void:
	# 状態をリセット
	user_played_notes.clear()
	current_interaction_state = QuizInteractionState.AWAITING_INPUT

	# 新しいコードを選択
	var num_chords = len(code_manager.chord_data)
	var random_number = randi() % num_chords
	var chord_info = code_manager.get_chord_by_index(random_number)
	
	current_target_chord_name = chord_info[0]
	current_target_chord_notes = chord_info[1]["notes"]


func get_current_chord_name() -> String:
	return current_target_chord_name


func add_user_note(note_name: String) -> void:
	user_played_notes.append(note_name)
	transition_to_collecting()


func is_answer_ready() -> bool:
	return user_played_notes.size() >= current_target_chord_notes.size()


func evaluate_answer() -> bool:
	transition_to_evaluating()
	var is_correct = _check_answer_logic()
	
	# 次の問題のために状態をリセット
	user_played_notes.clear()
	transition_to_initial()
	
	return is_correct


func _check_answer_logic() -> bool:
	if user_played_notes.size() != current_target_chord_notes.size():
		return false

	var sorted_user_notes = user_played_notes.duplicate()
	var sorted_target_notes = current_target_chord_notes.duplicate()
	sorted_user_notes.sort()
	sorted_target_notes.sort()

	return sorted_user_notes == sorted_target_notes
