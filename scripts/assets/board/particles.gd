extends Node
class_name BoardParticleHandling

var blockExplosionScene: PackedScene = preload("res://assets/block/block_explosion.tscn")

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass

func add_explosion(pos: Vector2, color: Color) -> void:
	var blockExplosion: BlockExplosion = blockExplosionScene.instantiate()
	var particleObj: GPUParticles3D = blockExplosion.get_node("ExplosionParticles")
	particleObj.finished.connect(on_explosion_expired.bind(blockExplosion))
	
	blockExplosion.position = Vector3(pos.x, -pos.y+1, 0)
	particleObj.emitting = true
	particleObj.process_material = particleObj.process_material.duplicate()
	particleObj.process_material.color = color
	#particleObj.process_material.emission = color
	#particleObj.material_override.albedo_color = color
	#particleObj.material_override.emission = color
	%Particles.add_child(blockExplosion)
	
	
func on_explosion_expired(blockExplosion: BlockExplosion) -> void:
	%Particles.remove_child(blockExplosion)
	blockExplosion.queue_free()
