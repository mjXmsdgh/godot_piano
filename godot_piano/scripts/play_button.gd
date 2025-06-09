extends Button


@onready var select_chord_list:Node =get_node_or_null("../SelectChordList")
@onready var kenban:Node=get_node_or_null("../../kenban")
@onready var code_manager:Node=get_node_or_null("../../ChordManager")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	# ボタンが押された時の処理
	# 選択されているコード名を取得
	var selected_chord_name: String = select_chord_list.get_selected_chord_name()
	# コード名に対応する音符の配列を取得
	var notes_to_play:Array = code_manager.get_notes_by_chord_name(selected_chord_name)
	# 各音符を再生
	for note in notes_to_play:
		kenban.play_note(note)
