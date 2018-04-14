extends Node

const MAX_PLAYERS = 4
const SERVER_PORT = 4242

func start_server():
	var peer = NetworkedMultiplayerENet.new()
	assert(peer.create_server(SERVER_PORT, MAX_PLAYERS) == OK)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	
	# Register ourselves.
	$lobby.register_player(get_tree().get_network_unique_id(), $lobby.my_info)
	
func connect_to_server(ip):
	var peer = NetworkedMultiplayerENet.new()
	assert(peer.create_client(ip, SERVER_PORT) == OK)
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)


func check_name():
	if len($player_name.text) == 0:
		$warning_dialog.dialog_text = 'You need to type in a player name'
		$warning_dialog.popup_centered()
		return false
	return true

func _on_start_server_btn_pressed():
	if not check_name():
		return
		
	start_server()
	$start_server_btn/ip_address.text = str(IP.get_local_addresses())
	disable_buttons()
	$start_game_btn.disabled = false

func _on_connect_to_server_btn_pressed():
	if not check_name():
		return
		
	connect_to_server($connect_to_server_btn/ip_address.text)
	disable_buttons()
	
func disable_buttons():
	$start_server_btn.disabled = true
	$connect_to_server_btn.disabled = true
	$connect_to_server_btn/ip_address.editable = false

func _on_player_name_text_changed(player_name):
	$lobby.my_info = {'name': player_name}

func _on_start_game_btn_pressed():
	rpc("start_game")

sync func start_game():
	get_tree().change_scene("res://game/game.tscn")
