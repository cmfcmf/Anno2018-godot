extends Node

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_infos = {}
# Info we send to other players
var my_info = {}

# Called whenever someone connects to the multiplayer session.
func _player_connected(id):
	pass

# Called whenever someone leaves the multiplayer session.
func _player_disconnected(id):
	player_infos.erase(id)
	update_lobby_player_list()

# Called when I, a client, have connected to the server.
func _connected_ok():
	# Send my ID and info to all the other peers
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func _server_disconnected():
	pass # Server kicked us, show error and abort

func _connected_fail():
	pass # Could not even connect to server, abort

remote func register_player(id, info):
	player_infos[id] = info
	# If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
		# Send the info of existing players
		for peer_id in player_infos:
			rpc_id(id, "register_player", peer_id, player_infos[peer_id])

	# Call function to update lobby UI here
	update_lobby_player_list()
	
func update_lobby_player_list():
	$"../players".text = ""
	for peer_id in player_infos.keys():
		var player_info = player_infos[peer_id]
		$"../players".text += player_info['name'] + "\n"