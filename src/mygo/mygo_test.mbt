///|
fn fs_scandir(uv : @uv.Loop, path : String) -> Iter[String] raise Error {
  @mygo.suspend((resolve, reject) => try
    uv.fs_scandir(
      path,
      0,
      scandir => resolve(
        Iter::new(fn(yield_) {
          while true {
            let dirent = scandir.next() catch { _ => break IterContinue }
            match yield_(dirent.name()) {
              IterEnd => break IterEnd
              IterContinue => continue
            }
          } else {
            IterContinue
          }
        }),
      ),
      e => reject(e),
    )
    |> ignore()
  catch {
    e => reject(e)
  })
}

///|
test {
  let uv = @uv.Loop::new()
  @mygo.run(() => {
    println("inside @mygo.run")
    try {
      for file in fs_scandir(uv, "test/fixtures") {
        println("Found file: \{file}")
      }
    } catch {
      e => println("Error opening file: \{e}")
    }
  })
  println("after @mygo.run")
  println("before uv.run")
  uv.run(Default)
  println("after uv.run")
  uv.close()
}
