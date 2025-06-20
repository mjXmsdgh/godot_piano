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
	#    target_number が1の場合はこのループは実行されない。
	for _i in range(target_number - 1):
		if generated_chords.is_empty():
			printerr("Error: generated_chords is empty before generating the next chord. This should not happen if a start chord was added.")
			break # 開始コードが何らかの理由で追加されなかった場合

		var current_chord_name: String = generated_chords.back()
		var current_chord_function: String = ""

		# a. 現在のコードの機能を見つける
		for chord_data in diatonic_chord_list:
			if chord_data["key"] == target_key and chord_data["chord_name"] == current_chord_name:
				current_chord_function = chord_data["function_name"]
				break
		
		if current_chord_function.is_empty():
			printerr("Error: Could not find function for current chord '%s' in key '%s'. Stopping generation." % [current_chord_name, target_key])
			break 

		var candidates_for_next_chord: Array[String] = []

		# b. 次のコードの機能を選択し、候補コード群を取得する (シンプルなルール)
		if current_chord_function == "T":
			# トニック(T)からはサブドミナント(SD)またはドミナント(D)へ (ランダムに選択)
			var choice = randi_range(0, 1) # 0: SDを試す, 1: Dを試す
			if choice == 0 and not subdominant_chords_in_key.is_empty():
				candidates_for_next_chord = subdominant_chords_in_key
			elif not dominant_chords_in_key.is_empty(): # SDが空だったか、Dが選ばれた場合
				candidates_for_next_chord = dominant_chords_in_key
			elif not subdominant_chords_in_key.is_empty(): # Dも空でSDが残っていた場合 (choice == 1 だったがDが空)
				candidates_for_next_chord = subdominant_chords_in_key
			else:
				# SDもDも利用できない場合、他のトニックコードがあればそれを選ぶ (現在のコード以外)
				printerr("Warning: No SD or D chords available from T in key '%s'. Trying to use another T chord." % target_key)
				var other_tonic_chords = tonic_chords_in_key.filter(func(c): return c != current_chord_name)
				if not other_tonic_chords.is_empty():
					candidates_for_next_chord = other_tonic_chords
				else:
					printerr("Error: No alternative T chords available. Stopping generation as no valid next chord found.")
					break # 進行不可
					
		elif current_chord_function == "SD":
			# サブドミナント(SD)からはドミナント(D)へ
			if not dominant_chords_in_key.is_empty():
				candidates_for_next_chord = dominant_chords_in_key
			else:
				printerr("Error: No D chords available from SD in key '%s'. Stopping generation." % target_key)
				break # 進行不可
				
		elif current_chord_function == "D":
			# ドミナント(D)からはトニック(T)へ
			if not tonic_chords_in_key.is_empty():
				candidates_for_next_chord = tonic_chords_in_key
			else:
				printerr("Error: No T chords available from D in key '%s'. Stopping generation." % target_key)
				break # 進行不可
		else:
			printerr("Error: Unknown current chord function '%s' for chord '%s'. Stopping generation." % [current_chord_function, current_chord_name])
			break 

		# c. 候補の中から具体的なコードを選択 (同じコードの連続を避ける試み)
		var next_chord: String
		var filtered_candidates = candidates_for_next_chord.filter(func(c): return c != current_chord_name)
		
		if not filtered_candidates.is_empty():
			next_chord = filtered_candidates[randi_range(0, filtered_candidates.size() - 1)]
		elif not candidates_for_next_chord.is_empty(): # フィルタリング後の候補がないが、元の候補はある場合 (つまり全ての候補がカレントコードと同じ)
			next_chord = candidates_for_next_chord[randi_range(0, candidates_for_next_chord.size() - 1)] # 仕方ないので同じコードを選ぶ
		
		generated_chords.append(next_chord)


	# 4. コード進行の終了処理 (任意):
	#    生成されたコード進行の最後を、そのキーのI度のトニックコードで終わらせる。
	if not generated_chords.is_empty():
		var primary_tonic_chord_name: String = ""

		# a. target_key の I度のトニックコードを見つける
		#    diatonic_chord_list から "degree" が "I" (またはキーによって "Im" など) のものを探す
		#    ここでは簡単のため、tonic_chords_in_key の最初の要素をI度と仮定する。
		#    より正確には degree 情報を使うべき。
		#    例: Cメジャーなら "C", Aマイナーなら "Am"
		for chord_data in diatonic_chord_list:
			if chord_data["key"] == target_key and (chord_data["degree"] == "I" or chord_data["degree"] == "Im"): # メジャーのI度、マイナーのIm度を考慮
				primary_tonic_chord_name = chord_data["chord_name"]
				break
		
		if not primary_tonic_chord_name.is_empty():
			# b. 最後のコードがI度のトニックでなければ置き換える
			if generated_chords.back() != primary_tonic_chord_name:
				generated_chords.pop_back() # 最後の要素を削除
				generated_chords.append(primary_tonic_chord_name) # I度のトニックを追加


	# 結果表示
	display_generated_chords()



func display_generated_chords() -> void:
	print(generated_chords)
