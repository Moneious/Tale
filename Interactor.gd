extends Node

onready var generator = $"../Generator"
onready var actor = $"../Actor"
onready var spot = $"../Tile/Spot"
onready var current_coor = Vector2(-1, -1)
onready var placeable = false
onready var chess_coor = generator.chess_base_coor

onready var move = false
onready var moving = false

onready var attack = true

func _process(delta):
	var mouse_pos = spot.world_to_map(spot.get_global_mouse_position())
	var get_coor = generator.map_to_array(mouse_pos.x, mouse_pos.y)
	if get_coor != Vector2(-1, -1):
		if current_coor != get_coor:
			generator.set_spot(current_coor.x, current_coor.y, -1)
			if move:
				placeable = actor.moveable(chess_coor, get_coor)
				if placeable:
					generator.set_spot(get_coor.x, get_coor.y, 1)
			else:
				placeable = generator.set_spot(get_coor.x, get_coor.y, 0)
			current_coor = get_coor

	else:
		placeable = false
	
func _input(event):
	if move and not moving:
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == 1 and placeable: # Left button
				moving = true
				generator.move_chess(chess_coor, current_coor, 1)
				chess_coor = current_coor
				yield(get_tree().create_timer(1), "timeout")
				moving = false
