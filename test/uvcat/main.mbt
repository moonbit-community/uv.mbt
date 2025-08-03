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
let buffer : Bytes = Bytes::make(1024, 0)

///|
fn on_write(uv : @uv.Loop, file : @uv.File) -> Unit {
  try
    uv.fs_read(file, [buffer], on_read(uv, file, _), errno => println(
      "error reading file: \{(errno : Error)}",
    ))
    |> ignore()
  catch {
    errno => println("error reading file: \{(errno : Error)}")
  }
}

///|
fn on_read(uv : @uv.Loop, file : @uv.File, count : Int) -> Unit {
  if count == 0 {
    try
      uv.fs_close(file, () => (), fn(errno) {
        println("error closing file: \{(errno : Error)}")
      })
      |> ignore()
    catch {
      error => println("error closing file: \{(error : Error)}")
    }
  } else {
    try
      uv.fs_write(@uv.stdout(), [buffer[:count]], _ => on_write(uv, file), fn(
        errno,
      ) {
        println("error writing file: \{(errno : Error)}")
      })
      |> ignore()
    catch {
      error => println("error writing file: \{(error : Error)}")
    }
  }
}

///|
fn on_open(uv : @uv.Loop, file : @uv.File) -> Unit {
  try
    uv.fs_read(file, [buffer], fn(count) { on_read(uv, file, count) }, fn(
      errno,
    ) {
      println("error reading file: \{(errno : Error)}")
    })
    |> ignore()
  catch {
    error => println("error reading file: \{(error : Error)}")
  }
}

///|
fn main {
  try {
    let uv = @uv.Loop::new()
    let args = @uv.args()
    uv.fs_open(
      args[1],
      @uv.OpenFlags::read_only(),
      0,
      file => on_open(uv, file),
      errno => println("error opening file: \{(errno : Error)}"),
    )
    |> ignore()
    uv.run(Default)
    uv.close()
  } catch {
    error => println("error: \{(error : Error)}")
  }
}
