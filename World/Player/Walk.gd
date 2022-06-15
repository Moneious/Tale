extends KinematicBody2D


const ACCELERATION = 80
const FRICTION = 90
const SPEED = Vector2(50, 40)

var velocity = Vector2.ZERO
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var stand_sprite = $Stand
onready var jump_sprite = $Jump
onready var ocean = $ParallaxBackground/ParallaxLayer/Ocean

func _ready():
	jump_sprite.visible = false
	ocean.visible = true
	animation_tree.active = true
	animation_player.play("Oceaning")
	
func _process(delta):
	var input_vector = Vector2.ZERO
	var accelerate_vector = Vector2.ZERO
	input_vector.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	input_vector.y = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	accelerate_vector.x = input_vector.x * SPEED.x if input_vector.x * SPEED.x < SPEED.x else SPEED.x
	accelerate_vector.y = input_vector.y * SPEED.y if input_vector.y * SPEED.y < SPEED.y else SPEED.y
	if input_vector != Vector2.ZERO:
		if Input.get_action_strength("ui_select"):
			stand_sprite.visible = false
		else:
			animation_state.travel("run")
			stand_sprite.visible = true
			velocity = velocity.move_toward(accelerate_vector, (ACCELERATION * delta) * 2)
		jump_sprite.visible = !stand_sprite.visible
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/run/blend_position", input_vector)
		animation_tree.set("parameters/jump/blend_position", velocity.normalized())
	else:
		animation_state.travel("idle")
		if velocity != Vector2.ZERO:
			if velocity.length() < 1:
				velocity = Vector2.ZERO
			else:
				velocity = velocity.move_toward(Vector2.ZERO, (FRICTION * delta) * 4)
				
	velocity = move_and_slide(velocity)

