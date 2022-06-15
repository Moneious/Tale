extends ColorRect


signal transition_in_done
signal transition_out_done


onready var animation_player = $AnimationPlayer
onready var ui = $"../Sort/Body/UI"


func transition_in():
	animation_player.play("transition_in")


func transition_out():
	animation_player.play("transition_out")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "transition_in":
		emit_signal("transition_in_done")
	elif anim_name == "transition_out":
		emit_signal("transition_out_done")
