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
var _is_code_manager_initialized_successfully: bool = false # CodeManagerが正常に初期化されたかのフラグ


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# ピアノキーボードノード
	if not is_instance_valid(piano_keyboard_node):
		push_warning("QuestionNode: Piano keyboard node ('../kenban') not found. Key press signals will not be connected.")
	#else:
		# ピアノキーボードノードの子要素（各キー）を反復処理
		#for key_child: Node in piano_keyboard_node.get_children():
			# 各キーが "key_pressed" シグナルを持っているか確認します。
			#if key_child.has_signal("key_pressed"):
				# "key_pressed" シグナルを "_on_key_pressed_received" メソッドに接続します。
				#key_child.key_pressed.connect(_on_key_pressed_received)

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
		_is_code_manager_initialized_successfully = false
	else:
		_is_code_manager_initialized_successfully = true

	# 問題表示用ラベルノード
	if not is_instance_valid(question_label):
		push_warning("QuestionNode: Question Label node ('$Question') not found. Question text will not be updated.")

	randomize() # 乱数ジェネレータを初期化


# Called every frame. 'delta' is the elapsed time since the previous frame.
# この関数が空の場合、リファクタリング計画 3. その他 に基づき削除を検討してください。
# 今回は計画 4.2 の範囲で変更するため、そのまま残しています。
func _process(delta: float) -> void:
	pass


func get_chord_count() -> int:
	if not is_instance_valid(code_manager):
		return 0

	return 24#code_manager.get_chord_count() あとで作る



# プライベートメソッド: コード選択エラー時に状態をリセットする
func _reset_chord_selection_state() -> void:
	current_question_chord_name = ""
	target_chord_notes.clear() # 配列は clear() で空にするのが一般的


func select_chord() -> void:
	# _ready() での CodeManager の初期化結果を確認する
	if not _is_code_manager_initialized_successfully:
		_reset_chord_selection_state()
		push_warning("QuestionNode: Cannot select chord because CodeManager was not properly initialized or is missing.")
		return

	var random_index: int = randi() % get_chord_count() # get_chord_count() は内部で is_instance_valid(code_manager) をチェックしています

	if not code_manager.has_method("get_chord_by_index"):
		_reset_chord_selection_state()
		push_warning("QuestionNode: CodeManager does not have 'get_chord_by_index' method.")
		return

	var chord_data_pair: Variant = code_manager.get_chord_by_index(random_index)

	# ガード節: chord_data_pair が不正な場合は早期リターン
	if not chord_data_pair is Array or chord_data_pair.size() != 2:
		_reset_chord_selection_state()
		push_warning("QuestionNode: Failed to retrieve valid chord data pair (not an array or wrong size). Received: " + str(chord_data_pair))
		return

	# ガード節: コード名が文字列でない場合は早期リターン
	if not chord_data_pair[0] is String:
		_reset_chord_selection_state()
		push_warning("QuestionNode: Chord name in data pair is not a String. Received: " + str(chord_data_pair[0]))
		return

	# ガード節: コード詳細が辞書でない場合は早期リターン
	if not chord_data_pair[1] is Dictionary:
		_reset_chord_selection_state()
		push_warning("QuestionNode: Chord details in data pair is not a Dictionary. Received: " + str(chord_data_pair[1]))
		return

	var chord_details: Dictionary = chord_data_pair[1]

	# ガード節: "notes" キーが存在しないか、その値が配列でない場合は早期リターン
	if not chord_details.has("notes") or not chord_details["notes"] is Array:
		_reset_chord_selection_state()
		push_warning("QuestionNode: 'notes' field in chord details is missing or not an Array. Details: " + str(chord_details))
		return

	# ここまで到達すれば、データの基本構造は期待通り
	# コード名
	current_question_chord_name = chord_data_pair[0] # is String で型確認済みなので as String は不要
	# 音 (Array[String]であることを期待)
	var notes_variant: Array = chord_details["notes"] # is Array で型確認済み

	target_chord_notes.clear()
	for note_item: Variant in notes_variant:
		if note_item is String: # Godot 4.x スタイルでは typeof より is を推奨
			target_chord_notes.append(note_item) # is String で型確認済みなので as String は不要
		else:
			push_warning("QuestionNode: Chord data notes contain non-string element: " + str(note_item))
			# 不正な要素があっても、他の有効な要素は追加を試みる (仕様による)




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


# Answer Button が押されたときの処理
func _on_answer_pressed() -> void:

	if not piano_keyboard_node:
		push_warning("QuestionNode: Cannot play answer because Piano keyboard node is not found.")
		return

	if not piano_keyboard_node.has_method("play_note"):
		push_warning("QuestionNode: Piano keyboard node does not have 'play_note' method.")
		return

	for item: String in target_chord_notes:
		piano_keyboard_node.play_note(item)


# Memoryノードから recall_chord_selected シグナルを受信したときの処理
func _on_recall_chord_selected(name: String, notes: Array) -> void: # notes は Array[String] を期待
	print("QuestionNode: Received recall_chord_selected signal with name: ", name, ", notes: ", notes) # デバッグ用 (計画2.7で整理)

	# notes が Array[String] であることを期待。より堅牢な型チェックと変換を行うことも可能。
	target_chord_notes.clear()
	if notes is Array: # Godot 4.x スタイル: typeof より is を推奨
		for note_item: Variant in notes:
			# note_item が String でない場合は警告を出して、この要素の処理をスキップ
			if not note_item is String: # Godot 4.x スタイル: typeof より is を推奨し、条件を反転
				push_warning("QuestionNode: Recalled notes contain non-string element: " + str(note_item))
				continue # 次の note_item へ
			# ここに到達した場合、note_item は String 型
			target_chord_notes.append(note_item) # is String で型確認済みなので as String は不要
	else:
		push_warning("QuestionNode: Recalled notes are not in expected Array format. Received: " + str(notes))

	current_question_chord_name = name # リファクタリング計画 2.7 に従い、現在のコード名も更新
	
	if question_label:
		question_label.text = current_question_chord_name
	else:
		print("QuestionNode: Question Label not found. Current question chord: ", current_question_chord_name)
		
	print("QuestionNode: Current question chord after recall: ", current_question_chord_name) # デバッグ用 (計画2.7で整理)

	played_notes_buffer.clear() # リコール後は入力バッファをクリア
