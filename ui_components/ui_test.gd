extends Control

@onready var dialog: UIBaseDialog = $dialog


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    dialog.title = "The Magic Box"
    dialog.ok_pressed.connect(on_ok)
    dialog.apply_pressed.connect(on_apply)

    var temp: PackedScene = load("res://ui_components/test_content.tscn")
    dialog.add_content(temp.instantiate())


func _process(_delta: float) -> void:
    pass


func on_ok():
    print("OK")

func on_apply():
    print("Apply")
