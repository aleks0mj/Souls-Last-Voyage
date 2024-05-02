extends Node

# Respawn location
var respawn_position = Vector2(0,0)  # Set this to your desired respawn location

func fade_screen_and_respawn():
	$AnimationPlayer.play("fade")
	$Player.position = respawn_position
	$Player.set_physics_process(true)
	$Player.get_node("AnimatedSprite2D").play("idle")

# This function is connected to the body_exited signal from a kill zone
func _on_void_kill_zone_body_exited(_body):
	play_death_animation()
	# Wait for x seconds using await
	await get_tree().create_timer(1.5).timeout
	fade_screen_and_respawn()

# This function handles the player's death animation
func play_death_animation():
	$Player.get_node("AnimatedSprite2D").play("death")
	$Player.set_physics_process(false)  # Optionally stop other processing
