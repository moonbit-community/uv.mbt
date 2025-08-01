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
test "fs_event" {
  let uv = @uv.Loop::new()
  let fs_event = @uv.FsEvent::new(uv)
  let errors : Array[Error] = []
  let events : Array[(String?, Array[FsEventType])] = []
  fs_event.start(
    "test/fixtures/",
    FsEventFlags::new(),
    fn(_, name, types) { events.push((name, types)) },
    fn(_, _, errno) {
      errors.push(errno)
      fs_event.stop() catch {
        e => errors.push(e)
      }
      fs_event.close(() => ())
    },
  )
  uv.fs_open(
    "test/fixtures/test.txt",
    @uv.OpenFlags::write_only(create=true),
    0o644,
    file => try
      uv.fs_write(
        file,
        [b"Hello, world!"],
        _ => try
          uv.fs_close(
            file,
            () => try
              uv.fs_unlink(
                "test/fixtures/test.txt",
                () => try {
                  let timer = @uv.Timer::new(uv)
                  timer.start(timeout=100, repeat=0, _ => {
                    timer.stop() catch {
                      e => errors.push(e)
                    }
                    timer.close(() => {
                      fs_event.stop() catch {
                        e => errors.push(e)
                      }
                      fs_event.close(() => ())
                    })
                  })
                } catch {
                  e => errors.push(e)
                },
                e => errors.push(e),
              )
              |> ignore()
            catch {
              e => errors.push(e)
            },
            e => errors.push(e),
          )
          |> ignore()
        catch {
          e => errors.push(e)
        },
        e => errors.push(e),
      )
      |> ignore()
    catch {
      e => errors.push(e)
    },
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  for e in errors {
    raise e
  }
  assert_true(
    events.search_by(fn(event) {
      let (file, _) = event
      file is Some("test.txt")
    })
    is Some(_),
  )
}
