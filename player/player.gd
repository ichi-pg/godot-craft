extends CharacterBody2D

signal moved(pos)
signal picked_up(category, item_id, amount)

const SPEED = 400.0
const JUMP_VELOCITY = -1500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D


func _process(delta):
	# TODO input vs process
	if Input.is_action_just_pressed("battle_attack"):
		pass # TODO attack
	if Input.is_action_just_pressed("battle_guard"):
		pass # TODO guard
	if Input.is_action_just_pressed("battle_heal"):
		pass # TODO heal

	if velocity.x:
		sprite.flip_h = velocity.x < 0
	if velocity.y:
		sprite.animation = "jump"
		sprite.play()
	elif velocity.x:
		sprite.animation = "walk"
		sprite.play()
	else:
		sprite.animation = "walk"
		sprite.stop()


func _physics_process(delta):
	# TODO on input vs each update
	if not is_on_floor():
		velocity.y += gravity * delta
	elif Input.is_action_just_pressed("battle_dodge"):
		pass # TODO dodge
	elif Input.is_action_just_pressed("battle_jump"):
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# TODO jump sensitivity
	# TODO move inertia

	move_and_slide()

	if velocity.x or velocity.y:
		moved.emit(global_position)


func _on_pickup_body_entered(drop):
	picked_up.emit(drop.category, drop.item_id, drop.amount)
	drop.queue_free()
