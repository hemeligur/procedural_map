extends Sprite


export var size:int

export var map_seed:int

export var water_level = -0.3
var sand_level_bot: float
var sand_level_top: float
var grass_level_bot: float
var grass_level_top: float
var dirt_level_bot: float
var dirt_level_top: float
var mountain_level_bot: float
var mountain_level_top: float
var snow_level_bot: float

var noise_map
var noise: OpenSimplexNoise

var max_noise_value = -9999.9
var min_noise_value = 9999.9
var max_img_value = -9999.9
var min_img_value = 9999.9


func _ready() -> void:
    randomize()
    $"../GUIMarginContainer/ButtonsContainer/WaterLevelSlider".value = self.water_level
    $"../GUIMarginContainer/ButtonsContainer/WaterLevelSpinBox".value = self.water_level
    generate_map()


func generate_map() -> void:
    self.snow_level_bot = 0.9
    self.sand_level_bot = self.water_level
    self.sand_level_top = self.sand_level_bot + 0.09
    self.grass_level_bot = self.sand_level_top
    self.grass_level_top = self.grass_level_bot + 0.5
    self.dirt_level_bot = self.grass_level_top
    self.mountain_level_top = self.snow_level_bot
    self.mountain_level_bot = self.mountain_level_top - 0.3
    self.dirt_level_top = max(self.dirt_level_bot + 0.2, self.mountain_level_bot)
    
    var viewport_size = get_viewport().size
    self.size = min(viewport_size.x, viewport_size.y) * 0.9
    
    setup_noise_image(true)
    var base_img = set_base_img()
    set_sprite_texture(base_img)
    
    print("###################")
    print("Sand bot:", sand_level_bot)
    print("Sand top:", sand_level_top)
    print("Grass bot:", grass_level_bot)
    print("Grass top:", grass_level_top)
    print("Dirt bot:", dirt_level_bot)
    print("Dirt top:", dirt_level_top)
    print("Mountain bot:", mountain_level_bot)
    print("Mountain top:", mountain_level_top)
    print("Max noise:", max_noise_value)
    print("Min noise:", min_noise_value)
    print("Max img:", max_img_value)
    print("Min img:", min_img_value)
    


func set_sprite_texture(base_img: Image) -> void:
    var map_texture = ImageTexture.new()
    map_texture.create_from_image(base_img)
    self.texture = map_texture
    
    var position = get_viewport().size/2
    self.position = position


func set_base_img() -> Image:
    var img = Image.new()
    img.create(self.size, self.size, false, Image.FORMAT_RGBA8)
    img.lock()
    for x in range(img.get_width()):
        for y in range(img.get_height()):
            var altitude = get_map_noise(x,y)
            
            self.min_img_value = min(self.min_img_value, altitude)
            self.max_img_value = max(self.max_img_value, altitude)
            
            var color = get_altitude_color(altitude)
            img.set_pixel(x, y, color)
    img.unlock()
    
    return img


func setup_noise_image(on_the_fly=false, generate_seamless_img=false) -> void:
    self.noise = OpenSimplexNoise.new()
    
#   seed [padrão: 0]
#   octaves [padrão: 3]
#   period [padrão: 64.0]
#   persistence [padrão: 0.5]
#   lacunarity [padrão: 2.0]

    self.noise.seed = self.map_seed
    self.noise.octaves = 5
    self.noise.period = 64.0
    self.noise.persistence = 0.5
    self.noise.lacunarity = 2.0
    
    if generate_seamless_img:
        self.noise_map = noise.get_seamless_image(self.size)
    elif not on_the_fly:
        self.noise_map = []
        self.noise_map.resize(pow(self.size, 2))
        
        for i in range(self.size):
            for j in range(self.size):
                self.noise_map[i*self.size+j] = self.noise.get_noise_2d(i, j)
        
        self.max_noise_value = self.noise_map.max()
        self.min_noise_value = self.noise_map.min()


func get_map_noise(x:int, y:int) -> float:
    var value
    if self.noise_map != null:
        if self.noise_map is Image:
                self.noise_map.lock()
                value = self.noise_map.get_pixel(x, y).gray()
                self.noise_map.unlock()
        elif self.noise_map is Array:
                value = self.noise_map[x*self.size+y]
                value = normalize_value(self.max_noise_value, self.min_noise_value, value)
    else:
        value = self.noise.get_noise_2d(x, y)
    
    return value


func normalize_value(max_value: float, min_value: float, value: float) -> float:
    var normalized_value = 2 / (max_value - min_value) * (value - max_value) + 1
    return normalized_value


func get_altitude_color(altitude: float) -> Color:
    var color
    if altitude <= self.water_level:
        color = Color.aqua
    elif altitude >= self.sand_level_bot and altitude <= self.sand_level_top:
        color = Color.sandybrown
    elif altitude >= self.grass_level_bot and altitude <= self.grass_level_top:
        color = Color.webgreen
    elif altitude >= self.dirt_level_bot and altitude <= self.dirt_level_top:
        color = Color.chocolate
    elif altitude >= self.mountain_level_bot and altitude <= self.mountain_level_top:
        color = Color.webgray
    elif altitude >= self.snow_level_bot:
        color = Color.snow
    else:
        color = Color.black
    
    return color


func _on_RefreshButton_pressed() -> void:
    generate_map()


func _on_NewMapButton_pressed() -> void:
    map_seed = randi()
    generate_map()


func _on_WaterLevelSlider_value_changed(value: float) -> void:
    self.water_level = value
    $"../GUIMarginContainer/ButtonsContainer/WaterLevelSpinBox".value = value


func _on_SpinBox_value_changed(value: float) -> void:
    self.water_level = value
    $"../GUIMarginContainer/ButtonsContainer/WaterLevelSlider".value = value
