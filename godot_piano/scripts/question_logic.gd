extends Node2D


@onready var code_manager: Node = get_node_or_null("../../CodeManager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func init() -> void:
	if not is_instance_valid(code_manager):
		push_warning("QuestionNode: CodeManager node ('../CodeManager') not found. Chord selection might fail.")

	

func _select_chord_logic() -> Array:

	# 利用可能なコードの数を取得
	var num_chords = len(code_manager.chord_data)

	var random_number=randi() % num_chords

	return code_manager.get_chord_by_index(random_number)
