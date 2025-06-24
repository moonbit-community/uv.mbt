///|
test "tmpdir" {
  let uv = @uv.Loop::new()
  let tmpdir = @uv.os_tmpdir()
  let stat = uv.fs_stat_sync(tmpdir)
  @json.inspect(stat.type_(), content="dir")
  uv.close()
}

///|
test "exepath" {
  ignore(@uv.exepath())
}

///|
test "homedir" {
  let uv = @uv.Loop::new()
  let homedir = @uv.os_homedir()
  let stat = uv.fs_stat_sync(homedir)
  @json.inspect(stat.type_(), content="dir")
  uv.close()
}

///|
test "chdir" {
  let uv = @uv.Loop::new()
  let old_cwd = @uv.cwd()
  let dir = uv.fs_realpath_sync(old_cwd + "/test/fixtures")
  @uv.chdir("test/fixtures")
  let new_cwd = @uv.cwd()
  assert_eq(new_cwd, dir)
  @uv.chdir(old_cwd)
  uv.close()
}
