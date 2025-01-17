class_name WheelSuspensionParameters
extends Resource

@export var tire_model := BaseTireModel.new()
@export var spring_length := 0.15
@export var spring_stiffness := 45000.0
@export var bump := 10000.0
@export var rebound := 11000.0
@export var wheel_mass := 20.0 # Including brake disc and drive shaft
@export var ackermann := 0.15
@export var anti_roll := 50.0
