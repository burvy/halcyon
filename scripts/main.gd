extends Node3D

@export var input_address: LineEdit
@export var menu: PanelContainer

const PORT: int = 7777
const MAX_PLAYERS: int = 64


func _on_host_pressed() -> void:
	host_game()
	menu.hide()

func _on_join_pressed() -> void:
	join_game(input_address.text)
	menu.hide()


func host_game() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer

func join_game(address: String) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer
