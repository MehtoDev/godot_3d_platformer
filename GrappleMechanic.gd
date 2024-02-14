extends Node

func grapple_point(target : Node, pos : Vector3) -> RigidBody3D:
	var rigid_body := RigidBody3D.new()
	var shape := CollisionShape3D.new()
	var joint := PinJoint3D.new()
	
	get_tree().get_root().add_child(rigid_body)
	
	rigid_body.global_position = pos
	rigid_body.freeze = true
	rigid_body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

	joint.node_a = rigid_body.get_path()
	joint.node_b = target.get_path()
	
	rigid_body.add_child(shape)
	rigid_body.add_child(joint)
	
	return rigid_body

func grapple_root(target : Node, pos : Vector3, velocity : Vector3) -> RigidBody3D:
	var rigid_body := RigidBody3D.new()
	var shape := CollisionShape3D.new()
	var remote := RemoteTransform3D.new()
	
	get_tree().get_root().add_child(rigid_body)
	
	rigid_body.global_position = pos
	rigid_body.linear_velocity = velocity
	remote.remote_path = target.get_path()
	remote.update_position = true
	remote.update_rotation = false
	remote.update_scale = false
	
	rigid_body.add_child(shape)
	rigid_body.add_child(remote)
	
	return rigid_body
