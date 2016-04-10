
extends Node2D

var can_press = false
var sound

func _ready():
	sound = get_node("SamplePlayer")
	set_fixed_process(true)

func _fixed_process(delta):
	if (not Input.is_action_pressed("pause")):
		can_press = true
	elif (can_press and Input.is_action_pressed("pause")):
		print("lets go")
		can_press = false
		if (get_tree().is_paused()):
			sound.play("cancel")
			get_tree().set_pause(false)
			hide()
		else:
			show()
			get_tree().set_pause(true)
			sound.play("accept")