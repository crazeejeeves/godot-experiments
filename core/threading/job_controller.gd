class_name JobController
extends Node


signal job_completed(result)


@export_range(1, 16) var thread_pool_size: int = 4

var _thread_pool: Array[Thread]
var _thread_semaphore: Semaphore = null
var _is_pool_active: bool = false
var _is_pool_shutting_down: bool = false

var _job_queue: SafeQueue = null



func _ready() -> void:
    _job_queue = SafeQueue.new()
    _thread_semaphore = Semaphore.new()

    _initialize_thread_pool()


func run(callback: Callable, params: Array) -> void:
    var job = Job.new(callback, params)
    _job_queue.push(job)

    if not _is_pool_active:
        _warmup_pool()

    _thread_semaphore.post()


func shutdown() -> void:
    if _is_pool_shutting_down:
        return

    _is_pool_shutting_down = true
    for t in _thread_pool:
        _thread_semaphore.post()


func _initialize_thread_pool() -> void:
    _thread_pool = []

    assert(thread_pool_size >= 1)
    for i in range(0, thread_pool_size):
        _thread_pool.append(Thread.new())


func _warmup_pool() -> void:
    var index: int = 0

    for t in _thread_pool:
        var thread_callback: Callable = self._thread_execute.bind(index)
        #thread_callback.bind(index)
        t.start(thread_callback)
        index += 1

    _is_pool_active = true


func _wait_for_threads() -> void:
    print("Waiting for thread pool to shutdown...")

    for t in _thread_pool:
        if t.is_alive():
            t.wait_to_finish()

    print("Thread pool shutdown completed")


func _notification(what: int) -> void:
    match(what):
        NOTIFICATION_PREDELETE:
            shutdown()
            _wait_for_threads()


func _thread_execute(id: int) -> void:
    print("Thread(%s) started" % id)

    while not _is_pool_shutting_down:
        print("Thread(%s) picked up a job" % id)
        _thread_semaphore.wait()
        if _is_pool_shutting_down:
            break

        var job = _job_queue.pop() as Job
        var result = null

        if job:
            result = job._execute()
            call_deferred("_job_completed", job, result)
            print("Thread(%s) completed a job" % id)

    print("Thread(%s) execution closed" % id)


func _job_completed(_job: Job, result) -> void:
    job_completed.emit(result)


class Job:
    var _callback: Callable
    var _params: Array

    func _init(callback, params):
        _callback = callback
        _params = params

    func _execute():
        return _callback.callv(_params)
