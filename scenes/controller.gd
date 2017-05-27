extends Node

var root
# Lifeforce Management
var lf_active = true
var full_lifeforce = true
var lifeforce_timer
var death = false
var lf_time = 8
const LF_UP = 3
var progress
# Scene Management Variables
var map_layer
var current_map = null
var current_map_name = null
var checkpoint = 0
var player
# UI Variables
var ui # UI Node
var fader
var bosshp
var face_anim
var text_win
var multiplayer
# Camera Variables
var camera
var cam_collision
var cam_target = null
var player_class = preload("res://scenes/player.gd")
var is_shaking
var shake_state = "none"
const CAM_OFFSET = -16
const CAM_HSTR = 3#4
const CAM_VSTR = 12#4
const CAM_CUTS = 12
# Sound variables
var snd_manager
# Input variables
var cutscene = false
var press_full = false
var numberofplayers = 1

func _ready():
#	OS.set_iterations_per_second(60)
#	OS.set_target_fps(60)
	OS.set_window_maximized(true)
	randomize()
	var _root=get_tree().get_root()
	root = _root.get_child(_root.get_child_count()-1)
	lifeforce_timer = root.get_node("LifeforceTimer")
	progress = get_node("/root/Progress")
	ui = root.get_node("UILayer/UI")
	print(["ui ",ui])
	bosshp = ui.get_node("BossHP")
	fader = root.get_node("UILayer/Fade")
	face_anim = ui.get_node("FaceAnim")
	text_win = ui.get_node("TextWindow")
	multiplayer = ui.get_node("enablesora") #For enabling and disabling multiplayer with sora
	map_layer = root.get_node("Map")
	camera = root.get_node("Map/Camera")
	camera.make_current()
	snd_manager = get_node("/root/SoundManager")
	set_fixed_process(true)

func _fixed_process(delta):
#	print(current_map.get_child_count())
#	print(checkpoint)
	if (cam_target != null):
		scroll_camera()
	else:
		camera.set_pos(Vector2(160,90))

	if (is_shaking):
		cam_shake()
	# Manage Input
	if (Input.is_action_pressed("exit")):
		get_tree().quit()
	if (!Input.is_action_pressed("fullscreen")):
		press_full = false
	elif (not press_full and Input.is_action_pressed("fullscreen")):
		press_full = true
		if (OS.is_window_fullscreen()):
			OS.set_window_fullscreen(false)
		else:
			OS.set_window_fullscreen(true)

	# Manage Lifeforce
	var orb = ui.get_node("Orb")
	if (lf_active):
		var lifeforce_bar = ui.get_node("BarFill")
		if (lifeforce_timer.get_time_left() > 0):
			var raw_progress = lifeforce_timer.get_wait_time()-lifeforce_timer.get_time_left()
			var max_progress = lifeforce_timer.get_wait_time()
			var progress = raw_progress*100/max_progress
			lifeforce_bar.set_value(progress)
			orb.hide()
		elif (full_lifeforce and orb.is_hidden()):
			lifeforce_bar.set_value(100)
			orb.show()
	else:
		var lifeforce_bar = ui.get_node("BarFill")
		lifeforce_bar.set_value(0)
		orb.hide()
		lifeforce_timer.stop()
		full_lifeforce = false

func life_up():
	var time = lf_time - LF_UP * progress.checks["1ShieldUpgrade"]
	time -= LF_UP * LF_UP * progress.checks["2ShieldUpgrade"] + LF_UP * progress.checks["3ShieldUpgrade"]
	if (not full_lifeforce):
		snd_manager.play_sfx("ding")
		ui.get_node("Effects").play("FullHP")
	full_lifeforce = true
	lifeforce_timer.stop()
	lifeforce_timer.set_wait_time(time)

func life_down():
	if (not death):
		change_face("Hurt")
		if (not full_lifeforce):
			death = true
			get_player().death()
			lifeforce_timer.stop()
			root.get_node("DeathTimer").start()
		else:
			snd_manager.play_sfx("hurt",true)
			lifeforce_timer.start()
			full_lifeforce = false

func get_player():
	var player_array = get_tree().get_nodes_in_group("Player0")
	return player_array[player_array.size()-1]

func scroll_camera():
# Camera distance to player
#	print([cam_target, cam_target.get_name()])
	var pos = camera.get_global_pos()
	var opos = cam_target.get_global_pos()
	opos.y += CAM_OFFSET
	var dist = opos - pos
	dist = Vector2(round(dist.x),round(dist.y))
	var move = Vector2(dist.x/(CAM_HSTR + CAM_CUTS*(cam_target != player)), dist.y/CAM_VSTR)
#	print(dist)
	if (abs(move.x) < 1):
		move.x = sign(move.x)
	if (abs(move.y) < 1):
		move.y = sign(move.y)
		
#	# Horizontal scrolling
	if (dist.x != 0):
		pos.x += move.x
			
	# Vertical scrolling
	if (dist.y != 0):
		pos.y += move.y
#	
	pos.y = round(pos.y)
	pos.x = round(pos.x)
	# Resolve movement
	camera.set_pos(pos)

func cam_shake():
	if (shake_state == "none"):
		camera.set_offset(Vector2(-2,-2))
		shake_state = "tl"
	elif (shake_state == "tl"):
		camera.set_offset(Vector2(0,0))
		shake_state = "zero"
	elif (shake_state == "zero"):
		camera.set_offset(Vector2(2,2))
		shake_state = "br"
	elif (shake_state == "br"):
		camera.set_offset(Vector2(0,0))
		is_shaking = false
		shake_state = "none"

func show_text(text):
	text_win.show_text(text)

func change_face(text):
	face_anim.play(text)
	face_anim.queue("Neutral")
	
func begin_cutscene():
#	var player = get_player()
	cutscene = true
#	player.falling = false
#	player.jumping = false
#	player.attacking = false
#	player.top_sprite.play("Idle")
#	player.bot_sprite.play("Idle")

func end_cutscene():
	cutscene = false

func show_bosshp(value):
	bosshp.show()
	bosshp.top = value
	bosshp.current = 0

func hide_bosshp():
	bosshp.hide()
	bosshp.top = 1
	bosshp.current = 0
	bosshp.bar.set_value(0)