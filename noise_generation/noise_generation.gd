extends Node

@onready var noise_generator: FastNoiseLite = FastNoiseLite.new()

@export var noise_dimensions: Vector2 = Vector2(256, 256)
@export var noise_type: FastNoiseLite.NoiseType = FastNoiseLite.TYPE_SIMPLEX
@export var fractal_type: FastNoiseLite.FractalType = FastNoiseLite.FRACTAL_FBM
@export var noise_octaves: int = 4

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

const NOISE_TYPES: Array[String] = ["Simplex","Simplex Smooth","Cellular","Perlin","Value Cubic","Value"]
const FRACTAL_TYPES: Array[String] = ["None", "FBM", "Ridged", "Ping Pong"]

func _ready() -> void:
    rng.randomize()

    for i in NOISE_TYPES:
        %select_noisetype.add_item(i)
    %select_noisetype.item_activated.connect(on_noisetype_activated)
    
    for i in FRACTAL_TYPES:
        %select_fractaltype.add_item(i)
    %select_fractaltype.item_activated.connect(on_fractaltype_activated)
    
    
    generate_texture()


func generate_texture() -> void:
    if noise_generator == null:
        return

    
    noise_generator.seed = rng.randi_range(1000, 999999999)
    noise_generator.noise_type = noise_type
    noise_generator.fractal_type = fractal_type
    noise_generator.fractal_octaves = noise_octaves
    
    var noise_texture: NoiseTexture2D = NoiseTexture2D.new()
    noise_texture.noise = noise_generator
    await noise_texture.changed
    
    %preview.texture = noise_texture


func on_noisetype_activated(index: int) -> void:
    if index == -1:
        return
        
    noise_type = index
    generate_texture()


func on_fractaltype_activated(index: int) -> void:
    if index == -1:
        return
        
    fractal_type = index
    generate_texture()
