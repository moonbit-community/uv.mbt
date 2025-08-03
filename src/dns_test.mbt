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
test "dns/ipv4" {
  let uv = @uv.Loop::new()
  let resolved = []
  let mut error = None
  uv.getaddrinfo(
    fn(infos) {
      try {
        for info in infos {
          resolved.push(info.addr().ip_name())
        }
      } catch {
        e => error = Some(e)
      }
    },
    fn(e) { error = Some(e) },
    "localhost",
    "http",
    hints=@uv.AddrInfoHints::new(
      protocol=@uv.Protocol::tcp(),
      flags=@uv.AddrInfoFlags::new(canonname=true),
      family=@uv.AddressFamily::inet(),
    ),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
  resolved.dedup()
  @assert.eq(resolved, ["127.0.0.1"])
}

///|
test "dns/ipv6" {
  let uv = @uv.Loop::new()
  let resolved = []
  let mut error = None
  uv.getaddrinfo(
    fn(infos) {
      try {
        for info in infos {
          resolved.push(info.addr().ip_name())
        }
      } catch {
        e => error = Some(e)
      }
    },
    fn(e) { error = Some(e) },
    "localhost",
    "http",
    hints=@uv.AddrInfoHints::new(
      protocol=@uv.Protocol::tcp(),
      flags=@uv.AddrInfoFlags::new(canonname=true),
      family=@uv.AddressFamily::inet6(),
    ),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
  resolved.dedup()
  @assert.eq(resolved, ["::1"])
}
