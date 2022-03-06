extends Node2D

export(NodePath) onready var connection_panel = get_node(connection_panel) as PanelContainer
export(NodePath) onready var host_field = get_node(host_field) as LineEdit
export(NodePath) onready var port_field = get_node(port_field) as LineEdit
export(NodePath) onready var message_label = get_node(message_label) as Label

func _ready() -> void:
	get_tree().connect('network_peer_connected', self, '_on_network_peer_connected')
	get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')


func _on_ServerButton_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(port_field.text), 1)
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = 'listening...'


func _on_ClientButton_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host_field.text, int(port_field.text))
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = 'connecting...'


func _on_network_peer_connected(id: int) -> void:
	message_label.text = 'connected!'


func _on_network_peer_disconnected(id: int) -> void:
	message_label.text = 'disconnected :('


func _on_server_disconnected() -> void:
	_on_network_peer_disconnected(1)
