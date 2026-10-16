extends Node3D

const ARENA_LIMIT := 5.2
const SAVE_PATH := "user://fighter_controls.cfg"
const CAMPAIGN_PATH := "user://fighter_campaign.cfg"

var player: Node3D
var enemy: Node3D
var player_arm: Node3D
var enemy_arm: Node3D
var player_leg: Node3D
var enemy_leg: Node3D
var campaign_round := 1
var player_hp := 100.0
var enemy_hp := 100.0
var enemy_clock := 1.0
var special_cooldown := 0.0
var round_over := false
var blocking := false
var customizing := false
var dragging_button: Button
var drag_start := Vector2.ZERO
var drag_origin := Vector2.ZERO
var control_buttons: Dictionary = {}
var arena_camera: Camera3D
var camera_shake_time := 0.0
var combo_count := 0
var combo_timer := 0.0

var hud: CanvasLayer
var root_ui: Control
var player_bar: ProgressBar
var enemy_bar: ProgressBar
var status_label: Label
var round_label: Label
var block_button: Button
var customize_button: Button
var special_button: Button
var joystick_base: Button
var joystick_knob: Button
var joystick_active := false
var joystick_center := Vector2.ZERO

func _ready() -> void:
    randomize()
    _load_campaign()
    # Show a visible HUD immediately so startup failures do not look like a silent black screen.
    _build_hud()
    _load_controls()
    _set_status("LOADING ARENA...")
    _build_world()
    player = _make_fighter("PLAYER", Color("#0b7cff"), Color("#f2f2f2"), Vector3(-2.1, 0, 0))
    enemy = _make_fighter("RIVAL", Color("#c51f32"), Color("#20242c"), Vector3(2.1, 0, 0))
    player_arm = player.get_node("RightArm")
    enemy_arm = enemy.get_node("RightArm")
    player_leg = player.get_node("RightLeg")
    enemy_leg = enemy.get_node("RightLeg")
    enemy_hp = minf(100.0 + float(campaign_round - 1) * 5.0, 160.0)
    enemy_bar.max_value = enemy_hp
    enemy_bar.value = enemy_hp
    _face_fighters()
    _set_status("STORY ROUND " + str(campaign_round) + "  •  FIGHT!")

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#7fc9ee")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#c3ddf0")
    environment.ambient_light_energy = 0.95
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.fog_enabled = true
    environment.fog_light_color = Color("#a8d8ed")
    environment.fog_density = 0.004
    env.environment = environment
    add_child(env)

    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-52, -30, 0)
    key_light.light_color = Color("#fff0cf")
    key_light.light_energy = 1.25
    key_light.shadow_enabled = true
    key_light.directional_shadow_max_distance = 35.0
    add_child(key_light)

    var rim_light := OmniLight3D.new()
    rim_light.position = Vector3(0, 4.0, -3.5)
    rim_light.light_color = Color("#72c9ff")
    rim_light.light_energy = 2.0
    rim_light.omni_range = 14.0
    add_child(rim_light)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 4.5, 2.5)
    fill.light_color = Color("#ffe1a1")
    fill.light_energy = 1.4
    fill.omni_range = 16.0
    add_child(fill)

    var floor := MeshInstance3D.new()
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(24, 22)
    floor.mesh = floor_mesh
    floor.position.y = -0.08
    floor.material_override = _mat(Color("#b58b56"), 0.0, 0.92)
    add_child(floor)

    var platform := MeshInstance3D.new()
    var platform_mesh := CylinderMesh.new()
    platform_mesh.top_radius = 5.8
    platform_mesh.bottom_radius = 6.1
    platform_mesh.height = 0.22
    platform_mesh.radial_segments = 8
    platform.mesh = platform_mesh
    platform.position.y = -0.02
    platform.material_override = _mat(Color("#6f523b"), 0.05, 0.86)
    add_child(platform)

    var ring := MeshInstance3D.new()
    var ring_mesh := BoxMesh.new()
    ring_mesh.size = Vector3(11.2, 0.13, 7.6)
    ring.mesh = ring_mesh
    ring.position.y = 0.12
    ring.material_override = _glow_mat(Color("#35d9ef"))
    add_child(ring)

    for x in [-5.0, -3.8, -2.6, -1.4, 0.0, 1.4, 2.6, 3.8, 5.0]:
        var tile := MeshInstance3D.new()
        var tile_mesh := BoxMesh.new()
        tile_mesh.size = Vector3(0.025, 0.018, 6.8)
        tile.mesh = tile_mesh
        tile.position = Vector3(x, 0.14, 0)
        tile.material_override = _glow_mat(Color("#163e73"))
        add_child(tile)

    for z in [-3.55, 3.55]:
        var rail := MeshInstance3D.new()
        var rail_mesh := BoxMesh.new()
        rail_mesh.size = Vector3(10.8, 0.10, 0.08)
        rail.mesh = rail_mesh
        rail.position = Vector3(0, 0.20, z)
        rail.material_override = _glow_mat(Color("#13dfff"))
        add_child(rail)

    for x in [-5.35, 5.35]:
        var rail := MeshInstance3D.new()
        var rail_mesh := BoxMesh.new()
        rail_mesh.size = Vector3(0.08, 1.15, 7.4)
        rail.mesh = rail_mesh
        rail.position = Vector3(x, 0.62, 0)
        rail.material_override = _mat(Color("#202a49"), 0.82, 0.18)
        add_child(rail)

    # Warm anime canyon backdrop with layered cliffs and a bright waterfall.
    for side in [-1.0, 1.0]:
        for i in range(5):
            var cliff := MeshInstance3D.new()
            var cliff_mesh := BoxMesh.new()
            var cliff_h := 3.0 + float((i * 3) % 4) * 0.9
            cliff_mesh.size = Vector3(2.3 + float(i % 2) * 0.8, cliff_h, 1.8)
            cliff.mesh = cliff_mesh
            cliff.position = Vector3(side * (7.0 + float(i % 2) * 0.8), cliff_h * 0.5 - 0.15, -5.8 - float(i) * 1.4)
            cliff.rotation.z = side * (0.04 + float(i % 3) * 0.025)
            cliff.material_override = _mat(Color("#9b7955") if i % 2 == 0 else Color("#b28a60"), 0.0, 0.98)
            add_child(cliff)
            var ledge := MeshInstance3D.new()
            var ledge_mesh := BoxMesh.new()
            ledge_mesh.size = Vector3(2.7, 0.22, 2.0)
            ledge.mesh = ledge_mesh
            ledge.position = cliff.position + Vector3(-side * 0.12, cliff_h * 0.28, 0.05)
            ledge.material_override = _mat(Color("#d1ad78"), 0.0, 1.0)
            add_child(ledge)

    var waterfall := MeshInstance3D.new()
    var waterfall_mesh := BoxMesh.new()
    waterfall_mesh.size = Vector3(2.8, 4.2, 0.12)
    waterfall.mesh = waterfall_mesh
    waterfall.position = Vector3(0.0, 2.0, -7.5)
    var water_mat := StandardMaterial3D.new()
    water_mat.albedo_color = Color(0.34, 0.78, 0.95, 0.78)
    water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    water_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    water_mat.emission_enabled = true
    water_mat.emission = Color("#65dfff")
    water_mat.emission_energy_multiplier = 0.45
    waterfall.material_override = water_mat
    add_child(waterfall)

    for i in range(9):
        var stream := MeshInstance3D.new()
        var stream_mesh := BoxMesh.new()
        stream_mesh.size = Vector3(0.055 + float(i % 3) * 0.025, 3.7, 0.035)
        stream.mesh = stream_mesh
        stream.position = Vector3(-1.25 + float(i) * 0.31, 1.9, -7.38)
        stream.material_override = _glow_mat(Color("#a6edff"))
        add_child(stream)

    for i in range(11):
        var rock := MeshInstance3D.new()
        var rock_mesh := SphereMesh.new()
        rock_mesh.radius = 0.45 + float(i % 3) * 0.16
        rock_mesh.height = rock_mesh.radius * 1.4
        rock.mesh = rock_mesh
        rock.position = Vector3(-7.2 + float(i) * 1.42, -0.02 + float(i % 2) * 0.12, -4.5 - float(i % 3) * 1.1)
        rock.scale = Vector3(1.4, 0.7, 0.8)
        rock.material_override = _mat(Color("#80664d") if i % 2 == 0 else Color("#a58a69"), 0.0, 0.95)
        add_child(rock)

    for x in [-6.2, 6.2]:
        for z in [-3.2, 3.2]:
            var pillar := MeshInstance3D.new()
            var pillar_mesh := CylinderMesh.new()
            pillar_mesh.top_radius = 0.16
            pillar_mesh.bottom_radius = 0.22
            pillar_mesh.height = 2.8
            pillar.mesh = pillar_mesh
            pillar.position = Vector3(x, 1.3, z)
            pillar.material_override = _mat(Color("#202b42"), 0.7, 0.2)
            add_child(pillar)
            var cap := MeshInstance3D.new()
            var cap_mesh := SphereMesh.new()
            cap_mesh.radius = 0.20
            cap_mesh.height = 0.4
            cap.mesh = cap_mesh
            cap.position = Vector3(x, 2.8, z)
            cap.material_override = _glow_mat(Color("#13dfff") if x < 0 else Color("#b72fff"))
            add_child(cap)

    arena_camera = Camera3D.new()
    arena_camera.position = Vector3(0, 5.9, 12.4)
    arena_camera.rotation_degrees = Vector3(-25, 0, 0)
    arena_camera.fov = 48
    add_child(arena_camera)
    arena_camera.make_current()

func _glow_mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy_multiplier = 1.6
    material.metallic = 0.25
    material.roughness = 0.22
    return material

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
    n.material_override = _mat(color, 0.16, 0.34)
    parent.add_child(n)
    return n

func _make_fighter(label: String, primary: Color, secondary: Color, pos: Vector3) -> Node3D:
    var root := Node3D.new()
    root.name = label
    root.position = pos
    add_child(root)

    var skin := Color("#c88763")
    var dark := primary.darkened(0.5)

    _piece(root, "Torso", CapsuleMesh.new(), Vector3(0, 1.35, 0), primary, Vector3(0.76, 0.92, 0.56))
    _piece(root, "Chest", BoxMesh.new(), Vector3(0, 1.48, -0.28), secondary, Vector3(0.54, 0.42, 0.12))
    _piece(root, "Belt", TorusMesh.new(), Vector3(0, 0.82, 0), dark, Vector3(0.72, 0.72, 0.72))

    var neck := CylinderMesh.new()
    neck.top_radius = 0.16
    neck.bottom_radius = 0.18
    neck.height = 0.22
    _piece(root, "Neck", neck, Vector3(0, 1.98, 0), skin, Vector3.ONE)

    _piece(root, "Head", SphereMesh.new(), Vector3(0, 2.3, 0), skin, Vector3(0.46, 0.52, 0.43))
    _piece(root, "Hair", SphereMesh.new(), Vector3(0, 2.55, -0.02), Color("#15171b"), Vector3(0.49, 0.25, 0.46))
    _piece(root, "Visor", BoxMesh.new(), Vector3(0, 2.33, -0.39), Color("#111820"), Vector3(0.34, 0.13, 0.035))

    var arm_r := _piece(root, "RightArm", CapsuleMesh.new(), Vector3(0.61, 1.42, -0.02), primary.lightened(0.08), Vector3(0.25, 0.62, 0.26))
    arm_r.rotation.z = -0.7
    var arm_l := _piece(root, "LeftArm", CapsuleMesh.new(), Vector3(-0.61, 1.42, -0.02), primary.lightened(0.08), Vector3(0.25, 0.62, 0.26))
    arm_l.rotation.z = 0.7
    _piece(root, "RightGlove", SphereMesh.new(), Vector3(0.83, 1.03, -0.12), Color("#0b0d12"), Vector3(0.27, 0.24, 0.28))
    _piece(root, "LeftGlove", SphereMesh.new(), Vector3(-0.83, 1.03, -0.12), Color("#0b0d12"), Vector3(0.27, 0.24, 0.28))

    _piece(root, "LeftLeg", CapsuleMesh.new(), Vector3(-0.25, 0.43, 0), dark, Vector3(0.29, 0.62, 0.32))
    _piece(root, "RightLeg", CapsuleMesh.new(), Vector3(0.25, 0.43, 0), dark, Vector3(0.29, 0.62, 0.32))
    _piece(root, "LeftBoot", BoxMesh.new(), Vector3(-0.25, 0.12, -0.15), secondary.darkened(0.65), Vector3(0.43, 0.18, 0.7))
    _piece(root, "RightBoot", BoxMesh.new(), Vector3(0.25, 0.12, -0.15), secondary.darkened(0.65), Vector3(0.43, 0.18, 0.7))

    for side in [-1.0, 1.0]:
        var shoulder := SphereMesh.new()
        _piece(root, "Shoulder" + str(side), shoulder, Vector3(0.63 * side, 1.68, 0), primary.lightened(0.18), Vector3(0.28, 0.25, 0.28))
        var forearm := _piece(root, "ForearmArmor" + str(side), CapsuleMesh.new(), Vector3(0.68 * side, 1.15, -0.12), secondary, Vector3(0.29, 0.25, 0.29))
        forearm.rotation.z = -0.25 * side
    _piece(root, "ChestCore", SphereMesh.new(), Vector3(0, 1.50, -0.37), Color("#10202d"), Vector3(0.18, 0.18, 0.07))
    _piece(root, "ChestGlow", SphereMesh.new(), Vector3(0, 1.50, -0.425), Color("#5de1ff") if label == "PLAYER" else Color("#ff3f72"), Vector3(0.09, 0.09, 0.035))
    _piece(root, "LeftKnee", SphereMesh.new(), Vector3(-0.25, 0.48, -0.19), secondary, Vector3(0.23, 0.19, 0.12))
    _piece(root, "RightKnee", SphereMesh.new(), Vector3(0.25, 0.48, -0.19), secondary, Vector3(0.23, 0.19, 0.12))
    return root

func _build_hud() -> void:
    hud = CanvasLayer.new()
    add_child(hud)
    root_ui = Control.new()
    root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.add_child(root_ui)

    var top := HBoxContainer.new()
    top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 28
    top.offset_right = -28
    top.offset_top = 18
    top.offset_bottom = 98
    top.add_theme_constant_override("separation", 22)
    root_ui.add_child(top)

    var pbox := VBoxContainer.new()
    pbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(pbox)
    var plabel := Label.new()
    plabel.text = "PLAYER"
    plabel.add_theme_font_size_override("font_size", 21)
    pbox.add_child(plabel)
    player_bar = ProgressBar.new()
    player_bar.max_value = 100
    player_bar.value = 100
    player_bar.custom_minimum_size = Vector2(100, 24)
    pbox.add_child(player_bar)

    var center := VBoxContainer.new()
    center.custom_minimum_size = Vector2(220, 0)
    top.add_child(center)
    round_label = Label.new()
    round_label.text = "STORY ROUND " + str(campaign_round).pad_zeros(2)
    round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    round_label.add_theme_font_size_override("font_size", 22)
    center.add_child(round_label)
    status_label = Label.new()
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 14)
    center.add_child(status_label)

    var ebox := VBoxContainer.new()
    ebox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(ebox)
    var elabel := Label.new()
    elabel.text = "RIVAL " + str(campaign_round).pad_zeros(2)
    elabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    elabel.add_theme_font_size_override("font_size", 21)
    ebox.add_child(elabel)
    enemy_bar = ProgressBar.new()
    enemy_bar.max_value = 100
    enemy_bar.value = 100
    enemy_bar.custom_minimum_size = Vector2(100, 24)
    ebox.add_child(enemy_bar)

    _build_joystick()
    _make_control("PUNCH", "punch", Vector2(940, 500), 112, _punch)
    _make_control("KICK", "kick", Vector2(1065, 500), 112, _kick)
    _make_control("BLOCK", "block", Vector2(940, 585), 112, _block_on)
    special_button = _make_control("SPECIAL", "special", Vector2(1065, 585), 112, _special)
    customize_button = _make_control("CUSTOMIZE", "customize", Vector2(34, 585), 125, _toggle_customize)

    var hint := Label.new()
    hint.name = "Hint"
    hint.text = "MOVE  •  PUNCH  •  KICK  •  BLOCK  •  SPECIAL"
    hint.position = Vector2(250, 675)
    hint.size = Vector2(780, 26)
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_font_size_override("font_size", 12)
    hint.modulate = Color(0.62, 0.75, 0.95, 0.8)
    root_ui.add_child(hint)

func _build_joystick() -> void:
    joystick_base = Button.new()
    joystick_base.name = "MoveJoystick"
    joystick_base.text = "MOVE\n●"
    joystick_base.position = Vector2(34, 455)
    joystick_base.size = Vector2(150, 118)
    joystick_base.add_theme_font_size_override("font_size", 17)
    joystick_base.add_theme_color_override("font_color", Color.WHITE)
    joystick_base.add_theme_color_override("font_hover_color", Color.WHITE)
    root_ui.add_child(joystick_base)

    joystick_knob = Button.new()
    joystick_knob.name = "MoveKnob"
    joystick_knob.text = "●"
    joystick_knob.position = joystick_base.position + Vector2(58, 50)
    joystick_knob.size = Vector2(34, 34)
    joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    joystick_knob.add_theme_font_size_override("font_size", 18)
    joystick_knob.add_theme_color_override("font_color", Color("#5de1ff"))
    root_ui.add_child(joystick_knob)

    joystick_center = joystick_base.position + joystick_base.size * 0.5
    joystick_base.gui_input.connect(_on_joystick_input)

func _on_joystick_input(event: InputEvent) -> void:
    if customizing:
        return
    if event is InputEventScreenTouch:
        joystick_active = event.pressed
        if joystick_active:
            _update_joystick(event.global_position)
        else:
            _reset_joystick()
    elif event is InputEventScreenDrag and joystick_active:
        _update_joystick(event.global_position)

func _update_joystick(point: Vector2) -> void:
    # Screen input positions must be compared with the joystick's global position.
    var center := joystick_base.global_position + joystick_base.size * 0.5
    var delta := point - center
    var radius := 42.0
    if delta.length() > radius:
        delta = delta.normalized() * radius
    joystick_knob.position = joystick_base.position + joystick_base.size * 0.5 + delta - joystick_knob.size * 0.5
    if absf(delta.x) > 10.0:
        _move(1.0 if delta.x > 0.0 else -1.0)

func _reset_joystick() -> void:
    joystick_active = false
    joystick_knob.position = joystick_center - joystick_knob.size * 0.5

func _make_control(text_value: String, key: String, pos: Vector2, width: float, callback: Callable) -> Button:
    var b := Button.new()
    b.name = key.to_pascal_case() + "Button"
    b.text = text_value
    b.position = pos
    b.size = Vector2(width, 72)
    b.add_theme_font_size_override("font_size", 15 if width < 110 else 13)
    b.add_theme_color_override("font_color", Color.WHITE)
    b.pressed.connect(callback)
    root_ui.add_child(b)
    control_buttons[key] = b
    b.gui_input.connect(_on_control_gui_input.bind(b, key))
    return b

func _on_control_gui_input(event: InputEvent, button: Button, _key: String) -> void:
    if not customizing:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            dragging_button = button
            drag_start = event.position
            drag_origin = button.position
        elif dragging_button == button:
            dragging_button = null
            _save_controls()
    elif event is InputEventScreenDrag and dragging_button == button:
        button.position = drag_origin + event.position - drag_start

func _toggle_customize() -> void:
    customizing = not customizing
    customize_button.text = "DONE" if customizing else "CUSTOMIZE"
    _set_status("DRAG BUTTONS TO YOUR LAYOUT" if customizing else "CONTROL LAYOUT SAVED")
    if not customizing:
        _save_controls()

func _save_controls() -> void:
    var cfg := ConfigFile.new()
    for key in control_buttons:
        cfg.set_value("controls", key, control_buttons[key].position)
    if joystick_base:
        cfg.set_value("controls", "joystick", joystick_base.position)
    cfg.save(SAVE_PATH)

func _load_controls() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) == OK:
        for key in control_buttons:
            if cfg.has_section_key("controls", key):
                control_buttons[key].position = cfg.get_value("controls", key)
        if joystick_base and cfg.has_section_key("controls", "joystick"):
            joystick_base.position = cfg.get_value("controls", "joystick")
            joystick_center = joystick_base.position + joystick_base.size * 0.5
            _reset_joystick()

func _face_fighters() -> void:
    if player and enemy:
        player.look_at(Vector3(enemy.position.x, 0, enemy.position.z), Vector3.UP)
        enemy.look_at(Vector3(player.position.x, 0, player.position.z), Vector3.UP)

func _move(direction: float) -> void:
    if round_over:
        return
    player.position.x = clampf(player.position.x + direction * 0.58, -ARENA_LIMIT, 0.5)
    _face_fighters()

func _block_on() -> void:
    if round_over:
        return
    blocking = not blocking
    block_button = control_buttons["block"]
    block_button.text = "BLOCK ON" if blocking else "BLOCK"
    player.scale = Vector3(1.0, 0.9, 1.0) if blocking else Vector3.ONE
    _set_status("GUARD UP" if blocking else "READY")

func _punch() -> void:
    _player_attack(9.0, "PUNCH", player_arm)

func _kick() -> void:
    _player_attack(15.0, "KICK", player_leg)

func _special() -> void:
    if round_over or special_cooldown > 0.0:
        _set_status("SPECIAL RECHARGING")
        return
    special_cooldown = 4.0
    _player_attack(28.0, "SPECIAL", player_arm)
    _burst_effect(enemy.position + Vector3(0, 1.25, -0.4))

func _player_attack(damage: float, move_name: String, limb: Node3D) -> void:
    if round_over:
        return
    _attack_animation(limb, move_name)
    if absf(enemy.position.x - player.position.x) <= 3.15:
        if combo_timer > 0.0:
            combo_count += 1
        else:
            combo_count = 1
        combo_timer = 1.35
        var combo_bonus := minf(float(maxi(0, combo_count - 1)) * 0.08, 0.4)
        damage *= 1.0 + combo_bonus
        camera_shake_time = 0.18 if move_name != "SPECIAL" else 0.32
        _burst_effect(enemy.position + Vector3(0, 1.25, -0.4))
        enemy_hp = maxf(0.0, enemy_hp - damage)
        enemy_bar.value = enemy_hp
        _flash(enemy)
        _set_status(move_name + " HIT!  -" + str(int(damage)) + ("  •  " + str(combo_count) + " HIT COMBO" if combo_count > 1 else ""))
        if enemy_hp <= 0:
            _finish(true)
    else:
        _set_status("TOO FAR — MOVE CLOSER")

func _attack_animation(limb: Node3D, move_name: String) -> void:
    if not is_instance_valid(limb):
        return

    var torso: Node3D = limb.get_parent().get_node_or_null("Torso") as Node3D
    if move_name == "KICK":
        # Rotate the leg forward, rather than sideways, for a readable kick.
        var leg_start_x := limb.rotation.x
        var kick := create_tween()
        kick.tween_property(limb, "rotation:x", -0.95, 0.10)
        kick.tween_property(limb, "rotation:x", leg_start_x, 0.20)
        if is_instance_valid(torso):
            var torso_start_x := torso.rotation.x
            var lean := create_tween()
            lean.tween_property(torso, "rotation:x", 0.18, 0.10)
            lean.tween_property(torso, "rotation:x", torso_start_x, 0.20)
        return

    var start := limb.rotation.z
    var reach := -1.65 if move_name == "SPECIAL" else -1.48
    var tw := create_tween()
    tw.tween_property(limb, "rotation:z", reach, 0.08)
    tw.tween_property(limb, "rotation:z", start, 0.17)
    if is_instance_valid(torso):
        var torso_start_z := torso.rotation.z
        var lean := create_tween()
        lean.tween_property(torso, "rotation:z", torso_start_z - 0.12, 0.08)
        lean.tween_property(torso, "rotation:z", torso_start_z, 0.17)

func _burst_effect(pos: Vector3) -> void:
    var fx := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    fx.mesh = mesh
    fx.position = pos
    fx.scale = Vector3(0.18, 0.18, 0.18)
    fx.material_override = _glow_mat(Color("#5de1ff"))
    add_child(fx)
    var tw := create_tween()
    tw.tween_property(fx, "scale", Vector3(1.7, 1.7, 1.7), 0.18)
    tw.tween_interval(0.08)
    tw.tween_callback(fx.queue_free)

func _flash(target: Node3D) -> void:
    target.scale = Vector3(1.12, 0.9, 1.12)
    var tw := create_tween()
    tw.tween_property(target, "scale", Vector3.ONE, 0.14)

func _process(delta: float) -> void:
    if combo_timer > 0.0:
        combo_timer = maxf(0.0, combo_timer - delta)
        if combo_timer <= 0.0:
            combo_count = 0
    if camera_shake_time > 0.0 and is_instance_valid(arena_camera):
        camera_shake_time = maxf(0.0, camera_shake_time - delta)
        var shake_strength := 0.075 if camera_shake_time > 0.1 else 0.035
        arena_camera.position.x = randf_range(-shake_strength, shake_strength)
        arena_camera.position.y = 5.9 + randf_range(-shake_strength, shake_strength)
    elif is_instance_valid(arena_camera):
        arena_camera.position.x = move_toward(arena_camera.position.x, 0.0, delta * 0.8)
        arena_camera.position.y = move_toward(arena_camera.position.y, 5.9, delta * 0.8)

    if special_cooldown > 0.0:
        special_cooldown = maxf(0.0, special_cooldown - delta)
        if is_instance_valid(special_button):
            special_button.text = "SPECIAL " + str(ceili(special_cooldown)) + "s"
        if special_cooldown <= 0.0 and not round_over:
            if is_instance_valid(special_button):
                special_button.text = "SPECIAL"
            _set_status("SPECIAL READY")
    elif is_instance_valid(special_button) and not round_over:
        special_button.text = "SPECIAL"

    if round_over:
        return

    enemy_clock -= delta
    if enemy_clock <= 0:
        var speed_bonus := minf(float(campaign_round - 1) * 0.05, 0.35)
        enemy_clock = randf_range(maxf(0.45, 0.9 - speed_bonus), maxf(0.7, 1.55 - speed_bonus))
        if absf(enemy.position.x - player.position.x) > 2.55:
            enemy.position.x = move_toward(enemy.position.x, player.position.x + 1.25, 0.62)
            enemy.position.x = clampf(enemy.position.x, 0.6, ARENA_LIMIT)
            _face_fighters()
            _set_status("RIVAL ADVANCING")
        else:
            _attack_animation(enemy_arm, "PUNCH")
            var damage := randf_range(6.0, 11.0) + minf(float(campaign_round - 1) * 1.5, 15.0)
            if blocking:
                damage *= 0.2
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
    joystick_active = false
    _reset_joystick()
    var p: Button = control_buttons["punch"] as Button
    var k: Button = control_buttons["kick"] as Button
    p.pressed.disconnect(_punch)
    k.pressed.disconnect(_kick)

    # Freeze combat-only controls after the round so they cannot overwrite
    # the victory/defeat message or consume inputs behind the result screen.
    var guard: Button = control_buttons["block"] as Button
    guard.disabled = true
    if is_instance_valid(special_button):
        special_button.disabled = true
        special_button.text = "SPECIAL"

    if won:
        _set_status("VICTORY!  •  TAP NEXT ROUND")
        p.text = "NEXT ROUND"
        k.text = "NEXT ROUND"
        p.pressed.connect(_next_round)
        k.pressed.connect(_next_round)
    else:
        _set_status("DEFEAT  •  TAP RETRY")
        p.text = "RETRY"
        k.text = "RETRY"
        p.pressed.connect(_restart)
        k.pressed.connect(_restart)

func _load_campaign() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(CAMPAIGN_PATH) == OK:
        campaign_round = maxi(1, int(cfg.get_value("story", "round", 1)))

func _save_campaign() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("story", "round", campaign_round)
    cfg.save(CAMPAIGN_PATH)

func _next_round() -> void:
    campaign_round += 1
    _save_campaign()
    get_tree().reload_current_scene()

func _restart() -> void:
    get_tree().reload_current_scene()
