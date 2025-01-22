extends Node3D


@onready var ms: MultiplayerSpawner = $MultiplayerSpawner
@onready var multhud: Control = $Multiplayerhud
@onready var lobbies: VBoxContainer = $Multiplayerhud/LobbyContainer/Lobbies
@onready var lobby_entry: LineEdit = $Multiplayerhud/lobby_id

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	open_lobby_list()



func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a
	

func _on_host_pressed() -> void:
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://scenes/main_level.tscn")
	multhud.hide()
	lobbies.hide()




func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	multhud.hide()
	lobbies.hide()

func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name", str(Steam.getPersonaName()+"'s lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)

func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	


func _on_lobby_match_list(lobby_list):
	
	for lobby in lobby_list:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		var memb_count = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		but.set_text(str(lobby_name,"| Player Count:", memb_count))
		but.set_size(Vector2(100,5))
		but.connect("pressed",Callable(self, "join_lobby").bind(lobby))
		
		lobbies.add_child(but)


func _on_refresh_pressed() -> void:
	if lobbies.get_child_count() > 0:
		for n in lobbies.get_children():
			n.queue_free()


func _on_join_pressed() -> void:
	join_lobby(int(lobby_entry.text))
