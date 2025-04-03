extends AudioStreamPlayer2D

# C4 の周波数 (Hz)
const C4_FREQUENCY = 261.63

# サンプリングレート (Hz) - CD 音質と同じ
const SAMPLE_RATE = 44100

# バッファの長さ (秒) - 0.5 秒の音を生成
const BUFFER_LENGTH = 0.5

# 音の振幅 (0.0 ~ 1.0) - 0.5 は中くらいの音量
const AMPLITUDE = 0.5

func _ready():
	pass

func play_c4_sound():
	# AudioStreamGenerator を作成
	var audio_stream_generator = AudioStreamGenerator.new()
	audio_stream_generator.mix_rate = SAMPLE_RATE
	audio_stream_generator.buffer_length = BUFFER_LENGTH

	# サイン波のデータを生成
	var buffer_size = int(BUFFER_LENGTH * SAMPLE_RATE)
	var data = PackedFloat32Array()
	for i in range(buffer_size):
		var time = float(i) / SAMPLE_RATE
		var sample = AMPLITUDE * sin(2.0 * PI * C4_FREQUENCY * time)
		data.push_back(sample)

	# SoundPlayer に生成したストリームを設定
	stream = audio_stream_generator

	# 音を再生
	play()
