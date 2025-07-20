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

	
func select_chord() -> void:
	var chord_info=_select_chord_logic()
	#current_target_chord_name=chord_info[0]
	#current_target_chord_notes=chord_info[1]["notes"]
	
	
func _select_chord_logic() -> Array:
	var num_chords=len(code_manager.chord_data)
	var random_number=randi()%num_chords
	return code_manager.get_chord_by_index(random_number)
