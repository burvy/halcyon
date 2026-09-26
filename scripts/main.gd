extends Node3D

@export var input_address: LineEdit
@export var menu: PanelContainer
@export var players: Node
@export var player_scene: PackedScene

const PORT: int = 14641
const WS_PORT: int = 14642

const CERT_DIR: String = "C:/burvy/certs/webtrans.burvy.dev"
const DEFAULT_SERVER: String = "webtrans.burvy.dev"

const MAX_PLAYERS: int = 64


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_join_online_pressed() -> void:
	join_game_online(DEFAULT_SERVER)
	menu.hide()


func _on_join_online_custom_pressed() -> void:
	join_game_online(input_address.text)
	menu.hide()

func _on_join_offline_pressed() -> void:
	join_game_offline(input_address.text)
	menu.hide()

func _on_host_rendered_pressed() -> void:
	host_game_headed()
	menu.hide()

func _on_host_renderless_pressed() -> void:
	host_game_renderless()
	get_viewport().scaling_3d_scale = 0.05
	menu.hide()


func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		_spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		_despawn_player(id)

func _spawn_player(id: int) -> void:
	var player: Node = player_scene.instantiate()
	player.name = str(id)
	players.add_child(player)

func _despawn_player(id: int) -> void:
	var p: Node = players.get_node_or_null(str(id))
	if p:
		p.queue_free()


func host_game_headed() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	_spawn_player(multiplayer.get_unique_id())

## host the game but renderless for websocket and performance
func host_game_renderless() -> void:
	var key: CryptoKey = CryptoKey.new()
	key.load(CERT_DIR + "/webtrans.burvy.dev-key.pem")
	var cert: X509Certificate = X509Certificate.new()
	cert.load(CERT_DIR + "/webtrans.burvy.dev-chain.pem")
	var tls_options: TLSOptions = TLSOptions.server(key, cert)

	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_server(WS_PORT, "*", tls_options)
	multiplayer.multiplayer_peer = peer


func join_game_offline(address: String) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer

func join_game_online(address: String) -> void:
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_client("wss://%s:%d" % [address, WS_PORT])
	multiplayer.multiplayer_peer = peer
