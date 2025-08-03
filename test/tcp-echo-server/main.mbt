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

// TCP echo server implementation
//
// This server listens on port 7000 and echoes back any data received from
// clients. It demonstrates the use of MoonBit's uv library for asynchronous TCP
// networking.

///|
let default_port : Int = 7000

///|
let default_backlog : Int = 128

///|
fn echo_write() -> Unit {
  // Write completed successfully - no action needed
}

///|
fn echo_write_error(errno : @uv.Errno) -> Unit {
  println("Write error: \{(errno : Error)}")
}

///|
fn echo_read(client : @uv.Tcp, nread : Int, buf : @bytes.View) -> Unit {
  if nread > 0 {
    try client.write([buf], echo_write, echo_write_error) |> ignore() catch {
      error => println("Error echoing data: \{(error : Error)}")
    }
  }
}

///|
fn echo_read_error(client : @uv.Tcp, errno : @uv.Errno) -> Unit {
  if not(errno is EOF) {
    println("Read error: \{(errno : Error)}")
  }
  client.close(() => ())
}

///|
fn alloc_buffer(_ : @uv.Tcp, suggested_size : Int) -> @bytes.View {
  Bytes::make(suggested_size, 0)
}

///|
fn on_new_connection(server : @uv.Tcp) -> Unit {
  try {
    let client = @uv.Tcp::new(server.loop_())
    try {
      @uv.accept(server, client)
      client.read_start(alloc_buffer, echo_read, echo_read_error)
    } catch {
      error => {
        println("Error accepting new connection: \{(error : Error)}")
        client.close(() => ())
      }
    }
  } catch {
    error => println("Error accepting new connection: \{(error : Error)}")
  }
}

///|
fn on_connection_error(_ : @uv.Tcp, errno : @uv.Errno) -> Unit {
  println("New connection error: \{(errno : Error)}")
}

///|
fn main {
  try {
    let uv = @uv.Loop::new()
    let server = @uv.Tcp::new(uv)
    let addr = @uv.ip4_addr("0.0.0.0", default_port)
    server.bind(addr, @uv.TcpBindFlags::new())
    server.listen(default_backlog, on_new_connection, on_connection_error)
    println("TCP echo server listening on 0.0.0.0:\{default_port}")
    uv.run(Default)
    uv.close()
  } catch {
    error => println("Server error: \{(error : Error)}")
  }
}
