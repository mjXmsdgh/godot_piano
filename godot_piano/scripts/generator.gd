extends Node2D

# キー
var target_key: String

# コード数
var target_number: int

# 生成されたコード進行
var generated_chords: Array[String] = [] 


var diatonic_chord_list: Array[Dictionary] = [] # 格納するデータ構造に合わせて型を Array[Dictionary] に変更




# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# 仮
	target_key="C"
	target_number=4

	# chord_listを読み込む
	load_chord_list()

	# 確認用の表示
	#display_diatonic_chord_list()

	generate_chord()
	pass # Replace with function body.


func load_chord_list() -> void:
	# 0. diatonic_chord_list をクリアする (もし複数回呼び出される可能性がある場合)
	diatonic_chord_list.clear()

	# 1. CSVファイルのパスを定義する
	var file_path = "res://assets/diatonic_chord_list.csv"

	# 2. FileAccess を使用してCSVファイルを開く
	var file = FileAccess.open(file_path, FileAccess.READ)

	# 3. ファイルが正しく開けたか確認する
	if FileAccess.get_open_error() != OK:
		printerr("Failed to open diatonic_chord_list.csv: ", FileAccess.get_open_error())
		return

	# 4. ファイルを1行ずつ読み込むループ
	while not file.eof_reached():
		
		# CSVの1行を配列として取得
		var line: PackedStringArray = file.get_csv_line() 

		# 5. ヘッダー行をスキップする
		if is_header_row(line):
			continue

		# 6. データ行の列数を確認 (キー, ディグリー, コード名, 機能名の最低4列を期待)
		if line.size() < 4:
			printerr("Skipping malformed CSV data line (expected at least 4 columns, got %s): %s" % [line.size(), str(line)])
			continue

		var key = line[0]
		var degree = line[1]
		var chord_name = line[2]
		var function_name = line[3]
	
		diatonic_chord_list.append({ "key": key, "degree": degree, "chord_name": chord_name, "function_name": function_name })


	# 7. ファイルを閉じる
	file.close()
	

func is_header_row(line: Array[String]) -> bool:

	# lineが空でないこと、かつ最初の要素が文字列で、"#"で始まるかを確認
	if not line.is_empty() and line[0] is String and line[0].begins_with("#"):
		return true
	else:
		return false

func display_diatonic_chord_list() -> void:
	for item in diatonic_chord_list:
		print(item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_target_key(key: String) -> void:
	target_key = key


func set_target_number(number: int) -> void:
	target_number = number	


func generate_chord() -> void:
	generated_chords.clear() # 前回生成されたコード進行をクリア

	# --- コード生成ロジック ---

	# 1. `target_key` に基づいてダイアトニックコードをフィルタリング:
	#    - `diatonic_chord_list` から、現在の `target_key` に一致するコードのみを抽出する。
	#    - 抽出したコードを、機能（トニック(T), サブドミナント(SD), ドミナント(D)など）ごとに分類しておく。
	#      例: `tonic_chords_in_key`, `subdominant_chords_in_key`, `dominant_chords_in_key` のような配列や辞書を作成する。
	var tonic_chords_in_key: Array[String] = []
	var subdominant_chords_in_key: Array[String] = []
	var dominant_chords_in_key: Array[String] = []

	for chord in diatonic_chord_list:
		if chord["key"] == target_key:
			if chord["function_name"] == "T":
				tonic_chords_in_key.append(chord["chord_name"])
			elif chord["function_name"] == "SD":
				subdominant_chords_in_key.append(chord["chord_name"])
			elif chord["function_name"] == "D":
				dominant_chords_in_key.append(chord["chord_name"])


	# 2. コード進行の開始コードを選択:
	#    - 一般的に、コード進行はトニック(T)から始まることが多い。
	#    - `tonic_chords_in_key` の中からランダムに1つ、または主要なトニックコード（例: I度）を選択し、`generated_chords` に追加する。

	var start_chord_index = randi_range(0, tonic_chords_in_key.size() - 1)
	generated_chords.append(tonic_chords_in_key[start_chord_index])


	# 3. 2番目以降のコードを選択 (target_number - 1 回繰り返す):

	# 4. コード進行の終了処理 (任意):
	

	# 結果表示
	display_generated_chords()



func display_generated_chords() -> void:
	print(generated_chords)

