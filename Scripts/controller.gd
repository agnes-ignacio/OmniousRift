extends Node2D

signal players_turn
signal enemies_turn
var is_enemies_turn: bool

func _ready():
	battle()
	finish_battle()

func is_player_alive():
	if $Player.health > 0:
		return true
	return false

func has_enemies():
	return !get_children().filter(is_enemy).is_empty()
	
func is_enemy(node):
	return node.name.contains("Enemy")

func battle():
	while is_player_alive() && has_enemies():
		players_turn.emit()
		await $Player.finished
		enemies_turn.emit()

func finish_battle():
	if !is_player_alive():
		game_over()
	if !has_enemies():
		players_turn.emit()

func game_over():
	pass


func _on_player_attacking(enemy, damage):
	enemy.health -= damage
	enemy.set_health_bar()
	if enemy.health <= 0:
		enemy.queue_free()


func _on_enemy_attacking(damage):
	$Player.health -= damage
	$Player.set_health_label()
