
extends Node2D

const map_names = { "res://scenes/title_screen.xscn":"title", 
					"res://scenes/tutorial.xscn":"tutorial", 
					"res://scenes/level1.xscn":"level1",
					"res://scenes/game_over.xscn":"gameover", 
					"res://scenes/level2.xscn":"level2",}
const map_songs = {	"level1":"res://sounds/snow.ogg",
					"tutorial":null,
					"title":"res://sounds/undine.ogg",
					"gameover":null, 
					"level2":null,}

var c
var load_state = 0
var load_timer
var tmap
var tcp

func _ready():
	c = get_node("/root/Controller")
	load_timer = get_node("LoadTimer")
	change_map("res://scenes/title_screen.xscn", 0)
	
func _on_Timer_timeout():
	c.life_up()

func _on_DeathTimer_timeout():
	c.death = false
	change_map(c.current_map_name, c.checkpoint)

func change_map(map, cp):
#	print([map,cp, load_timer, load_state])
	if (load_state == 0):
		if (c.current_map_name != map):
			var song = map_songs[map_names[map]]
			if (song != null):
				c.snd_manager.change_song(song)
		c.begin_cutscene()
		if (c.current_map!=null):
			c.fader.play("FadeOut")
			c.ui.hide()
		load_timer.set_wait_time(0.5)
		load_timer.start()
		tmap = map
		tcp = cp
		load_state = 1
	elif (load_state == 1):
		c.cam_target = null
		if (c.current_map!=null):
			c.current_map.queue_free()
			c.current_map.set_name(c.current_map.get_name() + "_deleted" )
		var m = load(map)
		c.checkpoint = cp
		c.current_map = m.instance()
		c.current_map_name = map
		c.map_layer.add_child(c.current_map)
		c.hide_bosshp()
		c.life_up()
		c.lifeforce_timer.stop()
		for cps in get_tree().get_nodes_in_group("Checkpoints"):
				if (cps.id == c.checkpoint):
					c.player = c.get_player()
					c.player.set_global_pos(cps.get_global_pos()-Vector2(0,-1))
		load_timer.set_wait_time(1)
		load_timer.start()
		load_state = 2
	else:
		c.end_cutscene()
		if (map_names[c.current_map_name] != "title"):
			c.ui.show()
		c.fader.play("FadeIn")
		load_state = 0

func _on_LoadTimer_timeout():
	change_map(tmap, tcp)