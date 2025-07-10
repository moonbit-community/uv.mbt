///|
test {
  @mygo.start(() => try {
    try {
      for path in @mygo.Path::new("test/fixtures").iter() {
        if path.name() is Some("example.txt") {
          raise @uv.ENOTDIR
        }
      }
    } catch {
      e => {
        println("for: \{e}")
        raise e
      }
    }
  } catch {
    e => println("Error: \{e}")
  })
}
