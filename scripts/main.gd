extends Node3D

@export var input_address: LineEdit
@export var menu: PanelContainer
@export var players: Node
@export var player_scene: PackedScene

const PORT: int = 7777
const MAX_PLAYERS: int = 64


func _on_host_pressed() -> void:
	host_game()
	menu.hide()

func _on_join_pressed() -> void:
	join_game(input_address.text)
	menu.hide()

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		_spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		_despawn_player(id)

func _spawn_player(id: int) -> void:
	var player: Node = player_scene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	players.add_child(player)

func _despawn_player(id: int) -> void:
	var p: Node = players.get_node_or_null(str(id))
	if p:
		p.queue_free()


func host_game() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	_spawn_player(multiplayer.get_unique_id())

func join_game(address: String) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer
