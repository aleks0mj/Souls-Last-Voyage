extends Node

# Respawn location
var respawn_position = Vector2(0,0)  # Set this to your desired respawn location
var heaven_mode = false
var floating_velocity_y = 0.0

# Reference to the "Play Again" button
@onready var play_again_button = $CanvasLayer/PlayAgainButton  # Adjust path as necessary

func fade_screen_and_respawn():
	$AnimationPlayer.play("fade")
	await get_tree().create_timer(1.5).timeout
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

# This function is connected to the body_entered signal from HeavenZone
func _on_heaven_zone_body_entered(_body):
	heaven_mode = true
	floating_velocity_y = -20.0  # Initial upward velocity
	$Player.set_physics_process(false)  # Optionally stop other processing
	$Player.heaven_mode = true  # Set heaven mode in the player script
	$Player.get_node("AnimatedSprite2D").play("float")  # Assuming you have a float animation
	$Player.get_node("AudioStreamPlayer2D2").play()  # Play the heaven music
	$Player.get_node("AnimationPlayer0").play("CloudFade")
	fade_out_audio_stream_player2d()
	trigger_fade_to_white()
	stop_floating_after_delay()
	await get_tree().create_timer(11).timeout
	$Player.get_node("AnimationPlayer1").play("Credits")
	await get_tree().create_timer(69).timeout  # Wait for the credits to finish
	$AnimationPlayer.play("GameTitleIn")
	await get_tree().create_timer(4.5).timeout
	show_play_again_button()
	await get_tree().create_timer(3.5).timeout
	$AnimationPlayer.play("Minou")
	await get_tree().create_timer(67).timeout
	$AnimationPlayer.play("GameTitleOut")
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("DadQuote")

func _process(delta):
	if heaven_mode:
		floating_velocity_y *= 1.001  # Gradually increase the velocity
		$Player.position.y += floating_velocity_y * delta  # Apply the velocity with delta

func trigger_fade_to_white():
	await get_tree().create_timer(65.0).timeout  # Wait for x seconds
	#$Fade2.modulate = Color(1, 1, 1, 0)  # Ensure the initial alpha is 0
	#$Fade2.visible = true  # Make sure the Fade2 is visible
	$AnimationPlayer.play("fade2")  # Play the fade to white animation

func fade_out_audio_stream_player2d():
	var initial_volume = $Player.get_node("AudioStreamPlayer2D").volume_db
	var target_volume = -80  # A very low volume value, effectively silent
	var duration = 2.0  # Duration over which to fade out

	for t in range(duration * 10):
		var new_volume = initial_volume + (target_volume - initial_volume) * (t / (duration * 10))
		$Player.get_node("AudioStreamPlayer2D").volume_db = new_volume
		await get_tree().create_timer(0.1).timeout
	$Player.get_node("AudioStreamPlayer2D").stop()

func stop_floating_after_delay():
	await get_tree().create_timer(80.0).timeout  # Wait for 80 seconds
	heaven_mode = false  # Disable heaven mode
	floating_velocity_y = 0  # Stop the upward velocity

func show_play_again_button():
	play_again_button.visible = true
	play_again_button.grab_focus()
	# Optionally, play an animation to show the button
	$AnimationPlayer.play("show_play_again_button")

func fade_out_audio_stream_player2d2():
	var audio_player = $Player.get_node("AudioStreamPlayer2D2")
	if audio_player.playing:
		var initial_volume = audio_player.volume_db
		var target_volume = -80  # A very low volume value, effectively silent
		var duration = 3.0  # Duration over which to fade out

		for t in range(int(duration * 10)):
			var new_volume = initial_volume + (target_volume - initial_volume) * (t / (duration * 10))
			audio_player.volume_db = new_volume
			await get_tree().create_timer(0.1).timeout
		audio_player.stop()

# Function to handle the play again button press
func _on_PlayAgainButton_pressed():
	$AnimationPlayer2.play("EndFade")
	await fade_out_audio_stream_player2d2()
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
