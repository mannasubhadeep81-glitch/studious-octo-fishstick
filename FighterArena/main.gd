extends Node3D

const ARENA_LIMIT := 5.2
var player: Node3D
var enemy: Node3D
var player_arm: Node3D
var enemy_arm: Node3D
var player_hp := 100.0
var enemy_hp := 100.0
var enemy_clock := 1.1
var round_over := false
var blocking := false
var hud: CanvasLayer
var player_bar: ProgressBar
var enemy_bar: ProgressBar
var status_label: Label
var round_label: Label
var attack_button: Button
var kick_button: Button
var block_button: Button

func _ready() -> void:
    _build_world()
    player = _make_fighter("PLAYER", Color(0.08, 0.65, 1.0), Vector3(-2.1, 0, 0))
    enemy = _make_fighter("RIVAL", Color(1.0, 0.19, 0.16), Vector3(2.1, 0, 0))
    player_arm = player.get_node("RightArm")
    enemy_arm = enemy.get_node("RightArm")
    _build_hud()
    _face_fighters()
    _set_status("ROUND 1  •  FIGHT!")

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.018, 0.025, 0.055)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.42, 0.52, 0.72)
    environment.ambient_light_energy = 0.8
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = environment
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.7
    sun.shadow_enabled = true
    add_child(sun)

    var floor := MeshInstance3D.new()
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(15, 15)
    floor.mesh = floor_mesh
    floor.position.y = -0.08
    floor.material_override = _mat(Color(0.075, 0.095, 0.15), 0.25, 0.25)
    add_child(floor)

    var ring := MeshInstance3D.new()
    var ring_mesh := BoxMesh.new()
    ring_mesh.size = Vector3(10.8, 0.12, 7.2)
    ring.mesh = ring_mesh
    ring.position.y = 0.02
    ring.material_override = _mat(Color(0.09, 0.16, 0.26), 0.4, 0.3)
    add_child(ring)

    for i in range(4):
        var strip := MeshInstance3D.new()
        var strip_mesh := BoxMesh.new()
        strip_mesh.size = Vector3(10.9 if i < 2 else 0.08, 0.035, 0.08 if i < 2 else 7.3)
        strip.mesh = strip_mesh
        var z_pos := -3.55 if i == 0 else (3.55 if i == 1 else 0.0)
        var x_pos := -5.4 if i == 2 else (5.4 if i == 3 else 0.0)
        strip.position = Vector3(x_pos, 0.1, z_pos)
        strip.material_override = _mat(Color(0.05, 0.78, 1.0), 0.15, 0.2)
        add_child(strip)

    for x in [-6.3, 6.3]:
        for z in [-3.2, 3.2]:
            var pillar := MeshInstance3D.new()
            var pillar_mesh := BoxMesh.new()
            pillar_mesh.size = Vector3(0.22, 2.5, 0.22)
            pillar.mesh = pillar_mesh
            pillar.position = Vector3(x, 1.2, z)
            pillar.material_override = _mat(Color(0.12, 0.2, 0.32), 0.25, 0.35)
            add_child(pillar)

    var camera := Camera3D.new()
    camera.position = Vector3(0, 6.7, 11.8)
    camera.rotation_degrees = Vector3(-27, 0, 0)
    camera.fov = 47
    camera.current = true
    add_child(camera)

func _mat(color: Color, metallic: float = 0.0, roughness: float = 0.55) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    return m

func _piece(parent: Node3D, name: String, mesh: Mesh, pos: Vector3, color: Color, scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name
    n.mesh = mesh
    n.position = pos
    n.scale = scale
    n.material_override = _mat(color, 0.12, 0.38)
    parent.add_child(n)
    return n

func _make_fighter(label: String, color: Color, pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = label
    root.position = pos
    add_child(root)
    var dark := color.darkened(0.48)
    _piece(root, "Torso", CapsuleMesh.new(), Vector3(0, 1.28, 0), color, Vector3(0.78, 0.95, 0.55))
    _piece(root, "Belt", BoxMesh.new(), Vector3(0, 0.77, 0), dark, Vector3(0.82, 0.18, 0.6))
    _piece(root, "Head", SphereMesh.new(), Vector3(0, 2.12, 0), Color(0.82, 0.62, 0.46), Vector3(0.47, 0.5, 0.45))
    _piece(root, "Hair", SphereMesh.new(), Vector3(0, 2.36, -0.015), dark, Vector3(0.49, 0.25, 0.47))
    var arm := _piece(root, "RightArm", CapsuleMesh.new(), Vector3(0.56, 1.35, -0.05), color.lightened(0.12), Vector3(0.27, 0.65, 0.28))
    arm.rotation.z = -0.72
    var left_arm := _piece(root, "LeftArm", CapsuleMesh.new(), Vector3(-0.56, 1.35, -0.05), color.lightened(0.12), Vector3(0.27, 0.65, 0.28))
    left_arm.rotation.z = 0.72
    _piece(root, "RightGlove", SphereMesh.new(), Vector3(0.78, 1.0, -0.1), Color(0.95, 0.88, 0.7), Vector3(0.25, 0.22, 0.25))
    _piece(root, "LeftGlove", SphereMesh.new(), Vector3(-0.78, 1.0, -0.1), Color(0.95, 0.88, 0.7), Vector3(0.25, 0.22, 0.25))
    _piece(root, "LeftLeg", CapsuleMesh.new(), Vector3(-0.25, 0.42, 0), dark, Vector3(0.28, 0.62, 0.32))
    _piece(root, "RightLeg", CapsuleMesh.new(), Vector3(0.25, 0.42, 0), dark, Vector3(0.28, 0.62, 0.32))
    _piece(root, "LeftBoot", BoxMesh.new(), Vector3(-0.25, 0.12, -0.12), Color(0.035, 0.04, 0.06), Vector3(0.42, 0.18, 0.65))
    _piece(root, "RightBoot", BoxMesh.new(), Vector3(0.25, 0.12, -0.12), Color(0.035, 0.04, 0.06), Vector3(0.42, 0.18, 0.65))
    return root

func _build_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    var top := HBoxContainer.new()
    top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 28
    top.offset_right = -28
    top.offset_top = 18
    top.offset_bottom = 100
    top.add_theme_constant_override("separation", 26)
    hud.add_child(top)

    var pbox := VBoxContainer.new()
    pbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(pbox)
    var plabel := Label.new()
    plabel.text = "NOVA  |  PLAYER"
    plabel.add_theme_font_size_override("font_size", 22)
    pbox.add_child(plabel)
    player_bar = ProgressBar.new()
    player_bar.max_value = 100
    player_bar.value = 100
    player_bar.custom_minimum_size = Vector2(100, 22)
    pbox.add_child(player_bar)

    var center := VBoxContainer.new()
    center.custom_minimum_size = Vector2(230, 0)
    top.add_child(center)
    round_label = Label.new()
    round_label.text = "ROUND 01"
    round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    round_label.add_theme_font_size_override("font_size", 23)
    center.add_child(round_label)
    status_label = Label.new()
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 15)
    center.add_child(status_label)

    var ebox := VBoxContainer.new()
    ebox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(ebox)
    var elabel := Label.new()
    elabel.text = "RIVAL  |  TITAN"
    elabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    elabel.add_theme_font_size_override("font_size", 22)
    ebox.add_child(elabel)
    enemy_bar = ProgressBar.new()
    enemy_bar.max_value = 100
    enemy_bar.value = 100
    enemy_bar.custom_minimum_size = Vector2(100, 22)
    ebox.add_child(enemy_bar)

    var left_controls := HBoxContainer.new()
    left_controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
    left_controls.offset_left = 28
    left_controls.offset_top = -112
    left_controls.offset_right = 340
    left_controls.offset_bottom = -22
    left_controls.add_theme_constant_override("separation", 12)
    hud.add_child(left_controls)
    _add_button(left_controls, "LEFT", 74, _move.bind(-1.0))
    _add_button(left_controls, "RIGHT", 74, _move.bind(1.0))

    var right_controls := HBoxContainer.new()
    right_controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    right_controls.offset_left = -420
    right_controls.offset_top = -112
    right_controls.offset_right = -22
    right_controls.offset_bottom = -22
    right_controls.add_theme_constant_override("separation", 10)
    block_button = _add_button(right_controls, "BLOCK", 90, _block_on)
    attack_button = _add_button(right_controls, "PUNCH", 90, _punch)
    kick_button = _add_button(right_controls, "KICK", 90, _kick)

    var hint := Label.new()
    hint.text = "MOVE  •  BLOCK  •  PUNCH  •  KICK"
    hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    hint.offset_top = -22
    hint.offset_bottom = -3
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", 12)
    hint.modulate = Color(0.65, 0.78, 0.95, 0.8)
    hud.add_child(hint)

func _add_button(parent: Control, text_value: String, width: float, callback: Callable) -> Button:
    var b := Button.new()
    b.text = text_value
    b.custom_minimum_size = Vector2(width, 72)
    b.add_theme_font_size_override("font_size", 17 if width < 90 else 14)
    b.add_theme_color_override("font_color", Color.WHITE)
    b.add_theme_color_override("font_hover_color", Color(0.3, 0.9, 1.0))
    b.pressed.connect(callback)
    parent.add_child(b)
    return b

func _face_fighters() -> void:
    if player and enemy:
        player.look_at(Vector3(enemy.position.x, 0, enemy.position.z), Vector3.UP)
        enemy.look_at(Vector3(player.position.x, 0, player.position.z), Vector3.UP)

func _move(direction: float) -> void:
    if round_over:
        return
    player.position.x = clampf(player.position.x + direction * 0.62, -ARENA_LIMIT, 0.1)
    _face_fighters()

func _block_on() -> void:
    if round_over:
        return
    blocking = not blocking
    block_button.text = "BLOCK ON" if blocking else "BLOCK"
    player.scale = Vector3(1.0, 0.92, 1.0) if blocking else Vector3.ONE
    _set_status("GUARD UP" if blocking else "READY")

func _punch() -> void:
    _player_attack(9.0, "PUNCH")

func _kick() -> void:
    _player_attack(15.0, "KICK")

func _player_attack(damage: float, move_name: String) -> void:
    if round_over:
        return
    _swing(player_arm)
    if absf(enemy.position.x - player.position.x) <= 3.1:
        enemy_hp = maxf(0.0, enemy_hp - damage)
        enemy_bar.value = enemy_hp
        _flash(enemy)
        _set_status(move_name + " HIT!  -" + str(int(damage)))
        if enemy_hp <= 0:
            _finish(true)
    else:
        _set_status("TOO FAR — MOVE CLOSER")

func _swing(arm: Node3D) -> void:
    if not is_instance_valid(arm):
        return
    var tw := create_tween()
    tw.tween_property(arm, "rotation:z", -1.45, 0.09)
    tw.tween_property(arm, "rotation:z", -0.72, 0.16)

func _flash(target: Node3D) -> void:
    target.scale = Vector3(1.08, 0.94, 1.08)
    var tw := create_tween()
    tw.tween_property(target, "scale", Vector3.ONE, 0.14)

func _process(delta: float) -> void:
    if round_over:
        return
    enemy_clock -= delta
    if enemy_clock <= 0:
        enemy_clock = randf_range(1.05, 1.8)
        if absf(enemy.position.x - player.position.x) > 2.7:
            enemy.position.x = move_toward(enemy.position.x, player.position.x + 1.45, 0.55)
            enemy.position.x = clampf(enemy.position.x, 0.6, ARENA_LIMIT)
            _face_fighters()
            _set_status("RIVAL ADVANCING")
        else:
            _swing(enemy_arm)
            var damage := randf_range(5.0, 10.0)
            if blocking:
                damage *= 0.25
                _set_status("BLOCKED!  -" + str(int(damage)))
            else:
                _set_status("RIVAL STRIKE!  -" + str(int(damage)))
            player_hp = maxf(0.0, player_hp - damage)
            player_bar.value = player_hp
            _flash(player)
            if player_hp <= 0:
                _finish(false)

func _set_status(value: String) -> void:
    if is_instance_valid(status_label):
        status_label.text = value

func _finish(won: bool) -> void:
    round_over = true
    _set_status("VICTORY!  NEXT RIVAL SOON" if won else "DEFEAT  •  TRY AGAIN")
    attack_button.text = "AGAIN"
    kick_button.text = "AGAIN"
    attack_button.pressed.disconnect(_punch)
    kick_button.pressed.disconnect(_kick)
    attack_button.pressed.connect(_restart)
    kick_button.pressed.connect(_restart)

func _restart() -> void:
    get_tree().reload_current_scene()
