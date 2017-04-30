
extends "res://scenes/attack.gd"

func attack():
	set_layer_mask(0)
	set_collision_mask(0)

func free():
	self.queue_free()
