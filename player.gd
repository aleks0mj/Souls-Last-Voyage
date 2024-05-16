extends CharacterBody2D

# Constants for player movement and physics
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FRICTION = 3000  # Ground friction
const AIR_RESISTANCE = 2000  # Air friction

# Reference to the Fade node for screen transition effects
@onready var fade = get_node("../Fade")  # Adjust path as necessary

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add gravity to the player's vertical velocity
	if not is_on_floor():
		velocity.y += gravity * delta

		# Apply air resistance when in the air
		velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE * delta)

		# Play the jump animation if moving upwards and it's not already playing
		if velocity.y < 0 and $AnimatedSprite2D.animation != "jump":
			$AnimatedSprite2D.animation = "jump"
			$AnimatedSprite2D.play()

	# Handle jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.animation = "jump"
		$AnimatedSprite2D.play()

	# Get the input direction and handle the movement/deceleration
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1

	if direction != 0:
		# Move the player horizontally based on input direction
		velocity.x = direction * SPEED

		# Update animation and flip sprite based on movement direction
		if is_on_floor():
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.play()
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		# Apply ground friction to stop the character when no input is detected
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
			if velocity.x == 0:
				$AnimatedSprite2D.animation = "idle"
				$AnimatedSprite2D.play()

	# Apply movement and physics to the player
	move_and_slide()  # No parameters needed in Godot 4.0 for CharacterBody2D
