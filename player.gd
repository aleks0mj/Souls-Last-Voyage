extends CharacterBody2D

# Constants for player movement and physics
const SPEED = 300.0
const RUN_SPEED_MULTIPLIER = 1.5
const JUMP_VELOCITY = -400.0
const FRICTION = 3000  # Ground friction
const AIR_RESISTANCE = 2000  # Air friction

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variable to track if the player is in heaven mode
var heaven_mode = false

# Track the player's jump start position
var jump_start_y = null

func _physics_process(delta):
	# If in heaven mode, skip normal physics processing
	if heaven_mode:
		return

	# Add gravity to the player's vertical velocity
	if not is_on_floor():
		velocity.y += gravity * delta

		# Apply air resistance when in the air
		velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE * delta)

		# Check if the player is falling
		if velocity.y > 0:
			if jump_start_y != null and global_position.y > jump_start_y:
				if $AnimatedSprite2D.animation != "fall":
					$AnimatedSprite2D.animation = "fall"
					$AnimatedSprite2D.play()
			elif jump_start_y == null:
				if $AnimatedSprite2D.animation != "fall":
					$AnimatedSprite2D.animation = "fall"
					$AnimatedSprite2D.play()
		elif velocity.y < 0:
			if $AnimatedSprite2D.animation != "jump":
				$AnimatedSprite2D.animation = "jump"
				$AnimatedSprite2D.play()
	else:
		# Reset jump_start_y when the player is on the ground
		jump_start_y = null

		# Handle jump input
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			jump_start_y = global_position.y
			$AnimatedSprite2D.animation = "jump"
			$AnimatedSprite2D.play()

	# Get the input direction and handle the movement/deceleration
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -= 1
	if Input.is_action_pressed("move_right"):
		direction += 1

	var current_speed = SPEED
	var is_running = Input.is_action_pressed("run")

	if is_running:
		current_speed *= RUN_SPEED_MULTIPLIER

	if direction != 0:
		# Move the player horizontally based on input direction
		velocity.x = direction * current_speed

		# Update animation and flip sprite based on movement direction
		if is_on_floor():
			if is_running:
				$AnimatedSprite2D.animation = "run"
			else:
				$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.play()
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		# Apply ground friction to stop the character when no input is detected
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
			if velocity.x == 0:
				if is_running:
					$AnimatedSprite2D.animation = "prepare"
				else:
					$AnimatedSprite2D.animation = "idle"
				$AnimatedSprite2D.play()

	# Apply movement and physics to the player
	move_and_slide() 
