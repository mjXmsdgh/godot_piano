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


# 異名同音（例: B#とC、BbとA#）を、鍵盤で定義されている標準的な音名に正規化する
func _normalize_note_name(note_name: String) -> String:
	if note_name.length() < 2:
		return note_name # "C" のような単一文字や空文字列はそのまま返す

	var note_base: String = note_name.substr(0, 1)
	var octave_str: String = note_name.right(1)

	if not octave_str.is_valid_int():
		return note_name # "C#" のようにオクターブがない形式は非対応としてそのまま返す

	var octave: int = octave_str.to_int()
	var accidentals: String = note_name.substr(1, note_name.length() - 2)

	# 音階の基本値を定義 (C=0)
	const PITCH_CLASSES = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
	if not PITCH_CLASSES.has(note_base):
		return note_name # 不正な音階名

	var pitch_class: int = PITCH_CLASSES[note_base]

	# 変化記号を解釈してピッチクラスを計算
	for acc in accidentals:
		if acc == '#':
			pitch_class += 1
		elif acc == 'b':
			pitch_class -= 1

	# ピッチクラスが0-11の範囲に収まるように正規化し、オクターブを調整
	while pitch_class < 0:
		pitch_class += 12
		octave -= 1
	while pitch_class > 11:
		pitch_class -= 12
		octave += 1

	# key_dataで使われているシャープ系の音名に変換
	const NORMALIZED_NOTES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	var normalized_base = NORMALIZED_NOTES[pitch_class]

	return normalized_base + str(octave)

# 指定された音名の音を再生する
func play_note(note_name: String) -> void:
	var normalized_name: String = _normalize_note_name(note_name)
	if not notes.has(normalized_name):
		printerr("KenbanNode: Key '", normalized_name, "' (normalized from '", note_name, "') not found in notes dictionary.")
		return

	# 辞書から音名に対応する鍵盤ノードを取得
	var key_node = notes[normalized_name]
	# 取得したノードが有効か（削除されていないか等）をチェック
	if not is_instance_valid(key_node):
		printerr("KenbanNode: key_node is not valid for note_name: '", normalized_name, "'")
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
