extends Node2D

onready var tile_0 = $"/root/World/Tile/Cliff"

func _ready():
	var shadow_0 = tile_0.duplicate()
	print(shadow_0.offset)
	pass
