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
test "spawn: capture stdout and stderr" {
  @async.start(fn() {
    let stdout = @async.Pipe::new()
    let process = @async.spawn("moon", ["--help"], stdout=Pipe(stdout))
    @json.inspect(process.status(), content=0)
    inspect(
      stdout
      .read_text(encoding=UTF8)
      .split("\n")
      .peek()
      .or_error(Failure("No output")),
      content="The build system and package manager for MoonBit.",
    )
  })
}

///|
test "spawn: send stdin" {
  @async.start(fn() {
    if @async.system() != "Windows_NT" {
      let stdin = @async.Pipe::new()
      let stdout = @async.Pipe::new()
      let process = @async.spawn(
        "cat",
        [],
        stdin=Pipe(stdin),
        stdout=Pipe(stdout),
      )
      stdin.write_bytes("hello\n")
      stdin.close()
      @json.inspect(process.status(), content=0)
      @json.inspect(stdout.read_text(encoding=UTF8), content="hello\n")
    }
  })
}
