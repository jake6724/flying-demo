class_name Trail
extends MeshInstance3D

var prev: Vector3 = Vector3.ZERO

var queue: Array = []

# func _ready():
# 	# Begin draw.
# 	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

# 	# Prepare attributes for add_vertex.
# 	mesh.surface_set_normal(Vector3(0, 0, 1))
# 	mesh.surface_set_uv(Vector2(0, 0))
# 	# Call last for each vertex, adds the above attributes.
# 	mesh.surface_add_vertex(Vector3(-1, -1, 0))

# 	mesh.surface_set_normal(Vector3(0, 0, 1))
# 	mesh.surface_set_uv(Vector2(0, 1))
# 	mesh.surface_add_vertex(Vector3(-1, 1, 0))

# 	mesh.surface_set_normal(Vector3(0, 0, 1))
# 	mesh.surface_set_uv(Vector2(1, 1))
# 	mesh.surface_add_vertex(Vector3(1, 1, 0))

	# # End drawing.
	# mesh.surface_end()

func _process(delta):
	mesh.clear_surfaces()
	var material := ORMMaterial3D.new()


	queue.append((transform.origin))
	if queue.size() > 10:
		queue.pop_front()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, material)
	if queue.size() % 2 == 0:
		for point: Vector3 in queue:
			mesh.surface_add_vertex(point)
			mesh.surface_add_vertex(point + (Vector3(-10, 0, 0)))
			mesh.surface_add_vertex(point + (Vector3(10, 0, 0)))
		mesh.surface_end()

	print(queue)

	# if prev != Vector3.ZERO:
	# 	# Begin draw.
	# 	mesh.surface_begin(Mesh.PRIMITIVE_POINTS)
	# 	# mesh.surface_add_vertex(prev)
	# 	# Add point
	# 	mesh.surface_add_vertex(global_position)
	# 	# End
	# 	mesh.surface_end()

	# prev = global_position