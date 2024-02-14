extends Node

@export var gravity : float = 9.8
@export var friction : float = 8.0
@export var max_velocity_air : float = 0.6
@export var max_velocity_ground : float = 5.5
@export var max_acceleration : float = 8 * max_velocity_ground
@export var stop_speed : float = 1.5
@export var jump_impulse : float = sqrt(2 * gravity * 0.85)
@export var fov : float = 90.0

var jump_height : float = 2
var jump_time_peak : float = 0.4
var jump_time_descent : float = 0.3
var v_climb_time : float = 0.5
var h_climb_time : float = 0.3
