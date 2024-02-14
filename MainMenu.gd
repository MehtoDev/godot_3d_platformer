extends Control

@onready var start_button = $CenterContainer/VBoxContainer/Start
@onready var quit_button = $CenterContainer/VBoxContainer/Quit

@export var level : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_start_pressed():
	get_tree().change_scene_to_file("res://GameLevel1.tscn")

func _on_quit_pressed():
	get_tree().quit()
