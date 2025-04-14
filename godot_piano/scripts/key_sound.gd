extends AudioStreamPlayer2D


const SAMPLE_RATE: int = 44100   # サンプリングレート (Hz) - CD 音質と同じ
const DURATION: float = 1.0      # 再生時間を秒単位で定義

var buffer_size: int = 0         # バッファサイズ
var freq: float = 0.0            # 現在の周波数

var is_wave_generated: bool = false                      # 波形データが現在の周波数で生成済みかを示すフラグ
var wave_data: PackedVector2Array = PackedVector2Array() # 事前生成された波形データ


func _ready() -> void:

	# バッファサイズを計算
	buffer_size = int(SAMPLE_RATE * DURATION)

	# オーディオストリームを作成
	var audio_stream: AudioStreamGenerator = AudioStreamGenerator.new()
	audio_stream.mix_rate = SAMPLE_RATE
	audio_stream.buffer_length = DURATION

	# AudioStreamPlayer2Dにストリームを設定
	self.stream = audio_stream


# 周波数を設定する関数
func set_freq(input_freq: float) -> void:

	if freq == input_freq:
		return

	freq=input_freq

	_generate_wave_data()


# 波形データを生成する内部関数
func _generate_wave_data() -> void:

	# すでに現在の周波数で生成済みなら何もしない
	if is_wave_generated:
		return

	# 配列のサイズを確保
	wave_data.resize(buffer_size)

	# 正弦波データを生成
	for i in range(buffer_size):
		
		var time=float(i) / float(SAMPLE_RATE)
		var sample_value: float = sin(2.0 * PI * freq * time)
		
		var envelope=max(0.0,1.0-(time/DURATION))
		sample_value*=envelope


		# ステレオなので左右チャンネルに同じ値を入れる
		wave_data[i] = Vector2(sample_value, sample_value)

	# 生成完了フラグを立てる
	is_wave_generated = true


# 音を再生する関数
func play_sound() -> void:

	# 再生前に波形データが生成されているか確認し、なければ生成する
	if not is_wave_generated:
		_generate_wave_data()

	# 再生開始
	self.play()

	# 1フレーム待機して playback オブジェクトを取得
	# これにより、play() によって playback が準備されるのを待つ
	await get_tree().process_frame

	# オーディオストリーム生成プレイバックを取得
	var playback: AudioStreamGeneratorPlayback = get_stream_playback() as AudioStreamGeneratorPlayback

	# playback が正常に取得できたら、生成済みの波形データを一括で書き込む
	if playback != null:
		var pushed_frames = playback.push_buffer(wave_data)
	else:
		printerr("Failed to get AudioStreamGeneratorPlayback for key_sound.gd")

# _process は現在使用していないため、コメントアウトまたは削除しても良い
# func _process(delta: float) -> void:
# 	pass
