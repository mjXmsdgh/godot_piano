extends Node2D

# リファクタリング計画 4.2 適用:
# - 型ヒントの追加
# - 変数名と関数名の明確化
# - @onready を使用したノード参照の整理
# - Callable (シグナル接続) の記法を Godot 4.x スタイルに更新

# CodeManagerへの参照
@onready var code_manager: Node = get_node_or_null("../CodeManager")
# 現在の問題となっているコード名 (例: "CMaj7")
var current_question_chord_name: String = ""
# 現在の問題となっているコードの構成音 (例: ["C", "E", "G", "B"])
var target_chord_notes: Array[String] = []
# プレイヤーが押したキーのバッファ
var played_notes_buffer: Array[String] = []
# ピアノキーボードノードへの参照
@onready var piano_keyboard_node: Node = get_node_or_null("../kenban")
# Memoryノードへの参照
@onready var memory_node: Node = get_node_or_null("./Memory")
# 問題表示用ラベルへの参照 (インスペクタで $Question が Label ノードであることを確認してください)
@onready var question_label: Label = $Question


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ピアノキーボードノード
	if not is_instance_valid(piano_keyboard_node):
		push_warning("QuestionNode: Piano keyboard node ('../kenban') not found. Key press signals will not be connected.")
	else:
		# ピアノキーボードノードの子要素（各キー）を反復処理
		for key_child: Node in piano_keyboard_node.get_children():
			# 各キーが "key_pressed" シグナルを持っているか確認します。
			if key_child.has_signal("key_pressed"):
				# "key_pressed" シグナルを "_on_key_pressed_received" メソッドに接続します。
				key_child.key_pressed.connect(_on_key_pressed_received)

	# Memoryノード
	if not is_instance_valid(memory_node):
		push_warning("QuestionNode: Memory node ('./Memory') not found. Recall chord signal will not be connected.")
	else:
		# Memoryノードが "recall_chord_selected" シグナルを持っているか確認します。
		if memory_node.has_signal("recall_chord_selected"):
			# "recall_chord_selected" シグナルを "_on_recall_chord_selected" メソッドに接続します。
			memory_node.recall_chord_selected.connect(_on_recall_chord_selected)
		else:
			push_warning("QuestionNode: Memory node does not have 'recall_chord_selected' signal.")
	
	# CodeManagerノード
	if not is_instance_valid(code_manager):
		push_warning("QuestionNode: CodeManager node ('../CodeManager') not found. Chord selection might fail.")
	
	# 問題表示用ラベルノード
	if not is_instance_valid(question_label):
		push_warning("QuestionNode: Question Label node ('$Question') not found. Question text will not be updated.")

	randomize() # 乱数ジェネレータを初期化


# Called every frame. 'delta' is the elapsed time since the previous frame.
# この関数が空の場合、リファクタリング計画 3. その他 に基づき削除を検討してください。
# 今回は計画 4.2 の範囲で変更するため、そのまま残しています。
func _process(delta: float) -> void:
	pass


func select_chord() -> void:
	if not code_manager:
		current_question_chord_name = ""
		target_chord_notes = []
		push_warning("QuestionNode: Cannot select chord because CodeManager is not available.")
		return

	# 0から23の中から数字をランダムに選ぶ (マジックナンバー24はリファクタリング計画1.1で定数化を検討)
	var random_index: int = randi() % 24

	# code_managerからコードを選んでくる
	if not code_manager.has_method("get_chord_by_index"):
		current_question_chord_name = ""
		target_chord_notes = []
		push_warning("QuestionNode: CodeManager does not have 'get_chord_by_index' method.")
		return

	var chord_data_pair: Variant = code_manager.get_chord_by_index(random_index)

	# chord_data_pair のnullチェックや期待される構造かの確認 (リファクタリング計画1.2で詳細な堅牢性向上を検討)
	if chord_data_pair and typeof(chord_data_pair) == TYPE_ARRAY and chord_data_pair.size() == 2:
		if typeof(chord_data_pair[0]) == TYPE_STRING and \
		   typeof(chord_data_pair[1]) == TYPE_DICTIONARY and \
		   (chord_data_pair[1] as Dictionary).has("notes") and \
		   typeof((chord_data_pair[1] as Dictionary)["notes"]) == TYPE_ARRAY:
			
			# コード名
			current_question_chord_name = chord_data_pair[0] as String
			# 音 (Array[String]であることを期待)
			var notes_variant: Variant = (chord_data_pair[1] as Dictionary)["notes"]
			target_chord_notes.clear()
			for note_item: Variant in notes_variant as Array: # notes_variant が Array であることを期待
				if typeof(note_item) == TYPE_STRING:
					target_chord_notes.append(note_item as String)
				else:
					push_warning("QuestionNode: Chord data notes contain non-string element: " + str(note_item))
		else:
			current_question_chord_name = ""
			target_chord_notes = []
			push_warning("QuestionNode: Retrieved chord data from CodeManager has unexpected structure. Data: " + str(chord_data_pair))
	else:
		current_question_chord_name = ""
		target_chord_notes = []
		push_warning("QuestionNode: Failed to retrieve valid chord data pair from CodeManager. Received: " + str(chord_data_pair))


# Question Buttonが押されたとき
func _on_button_pressed() -> void:
	select_chord()
	if question_label:
		question_label.text = current_question_chord_name
	else:
		# question_label が見つからない場合、コンソールに情報を表示
		print("QuestionNode: Question Label not found. Current question chord: ", current_question_chord_name)
	
	# played_notes_buffer.clear() # ボタンが押された時にクリアするかは、ゲームの仕様によります。
								  # 現状はコメントアウトしています。


# プレイヤーが押したコードがターゲットと一致するかチェックする (リファクタリング計画 4.2: 関数名を変更)
func check_played_chord_against_target() -> void:
	# 構成音の最小数を3と仮定 (このマジックナンバー3はリファクタリング計画で定数化を検討)
	# または、target_chord_notes.size() と比較する方がより一般的です (計画2.4で検討)
	if played_notes_buffer.size() < 3:
		return

	var sorted_played: Array[String] = played_notes_buffer.duplicate()
	sorted_played.sort() # 文字列としてソート
	var sorted_target: Array[String] = target_chord_notes.duplicate()
	sorted_target.sort() # 文字列としてソート

	if sorted_played == sorted_target:
		print("OK") # UIへのフィードバックはリファクタリング計画2.5で改善を検討
	else:
		print("NG") # UIへのフィードバックはリファクタリング計画2.5で改善を検討
		

# key.gd から key_pressed シグナルを受信したときに呼び出される関数
func _on_key_pressed_received(pressed_key_name: String) -> void:
	played_notes_buffer.append(pressed_key_name)
	check_played_chord_against_target()


# Answer Button が押されたときの処理
func _on_answer_pressed() -> void:
	print("----------------") # デバッグ用出力 (リファクタリング計画2.6で整理対象)

	if not piano_keyboard_node:
		push_warning("QuestionNode: Cannot play answer because Piano keyboard node is not found.")
		return

	if not piano_keyboard_node.has_method("play_note"):
		push_warning("QuestionNode: Piano keyboard node does not have 'play_note' method.")
		return

	for item: String in target_chord_notes:
		print(item) # デバッグ用出力 (リファクタリング計画2.6で整理対象)
		piano_keyboard_node.play_note(item)


# Memoryノードから recall_chord_selected シグナルを受信したときの処理
func _on_recall_chord_selected(name: String, notes: Array) -> void: # notes は Array[String] を期待
	print("QuestionNode: Received recall_chord_selected signal with name: ", name, ", notes: ", notes) # デバッグ用 (計画2.7で整理)

	# notes が Array[String] であることを期待。より堅牢な型チェックと変換を行うことも可能。
	target_chord_notes.clear()
	if typeof(notes) == TYPE_ARRAY:
		for note_item: Variant in notes:
			if typeof(note_item) == TYPE_STRING:
				target_chord_notes.append(note_item as String)
			else:
				push_warning("QuestionNode: Recalled notes contain non-string element: " + str(note_item))
	else:
		push_warning("QuestionNode: Recalled notes are not in expected Array format. Received: " + str(notes))


	current_question_chord_name = name # リファクタリング計画 2.7 に従い、現在のコード名も更新
	
	if question_label:
		question_label.text = current_question_chord_name
	else:
		print("QuestionNode: Question Label not found. Current question chord: ", current_question_chord_name)
		
	print("QuestionNode: Current question chord after recall: ", current_question_chord_name) # デバッグ用 (計画2.7で整理)

	played_notes_buffer.clear() # リコール後は入力バッファをクリア
