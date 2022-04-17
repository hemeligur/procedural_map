extends Container


onready var viewport_size = get_viewport().size


func _ready() -> void:
    position_container()


func _process(_delta: float) -> void:
    if get_viewport().size != self.viewport_size:
        self.viewport_size = get_viewport().size
        position_container()


func position_container() -> void:
    self.rect_position = Vector2(viewport_size.x - 95, 15)
