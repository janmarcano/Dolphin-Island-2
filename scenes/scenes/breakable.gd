
extends Sprite

export var solid = true
export var strong = true
export var hits = 1
var normal_hit = preload("res://scenes/attack.gd")
var strong_hit = preload("res://scenes/strong_attack.gd")
var smoke_effects = preload("res://scenes/smoke_effects.scn")
var controller

func _ready():
	controller = get_node("/root/Controller")

func _on_Area2D_body_enter( body ):
	if (body extends strong_hit):
		var instance = smoke_effects.instance()
		var player = controller.get_player()
		controller.current_map.add_child(instance)
		instance.play()
		instance.set_global_pos(get_global_pos()+Vector2(8,8))
		controller.is_shaking = true
		controller.snd_manager.play_sfx("smoke",true)
		queue_free()
