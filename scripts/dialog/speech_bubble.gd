extends Node
@onready var _label = $Label

@export var time_between_chars = 0.06
@export var time_until_disappear = 3
@export var voice = "none"

var sound_player := AudioStreamPlayer2D.new()
var rnd = RandomNumberGenerator.new()

#todo: parse out text from play_passive_text using dellimeter which will allow messages over multiple speech bubles
var text_queue : Array[String] = []
var full_text = ""
var current_text 
var characters_displayed = 0
var full_text_displayed = false
var ready_to_disappear = false
var wait_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	characters_displayed = 0
	current_text = ""
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	add_child(sound_player)
	sound_player.bus = "Effects"
	
func set_label_text(text):
	_label.text = text
	
func play_passive_text(text, newVoice):
	full_text = text
	full_text_displayed = false
	characters_displayed = 0
	current_text = ""
	voice = newVoice

func isVowel(subStr):
	if(subStr == "a" ||
	   subStr == "e" ||
	   subStr == "i" ||
	   subStr == "o" ||
	   subStr == "u" ||
	   subStr == "y"):
		return true
	else: false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	wait_time = wait_time + delta
	if(full_text_displayed == false):
		if(wait_time >= time_between_chars):
			wait_time = 0
			if(voice != "none" && isVowel(full_text.substr(characters_displayed,1))):
				var voice_num = rnd.randi_range(1,5)
				sound_player.stream = load(str("res://audio/soundFX/voice/",voice,"/",voice_num,".wav"))
				sound_player.play()
			characters_displayed = characters_displayed + 1
		current_text = full_text.substr(0,characters_displayed)
	else:
		current_text = full_text
		if(!ready_to_disappear && wait_time >= time_until_disappear):
			ready_to_disappear = true
	
	if(characters_displayed >= full_text.length()):
		full_text_displayed = true
	
	set_label_text(current_text)
