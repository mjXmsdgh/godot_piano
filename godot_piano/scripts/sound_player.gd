extends AudioStreamPlayer2D

# サンプリングレート (Hz) - CD 音質と同じ
const SAMPLE_RATE: int = 44100

# 再生時間を秒単位で定義
const DURATION: float = 1.0

#　周波数
var FREQUENCY: float = 440.0

# バッファサイズ
var buffer_size: int = 0


func _ready() -> void:
	# バッファサイズを計算
	buffer_size = int(SAMPLE_RATE * DURATION)
	
	# オーディオストリームを作成
	var audio_stream: AudioStreamGenerator = AudioStreamGenerator.new()
	audio_stream.mix_rate = SAMPLE_RATE
	
	# AudioStreamPlayer2Dにストリームを設定
	self.stream = audio_stream


func set_freq(input_freq: float) -> void:
	FREQUENCY = input_freq



func play_c4_sound() -> void:

	# 再生
	self.play()
	
	# 1フレーム待機
	await get_tree().process_frame
	
	# オーディオストリーム生成プレイバックを作成
	var playback: AudioStreamGeneratorPlayback = self.get_stream_playback() as AudioStreamGeneratorPlayback
	
	# 正弦波データを生成
	for i in range(buffer_size):
		var sample_value: float = sin(2.0 * PI * FREQUENCY * float(i) / float(SAMPLE_RATE))
		playback.push_frame(Vector2(sample_value, sample_value))
