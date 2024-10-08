class_name WordObject extends RigidBody2D

@export var text: String
@export var dynamic: float = 0.5
@export var color: Color = Color("#888888")
@export var subcolor: Color = Color("#555555")
@export_enum("wide", "tall", "small", "big") var size_and_shape: String = "small"

var colliding: Array[Node2D]

var p: Vector2
var r: bool
var always_frozen: bool

var size: Vector2 = Vector2(64, 0)
var placing: bool 

func _ready() -> void:
	%Area2D.body_entered.connect(_on_body_entered)
	%Area2D.body_exited.connect(_on_body_exited)
	
	await %AnimationPlayer.animation_finished
	%AnimationPlayer.play("shake")

func _on_body_entered(body: Node2D) -> void:
	if not body in colliding:
		colliding.append(body)
		if placing and has_node("%Cover"):
			%Cover.visible = true
func _on_body_exited(body: Node2D) -> void:
	if body in colliding:
		colliding.remove_at(colliding.find(body))
	if len(colliding) == 0:
		if has_node("%Cover"):
			%Cover.visible = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if r:
		r = false
		state.transform.origin = p
		%Area2D.position = Vector2()

func initialize() -> void:
	print(size_and_shape)
	match size_and_shape:
		"wide":
			size = Vector2(64, 32)
		"tall":
			size = Vector2(32, 64)
		"small":
			size = Vector2(32, 32)
		"big":
			size = Vector2(64, 64)
		"very_big":
			size = Vector2(128, 128)
	%Sprite2D.scale = size
	%Cover.scale = size 
	
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	
	%CollisionShape2D.shape = shape
	%CollisionShape2D2.shape = shape
	
	%Label.custom_minimum_size = size
	%Label.size = size
	
	%Label.text = "[shake rate=%.2f][center] %s" % [dynamic + 0.1 * 20.0, text]
	%Label2.text = (text + " ").repeat(32)
	%Label2.custom_minimum_size = size
	%Label2.size = size
	%Label2.modulate = color
	#%Label2.modulate.a = 0.3
	%Label2.visible = false
	%Sprite2D.modulate = color
	%Sprite2D.modulate.a = 0.6

func move_to(new_position: Vector2) -> void:
	%Area2D.global_position = new_position

func actual_move_to(new_position: Vector2) -> void:
	p = new_position
	r = true

func disable() -> void:
	%CollisionShape2D.disabled = true
	freeze = true

func enable() -> void:
	%CollisionShape2D.disabled = false
	freeze = false
	sleeping = false

func spawn() -> void:
	%AnimationPlayer.stop()
	%Area2D.rotation = 0
	%Area2D.scale = Vector2(1, 1)
	%SpawnParticles.set_deferred("emitting", true)
	%PopSound.play()
