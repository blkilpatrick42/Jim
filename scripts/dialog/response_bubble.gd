class_name response_bubble
extends Node2D

var label_settings = preload("res://dialog/bubble_settings.tres")
@onready var _label = $Label

func set_label(text : String):
	_label.text = text
