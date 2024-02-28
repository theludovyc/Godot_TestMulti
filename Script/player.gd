extends CharacterBody2D

const SPEED = 300.0
const ACC = 100.0

const scene_player_camera = preload("res://Scene/player_camera.tscn")

@onready var inputs = $InputSynchronizer

var multiplayer_id:int

func set_player_authority(id:int):
	$InputSynchronizer.set_multiplayer_authority(id)
	
	multiplayer_id = id

func _ready():
	set_physics_process(multiplayer.is_server())
	
	if multiplayer.is_server():
		# load is allowed here, because CollisionShape2D is really tiny
		# do not use preload, because it load the res for everyone
		# for bigger res, make a loading screen
		add_child(load("res://Scene/player_shape.tscn").instantiate())
		
	if multiplayer.get_unique_id() == multiplayer_id:
		add_child(scene_player_camera.instantiate())

func _physics_process(_delta):
	if inputs.direction != Vector2.ZERO:
		velocity = velocity.move_toward(inputs.direction * SPEED, ACC)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACC)

	move_and_slide()

