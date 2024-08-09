class_name dialog_bubble
extends Node2D

var time_between_chars = 0.06

@onready var _portrait = $portrait
@onready var _label = $Label

var full_text = ""
var current_text 
var characters_displayed = 0
var full_text_displayed = false
var wait_time = 0
var voice : String = "none"

var sound_player := AudioStreamPlayer2D.new()
var rnd = RandomNumberGenerator.new()

func set_portrait(sprite : SpriteFrames, animation_name : String):
	_portrait.sprite_frames = sprite
	_portrait.play(animation_name)

func set_label(text : String):
	_label.text = text

func set_text(text : String):
	full_text = text

func set_voice(in_voice : String):
	voice = in_voice

func set_time_between_chars(time : float):
	time_between_chars = time

func play_text(text, newVoice):
	full_text = text
	full_text_displayed = false
	characters_displayed = 0
	current_text = ""
	voice = newVoice

func is_text_done_playing():
	return full_text_displayed

func isVowel(subStr):
	if(subStr == "a" ||
	   subStr == "e" ||
	   subStr == "i" ||
	   subStr == "o" ||
	   subStr == "u" ||
	   subStr == "y"):
		return true
	else: false

func _ready():
	characters_displayed = 0
	current_text = ""
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	add_child(sound_player)
	sound_player.bus = "Effects"
	

func _process(delta):
	if(_portrait.sprite_frames == null):
		_label.size.x = 220
		_label.position.x = -110
	else:
		_label.size.x = 110
		_label.position.x = 0
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
	
	if(characters_displayed >= full_text.length()):
		full_text_displayed = true
	
	set_label(current_text)
