extends Area2D

var tile_size = 16
var inputs = {"Right": Vector2.RIGHT,
"Left": Vector2.LEFT,
"Down": Vector2.DOWN,
"Up": Vector2.UP,
"UpLeft": Vector2(-1, -1),
"UpRight": Vector2(1, -1),
"DownLeft": Vector2(-1, 1),
"DownRight": Vector2(1, 1)}
@onready var ray = $RayCast2D
var animation_speed = 3
var moving = false
var last_direction
var health = 10
signal attacking(damage)
signal finished()
var is_players_turn

func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$AnimationPlayer.play("idle")
	set_health_label()

func set_health_label():
	$HealthBar.value = health

func _unhandled_input(event):
	if moving:
		return
		
	if (event.is_action_pressed("Up") && Input.is_key_pressed(KEY_LEFT)) || (event.is_action_pressed("Left") && Input.is_key_pressed(KEY_UP)):
		move("UpLeft") 
	elif (event.is_action_pressed("Up") && Input.is_key_pressed(KEY_RIGHT)) || (event.is_action_pressed("Right") && Input.is_key_pressed(KEY_UP)):
		move("UpRight")
	elif (event.is_action_pressed("Down") && Input.is_key_pressed(KEY_LEFT)) || (event.is_action_pressed("Left") && Input.is_key_pressed(KEY_DOWN)):
		move("DownLeft")
	elif (event.is_action_pressed("Down") && Input.is_key_pressed(KEY_RIGHT)) || (event.is_action_pressed("Right") && Input.is_key_pressed(KEY_DOWN)):
		move("DownRight")
	elif event.is_action_pressed("Up"):
		move("Up")
	elif event.is_action_pressed("Down"):
		move("Down")
	elif event.is_action_pressed("Left"):
		move("Left")
	elif event.is_action_pressed("Right"):
		move("Right")
	
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
				attack(collider)
			end_turn()

func attack(enemy):
	attacking.emit(enemy, 1)
	if $Sprite2D.flip_h:
		$AnimationPlayer.play("attack (flipped)")
	else:
		$AnimationPlayer.play("attack")
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("idle")
	$Sprite2D.position = Vector2(0, -4)

func end_turn():
	moving = false
	is_players_turn = false
	finished.emit()

func invert_direction(dir):
	if dir == "Up":
		return "Down"
	elif dir == "Down":
		return "Up"
	elif dir == "Right":
		return "Left"
	elif dir == "Left":
		return "Right"
	elif dir == "Up/Left":
		return "Down/Right"
	elif dir == "Down/Right":
		return "Up/Left"
	elif dir == "Down/Left":
		return "Up/Right"
	elif dir == "Up/Right":
		return "Down/Left"

func _on_node_2d_players_turn():
	is_players_turn = true
