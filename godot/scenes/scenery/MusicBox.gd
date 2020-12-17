extends OQClass_GrabbableRigidBody

func _on_MusicBox_tree_entered():
	if not $Piano.playing:
		$Piano.play()
