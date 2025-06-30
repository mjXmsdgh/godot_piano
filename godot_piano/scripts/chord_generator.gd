extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# test
	#var chords: Array[String] = generate_chord("C", 4)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_chord(target_key: String, target_number: int) -> Array[String]:

	# コードジェネレーターのノードを取得
	var chord_logic_node=get_node_or_null("./generate_chord")

	chord_logic_node.set_target_key(target_key)
	chord_logic_node.set_target_number(target_number)
	chord_logic_node.generate_chord()

	var generated_chords: Array[String] = chord_logic_node.generated_chords

	print("Generated Chords: ", generated_chords)
	return generated_chords
