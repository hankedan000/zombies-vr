extends Area

signal hit(damage)

# colliders should call this function to cause damage
func hit(damage):
	emit_signal("hit",damage)
