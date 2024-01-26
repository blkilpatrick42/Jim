extends Node
@onready var _label = $Label

@export var time_between_chars = 0.1
@export var time_until_disappear = 2

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
	
func set_label_text(text):
	_label.text = text
	
func play_passive_text(text):
	full_text = text
	full_text_displayed = false
	characters_displayed = 0
	current_text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wait_time = wait_time + delta
	if(full_text_displayed == false):		
		if(wait_time >= time_between_chars):
			wait_time = 0
			characters_displayed = characters_displayed + 1
		current_text = full_text.substr(0,characters_displayed)
	else:
		current_text = full_text
		if(!ready_to_disappear && wait_time >= time_until_disappear):
			ready_to_disappear = true
	
	if(characters_displayed >= full_text.length()):
		full_text_displayed = true
	
	set_label_text(current_text)
