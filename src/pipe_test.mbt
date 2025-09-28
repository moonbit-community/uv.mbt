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
