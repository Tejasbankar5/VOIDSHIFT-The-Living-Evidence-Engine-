class_name AudioSynthesizer
extends Node

## Procedural Sci-Fi Audio Synthesizer for VOIDSHIFT.
## Generates procedural UI beeps, task clicks, alarm sirens, and kill stings
## using native AudioStreamGenerator without external audio file dependencies.

var player_audio: AudioStreamPlayer = null
var generator: AudioStreamGenerator = null
var playback: AudioStreamGeneratorPlayback = null

func _ready() -> void:
	player_audio = AudioStreamPlayer.new()
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.1
	player_audio.stream = generator
	add_child(player_audio)
	player_audio.play()
	playback = player_audio.get_stream_playback() as AudioStreamGeneratorPlayback

func play_beep(freq: float = 880.0, duration_sec: float = 0.08) -> void:
	if playback == null:
		return
	var sample_count := int(22050.0 * duration_sec)
	for i in range(sample_count):
		var t: float = float(i) / 22050.0
		var envelope: float = 1.0 - (float(i) / float(sample_count))
		var sample: float = sin(t * freq * TAU) * envelope * 0.25
		playback.push_frame(Vector2(sample, sample))

func play_task_success() -> void:
	play_beep(660.0, 0.08)
	play_beep(880.0, 0.12)

func play_kill_sting() -> void:
	play_beep(220.0, 0.3)

func play_emergency_alarm() -> void:
	play_beep(520.0, 0.15)
	play_beep(780.0, 0.15)
