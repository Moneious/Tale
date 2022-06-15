extends Area2D

onready var circle_transition = $"../../../Transition"

var entered = false
signal accepted_pressed

func _on_Area2D_body_entered(body: PhysicsBody2D):
	entered = true
	pass # Replace with function body.
	

func _on_Area2D_body_exited(body: PhysicsBody2D):
	entered = false
	pass # Replace with function body.

func _process(delta):
	if entered:
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("accepted_pressed")
