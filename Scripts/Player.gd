extends Area2D

var tile_size = 16
var inputs = {"Right": Vector2.RIGHT,
"Left": Vector2.LEFT,
"Down": Vector2.DOWN,
"Up": Vector2.UP}
@onready var ray = $RayCast2D
var animation_speed = 3
var moving = false
signal enemys_turn()
var is_players_turn 
var last_direction
var health = 10
signal enemy_is_damaged(damage)


func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$AnimationPlayer.play("idle")
	set_health_label()
	is_players_turn = true

func set_health_label():
	$HealthBar.value = health

func _unhandled_input(event):
	if moving:
		return
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func _physics_process(delta):
	if has_overlapping_bodies():
		var dir = invert_direction(last_direction)
		position = position + inputs[dir] * tile_size

func move(dir):
	if is_players_turn:
		if dir == "Left":
			$Sprite2D.flip_h = true
		if dir == "Right":
			$Sprite2D.flip_h = false
		ray.target_position = inputs[dir] * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding() || ray.get_collider().name == "Range":
			position = position + inputs[dir] * tile_size
			last_direction = dir
			end_turn()
		else:
			var collider = ray.get_collider()
			if collider.name.contains("Enemy"):
				attack()
		enemys_turn.emit()

func attack():
	enemy_is_damaged.emit(1)
	if $Sprite2D.flip_h:
		$AnimationPlayer.play("attack (flipped)")
	else:
		$AnimationPlayer.play("attack")
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("idle")
	$Sprite2D.position = Vector2(0, -4)

func end_turn():
	moving = false
	if get_tree().get_nodes_in_group("enemies"):
		print("entrou")
		is_players_turn = false

func invert_direction(dir):
	if dir == "Up":
		return "Down"
	elif dir == "Down":
		return "Up"
	elif dir == "Right":
		return "Left"
	elif dir == "Left":
		return "Right"

func _on_enemy_players_turn():
	is_players_turn = true


func _on_enemy_player_is_damaged(damage):
	health -= damage
	set_health_label()
