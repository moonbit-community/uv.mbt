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
pub(all) enum ProcessInput {
  Ignore
  Stdin
  Pipe(Pipe)
  Inherit(File)
}

///|
pub(all) enum ProcessOutput {
  Ignore
  Stdout
  Stderr
  Pipe(Pipe)
  Inherit(File)
}

///|
struct Process {
  mut process : @uv.Process?
  mut stdin : Pipe?
  mut stdout : Pipe?
  mut stderr : Pipe?
  mut status : Int?
  mut signal : Int?
  resolve : @queue.T[(Unit) -> Unit]
}

///|
pub async fn Process::wait(self : Process) -> Unit {
  guard self.process is Some(_) else { return }
  if self.status is None {
    async_suspend(resolve => self.resolve.push(resolve))
  }
  self.process = None
}

///|
pub async fn Process::status(self : Process) -> Int {
  guard self.status is Some(status) else {
    self.wait()
    guard self.status is Some(status)
    status
  }
  status
}

///|
pub async fn Process::signal(self : Process) -> Int {
  guard self.signal is Some(signal) else {
    self.wait()
    guard self.signal is Some(signal)
    signal
  }
  signal
}

///|
fn Process::new() -> Process {
  {
    process: None,
    stdin: None,
    stdout: None,
    stderr: None,
    resolve: @queue.new(),
    status: None,
    signal: None,
  }
}

///|
fn Process::setup_stdin(
  self : Process,
  stdin : ProcessInput,
  stdio : Array[@uv.StdioContainer]
) -> Unit {
  match stdin {
    Ignore => stdio.push(@uv.StdioContainer::ignore())
    Inherit(file) => stdio.push(@uv.StdioContainer::inherit_file(file.inner()))
    Pipe(pipe) => {
      stdio.push(@uv.StdioContainer::create_pipe(pipe.inner(), readable=true))
      self.stdin = Some(pipe)
    }
    Stdin => stdio.push(@uv.StdioContainer::inherit_file(@uv.stdin()))
  }
}

///|
fn Process::setup_stdout(
  self : Process,
  stdout : ProcessOutput,
  stdio : Array[@uv.StdioContainer]
) -> Unit {
  match stdout {
    Ignore => stdio.push(@uv.StdioContainer::ignore())
    Inherit(file) => stdio.push(@uv.StdioContainer::inherit_file(file.inner()))
    Pipe(pipe) => {
      stdio.push(@uv.StdioContainer::create_pipe(pipe.inner(), writable=true))
      self.stdout = Some(pipe)
    }
    Stdout => stdio.push(@uv.StdioContainer::inherit_file(@uv.stdout()))
    Stderr => stdio.push(@uv.StdioContainer::inherit_file(@uv.stderr()))
  }
}

///|
pub fn Process::setup_stderr(
  self : Process,
  stderr : ProcessOutput,
  stdio : Array[@uv.StdioContainer]
) -> Unit {
  match stderr {
    Ignore => stdio.push(@uv.StdioContainer::ignore())
    Inherit(file) => stdio.push(@uv.StdioContainer::inherit_file(file.inner()))
    Pipe(pipe) => {
      stdio.push(@uv.StdioContainer::create_pipe(pipe.inner(), writable=true))
      self.stderr = Some(pipe)
    }
    Stderr => stdio.push(@uv.StdioContainer::inherit_file(@uv.stderr()))
    Stdout => stdio.push(@uv.StdioContainer::inherit_file(@uv.stdout()))
  }
}

///|
pub fn Process::stdin(self : Process) -> Pipe raise {
  guard self.stdin is Some(stdin) else { raise ValueError::NotFound("stdin") }
  stdin
}

///|
pub fn Process::stdout(self : Process) -> Pipe raise {
  guard self.stdout is Some(stdout) else {
    raise ValueError::NotFound("stdout")
  }
  stdout
}

///|
pub fn Process::stderr(self : Process) -> Pipe raise {
  guard self.stderr is Some(stderr) else {
    raise ValueError::NotFound("stderr")
  }
  stderr
}

///|
pub fn Process::kill(self : Process, signum : Signum) -> Unit raise Error {
  guard self.process is Some(process)
  let signum = match signum {
    SIGHUP => @uv.Signum::sighup()
    SIGINT => @uv.Signum::sigint()
    SIGQUIT => @uv.Signum::sigquit()
    SIGABRT => @uv.Signum::sigabrt()
    SIGTERM => @uv.Signum::sigterm()
    SIGWINCH => @uv.Signum::sigwinch()
    SIGPIPE => @uv.Signum::sigpipe()
  }
  process.kill(signum)
}

///|
trait Executable {
  spawn(
    Self,
    Array[@string.View],
    cwd~ : Path?,
    stdin~ : ProcessInput,
    stdout~ : ProcessOutput,
    stderr~ : ProcessOutput,
  ) -> Process raise Error
}

///|
pub impl Executable for String with spawn(
  self : String,
  args : Array[@string.View],
  cwd~ : Path?,
  stdin~ : ProcessInput,
  stdout~ : ProcessOutput,
  stderr~ : ProcessOutput
) -> Process raise Error {
  let uv = uv()
  let args : Array[@string.View] = [
      self,
      ..args.map(fn(arg) { arg.to_string().view() }),
    ]
  let cwd = cwd.map(fn(cwd) { cwd.to_string().view() })
  let process = Process::new()
  let stdio = []
  process.setup_stdin(stdin, stdio)
  process.setup_stdout(stdout, stdio)
  process.setup_stderr(stderr, stdio)
  let options = @uv.ProcessOptions::new(self, args, stdio~, cwd?, fn(
    _,
    exit_status,
    term_signal
  ) {
    process.status = Some(exit_status.to_int())
    process.signal = Some(term_signal)
    if process.process is Some(child) {
      child.close(_ => while process.resolve.pop() is Some(resolve) {
        resolve(())
      })
    }
  })
  process.process = Some(uv.spawn(options))
  process
}

///|
pub impl Executable for Path with spawn(
  self : Path,
  args : Array[@string.View],
  cwd~ : Path?,
  stdin~ : ProcessInput,
  stdout~ : ProcessOutput,
  stderr~ : ProcessOutput
) -> Process raise Error {
  self.to_string() |> Executable::spawn(args, cwd~, stdin~, stdout~, stderr~)
}

///|
pub async fn[Exec : Executable] spawn(
  exec : Exec,
  args : Array[@string.View],
  cwd? : &ToPath,
  stdin~ : ProcessInput = Ignore,
  stdout~ : ProcessOutput = Ignore,
  stderr~ : ProcessOutput = Ignore
) -> Process raise {
  exec.spawn(args, cwd=cwd.map(_.to_path()), stdin~, stdout~, stderr~)
}
