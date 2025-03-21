///|
type Idle Bytes

///|`
pub fn idle_to_handle(idle : Idle) -> Handle = "%identity"

///|
pub extern "c" fn idle_alloc() -> Idle = "moonbit_uv_idle_alloc"

///|
pub extern "c" fn idle_init(loop_ : Loop, idle : Idle) -> Int = "moonbit_uv_idle_init"

///|
pub extern "c" fn idle_start(idle : Idle, cb : (Idle) -> Unit) -> Int = "moonbit_uv_idle_start"

///|
pub extern "c" fn idle_stop(idle : Idle) -> Int = "moonbit_uv_idle_stop"
