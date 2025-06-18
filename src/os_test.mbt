///|
test "tmpdir" {
  let tmpdir = @uv.os_tmpdir()
  println(tmpdir)
}
