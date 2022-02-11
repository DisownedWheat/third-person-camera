extends Spatial

var target_x = 0
var target_y = 0

onready var camera = $Camera
onready var rays = $Camera/Rays.get_children()
onready var check_rays = $Camera/BackCheckRays.get_children()
onready var front_rays = $Camera/FrontRays.get_children()
onready var default_z = camera.transform.origin.z

onready var y_ = rotation.y

export var rotation_speed = 500
export var zoom_speed = 1.0

func _ready():
	print(default_z)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if not (event is InputEventMouseMotion):
		return
	target_x += event.relative.y / rotation_speed
	_clamp()
	target_y += event.relative.x / rotation_speed

func _clamp():
	var x = rad2deg(target_x)
	x = clamp(x, -90, 90)
	target_x = deg2rad(x)

func _physics_process(delta):
	rotation.x = lerp(rotation.x, target_x, 0.5)
	rotation.y = lerp(rotation.y, target_y, 0.5)

	y_ = rotation.y

	var back_collision = false
	for ray in rays:
		if ray.get_collider():
			back_collision = true

	if back_collision:
		camera.transform.origin.z = lerp(camera.transform.origin.z, 1.3, 0.1)
	else:
		var back_check = false
		for ray in check_rays:
			if ray.get_collider():
				back_check = true

		if not back_check:
			camera.transform.origin.z = lerp(camera.transform.origin.z, default_z, 0.1)

