extends Spatial

var target_x = 0
var target_y = 0

onready var camera = $Camera
onready var rays = $Camera/Rays.get_children()
onready var check_rays = $Camera/BackCheckRays.get_children()
onready var front_rays = $Camera/FrontRays.get_children()

onready var y_ = rotation.y

export var rotation_speed = 500
export var joystick_rotation_speed = 10
export var default_z = 4
export var zoom_speed = 1.0
export (float, 0, 1) var rotation_lerp = 0.5
export var use_mouse_for_rotation = true
export var capture_mouse = true
export var debug_quit_on_escape = true
export (String) var rotation_up_action
export (String) var rotation_down_action
export (String) var rotation_left_action
export (String) var rotation_right_action
export var rotate_actions_are_axis = true

func _ready():
	if capture_mouse:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _get_property_list():
	var properties = []
	properties.append({
			name = "Rotate",
			type = TYPE_NIL,
			hint_string = "rotate_",
			usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	return properties

func _input(event):
	if debug_quit_on_escape and event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if use_mouse_for_rotation and event is InputEventMouseMotion:
		target_x += event.relative.y / rotation_speed
		_clamp()
		target_y += event.relative.x / rotation_speed

func _clamp():
	var x = rad2deg(target_x)
	x = clamp(x, -90, 90)
	target_x = deg2rad(x)

func _physics_process(delta):

	# Now all the inputs
	if rotate_actions_are_axis:
		target_y += (Input.get_action_strength(rotation_right_action) - Input.get_action_strength(rotation_left_action)) / joystick_rotation_speed
		target_x += (Input.get_action_strength(rotation_down_action) - Input.get_action_strength(rotation_up_action)) / joystick_rotation_speed
		_clamp()

	rotation.x = lerp(rotation.x, target_x, rotation_lerp)
	rotation.y = lerp(rotation.y, target_y, rotation_lerp)

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

