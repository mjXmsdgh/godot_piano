extends OptionButton

# CodeManagerノードへの参照。
@onready var code_manager: Node = get_node("../CodeManager")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# CodeManagerの_ready()が完了し、データがロードされるのを待つために、
	# populate_chord_optionsの呼び出しを遅延させます。
	call_deferred("populate_chord_options")


func populate_chord_options() -> void:

	var chords: Dictionary = code_manager.get("chord_data")

	self.clear()

	var chord_names: Array = chords.keys()

	for i in range(chord_names.size()):
		var chord_name: String = chord_names[i]
	
		self.add_item(chord_name, i)

	# アイテムが存在すれば、最初のアイテムをデフォルトで選択します。
	if self.item_count > 0:
		self.select(0)
