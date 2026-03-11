extends CharacterBody2D

signal health_depleted

var health = 100.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()

	const DAMAGE_RATE = 5.0
	var overlapping_mods = %HurtBox.get_overlapping_bodies()
	if overlapping_mods.size() > 0:
		health -= DAMAGE_RATE * overlapping_mods.size() * delta
		%ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()

@onready var background = %TextureRect

func _process(_delta):
	var shader_mat = background.material as ShaderMaterial
	# Divide by texture size to normalize the offset
	var tex_size = background.texture.get_size()
	shader_mat.set_shader_parameter("offset", global_position / tex_size)
