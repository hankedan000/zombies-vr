extends Node

var players = []
var nav : Navigation = null

func paused():
	return get_tree().paused

func add_player(node):
	players.append(node)
