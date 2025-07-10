// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
