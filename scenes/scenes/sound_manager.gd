
extends StreamPlayer

var sfx
var changing = false
var volume = 1
var next = null
const VOL_STEP = 0.05
var muted = false
var has_muted = false

func _ready():
#	play()
	sfx = get_node("sfx")
	set_process(true)

func _process(delta):	
	if (!Input.is_action_pressed("mute")):
		has_muted = false
	elif (not has_muted and Input.is_action_pressed("mute")):
		has_muted = true
		if (muted):
			AudioServer.set_stream_global_volume_scale(volume)
			AudioServer.set_fx_global_volume_scale(volume)
		else:
			AudioServer.set_stream_global_volume_scale(0)
			AudioServer.set_fx_global_volume_scale(0)
		muted = not muted
	if (changing and volume > 0):
		volume -= VOL_STEP
		if (not muted):
			AudioServer.set_stream_global_volume_scale(volume)
	elif (changing):
		changing = false
		set_stream(next)
		play()
		next = null
		volume = 1
		if (not muted):
			AudioServer.set_stream_global_volume_scale(volume)
	if (not is_playing() and not changing):
		play()

func play_sfx(name, unique=false):
	sfx.play(name, unique)

func change_song(song):
	if (not changing):
		next = load(song)
		changing = true