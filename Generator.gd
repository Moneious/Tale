extends Node

var land_coors = {
	0:[],
	1:[],
	2:[]
}
var chess_coors = []
var ready_for_cleaning = []

onready var land_0 = $"../Tile/Land_0"
onready var land_1 = $"../Tile/Land_1"
onready var land_2 = $"../Tile/Land_2"
onready var chess = $"../Tile/Chess"
onready var spot = $"../Tile/Spot"
onready var camera = $"../Camera2D"

onready var chess_anim = load("res://Asset/Chess/ChessAnimation/ChessAnimation.tres")
onready var chess_anim_inverse = load("res://Asset/Chess/ChessAnimation/ChessAnimationInverse.tres")
onready var timer = $Timer
onready var chess_base_coor = Vector2(0, 0)
onready var width = 1 # x_direction length
onready var height = 1 # y_direction length


func _ready():
	generate_land(width, height)
	# x, y, tile
	set_chess(chess_base_coor.x, chess_base_coor.y, 1)
	set_chess(1, 2, 1)
	construct_graph()
	# from, to, type
	# move_chess(Vector2(0, 0), Vector2(3, 0), 1)
	# move_chess(Vector2(1, 2), Vector2(2, 1), 1)
	
func construct_graph():
	var all_coors = {}
	# Layer 0 constructing
	for coor in land_coors[0]:
		all_coors[Vector3(coor.x, coor.y, 0)] = {}
		for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var coor_offset = coor + offset
			if coor + offset in land_coors[0]:
				all_coors[Vector3(coor.x, coor.y, 0)][Vector3(coor_offset.x, coor_offset.y, 0)] = 1
			if coor + offset in land_coors[1]:
				all_coors[Vector3(coor.x, coor.y, 0)][Vector3(coor_offset.x, coor_offset.y, 1)] = 2
			if coor + offset in land_coors[2]:
				all_coors[Vector3(coor.x, coor.y, 0)][Vector3(coor_offset.x, coor_offset.y, 1)] = -1
	# Layer 1 constructing
	for coor in land_coors[1]:
		all_coors[Vector3(coor.x, coor.y, 1)] = {}
		for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var coor_offset = coor + offset
			if coor + offset in land_coors[0]:
				all_coors[Vector3(coor.x, coor.y, 1)][Vector3(coor_offset.x, coor_offset.y, 0)] = 2
			if coor + offset in land_coors[1]:
				all_coors[Vector3(coor.x, coor.y, 1)][Vector3(coor_offset.x, coor_offset.y, 1)] = 1
			if coor + offset in land_coors[2]:
				all_coors[Vector3(coor.x, coor.y, 1)][Vector3(coor_offset.x, coor_offset.y, 2)] = 2
	# Layer 2 constructing
	for coor in land_coors[2]:
		all_coors[Vector3(coor.x, coor.y, 2)] = {}
		for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, 1), Vector2(0, -1)]:
			var coor_offset = coor + offset
			if coor + offset in land_coors[0]:
				all_coors[Vector3(coor.x, coor.y, 2)][Vector3(coor_offset.x, coor_offset.y, 0)] = -1
			if coor + offset in land_coors[1]:
				all_coors[Vector3(coor.x, coor.y, 2)][Vector3(coor_offset.x, coor_offset.y, 1)] = 2
			if coor + offset in land_coors[2]:
				all_coors[Vector3(coor.x, coor.y, 2)][Vector3(coor_offset.x, coor_offset.y, 2)] = 1
	return all_coors
	
	
func array_to_map(x: int, y: int, dx=0, dy=0) -> Vector2:
	var x0 = x+3*y
	var y0 = -3*x-y
	x0 += dx
	y0 += dy
	return Vector2(x0, y0)


func map_to_array(x: int, y: int, dx=0, dy=0) -> Vector2:
	x -= dx
	y -= dy
	var x0 = -(x+3*y)/8
	var y0 = (3*x+y)/8
	return Vector2(x0, y0)
	
	
func generate_land(x_range: int, y_range: int):
	for x in x_range:
		for y in y_range:
			set_land(x, y, 3, 0)
	if width > 3 and height > 3:
		camera.transform.origin += Vector2(15 * (width - 3), 2 * (height - 3))
	

func set_land(x: int, y: int, tile: int, layer: int) -> Dictionary:
	# index 0 for land_0, etc
	var coor = array_to_map(x, y, -layer, -layer)
	if tile != -1:
		land_coors[layer].append(Vector2(x, y))
	else:
		var index = search_land_exist(x, y, layer)
		if index >= 0:
			land_coors[layer].pop_at(index)
		else:
			pass

	var index = layer
	if index == 0:
		land_0.set_cell(coor.x, coor.y, tile)
	elif index == 1:
		land_1.set_cell(coor.x, coor.y, tile)
	elif index == 2:
		land_2.set_cell(coor.x, coor.y, tile)
	return land_coors


func get_land(x: int, y: int, layer: int) -> int:
	# index 0 for land_0, etc
	var coor = array_to_map(x, y, -layer, -layer)
	var index = layer
	if index == 0:
		return land_0.get_cell(coor.x, coor.y)
	elif index == 1:
		return land_1.get_cell(coor.x, coor.y)
	elif index == 2:
		return land_2.get_cell(coor.x, coor.y)
	else:
		return -1
		

func search_land_exist(x: int, y: int, layer: int) -> int:
	var index = 0
	for coor in land_coors[layer]:
		if coor == Vector2(x, y):
			return index
		index += 1
	return -1


func set_spot(x: int, y: int, tile: int) -> bool:
	var selected_layer = 0
	if search_land_exist(x, y, 0) >= 0:
		selected_layer = 0
		if search_land_exist(x, y, 1) >= 0:
			selected_layer = 1
			if search_land_exist(x, y, 2) >= 0:
				selected_layer = 2
	var set_coor = array_to_map(x, y)
	if land_0.get_cell(set_coor.x, set_coor.y) >= 0:
		spot.set_cell(set_coor.x - selected_layer, set_coor.y - selected_layer, tile)
		return true
	return false


func set_chess(x: int, y: int, tile: int) -> Vector3:
	var selected_layer = 0
	if search_land_exist(x, y, 0) >= 0:
		selected_layer = 0
		if search_land_exist(x, y, 1) >= 0:
			selected_layer = 1
			if search_land_exist(x, y, 2) >= 0:
				selected_layer = 2
	var coor = array_to_map(x, y, -2, -2)
	chess.set_cell(coor.x - selected_layer, coor.y - selected_layer, tile)
	var height = selected_layer
	if !(tile in [-1, 4, 5]):
		chess_coors.append(Vector3(x, y, height))
	return Vector3(x, y, height)
	

func move_chess(from: Vector2, to: Vector2, type: int):
	var moveable = false
	var kickable = false
	var index = 0
	var got_index = 0
		
	for coor in chess_coors:
		if from == Vector2(coor.x, coor.y):
			moveable = true
			got_index = index
		if to == Vector2(coor.x, coor.y):
			kickable = true
		index += 1

	if moveable:
		chess_coors.pop_at(got_index)
		set_chess(from.x, from.y, -1)
		if type == 1: 
			chess_anim.set_current_frame(0)
			chess_anim_inverse.set_current_frame(0)
			set_chess(from.x, from.y, 4)
			set_chess(to.x, to.y, 5)
			# ready_for_cleaning.append({"from": from,"to": to})
			# var coor_dic = ready_for_cleaning.pop_back()
			
			yield(get_tree().create_timer(1), "timeout")
			
			var coor_dic = {"from": from,"to": to}
			set_chess(coor_dic["from"].x, coor_dic["from"].y, -1)
			set_chess(coor_dic["to"].x, coor_dic["to"].y, 1)
	
	
	
