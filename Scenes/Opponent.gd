extends Node3D

@onready var hand = $Hand
@onready var bin = $Bin




@onready var block_formation = $Enemy_Region/Blocking_Formation
@onready var attack_formation = $Own_Region/Attacking_Formation
@onready var board = $Enemy_Region/In_Play_Not_Formation
@onready var away_board = $Own_Region/In_Play_Not_Formation

var active_board = board
var priority = true
var num_draw = 2
var starting_hand = 6
var resource_activations = 2
var activated_resources = 2
var auto_activate_resources = true
signal player_resources_changed()
