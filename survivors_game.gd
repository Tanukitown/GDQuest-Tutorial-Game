extends Node2D


@export var tree_scene: PackedScene = preload("res://pine_tree.tscn")
@export var spawn_radius: float
@export var despawn_radius: float
@export var max_trees: int = 30
@export var min_distance_between_trees: float = 80.0


func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	spawn_radius = viewport_size.length() * 0.8  # just outside screen diagonal
	despawn_radius = spawn_radius + 300.0
	spawn_mob()
	spawn_mob()
	spawn_mob()
	spawn_mob()


var spawned_trees: Array = []
var last_spawn_position: Vector2 = Vector2.ZERO

func _process(_delta):
	var player_pos = $Player.global_position

	if player_pos.distance_to(last_spawn_position) > 150.0:
		last_spawn_position = player_pos
		despawn_far_trees(player_pos)
		spawn_trees_around(player_pos)

func spawn_trees_around(pos: Vector2):
	if spawned_trees.size() >= max_trees:
		return

	var attempts = 10
	for i in attempts:
		var angle = randf() * TAU
		var distance = randf_range(spawn_radius * 0.5, spawn_radius)
		var spawn_pos = pos + Vector2(cos(angle), sin(angle)) * distance

		if is_position_clear(spawn_pos):
			var tree = tree_scene.instantiate()
			tree.global_position = spawn_pos
			add_child(tree)
			spawned_trees.append(tree)

func despawn_far_trees(pos: Vector2):
	for tree in spawned_trees.duplicate():
		if tree.global_position.distance_to(pos) > despawn_radius:
			spawned_trees.erase(tree)
			tree.queue_free()

func is_position_clear(pos: Vector2) -> bool:
	for tree in spawned_trees:
		if tree.global_position.distance_to(pos) < min_distance_between_trees:
			return false
	return true


func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)


func _on_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true
