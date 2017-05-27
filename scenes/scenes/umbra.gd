extends "enemy.gd"

# Animation and movement variables
export var active = false
var player
var anim
var state = "none"
var timer
var head
# Combat preloads
var bite_hit = preload("res://scenes/bite_hit.scn")
var swipeL = preload("res://scenes/swipeL.res")
var swipeR = preload("res://scenes/swipeR.res")
# Combat variables
const maxhp = 10
const SPIKE_AREA = 224
const INIT_CHILL = 0.75
var chill_time = INIT_CHILL
export var vulnerable = false
export var create_bite = false
var random_spike
var spike_timer
var is_spiking = false
var times_no_bite = 0
const NUM_ATTACKS = 3
const AIMED_BITE = 0
const LONG_SWIPE = 1
const ALL_THREE = 2


func _ready():
	hp = maxhp
	head = get_node("Head")
	anim = get_node("AnimationPlayer")
	timer = get_node("Timer")
	random_spike = get_node("Spike")
	spike_timer = get_node("SpikeTimer")
	player = controller.get_player()
	get_node("Head/Hitbox").connect("body_enter", self, "_on_Hitbox_body_enter")
	set_fixed_process(true)
	
func _fixed_process(delta):
#	get_node("Label").set_text("HP: "+str(hp)+" state:"+state+" Timer:"+str(timer.get_time_left()))
	if (active):
		if (hp < maxhp/2):
			chill_time = INIT_CHILL * 0.65
			if (not is_spiking):
				is_spiking = true
				spike_move()
		elif (hp < maxhp/4):
			chill_time = INIT_CHILL * 0.4
		if (state == "none"):
			state = "ready"
		if (state == "ready"):
		# Decide what to do
			var decision = randi() % NUM_ATTACKS
			if (times_no_bite > 1):
				decision = AIMED_BITE
			if (decision == AIMED_BITE):
				var dist_to_player = player.get_pos().x-head.get_global_pos().x
				aimed_bite(floor(dist_to_player))
				times_no_bite = 0
			elif (decision == LONG_SWIPE):
				times_no_bite += 0.5
				var direction = randi() % 2
				if (direction == 0):
					state = "beginlongswipeL"
					get_node("SwipeLeft").add_child(swipeL.instance())
				else:
					state = "beginlongswipeR"
					get_node("SwipeRight").add_child(swipeR.instance())
				timer.set_wait_time(0.5)
				timer.start()
			elif (decision == ALL_THREE):
				times_no_bite += 1
				get_node("SwipeLeft").add_child(swipeL.instance())
				get_node("SwipeRight").add_child(swipeR.instance())
				mid_bite()
				state = "allthreewait"
				timer.set_wait_time(1)
				timer.start()

	if (create_bite):
		create_bite = false
		head.add_child(bite_hit.instance())

func aimed_bite(dist):
	head.set_pos(Vector2(head.get_pos().x+dist,head.get_pos().y))
	anim.play("Bite")
	state = "bitewait"
	timer.set_wait_time(2)
	timer.start()
	
func mid_bite():
	head.set_pos(Vector2(0,head.get_pos().y))
	anim.play("ShortBite")
	state = "allthreeewait"
	timer.set_wait_time(1)
	timer.start()

func chill():
	timer.set_wait_time(chill_time)
	timer.start()
	state = "chill"

func spike_move():
	if (active):
		var pos = (randi() % SPIKE_AREA) - (SPIKE_AREA/2)
		random_spike.set_pos(Vector2(pos,0))
		spike_timer.start()
		random_spike.get_node("AnimationPlayer").play("Appear")

func _on_Timer_timeout():
	if (state == "chill"):
		state = "ready"
	elif (state == "bitewait"):
		chill()
	elif (state == "allthreewait"):
		chill()
	elif (state == "beginlongswipeL"):
		get_node("SwipeMid").add_child(swipeL.instance())
		state = "midlongswipeL"
		timer.start()
	elif (state == "midlongswipeL"):
		get_node("SwipeRight").add_child(swipeL.instance())
		state = "finishlongswipeL"
		timer.start()
	elif (state == "finishlongswipeL"):
		chill()
	elif (state == "beginlongswipeR"):
		get_node("SwipeMid").add_child(swipeR.instance())
		state = "midlongswipeR"
		timer.start()
	elif (state == "midlongswipeR"):
		get_node("SwipeLeft").add_child(swipeR.instance())
		state = "finishlongswipeR"
		timer.start()
	elif (state == "finishlongswipeR"):
		chill()

func _on_Hitbox_body_enter( body ):
	if (vulnerable and body extends attack):
		hp -= 1
		get_node("/root/SoundManager").play_sfx("hit",true)
		controller.is_shaking = true
		var map = controller.current_map
		var instance = hit_effects.instance()
		map.add_child(instance)
		instance.play()
		instance.set_global_pos(head.get_global_pos()-Vector2(0,64))
		instance.set_scale(Vector2(1 - 2*controller.get_player().sees_left,1))
		controller.is_shaking = true
		if (hp <= 0):
			_death()

func _death():
	active = false
	var instance = smoke_effects.instance()
	var player = controller.get_player()
	controller.current_map.add_child(instance)
	instance.play()
	instance.set_global_pos(head.get_global_pos()-Vector2(0,64))
	instance.set_scale(Vector2(1 - 2*player.sees_left,1))
	controller.is_shaking = true
	sound.play_sfx("smoke",true)
	queue_free()
	
func _get_hit():
	if (vulnerable):
		hp -= 1

func _on_SpikeTimer_timeout():
	spike_move()
