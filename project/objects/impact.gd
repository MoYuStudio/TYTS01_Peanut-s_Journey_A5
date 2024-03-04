
extends GPUParticles3D

# 动画完成后移除此冲击效果

func _on_finished():
	queue_free()
