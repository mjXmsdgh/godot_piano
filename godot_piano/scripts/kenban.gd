extends Node2D

# 各鍵盤ノードを音名と関連付けて格納するための辞書
var notes: Dictionary = {}

	
# 各鍵盤の情報をまとめた配列を定義
var key_data = [
	{"note_name": "A3", "frequency": 220.00, "node_path": "Key_A3"},
	{"note_name": "A#3", "frequency": 233.08, "node_path": "Key_As3"},
	{"note_name": "B3", "frequency": 246.94, "node_path": "Key_B3"},
	{"note_name": "C4", "frequency": 261.63, "node_path": "Key_C4"},
	{"note_name": "C#4", "frequency": 277.18, "node_path": "Key_Cs4"},
	{"note_name": "D4", "frequency": 293.66, "node_path": "Key_D4"},
	{"note_name": "D#4", "frequency": 311.13, "node_path": "Key_Ds4"},
	{"note_name": "E4", "frequency": 329.63, "node_path": "Key_E4"},
	{"note_name": "F4", "frequency": 349.23, "node_path": "Key_F4"},
	{"note_name": "F#4", "frequency": 369.99, "node_path": "Key_Fs4"},
	{"note_name": "G4", "frequency": 392.00, "node_path": "Key_G4"},
	{"note_name": "G#4", "frequency": 415.30, "node_path": "Key_Gs4"},
	{"note_name": "A4", "frequency": 440.00, "node_path": "Key_A4"},
	{"note_name": "A#4", "frequency": 466.16, "node_path": "Key_As4"},
	{"note_name": "B4", "frequency": 493.88, "node_path": "Key_B4"},
	{"note_name": "C5", "frequency": 523.25, "node_path": "Key_C5"},
	{"note_name": "C#5", "frequency": 554.37, "node_path": "Key_Cs5"},
	{"note_name": "D5", "frequency": 587.33, "node_path": "Key_D5"},
	{"note_name": "D#5", "frequency": 622.25, "node_path": "Key_Ds5"},
	{"note_name": "E5", "frequency": 659.26, "node_path": "Key_E5"},
	{"note_name": "F5", "frequency": 698.46, "node_path": "Key_F5"},
	{"note_name": "F#5", "frequency": 739.90, "node_path": "Key_Fs5"}, # 周波数の . を追加
	{"note_name": "G5", "frequency": 783.99, "node_path": "Key_G5"}
]




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# key_data配列をループして、各鍵盤ノードを初期化する
	for data in key_data:
		# 鍵盤データを変数に展開
		var note_name: String = data.note_name
		var frequency: float = data.frequency
		var node_path: String = data.node_path
		
		# パスを使ってシーンツリーから鍵盤ノードを取得
		var key_node = get_node(node_path)

		if !key_node:
			printerr("Error: Node not found at path: %s for note %s" % [node_path, note_name])

		# 鍵盤ノードに周波数と音名を設定
		key_node.set_freq(frequency)
		key_node.set_key_name(note_name)
		# 音名でノードを呼び出せるように、辞書に登録
		notes[note_name] = key_node


# 指定された音名の音を再生する
func play_note(note_name: String) -> void:
	# 辞書に指定された音名が存在するかチェック
	if not notes.has(note_name):
		printerr("KenbanNode: Key '", note_name, "' not found in notes dictionary.")
		return

	# 辞書から音名に対応する鍵盤ノードを取得
	var key_node = notes[note_name]
	# 取得したノードが有効か（削除されていないか等）をチェック
	if not is_instance_valid(key_node):
		printerr("KenbanNode: key_node is not valid for note_name: '", note_name, "'")
		return
		
	# 鍵盤ノードが再生メソッドを持っているかチェック
	if not key_node.has_method("play_sound"):
		printerr("KenbanNode: key_node '", key_node.name, "' does not have play_sound method.")
		return
			
	# 鍵盤ノードの再生メソッドを実行
	key_node.play_sound()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
