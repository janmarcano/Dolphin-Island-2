
extends AnimationPlayer

var label
var current_text = []
var timer
var snd_manager
var state = "closed"

func _ready():
	state = "closed"
	label = get_node("Text")
	timer = get_node("Timer")
	snd_manager = get_node("/root/SoundManager")
	
func _fixed_process(delta):
#	print(state)
	if (state == "waitaccept"):
		if (Input.is_action_pressed("attack") or Input.is_action_pressed("jump")):
			if (current_text.size() > 0):
				snd_manager.play_sfx("accept")
				label.set_text(current_text[0])
				current_text.remove(0)
				state = "waitread"
				timer.start()
			else:
				snd_manager.play_sfx("cancel")
				state = "waitdisappear"
				label.set_text("")
				play("Disappear")
				timer.set_wait_time(get_current_animation_length())
				timer.start()
	
func show_text(text):
	if (state == "closed"):
		current_text = text
#		print(current_text[0])
#		print(text)
		state = "waitappear"
		play("Appear")
		timer.start()
		set_fixed_process(true)

func _on_Timer_timeout():
	if (state == "waitappear"):
#		print("wtf")
#		print(current_text[0])
		label.set_text(current_text[0])
		current_text.remove(0)
		state = "waitread"
		timer.start()
#		timer.set_wait_time( 60 * ( (current_text.split(" ").size()+1) /150.0 ) )
#		timer.start()		
	elif (state == "waitread"):
		state = "waitaccept"
	elif (state == "waitdisappear"):
		current_text = []
		state = "closed"
		var cont = get_node("/root/Controller")
		if (cont.cutscene):
			cont.end_cutscene()
		set_fixed_process(false)