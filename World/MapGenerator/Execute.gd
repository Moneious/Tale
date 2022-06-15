extends Node

onready var generator_0 = $Generator_0
onready var generator_1 = $Generator_1

onready var auto_tile = $"../Circular"
onready var base_tile = $"../Floor"
onready var player = $"../../Sort/Body"

onready var current_pos = Vector2(-9, -9)
onready var update_width = 18
onready var update_height = 18
onready var updated_blocks = [current_pos]

onready	var random = generator_0.random
onready var noise = generator_0.noise

func _ready():
	execute_generating()


func _process(delta):
	var player_pos = Vector2(round(player.transform.get_origin()[0] / 16), 
							 round(player.transform.get_origin()[1] / 16))
	var old_pos = current_pos
	var poses = [Vector2(old_pos.x-update_width, old_pos.y), 
				 Vector2(old_pos.x+update_width, old_pos.y),
				 Vector2(old_pos.x, old_pos.y-update_height),
				 Vector2(old_pos.x, old_pos.y+update_height), 
				 Vector2(old_pos.x+update_width, old_pos.y+update_height),
				 Vector2(old_pos.x-update_width, old_pos.y-update_height),
				 Vector2(old_pos.x-update_width, old_pos.y+update_height),
				 Vector2(old_pos.x+update_width, old_pos.y-update_height)]

	for coor in poses:
		# Update surrounding blocks
		if !(coor in updated_blocks):
			# print(updated_blocks)
			current_pos = coor
			execute_generating()
			updated_blocks.append(coor)
			current_pos = old_pos
		
	for coor in poses:
		if check_inside_block(coor, player_pos):
			current_pos = coor


func execute_generating():
	generator_0.generate_land(current_pos.x, current_pos.y, 
		update_width, update_height)
	generator_0.generate_border(current_pos.x, current_pos.y, 
		update_width, update_height)
	# generate_puddle(current_pos.x, current_pos.y, 
		# update_width, update_height, 50)


func verify_cell(cell:int, tile:TileMap):
	var type = "null"
	if tile == base_tile:
		if cell in range(0, 40 + 1):
			type = "grass"
		elif cell in range(54, 61 + 1):
			type = "dirt"
		elif cell in range(47, 53 + 1) or cell in range(62, 73 + 1):
			type = "sand"
		else:
			type = "void"
	return type


func search_cell(x:int, y:int, cells:Array, dimension:int, tile:TileMap) -> Dictionary:
	var count = 0
	var coor = []
	for dx in range(-dimension, dimension + 1):
		for dy in range(-dimension, dimension + 1):
			for cell in range(cells[0], cells[1] + 1):
				if tile.get_cell(x + dx, y + dy) == cell:
					count += 1
					coor.append([dx, dy])
	return {"count": count, "coor": coor}


func check_inside_block(coor:Vector2, player_pos:Vector2) -> bool:
	var left_corner = false
	if player_pos.distance_squared_to(coor) < (pow(update_width, 2) + pow(update_height, 2)):
		left_corner = true
		
	var right_corner = false
	if player_pos.distance_squared_to(coor+Vector2(update_width, update_height)) < (pow(update_width, 2) + pow(update_height, 2)):
		right_corner = true
		
	if left_corner and right_corner:
		return true
	return false
		

func pick_tile(type:String, tile:TileMap, dec_weight=0.1, bas_tile=[], dec_tile=[]) -> int:
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	if tile == base_tile:
		if type == "sand":
			bas_tile = [47, 53]
			dec_tile = [62, 73]
		elif type == "grass":
			bas_tile = [0, 2]
			dec_tile = [3, 40]
		elif type == "dirt":
			bas_tile = [54, 57]
			dec_tile = [58, 61]
	
	var cell = random.randi_range(0, (1-dec_weight) * pow(10, 2))
	if not cell:
		cell = random.randi_range(dec_tile[0], dec_tile[1])
	else:
		cell = random.randi_range(bas_tile[0], bas_tile[1])
		
	return int(cell)
