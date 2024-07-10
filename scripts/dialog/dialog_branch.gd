@tool
class_name dialog_branch
extends Node2D

@onready var _editor_anim = $AnimatedSprite2D

@export var speaker_text : String
@export var speaker_portrait : SpriteFrames
@export var speaker_emote : String #animation to run on sprite

@export var speech_options : Array[String]
@export var option_branches: Array[dialog_branch]
@export var voice : String

func get_speaker_portrait():
	return speaker_portrait

func get_speaker_text():
	return speaker_text

func get_speaker_emote():
	return speaker_emote

func get_speech_options():
	return speech_options

func get_option_branches():
	return option_branches

func get_voice():
	return voice

func get_option_branch(index : int) -> dialog_branch:
	return option_branches[index]

#func _ready():
	#_editor_anim

func _draw():
	if(Engine.is_editor_hint()):
			for branch in option_branches:
				if(branch != null):
					draw_line(Vector2(), get_transform().affine_inverse() * branch.position, Color(1,0,0,1), -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Engine.is_editor_hint()):
		if(speaker_portrait != null):
			_editor_anim.sprite_frames = speaker_portrait
			if(speaker_emote != ""):
				_editor_anim.play(speaker_emote)
			else:
				_editor_anim.play("default")
		queue_redraw()