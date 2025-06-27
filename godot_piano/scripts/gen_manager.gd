extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_generate_pressed() -> void:

	# コードジェネレーターのノードを取得
	var chord_generator = get_node_or_null("./generator")

	# コード進行を生成し、結果を取得
	chord_generator.generate_chord()
	var generated_chord_progression: Array[String] = chord_generator.generated_chords

	print(generated_chord_progression)
