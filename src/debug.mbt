///|
extern "c" fn uv_print_all_handles(uv : Loop, fd : Int) -> Unit = "moonbit_uv_print_all_handles"

///|
pub fn Loop::print_all_handles(self : Loop, file : File) -> Unit {
  uv_print_all_handles(self, file.inner())
}
