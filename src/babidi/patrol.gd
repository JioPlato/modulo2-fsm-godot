extends State

var _index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enter() -> void:
	agent.set_body_color(LabPalette.PATRULHAR)

func execute(_delta: float) -> void:
	if agent.sensor.can_see():
		go(&"chase")
		return
	if agent.patrol_points.is_empty():
		agent.stop()
		return
	var destino := agent.patrol_points[_index]
	if agent.global_position.distance_to(destino) < 12.0:
		_index = (_index + 1) % agent.patrol_points.size()
		destino = agent.patrol_points[_index]
	agent.move_towards(destino)
	
