extends Node3D

@onready var area = $Area3D
@export var launch_speed = 20.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if area.has_overlapping_bodies():
		var bodies = area.get_overlapping_bodies()
		for i in bodies:
			i.velocity.y = launch_speed
	pass
