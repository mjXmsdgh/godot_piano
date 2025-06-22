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


# 指定されたキーのダイアトニックコードを機能別に分類して辞書として返す
func _get_chords_by_function_for_key(key: String) -> Dictionary:
	var chords_by_function: Dictionary = {
		"T": [] as Array[String],
		"SD": [] as Array[String],
		"D": [] as Array[String]
	}

	for chord_data in diatonic_chord_list:
		if chord_data["key"] == key:
			var function_name: String = chord_data["function_name"]
			if chords_by_function.has(function_name):
				chords_by_function[function_name].append(chord_data["chord_name"])
	
	return chords_by_function


func generate_chord() -> void:
	generated_chords.clear() # 前回生成されたコード進行をクリア

	# 1. `target_key` に基づいてダイアトニックコードをフィルタリング
	var chords_in_key: Dictionary = _get_chords_by_function_for_key(target_key)
	var tonic_chords_in_key: Array[String] = chords_in_key.get("T", [])
	var subdominant_chords_in_key: Array[String] = chords_in_key.get("SD", [])
	var dominant_chords_in_key: Array[String] = chords_in_key.get("D", [])
	
	if tonic_chords_in_key.is_empty():
		printerr("Error: No tonic chords found for key '%s'. Cannot generate chord progression." % target_key)
		return

	# 2. コード進行の開始コードを選択:
	#    - 一般的に、コード進行はトニック(T)から始まることが多い。
	#    - `tonic_chords_in_key` の中からランダムに1つ、または主要なトニックコード（例: I度）を選択し、`generated_chords` に追加する。

	var start_chord_index = randi_range(0, tonic_chords_in_key.size() - 1)
	generated_chords.append(tonic_chords_in_key[start_chord_index])


	# 3. 2番目以降のコードを選択 (target_number - 1 回繰り返す):
	#    target_number が1の場合はこのループは実行されない。
	for _i in range(target_number - 1):
		var next_chord: String = _get_next_chord(generated_chords.back(), target_key, tonic_chords_in_key, subdominant_chords_in_key, dominant_chords_in_key, diatonic_chord_list)
		generated_chords.append(next_chord)

	# 4. コード進行の終了処理
	_finalize_chord_progression(generated_chords, target_key, diatonic_chord_list)


	# 結果表示
	display_generated_chords()



func display_generated_chords() -> void:
	print(generated_chords)


# 現在のコードに基づいて次のコードを選択するプライベート関数
# 戻り値: 次のコード名 (String)。適切なコードが見つからない場合は空文字列 ("") を返す。
func _get_next_chord(current_chord_name: String, key: String, tonic_chords: Array[String], subdominant_chords: Array[String], dominant_chords: Array[String], all_diatonic_chords: Array[Dictionary]) -> String:
	var current_chord_function: String = ""

	# a. 現在のコードの機能を見つける
	for chord_data in all_diatonic_chords:
		if chord_data["key"] == key and chord_data["chord_name"] == current_chord_name:
			current_chord_function = chord_data["function_name"]
			break
	
	if current_chord_function.is_empty():
		printerr("Error: Could not determine function for chord '%s' in key '%s'." % [current_chord_name, key])
		return "" # 機能が見つからない場合は失敗

	var candidates_for_next_chord: Array[String] = []

	# b. 次のコードの機能を選択し、候補コード群を取得する (シンプルなルール)
	if current_chord_function == "T":
		# トニック(T)からはサブドミナント(SD)またはドミナント(D)へ (ランダムに選択)
		var choice = randi_range(0, 1) # 0: SDを試す, 1: Dを試す
		if choice == 0 and not subdominant_chords.is_empty():
			candidates_for_next_chord = subdominant_chords
		elif not dominant_chords.is_empty(): # SDが空だったか、Dが選ばれた場合
			candidates_for_next_chord = dominant_chords
		elif not subdominant_chords.is_empty(): # Dも空でSDが残っていた場合 (choice == 1 だったがDが空)
			candidates_for_next_chord = subdominant_chords
		else:
			# SDもDも利用できない場合、他のトニックコードがあればそれを選ぶ (現在のコード以外)
			printerr("Warning: No SD or D chords available from T in key '%s'. Trying to use another T chord." % key)
			var other_tonic_chords = tonic_chords.filter(func(c): return c != current_chord_name)
			if not other_tonic_chords.is_empty():
				candidates_for_next_chord = other_tonic_chords
			else:
				printerr("Warning: No suitable next chord found from T in key '%s'." % key)
				return "" # 適切な候補が見つからない場合は失敗
				
	elif current_chord_function == "SD":
		# サブドミナント(SD)からはドミナント(D)へ
		if not dominant_chords.is_empty():
			candidates_for_next_chord = dominant_chords
		else:
			printerr("Error: No D chords available from SD in key '%s'." % key)
			return "" # 進行不可の場合は失敗
			
	elif current_chord_function == "D":
		# ドミナント(D)からはトニック(T)へ
		if not tonic_chords.is_empty():
			candidates_for_next_chord = tonic_chords
		else:
			printerr("Error: No T chords available from D in key '%s'." % key)
			return "" # 進行不可の場合は失敗
	
	# c. 候補の中から具体的なコードを選択 (同じコードの連続を避ける試み)
	var filtered_candidates = candidates_for_next_chord.filter(func(c): return c != current_chord_name)
	
	if not filtered_candidates.is_empty():
		return filtered_candidates[randi_range(0, filtered_candidates.size() - 1)]
	elif not candidates_for_next_chord.is_empty(): # フィルタリング後の候補がないが、元の候補はある場合 (つまり全ての候補がカレントコードと同じ)
		return candidates_for_next_chord[randi_range(0, candidates_for_next_chord.size() - 1)] # 仕方ないので同じコードを選ぶ
	else:
		printerr("Error: No valid next chord could be selected even after filtering candidates for '%s'." % current_chord_name)
		return "" # 候補が全くない場合は失敗


# コード進行の最後を、そのキーの主要なトニックコードで解決させる
func _finalize_chord_progression(progression: Array[String], key: String, all_diatonic_chords: Array[Dictionary]) -> void:
	# 進行が空の場合は何もしない
	if progression.is_empty():
		return

	var primary_tonic_chord_name: String = ""

	# key の I度またはIm度のトニックコードを見つける
	for chord_data in all_diatonic_chords:
		if chord_data["key"] == key and (chord_data["degree"] == "I" or chord_data["degree"] == "Im"):
			primary_tonic_chord_name = chord_data["chord_name"]
			break
	
	# I度のトニックが見つかり、かつ最後のコードがそれと異なる場合、置き換える
	if not primary_tonic_chord_name.is_empty() and progression.back() != primary_tonic_chord_name:
		progression.pop_back()
		progression.append(primary_tonic_chord_name)
