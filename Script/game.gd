extends Node

const scene_player = preload("res://Scene/player.tscn")

@onready var le_port:LineEdit = get_node("%LineEdit_Port")
@onready var le_ip:LineEdit = get_node("%LineEdit_IP")

@onready var popup_error = $AcceptDialog

@onready var gui_connect = $ConnectGui

@onready var multi_spawner = $MultiplayerSpawner

@onready var player_spawn_pos = $PlayerSpawnPos
@onready var players = $Players

func _ready():
	# repeat the string path instead of create a const, so it will be deleted in memory
	multi_spawner.add_spawnable_scene("res://Scene/player.tscn")
	
	# use a custom spawn_function here, to set the multiplayer authority on player
	# if you do not it will create an error
	multi_spawner.spawn_function = add_player
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func add_player(id : int) -> Node:
	var player = scene_player.instantiate()
	player.set_player_authority(id)
	
	#necessary to remove them easily
	player.name = str(id)
	
	var players_count = players.get_child_count()
	
	match(players_count):
		0: player.modulate = Color.RED
			
		1: player.modulate = Color.GREEN
		
		3: player.modulate = Color.YELLOW
	
	player.position = player_spawn_pos.get_child(players_count).position
	
	return player

func _on_create_server_button_down():
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(int(le_port.text), 4) != OK:
		var str_er_create_serv = "cannot create the server !"
		
		push_error(name, str_er_create_serv)
		popup_error.dialog_text = str_er_create_serv
		popup_error.popup()
		return
	
	multiplayer.multiplayer_peer = peer
	
	var _on_peer_connected = func(id:int):
		multi_spawner.spawn(id)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	var _on_peer_disconnected = func(id:int):
		players.get_node(str(id)).call_deferred("queue_free")
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	multi_spawner.spawn(1)
	
	prints(name, "server is created !")
	
	gui_connect.call_deferred("queue_free")


func _on_connect_server_button_down():
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(le_ip.text, int(le_port.text)) != OK:
		var str_er_connect_serv = "cannot connect to the server !"
		
		push_error(name, str_er_connect_serv)
		popup_error.dialog_text = str_er_connect_serv
		popup_error.popup()
		return
		
	multiplayer.multiplayer_peer = peer
	
	var _on_server_disconnected = func():
		popup_error.dialog_text = "server is disconnected !"
	
		var _on_closed = func():
			get_tree().quit()
		
		popup_error.canceled.connect(_on_closed)
		popup_error.confirmed.connect(_on_closed)
		
		popup_error.popup()
	
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	prints(name, "connected to the server !")
	
	gui_connect.call_deferred("queue_free")
