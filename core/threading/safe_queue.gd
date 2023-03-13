class_name SafeQueue
extends RefCounted

var _items: Array = []
var _mutex: Mutex = Mutex.new()


func push(obj: Object) -> void:
    _mutex.lock()
    _items.push_back(obj)
    _mutex.unlock()


func pop() -> Object:
    _mutex.lock()

    var item = null
    if !_items.is_empty():
        item = _items.pop_front()

    _mutex.unlock()

    return item


func size() -> int:
    return _items.size()
