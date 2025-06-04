extends Node2D

# コードデータを管理するノード
@onready var code_manager: Node = get_node_or_null("../CodeManager")
# ピアノの音を再生するノード (ルートノードを想定)
@onready var piano_player: Node = get_node_or_null("../")
# コードを選択するOptionButtonノード
@onready var chord_option_button = get_node_or_null("../chord_OptionButton")

# _ready() はノード取得以外の初期化処理がなければ削除できます
func _ready() -> void:
	pass # 他に初期化処理がなければこの行も不要


func _on_play_chord_pressed() -> void:

	# OptionButtonから選択されたコード名を取得
	var chord_to_play: String = chord_option_button.get_chord()

	# CodeManagerから全体のコードデータを取得
	var chord_data: Dictionary = code_manager.chord_data

	# 選択されたコード名に対応する情報を取得
	var chord_info: Dictionary = chord_data[chord_to_play]

	# コード情報から音符の配列を取得
	var notes_array: Array = chord_info["notes"]

	# 配列内の各音符を再生
	for note in notes_array:
		piano_player.play_note(note)
