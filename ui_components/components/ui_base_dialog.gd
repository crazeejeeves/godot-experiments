class_name UIBaseDialog
extends Control


signal ok_pressed
signal cancel_pressed
signal apply_pressed
signal close_pressed


enum UIDialogActions {
    UIDA_CUSTOM = 0,
    UIDA_OK = 1,
    UIDA_CANCEL = 2,
    UIDA_APPLY = 4
}


@export var title: StringName = "Title":
    get:
        return title
    set(value):
        title = value
        %title.text = title

@export_flags("OK", "Cancel", "Apply") var action_flags: int = int(UIDialogActions.UIDA_OK)


@onready var _ui_title: Label = %title
#@onready var _ui_action_container: HBoxContainer = %action_container


func _ready():
    _ui_title.text = title
    _configure_default_actions()


func add_content(content: Control) -> void:
    if !content:
        return

    var prev_content: Control = %body.get_child(0)
    if prev_content:
        %body.remove_child(prev_content)

    %body.add_child(content)
    content.size_flags_horizontal = Control.SIZE_FILL
    content.size_flags_vertical = Control.SIZE_FILL


func _configure_default_actions() -> void:
    %action_ok.visible = bool(action_flags & UIDialogActions.UIDA_OK)
    %action_cancel.visible = bool(action_flags & UIDialogActions.UIDA_CANCEL)
    %action_apply.visible = bool(action_flags & UIDialogActions.UIDA_APPLY)

    _register_action(%action_ok, UIDialogActions.UIDA_OK, -1)
    _register_action(%action_cancel, UIDialogActions.UIDA_CANCEL, -1)
    _register_action(%action_apply, UIDialogActions.UIDA_APPLY, -1)


func _register_action(control: BaseButton, action_type: UIDialogActions, id: int, callback: Callable = _on_action_pressed) -> void:
    var bound_pressed_callback = callback.bind(action_type, id)
    control.pressed.connect(bound_pressed_callback)


func _on_action_pressed(action_type: UIDialogActions, _id: int) -> void:
    match(action_type):
        UIDialogActions.UIDA_OK:
            ok_pressed.emit()
        UIDialogActions.UIDA_CANCEL:
            cancel_pressed.emit()
        UIDialogActions.UIDA_APPLY:
            apply_pressed.emit()

