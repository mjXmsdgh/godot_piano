extends OptionButton

# CodeManagerノードへの参照。
@onready var code_manager: Node = get_node("../../ChordManager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# CodeManagerの_ready()が完了し、データがロードされるのを待つために、
	# populate_chord_optionsの呼び出しを遅延させます。
	call_deferred("populate_chord_options")


func populate_chord_options() -> void:
	# CodeManagerからコードデータを取得 (Dictionary型を期待)
	var chords: Dictionary = code_manager.get("chord_data")

	# OptionButtonの既存のアイテムをすべてクリア
	self.clear()

	# コードデータのキー（コード名）の配列を取得
	var chord_names: Array = chords.keys()

	# 取得したコード名でOptionButtonにアイテムを追加
	for i in range(chord_names.size()):
		var chord_name: String = chord_names[i]
		# アイテムのテキストとしてコード名、IDとしてインデックスを設定
		self.add_item(chord_name, i)

	# アイテムが存在すれば、最初のアイテムをデフォルトで選択します。
	if self.item_count > 0:
		self.select(0)


# 選択されているコード名を返す関数
func get_selected_chord_name() -> String:

	if self.selected == -1: # 何かアイテムが選択されていないか確認
		return "" # 何も選択されていない場合は空文字を返す

	return self.get_item_text(self.selected) # 選択されているアイテムのテキストを返す
