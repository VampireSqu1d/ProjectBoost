extends RigidBody3D

## How much vertical force to apply when moving
@export_range(750.0, 3000.0) var thrust: float = 1000.0
## How fast to rotate the player
@export_range(75.0, 1000.0) var torque_thrust: float = 100.0

@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound
@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var boost_sound: AudioStreamPlayer3D = $BoostSound
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_right: GPUParticles3D = $BoosterParticlesRight
@onready var booster_particles_left: GPUParticles3D = $BoosterParticlesLeft
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


var is_transionting: bool = false

func _ready() -> void:
	#print("player loaded")
	pass


func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if !boost_sound.playing:
			boost_sound.play()
	else:
		boost_sound.stop()
		booster_particles.emitting = false
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		booster_particles_right.emitting = true
	else:
		booster_particles_right.emitting = false
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
		booster_particles_left.emitting = true
	else:
		booster_particles_left.emitting = false
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _on_body_entered(body: Node) -> void:
	if !is_transionting:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		if "Hazard" in body.get_groups():
			crashed_sequence()


func complete_level(next_level_file: String) -> void:
	success_particles.emitting = true
	success_sound.play()
	set_process(false)
	is_transionting = true
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
	)


func crashed_sequence() -> void:
	explosion_particles.emitting = true
	explosion_sound.play()
	set_process(false)
	booster_particles.emitting = false
	boost_sound.stop()
	is_transionting = true
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
