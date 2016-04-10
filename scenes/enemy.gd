extends Node2D

var hp = 1
var attack = preload("res://scenes/attack.gd")
var hit_effects = preload("res://scenes/hit_effects.scn")
var smoke_effects = preload("res://scenes/smoke_effects.scn")
var controller
var sound

func _ready():
	controller = get_node("/root/Controller")
	sound = get_node("/root/SoundManager")
	get_node("Hitbox").connect("body_enter", self, "_on_Hitbox_body_enter")
	set_fixed_process(true)

func _on_Hitbox_body_enter( body ):
	if (body extends attack):
		_get_hit()
		sound.play_sfx("hit",true)
		var controller = get_node("/root/Controller")
		var map = controller.current_map
		var instance = hit_effects.instance()
		var player = controller.get_player()
		map.add_child(instance)
		instance.play()
		instance.set_global_pos(get_global_pos()-Vector2(0,16)) #-16 + 32*player.sees_left
		instance.set_scale(Vector2(1 - 2*player.sees_left,1))
		controller.is_shaking = true
		if (hp <= 0):
			_death()

func _death():
	var instance = smoke_effects.instance()
	var player = controller.get_player()
	controller.current_map.add_child(instance)
	instance.play()
	instance.set_global_pos(get_global_pos()-Vector2(0,16))
	instance.set_scale(Vector2(1 - 2*player.sees_left,1))
	controller.is_shaking = true
	sound.play_sfx("smoke",true)
	queue_free()

func _get_hit():
	hp -= 1