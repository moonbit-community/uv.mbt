///|
test "open" {
  let content = @sync.Path::new("moon.mod.json").open().read_text(encoding=UTF8)
    |> @json.parse()
  assert_true(content is Object({ "name": "tonyfettes/uv", .. }))
}

///|
test "read" {
  let content = @sync.Path::new("moon.mod.json").read_text(encoding=UTF8)
    |> @json.parse()
  assert_true(content is Object({ "name": "tonyfettes/uv", .. }))
}

///|
test "write" {
  let path = @sync.Path::new(["test", "fixtures", "example_write.txt"])
  assert_false(path.exists())
  path.write_text("Hello, world!", encoding=UTF8)
  assert_true(path.exists())
  inspect(path.read_text(encoding=UTF8), content="Hello, world!")
  path.unlink()
  assert_false(path.exists())
}

///|
test "write/stdio" {
  @sync.stdout.write_text("Hello, world!\n", encoding=UTF8)
}

///|
test "scandir" {
  @json.inspect(@sync.Path::new(["test", "fixtures"]).iter().collect(), content=[
    "test/fixtures/example.txt",
  ])
}

///|
test "copy_to/file" {
  let src = @sync.Path::new(["test", "fixtures", "example.txt"])
  assert_true(src.exists())
  let dst = @sync.Path::new(["test", "fixtures", "example_copy.txt"])
  assert_false(dst.exists())
  try {
    src.copy_to(dst)
    assert_true(dst.is_file())
    dst.unlink()
  } catch {
    error => {
      dst.unlink()
      raise error
    }
  }
}

///|
test "copy_to/directory" {
  let src = @sync.Path::new("src")
  let dst = @sync.Path::new("src_copy")
  src.copy_to(dst, recursive=true)
  assert_true(dst.is_dir())
  assert_true(dst.iter().collect().length() > 0)
  dst.remove(recursive=true)
}
