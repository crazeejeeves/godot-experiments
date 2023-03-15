extends Control

@onready var dialog: UIBaseDialog = $dialog


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    dialog.title = "This is a test to see how long it goes"
    dialog.ok_pressed.connect(on_ok)
    dialog.apply_pressed.connect(on_apply)


func _process(_delta: float) -> void:
    pass


func on_ok():
    print("OK")

func on_apply():
    print("Apply")
