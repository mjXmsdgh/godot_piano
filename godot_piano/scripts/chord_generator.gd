extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# test
	#var chords: Array[String] = generate_chord("C", 4)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 指定されたキーと数に基づいてコード進行を生成します。
# @param target_key: String - 基準となるキー (例: "C")
# @param target_number: int - 生成するコードの数
# @return Array[String] - 生成されたコード進行の配列
func generate_chord(target_key: String, target_number: int) -> Array[String]:

	# コード生成ロジックを持つ子ノードを取得
	var chord_logic_node=get_node_or_null("./generate_chord")

	# 子ノードにキーと生成数を設定
	chord_logic_node.set_target_key(target_key)
	chord_logic_node.set_target_number(target_number)
	
	# 子ノードにコード生成を実行させる
	chord_logic_node.generate_chord()

	# 生成されたコードを子ノードから取得
	var generated_chords: Array[String] = chord_logic_node.generated_chords

	# 結果を返す
	return generated_chords
