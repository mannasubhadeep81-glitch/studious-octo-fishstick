extends Node3D

const LANES := [-2.2, 0.0, 2.2]
const START_SPEED := 12.0
const MAX_SPEED := 27.0
const SEGMENT_LENGTH := 8.0
const WORLD_AHEAD := 112.0

var player: Node3D
var follower: Node3D
var runner_time := 0.0
var camera: Camera3D
var hud: CanvasLayer
var score_label: Label
var coin_label: Label
var message_label: Label
var restart_button: Button
var lane_index := 1
var speed := START_SPEED
var distance := 0.0
var coins := 0
var game_over := false
var jump_timer := 0.0
var slide_timer := 0.0
var swipe_start := Vector2.ZERO
var ground_segments: Array[Node3D] = []
var obstacles: Array[Node3D] = []
var coin_nodes: Array[Node3D] = []
var rng := RandomNumberGenerator.new()
var spawn_z := -18.0
var materials: Dictionary = {}

func _ready() -> void:
	# Mobile frame pacing: cap at 60 FPS and keep physics cadence consistent.
	Engine.max_fps = 60
	Engine.physics_ticks_per_second = 60
	rng.randomize()
	_make_materials()
	_build_player()
	_build_follower()
	_build_camera()
	_build_lighting()
	_build_hud()
	for i in range(16):
		_add_ground_segment(-float(i) * SEGMENT_LENGTH)
	for i in range(14):
		_spawn_row(-18.0 - float(i) * 7.0)
	_update_hud()

func _make_materials() -> void:
	materials["ground"] = _mat(Color(0.16, 0.23, 0.13))
	materials["ground2"] = _mat(Color(0.21, 0.29, 0.16))
	materials["path"] = _mat(Color(0.43, 0.32, 0.19))
	materials["player"] = _mat(Color(0.96, 0.42, 0.12))
	materials["skin"] = _mat(Color(0.93, 0.69, 0.48))
	materials["leaf"] = _mat(Color(0.08, 0.31, 0.13))
	materials["leaf2"] = _mat(Color(0.13, 0.43, 0.17))
	materials["wood"] = _mat(Color(0.38, 0.19, 0.08))
	materials["gold"] = _mat(Color(1.0, 0.72, 0.05), 0.25)
	materials["rock"] = _mat(Color(0.38, 0.40, 0.34))
	materials["white"] = _mat(Color(0.95, 0.95, 0.84))

func _mat(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = 0.92
	return m

func _box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.material_override = mat
	parent.add_child(node)
	return node

func _sphere(parent: Node3D, radius: float, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.material_override = mat
	parent.add_child(node)
	return node

func _build_player() -> void:
	# 3D stylized interpretation of the user's male reference: dark patterned shirt, tan cargo trousers, dark wavy hair and light sneakers.
	player = Node3D.new()
	player.name = "BoyRunner3D"
	add_child(player)
	var shirt := _mat(Color(0.12, 0.12, 0.14))
	var pants := _mat(Color(0.64, 0.53, 0.36))
	var skin := _mat(Color(0.55, 0.34, 0.23))
	var hair := _mat(Color(0.035, 0.025, 0.02))
	var shoe := _mat(Color(0.83, 0.82, 0.76))
	var pattern := _mat(Color(0.46, 0.43, 0.37))
	_box(player, Vector3(0.58, 0.68, 0.31), Vector3(0, 1.20, 0), shirt)
	# Small light pattern accents on the shirt to echo the reference fabric.
	for y in [1.40, 1.22, 1.04]:
		for x in [-0.19, 0.0, 0.19]:
			_sphere(player, 0.035, Vector3(x, y, 0.166), pattern)
	_sphere(player, 0.235, Vector3(0, 1.79, 0), skin)
	_sphere(player, 0.245, Vector3(0, 1.91, -0.015), hair)
	_sphere(player, 0.10, Vector3(-0.15, 1.98, 0.06), hair)
	_sphere(player, 0.10, Vector3(0.13, 1.98, 0.06), hair)
	for side in [-1, 1]:
		_box(player, Vector3(0.25, 0.49, 0.28), Vector3(0.17 * side, 0.57, 0), pants)
		_box(player, Vector3(0.27, 0.13, 0.29), Vector3(0.17 * side, 0.47, 0), pants)
		_box(player, Vector3(0.16, 0.54, 0.17), Vector3(0.37 * side, 1.17, 0), shirt)
		_sphere(player, 0.09, Vector3(0.37 * side, 0.86, 0), skin)
		_box(player, Vector3(0.24, 0.12, 0.36), Vector3(0.17 * side, 0.10, -0.04), shoe)
	player.position = Vector3(0, 0, 0)

func _build_follower() -> void:
	# 3D stylized interpretation of the female black/red/gold warrior reference.
	follower = Node3D.new()
	follower.name = "GirlFollower3D"
	add_child(follower)
	var robe := _mat(Color(0.075, 0.045, 0.055))
	var red := _mat(Color(0.62, 0.025, 0.07))
	var gold := _mat(Color(0.88, 0.60, 0.16), 0.35)
	var skin := _mat(Color(0.79, 0.62, 0.52))
	var hair := _mat(Color(0.035, 0.022, 0.026))
	var boot := _mat(Color(0.12, 0.08, 0.08))
	_box(follower, Vector3(0.53, 0.66, 0.29), Vector3(0, 1.18, 0), robe)
	_box(follower, Vector3(0.16, 0.58, 0.035), Vector3(0, 1.18, 0.16), red)
	_box(follower, Vector3(0.57, 0.08, 0.33), Vector3(0, 0.89, 0), gold)
	_sphere(follower, 0.22, Vector3(0, 1.75, 0), skin)
	_sphere(follower, 0.25, Vector3(0, 1.90, -0.02), hair)
	_sphere(follower, 0.13, Vector3(0, 1.67, 0.12), hair)
	# Long hair locks and red/gold hair ornaments.
	_box(follower, Vector3(0.12, 0.53, 0.13), Vector3(-0.23, 1.55, -0.02), hair)
	_box(follower, Vector3(0.12, 0.53, 0.13), Vector3(0.23, 1.55, -0.02), hair)
	_sphere(follower, 0.055, Vector3(0.13, 2.08, 0.02), gold)
	_box(follower, Vector3(0.045, 0.30, 0.04), Vector3(0.19, 1.91, 0.04), red)
	for side in [-1, 1]:
		_box(follower, Vector3(0.22, 0.43, 0.24), Vector3(0.15 * side, 0.58, 0), robe)
		_box(follower, Vector3(0.14, 0.52, 0.15), Vector3(0.34 * side, 1.17, 0), robe)
		_box(follower, Vector3(0.16, 0.11, 0.18), Vector3(0.34 * side, 1.02, 0.02), red)
		_sphere(follower, 0.08, Vector3(0.34 * side, 0.89, 0), skin)
		_box(follower, Vector3(0.24, 0.12, 0.34), Vector3(0.15 * side, 0.10, -0.04), boot)
	# Gold trim at shoulders and belt gives the silhouette a warrior-costume read.
	_box(follower, Vector3(0.60, 0.045, 0.31), Vector3(0, 1.48, 0), gold)
	follower.position = Vector3(0.8, 0, 4.2)
func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 5.5, 9.5)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera.current = true
	add_child(camera)

func _build_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -25, 0)
	sun.light_energy = 0.9
	sun.shadow_enabled = false
	add_child(sun)
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.12, 0.25, 0.18)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.65, 0.53)
	environment.ambient_light_energy = 0.55
	env.environment = environment
	add_child(env)

func _add_ground_segment(z: float) -> void:
	var segment := Node3D.new()
	segment.position.z = z
	add_child(segment)
	_box(segment, Vector3(9.0, 0.35, SEGMENT_LENGTH), Vector3(0, -0.22, -SEGMENT_LENGTH / 2.0), materials["ground"] if int(abs(z / SEGMENT_LENGTH)) % 2 == 0 else materials["ground2"])
	_box(segment, Vector3(6.8, 0.08, SEGMENT_LENGTH), Vector3(0, 0.0, -SEGMENT_LENGTH / 2.0), materials["path"])
	for lane_x in [-1.1, 1.1]:
		_box(segment, Vector3(0.06, 0.025, SEGMENT_LENGTH), Vector3(lane_x, 0.06, -SEGMENT_LENGTH / 2.0), materials["white"])
	for side in [-1, 1]:
		if rng.randf() < 0.65:
			var tree_x := float(side) * rng.randf_range(5.0, 8.0)
			_box(segment, Vector3(0.45, 2.8, 0.45), Vector3(tree_x, 1.25, -rng.randf_range(1.0, 7.0)), materials["wood"])
			_sphere(segment, rng.randf_range(1.1, 1.7), Vector3(tree_x, 3.3, -rng.randf_range(1.0, 7.0)), materials["leaf"] if side == -1 else materials["leaf2"])
	ground_segments.append(segment)

func _spawn_row(z: float) -> void:
	var lane := rng.randi_range(0, 2)
	var kind := rng.randi_range(0, 3)
	if kind == 0:
		for l in range(3):
			if l != lane:
				_spawn_coin(LANES[l], z)
		return
	if kind == 1:
		_spawn_coin(LANES[lane], z)
		return
	var obstacle := Node3D.new()
	obstacle.position = Vector3(LANES[lane], 0, z)
	add_child(obstacle)
	if kind == 2:
		_box(obstacle, Vector3(1.25, 0.9, 0.65), Vector3(0, 0.48, 0), materials["rock"])
		_sphere(obstacle, 0.3, Vector3(-0.25, 0.8, 0), materials["rock"])
	else:
		_box(obstacle, Vector3(1.45, 0.85, 0.5), Vector3(0, 0.9, 0), materials["wood"])
		_box(obstacle, Vector3(1.55, 0.12, 0.58), Vector3(0, 1.34, 0), materials["gold"])
	obstacles.append(obstacle)

func _spawn_coin(x: float, z: float) -> void:
	var coin := Node3D.new()
	coin.position = Vector3(x, 1.1, z)
	add_child(coin)
	var ring := TorusMesh.new()
	ring.rings = 6
	ring.ring_segments = 8
	ring.inner_radius = 0.22
	ring.outer_radius = 0.34
	var visual := MeshInstance3D.new()
	visual.mesh = ring
	visual.material_override = materials["gold"]
	coin.add_child(visual)
	coin_nodes.append(coin)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var panel := ColorRect.new()
	panel.color = Color(0.015, 0.035, 0.025, 0.68)
	panel.position = Vector2(16, 18)
	panel.size = Vector2(330, 112)
	hud.add_child(panel)
	score_label = Label.new()
	score_label.position = Vector2(32, 25)
	score_label.add_theme_font_size_override("font_size", 30)
	score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.46))
	hud.add_child(score_label)
	coin_label = Label.new()
	coin_label.position = Vector2(32, 67)
	coin_label.add_theme_font_size_override("font_size", 23)
	coin_label.add_theme_color_override("font_color", Color.WHITE)
	hud.add_child(coin_label)
	message_label = Label.new()
	message_label.anchor_left = 0.1
	message_label.anchor_right = 0.9
	message_label.anchor_top = 0.38
	message_label.anchor_bottom = 0.58
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 38)
	message_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.34))
	message_label.text = "JUNGLE RUSH 3D"
	hud.add_child(message_label)
	restart_button = Button.new()
	restart_button.text = "RUN AGAIN"
	restart_button.anchor_left = 0.3
	restart_button.anchor_right = 0.7
	restart_button.anchor_top = 0.62
	restart_button.anchor_bottom = 0.7
	restart_button.visible = false
	restart_button.pressed.connect(_restart)
	hud.add_child(restart_button)
	var controls := Label.new()
	controls.text = "SWIPE  ←  →  •  UP: JUMP  •  DOWN: SLIDE"
	controls.anchor_left = 0.05
	controls.anchor_right = 0.95
	controls.anchor_top = 0.92
	controls.anchor_bottom = 0.98
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 17)
	controls.add_theme_color_override("font_color", Color.WHITE)
	hud.add_child(controls)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
		else:
			_handle_swipe(event.position - swipe_start)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			swipe_start = event.position
		else:
			_handle_swipe(event.position - swipe_start)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT, KEY_A: _move_lane(-1)
			KEY_RIGHT, KEY_D: _move_lane(1)
			KEY_UP, KEY_SPACE: _jump()
			KEY_DOWN, KEY_S: _slide()

func _handle_swipe(delta: Vector2) -> void:
	if game_over:
		return
	if delta.length() < 30.0:
		return
	if abs(delta.x) > abs(delta.y):
		_move_lane(1 if delta.x > 0 else -1)
	elif delta.y < 0:
		_jump()
	else:
		_slide()

func _move_lane(direction: int) -> void:
	if not game_over:
		lane_index = clampi(lane_index + direction, 0, 2)

func _jump() -> void:
	if not game_over and jump_timer <= 0.0 and slide_timer <= 0.0:
		jump_timer = 0.62

func _slide() -> void:
	if not game_over and slide_timer <= 0.0 and jump_timer <= 0.0:
		slide_timer = 0.65

func _process(delta: float) -> void:
	if game_over:
		return
	distance += speed * delta
	runner_time += delta * speed
	speed = minf(MAX_SPEED, START_SPEED + distance * 0.006)
	player.position.x = lerpf(player.position.x, LANES[lane_index], minf(1.0, delta * 12.0))
	player.position.z -= speed * delta
	# Keep the follower behind the player and animate a simple running bounce.
	follower.position.x = lerpf(follower.position.x, player.position.x + 0.8, minf(1.0, delta * 4.0))
	follower.position.z = player.position.z + 4.2
	follower.position.y = absf(sin(runner_time * 0.85)) * 0.12
	follower.rotation.z = sin(runner_time * 0.65) * 0.035
	if jump_timer > 0.0:
		jump_timer -= delta
		player.position.y = sin((0.62 - jump_timer) / 0.62 * PI) * 1.65
	else:
		player.position.y = 0.0
	if slide_timer > 0.0:
		slide_timer -= delta
		player.scale.y = 0.55
	else:
		player.scale.y = 1.0
	camera.position.x = lerpf(camera.position.x, player.position.x * 0.35, minf(1.0, delta * 2.5))
	camera.position.z = player.position.z + 9.5
	camera.position.y = 5.5 + player.position.y * 0.35
	camera.look_at(player.position + Vector3(0, 1.1, -7.0), Vector3.UP)
	_update_world()
	_check_collisions()
	_update_hud()

func _update_world() -> void:
	while ground_segments.size() > 0 and ground_segments[0].position.z > player.position.z + 18.0:
		var old: Node3D = ground_segments.pop_front()
		old.queue_free()
	var farthest := -999999.0
	for segment in ground_segments:
		farthest = maxf(farthest, segment.position.z)
	while farthest > player.position.z - WORLD_AHEAD:
		farthest -= SEGMENT_LENGTH
		_add_ground_segment(farthest)
	while spawn_z > player.position.z - WORLD_AHEAD:
		spawn_z -= rng.randf_range(6.5, 9.0)
		_spawn_row(spawn_z)
	_cleanup_nodes(obstacles, player.position.z)
	_cleanup_nodes(coin_nodes, player.position.z)

func _cleanup_nodes(nodes: Array[Node3D], player_z: float) -> void:
	for i in range(nodes.size() - 1, -1, -1):
		if nodes[i].position.z > player_z + 12.0:
			nodes[i].queue_free()
			nodes.remove_at(i)

func _check_collisions() -> void:
	for obstacle in obstacles:
		if absf(obstacle.position.z - player.position.z) < 0.75 and absf(obstacle.position.x - player.position.x) < 0.85:
			if jump_timer <= 0.0 and slide_timer <= 0.0:
				_end_game()
				return
	for i in range(coin_nodes.size() - 1, -1, -1):
		var coin := coin_nodes[i]
		if absf(coin.position.z - player.position.z) < 1.0 and absf(coin.position.x - player.position.x) < 0.9:
			coins += 1
			coin.queue_free()
			coin_nodes.remove_at(i)

func _update_hud() -> void:
	if is_instance_valid(score_label):
		score_label.text = "DISTANCE  %05d" % int(distance)
		coin_label.text = "COINS  %d" % coins

func _end_game() -> void:
	game_over = true
	message_label.text = "GAME OVER\nDISTANCE: %d" % int(distance)
	restart_button.visible = true

func _restart() -> void:
	get_tree().reload_current_scene()
