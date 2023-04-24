class_name BaseTireModel
extends Resource

const TIRE_WEAR_CURVE = preload("res://resources/tire_wear_curve.tres")

@export var tire_stiffness := 0.5
@export var tire_width := 0.225
@export var tire_radius := 0.3
@export var tire_rated_load := 7000.0

# Possible input parameters for tire model
#export var tire_rated_pressure := 2.0

# Possible variables for force calculations
#var tire_pressure := 2.0
#var tire_ratio := 0.5
#var tire_rim_size := 16.0
#var pneumatic_trail = 0.03

var tire_wear := 0.0
var load_sensitivity := 1.0
#var tire_temperature := 20.0

var peak_sa := 0.12
var peak_sr := 0.09




# Override this
func update_tire_forces(_slip: Vector2, _normal_load: float, _surface_mu: float) -> Vector3:
	return Vector3.ZERO


func update_tire_wear(prev_wear: float, friction_power: float, delta: float):
	# From Speed Dreams wiki: https://sourceforge.net/p/speed-dreams/wiki/TireTempDeg
	var wear_rate := 0.000000015
	return prev_wear + friction_power * wear_rate * delta


func update_tire_temps(prev_temp: float, friction_power: float, speed: float, delta: float, ambient_temp := 20.0):
	# From Speed Dreams wiki: https://sourceforge.net/p/speed-dreams/wiki/TireTempDeg/
	# dT/SimDeltaTime = P * heatingm - aircoolm * (1 + speedcoolm * v) * (T-Tair)
	
	var tire_mass := 20.0
	var effective_heat_capacity := 2000.0 * tire_mass
	var heating_multiplier := 1 / effective_heat_capacity
	var tire_area := 2 * PI * tire_radius * tire_width
	var air_cooling_multiplier := 20.0 * tire_area / effective_heat_capacity
	var speed_cooling_multiplier :=  0.25
	
	var heating := friction_power * heating_multiplier
	var cooling: float = air_cooling_multiplier * (1 + speed_cooling_multiplier * abs(speed))
	
	var delta_temp := heating - cooling * (prev_temp - ambient_temp)
	delta_temp *= delta
#	delta_temp = clamp(delta_temp, -1, 1)
	
	prev_temp += delta_temp
	return prev_temp


func update_load_sensitivity(normal_load: float) -> float:
	var width_factor = tire_width / 0.225
	var max_mu = 2.0 - tire_stiffness * 0.9 + width_factor * 0.5 - 0.5
	var min_mu = 0.6 + tire_stiffness * 0.35 + width_factor * 0.5 - 0.5
	var load_factor = clamp(normal_load / tire_rated_load, 0.0, 1.0)
#	load_factor = clamp(load_factor, 0.0, 1.0)
	load_sensitivity = clamp(min_mu + (1 - load_factor) * (max_mu - min_mu), min_mu, max_mu)
#	print_debug(load_sensitivity)
	return load_sensitivity
