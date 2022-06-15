extends Node

# {index:{"coor":Vector2, "type":string, health":int, "durable":[int, int]} 
onready var scoreboard = {}


func init_scoreboard(human_num: int, robot_num: int, land_coors: Dictionary):
	var index = 0
	
	for i in human_num:
		scoreboard[index] = {}
		scoreboard[index]["coor"] = Vector2.ZERO
		scoreboard[index]["type"] = "human"
		scoreboard[index]["health"] = 10
		scoreboard[index]["durable"] = [5, 5]
		index += 1

	for j in robot_num:
		scoreboard[index] = {}
		scoreboard[index]["coor"] = Vector2.ZERO
		scoreboard[index]["type"] = "robot"
		scoreboard[index]["health"] = 10
		scoreboard[index]["durable"] = [5, 5]
		index += 1
		
		
func init_coordination():
	for index in scoreboard.size():
		if scoreboard[index]["type"] == "human":
			pass


func _ready():
	pass
