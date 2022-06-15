extends Node

onready var generator = $"../Generator"
onready var interactor = $"../Interactor"

func selector(x0: int, y0: int, region: int, cross: bool) -> Array:
	var selectable_coors = []
	if cross:
		for dx in range(-region, region+1):
			if generator.set_spot(x0+dx, y0, -1):
				selectable_coors.append(Vector2(x0+dx, y0))
		for dy in range(-region, region+1):
			if generator.set_spot(x0, y0+dy, -1):
				selectable_coors.append(Vector2(x0, y0+dy))
	else:
		for dx in range(-region, region+1):
			for dy in range(-region, region+1):
				if generator.set_spot(x0+dx, y0+dy, -1):
					selectable_coors.append(Vector2(x0+dx, y0+dy))
	return selectable_coors
	
	
func moveable(current_pos: Vector2, target_pos: Vector2):
	var acceptable_coors = selector(current_pos.x,current_pos.y, 1, true)
	if Vector2(target_pos.x, target_pos.y) in acceptable_coors:
		for coor in generator.chess_coors:
			if Vector2(coor.x, coor.y) == target_pos:
				return false
		return true
	else:
		return false
		

func attackable():
	pass

		
