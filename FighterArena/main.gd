extends Node3D

const ARENA_LIMIT := 5.2
const SAVE_PATH := "user://fighter_controls.cfg"

var player: Node3D
var enemy: Node3D
var player_arm: Node3D
var enemy_arm: Node3D
var player_leg: Node3D
var enemy_leg: Node3D
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
    _build_world()
    player = _make_fighter("PLAYER", Color("#0b7cff"), Color("#f2f2f2"), Vector3(-2.1, 0, 0))
    enemy = _make_fighter("RIVAL", Color("#c51f32"), Color("#20242c"), Vector3(2.1, 0, 0))
    player_arm = player.get_node("RightArm")
    enemy_arm = enemy.get_node("RightArm")
    player_leg = player.get_node("RightLeg")
    enemy_leg = enemy.get_node("RightLeg")
    _build_hud()
    _load_controls()
    _face_fighters()
    _set_status("ROUND 1  •  FIGHT!")

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#070b18")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#7d91b8")
    environment.ambient_light_energy = 1.0
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = environment
    add_child(env)

    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-52, -30, 0)
    key_light.light_energy = 2.0
    key_light.shadow_enabled = true
    key_light.directional_shadow_max_distance = 35.0
    add_child(key_light)

    var fill := OmniLight3D.new()
    fill.position = Vector3(0, 4.5, 2.5)
    fill.light_energy = 7.0
    fill.omni_range = 16.0
    add_child(fill)

    var floor := MeshInstance3D.new()
    var floor_mesh := PlaneMesh.new()
    floor_mesh.size = Vector2(16, 14)
    floor.mesh = floor_mesh
    floor.position.y = -0.08
    floor.material_override = _mat(Color("#151b2d"), 0.35, 0.3)
    add_child(floor)

    var ring := MeshInstance3D.new()
    var ring_mesh := BoxMesh.new()
    ring_mesh.size = Vector3(11.2, 0.16, 7.6)
    ring.mesh = ring_mesh
    ring.position.y = 0.02
    ring.material_override = _mat(Color("#263b61"), 0.55, 0.22)
    add_child(ring)

    for x in [-5.35, 5.35]:
        var rail := MeshInstance3D.new()
        var rail_mesh := BoxMesh.new()
        rail_mesh.size = Vector3(0.08, 1.15, 7.4)
        rail.mesh = rail_mesh
        rail.position = Vector3(x, 0.62, 0)
        rail.material_override = _mat(Color("#4b6d9f"), 0.75, 0.18)
        add_child(rail)

    for z in [-3.65, 3.65]:
        var rail := MeshInstance3D.new()
        var rail_mesh := BoxMesh.new()
        rail_mesh.size = Vector3(10.8, 0.12, 0.08)
        rail.mesh = rail_mesh
        rail.position = Vector3(0, 0.18, z)
        rail.material_override = _mat(Color("#1aa6d9"), 0.65, 0.2)
        add_child(rail)

    for x in [-6.2, 6.2]:
        for z in [-3.2, 3.2]:
            var pillar := MeshInstance3D.new()
            var pillar_mesh := CylinderMesh.new()
            pillar_mesh.top_radius = 0.16
            pillar_mesh.bottom_radius = 0.22
            pillar_mesh.height = 2.8
            pillar.mesh = pillar_mesh
            pillar.position = Vector3(x, 1.3, z)
            pillar.material_override = _mat(Color("#202b42"), 0.55, 0.2)
            add_child(pillar)

    for x in [-4.6, -2.3, 0, 2.3, 4.6]:
        var tile := MeshInstance3D.new()
        var tile_mesh := BoxMesh.new()
        tile_mesh.size = Vector3(0.035, 0.025, 6.9)
        tile.mesh = tile_mesh
        tile.position = Vector3(x, 0.105, 0)
        tile.material_override = _mat(Color("#33496e"), 0.3, 0.32)
        add_child(tile)

    var camera := Camera3D.new()
    camera.position = Vector3(0, 5.9, 12.4)
    camera.rotation_degrees = Vector3(-25, 0, 0)
    camera.fov = 50
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
    plabel.text = "PLAYER 01"
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
    round_label.text = "ROUND 01"
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
    elabel.text = "RIVAL 01"
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
            _update_joystick(event.position)
        else:
            _reset_joystick()
    elif event is InputEventScreenDrag and joystick_active:
        _update_joystick(event.position)

func _update_joystick(point: Vector2) -> void:
    var delta := point - joystick_center
    var radius := 42.0
    if delta.length() > radius:
        delta = delta.normalized() * radius
    joystick_knob.position = joystick_center + delta - joystick_knob.size * 0.5
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
        enemy_hp = maxf(0.0, enemy_hp - damage)
        enemy_bar.value = enemy_hp
        _flash(enemy)
        _set_status(move_name + " HIT!  -" + str(int(damage)))
        if enemy_hp <= 0:
            _finish(true)
    else:
        _set_status("TOO FAR — MOVE CLOSER")

func _attack_animation(limb: Node3D, move_name: String) -> void:
    if not is_instance_valid(limb):
        return
    var start := limb.rotation.z
    var reach := -1.48 if move_name != "KICK" else -1.05
    var tw := create_tween()
    tw.tween_property(limb, "rotation:z", reach, 0.08)
    tw.tween_property(limb, "rotation:z", start, 0.17)

func _burst_effect(pos: Vector3) -> void:
    var fx := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    fx.mesh = mesh
    fx.position = pos
    fx.scale = Vector3(0.18, 0.18, 0.18)
    fx.material_override = _mat(Color("#5de1ff"), 0.1, 0.15)
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
    if special_cooldown > 0.0:
        special_cooldown = maxf(0.0, special_cooldown - delta)
        if special_cooldown <= 0.0 and not round_over:
            _set_status("SPECIAL READY")

    if round_over:
        return

    enemy_clock -= delta
    if enemy_clock <= 0:
        enemy_clock = randf_range(0.9, 1.55)
        if absf(enemy.position.x - player.position.x) > 2.55:
            enemy.position.x = move_toward(enemy.position.x, player.position.x + 1.25, 0.62)
            enemy.position.x = clampf(enemy.position.x, 0.6, ARENA_LIMIT)
            _face_fighters()
            _set_status("RIVAL ADVANCING")
        else:
            _attack_animation(enemy_arm, "PUNCH")
            var damage := randf_range(6.0, 11.0)
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
    _set_status("VICTORY!" if won else "DEFEAT  •  TRY AGAIN")
    var p: Button = control_buttons["punch"] as Button
    var k: Button = control_buttons["kick"] as Button
    p.text = "AGAIN"
    k.text = "AGAIN"
    p.pressed.disconnect(_punch)
    k.pressed.disconnect(_kick)
    p.pressed.connect(_restart)
    k.pressed.connect(_restart)

func _restart() -> void:
    get_tree().reload_current_scene()
