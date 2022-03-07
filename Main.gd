extends Node2D

export(NodePath) onready var connection_panel = get_node(connection_panel) as PanelContainer
export(NodePath) onready var host_field = get_node(host_field) as LineEdit
export(NodePath) onready var port_field = get_node(port_field) as LineEdit
export(NodePath) onready var message_label = get_node(message_label) as Label
export(NodePath) onready var sync_lost_label = get_node(sync_lost_label) as Label

func _ready() -> void:
	SyncDebugger.show_debug_overlay(true)
	get_tree().connect('network_peer_connected', self, '_on_network_peer_connected')
	get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	SyncManager.connect('sync_started', self, '_on_SyncManager_sync_started')
	SyncManager.connect('sync_stopped', self, '_on_SyncManager_sync_stopped')
	SyncManager.connect('sync_lost', self, '_on_SyncManager_sync_lost')
	SyncManager.connect('sync_regained', self, '_on_SyncManager_sync_regained')
	SyncManager.connect('sync_error', self, '_on_SyncManager_sync_error')


func _on_ServerButton_pressed() -> void:
	var peer: = NetworkedMultiplayerENet.new()
	peer.create_server(int(port_field.text), 1)
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = 'listening...'


func _on_ClientButton_pressed() -> void:
	var peer: = NetworkedMultiplayerENet.new()
	peer.create_client(host_field.text, int(port_field.text))
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = 'connecting...'


func _on_network_peer_connected(id: int) -> void:
	message_label.text = 'connected!'
	SyncManager.add_peer(id)

	$ServerPlayer.set_network_master(1)
	if get_tree().is_network_server():
		$ClientPlayer.set_network_master(id)
	else:
		$ClientPlayer.set_network_master(get_tree().get_network_unique_id())

	if get_tree().is_network_server():
		message_label.text = 'starting...'
		# give SyncManager some time to gather ping data...
		yield(get_tree().create_timer(2.0), 'timeout')
		SyncManager.start()


func _on_network_peer_disconnected(id: int) -> void:
	message_label.text = 'disconnected :('
	SyncManager.remove_peer(id)


func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)


func _on_ResetButton_pressed() -> void:
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer: = get_tree().network_peer as NetworkedMultiplayerENet
	if peer:
		peer.close_connection()
	get_tree().reload_current_scene()


func _on_SyncManager_sync_started() -> void:
	message_label.text = 'started!'


func _on_SyncManager_sync_stopped() -> void:
	pass


func _on_SyncManager_sync_lost() -> void:
	sync_lost_label.visible = true


func _on_SyncManager_sync_regained() -> void:
	sync_lost_label.visible = false


func _on_SyncManager_sync_error(msg: String) -> void:
	message_label.text = 'fatal sync error: ' + msg
	sync_lost_label.visible = false

	# todo should this share code with _on_ResetButton_pressed?
	var peer: = get_tree().network_peer as NetworkedMultiplayerENet
	if peer:
		peer.close_connection()
	SyncManager.clear_peers()
