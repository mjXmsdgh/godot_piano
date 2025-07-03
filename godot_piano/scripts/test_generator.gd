extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_chord_pressed() -> void:
	# コードジェネレーターノードを取得
	var chord_generator = get_node_or_null("chord_generator")
	# 指定されたキーと数でコード進行を生成
	var generated_chords: Array[String] = chord_generator.generate_chord("C", 4)

	# UIラベルに生成されたコードリストを表示
	$chord_list.text = " ".join(generated_chords)
	
	# コードの構成音を管理するノードを取得
	var chord_manager = get_node_or_null("ChordManager")
	
	# デバッグ用に "C" コードの構成音を取得してコンソールに出力
	#var notes_for_chord = chord_manager.get_notes_by_chord_name("C")

	for item in generated_chords:
		var notes_for_chord = chord_manager.get_notes_by_chord_name(item)
		print(notes_for_chord)




	
