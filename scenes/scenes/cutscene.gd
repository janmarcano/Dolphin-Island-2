
extends Area2D

var player_class = preload("res://scenes/player.gd")
var controller
var text = ["Hi! I'm a forgotten cutscene.", "Please fix me."]
var check = null
var cutscene = true
var do_text = true

func _ready():
	controller = get_node("/root/Controller")
	connect("body_enter",self,"_on_Area2D_body_enter")
	pass

func _on_Area2D_body_enter( body ):
	if (body extends player_class):
		var test = get_node("/root/Progress").checks
		if (check == null or (check != null and not test[check])):
			show()
			if (cutscene):
				controller.begin_cutscene()
			if (check != null):
				test[check] = true
			if (do_text):
				controller.show_text(text)
