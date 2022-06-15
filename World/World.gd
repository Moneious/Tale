extends Node2D


onready var circle_transition = $Transition


func _ready():
	circle_transition.visible = true
	circle_transition.transition_out()
	
func _on_Tansition_transition_in_accepted():
	circle_transition.transition_in()
	
func _on_Transition_transition_in_done():
	get_tree().change_scene("res://Chess.tscn")
