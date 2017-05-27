
extends Area2D

export var id = 0
var player_class = preload("res://scenes/player.gd")
var controller
var sfx

func _ready():
	sfx = get_node("Sfx")
	controller = get_node("/root/Controller")

func _on_Checkpoint_body_enter( body ):
	if (body extends player_class and controller.checkpoint != id):
		controller.checkpoint = id
		get_node("AnimationPlayer").play("Effect")
		sfx.play("checkpoint")
	if (body extends player_class and controller.lf_active and not controller.full_lifeforce):
		var lifeforce_timer = controller.lifeforce_timer
		var time = lifeforce_timer.get_wait_time()
		lifeforce_timer.set_wait_time(0.0001)
		lifeforce_timer.start()
		lifeforce_timer.set_wait_time(time)