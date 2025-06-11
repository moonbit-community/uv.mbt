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
