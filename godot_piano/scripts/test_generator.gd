extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_chord_pressed() -> void:
	# コード生成
	var chord_generator_node=get_node_or_null("chord_generator")
	var chord_list: Array[String] = chord_generator_node.generate_chord("C", 4)

	$chord_list.text = " ".join(chord_list)
