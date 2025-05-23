///|
test "open" {
  let moon_mod_json = @sync.path!("moon.mod.json").read_text!()
    |> @json.parse!()
  assert_true!(moon_mod_json is Object({ "name": "tonyfettes/uv", .. }))
  inspect!(
    @sync.path!("README.md").read_text!().split("\n").peek().unwrap(),
    content="# tonyfettes/uv",
  )
}
