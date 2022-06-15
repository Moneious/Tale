extends Node


onready var auto_tile = $"../../Circular"
onready var base_tile = $"../../Floor"
onready var generator = $"../../Generator"

onready var current_pos = generator.current_pos
onready var update_width = generator.update_width
onready var update_height = generator.update_height
onready var updated_blocks = generator.updated_blocks

onready	var random = RandomNumberGenerator.new()
onready var noise = OpenSimplexNoise.new()

func _ready():
	random.randomize()
	noise.seed = random.randi()
	
func generate_land(x0:int, y0:int, width:int, height:int) -> Array:
	random.randomize()
	noise.set_period(64)
				
	var land_tiles = []
	var sand_tiles = []
	var peak_tiles = []
	for x in width:
		for y in height:
			var x1 = x + x0
			var y1 = y + y0
			if noise.get_noise_2d(x1, y1) > 0:
				base_tile.set_cell(x1, y1, generator.pick_tile("grass", base_tile), 
					random.randi_range(0, 1))
				land_tiles.append(Vector2(x1, y1))
				if noise.get_noise_2d(x1, y1) > 0.22:
					# auto_tile.set_cell(x, y, 0)
					base_tile.set_cell(x1, y1, 74)
					peak_tiles.append(Vector2(x1, y1))
			else:
				base_tile.set_cell(x1, y1, generator.pick_tile("dirt", base_tile), 
					random.randi_range(0, 1))
				sand_tiles.append(Vector2(x1, y1))
	
	return [land_tiles, sand_tiles, peak_tiles]


func generate_border(x0:int, y0:int, width:int, height:int):
	for x in width:
		for y in height:
			var x1 = x + x0
			var y1 = y + y0
			var placeable = false
			var current_tile = base_tile.get_cell(x1, y1)
			if generator.verify_cell(current_tile, base_tile) == "grass":
				placeable = true
					
			var asset = generator.search_cell(x1, y1, [54, 61], 1, base_tile)
			if placeable and asset["count"]:
				for binary in asset["coor"]:
					var cx = ceil((x1 * 2 + 1/2) + (binary[0] * 3/2))
					var cy = ceil((y1 * 2 + 1/2) + (binary[1] * 3/2))
					var fx = floor((x1 * 2 + 1/2) + (binary[0] * 3/2))
					var fy = floor((y1 * 2 + 1/2) + (binary[1] * 3/2))
					for dx in [-1, 0, 1]:
						for dy in [-1, 0, 1]:
							auto_tile.set_cell(cx + dx, cy + dy, 27)
							auto_tile.set_cell(fx + dx, fy + dy, 27)
	
	auto_tile.update_bitmask_region(Vector2(x0, y0) * 2 - Vector2(3, 3), 
									Vector2(width+x0, height+y0) * 2 + Vector2(3, 3))
	
func generate_puddle(x0:int, y0:int, width:int, height:int, frequency:int):
	# frequency should be smaller than 64
	var random = RandomNumberGenerator.new()
	random.randomize()
	noise.set_period(abs(64 - frequency))
	
	var puddle_tiles = []
	for x in width:
		for y in height:
			var x1 = x + x0
			var y1 = y + y0
			var base_certf = false
			var auto_certf = true
			# Never set cells on tiles which are not grass
			if generator.verify_cell(base_tile.get_cell(x1, y1), base_tile) == "grass":
				base_certf = true
			# Never set cells on tiles which are borders
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if auto_tile.get_cell(2 * x1 + dx, 2 * y1 + dy) == 27:
						auto_certf = false
				
			if noise.get_noise_2d(2 * x1, 2 * y1) > 0.3 and (base_certf and auto_certf):
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						auto_tile.set_cell(2 * x1 + dx, 2 * y1 + dy, 0)
						
	auto_tile.update_bitmask_region(Vector2(x0, y0) * 2 - Vector2(3, 3), 
									Vector2(width+x0, height+y0) * 2 + Vector2(3, 3))
