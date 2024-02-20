extends RigidBody2D

var tile_size = 16
var rng = RandomNumberGenerator.new()
var directions = ["Left", "Up", "Right", "Down"]
var inputs = {"Right": Vector2.RIGHT,
"Left": Vector2.LEFT,
"Down": Vector2.DOWN,
"Up": Vector2.UP}
@onready var ray = $RayCast2D
var animation_speed = 6
var player_is_visible
var players_position
signal attacking(damage)
var health = 5

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$AnimationPlayer.play("idle")
	set_health_bar()

func move(dir: String = ""):
	if dir == "":
		dir = directions[rng.randi_range(0, 3)]

	if dir == "Left":
		$Sprite2D.flip_h = true
	if dir == "Right":
		$Sprite2D.flip_h = false

	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding() || ray.get_collider().name.begins_with("Enemy"):
		position = position + inputs[dir] * tile_size

func pursuit():
	players_position = get_node("../Player").position
	if position.y - players_position.y > tile_size && position.y - players_position.y >= position.x - players_position.x:
		ray.target_position = inputs["Up"] * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			move("Up")
	elif position.y - players_position.y < -tile_size && position.y - players_position.y <= position.x - players_position.x:
		ray.target_position = inputs["Down"] * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			move("Down")
	elif position.x - players_position.x > tile_size:
		ray.target_position = inputs["Left"] * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			move("Left")
	elif position.x - players_position.x < -tile_size:
		ray.target_position = inputs["Right"] * tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			move("Right")
	elif (position.x - players_position.x <= tile_size) || position.y - players_position.y < -tile_size:
		attack()

func set_health_bar():
	$HealthBar.value = health

func attack():
	attacking.emit(1)
	if $Sprite2D.flip_h:
		$AnimationPlayer.play("attack (flipped)")
	else:
		$AnimationPlayer.play("attack")
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("idle")

func _on_node_2d_enemies_turn():
	if player_is_visible:
		pursuit()
	else:
		move()


func _on_range_area_entered(area):
	if area.name == "Player":
		player_is_visible = true

func _on_range_area_exited(area):
	if area.name == "Player":
		player_is_visible = false
