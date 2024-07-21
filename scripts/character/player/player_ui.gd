extends Control

@onready var heart_1 : AnimatedSprite2D = $health_meter/heart_1
@onready var heart_2 : AnimatedSprite2D = $health_meter/heart_2
@onready var heart_3 : AnimatedSprite2D = $health_meter/heart_3
@onready var location_header = $location_header
@onready var money_label = $money_tracker/money_label
@onready var pizza_lost = $pizza_lost

var sound_player = AudioStreamPlayer.new()

var hearts : Array[Node] = []

var money_timer = Timer.new()
var money_step_pause_secs = 0.06
var current_money = 0
var money = 0

var pizza_loss_timer = Timer.new()
var pizza_loss_on_screen_seconds = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	money_timer.one_shot = true
	pizza_loss_timer.one_shot = true
	add_child(money_timer)
	add_child(pizza_loss_timer)
	sound_player.bus = "Effects"
	add_child(sound_player)
	hearts = [heart_1, heart_2, heart_3]

func update_hearts(points : int):
	var iterator = 0
	while(iterator < hearts.size()):
		if(iterator < points):
			hearts[iterator].play("active")
		else:
			hearts[iterator].play("inactive")
		iterator+=1

func _on_pizza_lost():
	pizza_lost.visible = true
	pizza_loss_timer.start(pizza_loss_on_screen_seconds)
	sound_player.stream = load("res://audio/soundFX/pizza_lost.wav")
	sound_player.play()

func set_money(num : int):
	money = num

func set_money_tracker(money : int):
	money_label.text = str("$",money)
	

func activate_header(label : String):
	location_header.activate_header(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(money_timer.is_stopped()):
		if(current_money < money):
			current_money = current_money + 1
			sound_player.stream = load("res://audio/soundFX/coins.wav")
			sound_player.play()
		if(current_money > money):
			current_money = current_money - 1
			sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
			sound_player.play()
		money_timer.start(money_step_pause_secs)
	if(pizza_loss_timer.is_stopped() && pizza_lost.visible):
		pizza_lost.visible = false
	set_money_tracker(current_money)
