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
test "ip4_addr" {
  ignore(@uv.ip4_addr("127.0.0.1", 8080))
}

///|
test "ip6_addr" {
  ignore(@uv.ip6_addr("::1", 8080))
}

///|
test "ip4_name" {
  let addr = @uv.ip4_addr("127.0.0.1", 8080)
  inspect(addr.ip_name(), content="127.0.0.1")
}

///|
test "ip6_name" {
  let addr = @uv.ip6_addr("::1", 8080)
  inspect(addr.ip_name(), content="::1")
}
