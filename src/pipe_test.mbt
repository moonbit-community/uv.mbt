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
test "Pipe::connect" {
  let path : Bytes = if @uv.os_uname().sysname() is "Windows_NT" {
    "\\\\?\\pipe\\uv-mbt-test-pipe-connect.sock"
  } else {
    "/tmp/uv-mbt-test-pipe-connect.sock"
  }
  let uv = @uv.Loop::new()
  let server = @uv.Pipe::new(uv, ipc=false) catch {
    error => {
      uv.close()
      raise error
    }
  }
  server.bind(path, @uv.PipeBindFlags::new(truncate=true)) catch {
    error => {
      server.close(() => ())
      uv.close()
      raise error
    }
  }
  let errors : Array[Error] = []
  server.listen(
    128,
    server => try {
      let client = @uv.Pipe::new(server.loop_(), ipc=false)
      @uv.accept(server, client) catch {
        error => {
          client.close(() => ())
          raise error
        }
      }
      client.read_start(
        (_, _) => Bytes::make(1024, 0),
        (_, nread, bytes) => {
          try
            client.write([bytes[:nread]], () => (), error => errors.push(error))
            |> ignore()
          catch {
            error => errors.push(error)
          }
          client.read_stop() catch {
            error => errors.push(error)
          }
          client.close(() => ())
        },
        (_, error) => errors.push(error),
      )
    } catch {
      error => errors.push(error)
    },
    (_, error) => errors.push(error),
  )
  let client = @uv.Pipe::new(uv, ipc=false) catch {
    error => {
      server.close(() => ())
      uv.close()
      raise error
    }
  }
  client.connect(
    path,
    () => try
      client.write(
        ["Hello, world!"],
        () => client.read_start(
          (_, _) => Bytes::make(1024, 0),
          (_, nread, bytes) => {
            let received = bytes[:nread]
            @json.inspect(received.to_bytes(), content="Hello, world!") catch {
              error => errors.push(error)
            }
            client.read_stop() catch {
              error => errors.push(error)
            }
            client.close(() => server.close(() => ()))
          },
          (_, error) => errors.push(error),
        ) catch {
          error => errors.push(error)
        },
        error => errors.push(error),
      )
      |> ignore()
    catch {
      error => errors.push(error)
    },
    error => errors.push(error),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  for error in errors {
    raise error
  }
}

///|
test "Pipe::chmod" {
  if @uv.os_uname().sysname() is "Windows_NT" {
    return
  }
  let path : Bytes = "/tmp/uv-mbt-test-pipe-chmod.sock"
  let uv = @uv.Loop::new()
  defer (uv.close() catch { _ => () })
  defer (uv.fs_unlink_sync(path) catch { _ => () })
  let server = @uv.Pipe::new(uv, ipc=false) catch {
    error => {
      uv.close()
      raise error
    }
  }
  server.bind(path, @uv.PipeBindFlags::new(truncate=true)) catch {
    error => {
      server.close(() => ())
      uv.close()
      raise error
    }
  }
  let stat = uv.fs_stat_sync(path)
  @json.inspect(stat.mode().to_string(radix=8), content="140755")
  server.chmod(Writable)
  let stat = uv.fs_stat_sync(path)
  @json.inspect(stat.mode().to_string(radix=8), content="140222")
  server.chmod(Readable)
  let stat = uv.fs_stat_sync(path)
  @json.inspect(stat.mode().to_string(radix=8), content="140444")
  server.chmod(ReadWrite)
  let stat = uv.fs_stat_sync(path)
  @json.inspect(stat.mode().to_string(radix=8), content="140666")
  server.close(() => ())
  uv.run(Default)
}
