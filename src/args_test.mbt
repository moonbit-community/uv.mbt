///|
test {
  ignore(@uv.args())
}

///|
fn[T : Show] println(value : T) -> Unit {
  if @uv.args()[1].split("/").collect() is [filename] &&
    filename.contains("__moonbit_internal_doc_test") {
    @builtin.println(value)
  }
}
