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
test "FsPoll" {
  if @uv.os_getenv("CI") is Some("true") {
    return
  }
  let uv = @uv.Loop::new()
  let fs_poll = @uv.FsPoll::new(uv)
  let errors : Array[Error] = []
  let events : Array[(Stat, Stat)] = []
  fs_poll.start(
    "test/fixtures/",
    1000,
    fn(_, prev, curr) { events.push((prev, curr)) },
    fn(_, errno) {
      errors.push(errno)
      fs_poll.stop() catch {
        e => errors.push(e)
      }
      fs_poll.close(() => ())
    },
  )
  @assert.eq(fs_poll.get_path(), "test/fixtures/")
  uv.fs_open(
    "test/fixtures/test_poll.txt",
    @uv.OpenFlags::write_only(create=true),
    0o644,
    file => try
      uv.fs_write(
        file,
        [b"Hello, fs_poll!"],
        _ => try
          uv.fs_close(
            file,
            () => try
              uv.fs_unlink("test/fixtures/test_poll.txt", () => (), e => errors.push(
                e,
              ))
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
  let timer = @uv.Timer::new(uv)
  timer.start(timeout=2000, repeat=0, _ => {
    timer.stop() catch {
      e => errors.push(e)
    }
    timer.close(() => {
      fs_poll.stop() catch {
        e => errors.push(e)
      }
      fs_poll.close(() => ())
    })
  })
  uv.run(Default)
  uv.stop()
  uv.close()
  for e in errors {
    raise e
  }
  assert_true(events.length() > 0)
}
