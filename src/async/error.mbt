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
pub suberror FileSystemError {
  AlreadyExists(Path)
  IsDirectory(Path)
  NotDirectory(Path)
  NotEmpty(Path)
  NotFound(Path)
  NotSupported(String)
  Unknown(@uv.Errno)
}

///|
impl Show for FileSystemError with output(
  self : FileSystemError,
  logger : &Logger
) -> Unit {
  match self {
    AlreadyExists(path) =>
      logger.write_string("AlreadyExists: \{path.to_string()}")
    IsDirectory(path) => logger.write_string("IsDirectory: \{path.to_string()}")
    NotDirectory(path) =>
      logger.write_string("NotDirectory: \{path.to_string()}")
    NotEmpty(path) => logger.write_string("NotEmpty: \{path.to_string()}")
    NotFound(path) => logger.write_string("NotFound: \{path.to_string()}")
    NotSupported(message) => logger.write_string("NotSupported: \{message}")
    Unknown(errno) => logger.write_string("Unknown: \{errno.to_string()}")
  }
}

///|
priv type StackTrace @deque.T[SourceLoc]

///|
priv struct Context {
  stack_trace : StackTrace
  error_trace : StackTrace
}

///|
async fn[T, E : Error] Context::backtrace(
  self : Context,
  loc~ : SourceLoc,
  f : async () -> T raise E
) -> T raise E {
  self.stack_trace.inner().push_back(loc)
  try {
    let value = f()
    self.stack_trace.inner().pop_back() |> ignore()
    value
  } catch {
    error => {
      self.stack_trace.inner().pop_back() |> ignore()
      self.error_trace.inner().push_back(loc)
      raise error
    }
  }
}

///|
let context : Ref[Context] = Ref::new({
  stack_trace: @deque.new(),
  error_trace: @deque.new(),
})

///|
pub async fn[T, E : Error] backtrace(
  loc~ : SourceLoc = _,
  f : async () -> T raise E
) -> T raise E {
  context.val.backtrace(loc~, f)
}

///|
impl Show for StackTrace with output(self : StackTrace, logger : &Logger) -> Unit {
  let trace = self.inner()
  logger.write_string("Trace:\n")
  let uv = try? uv()
  let cwd = try? @uv.cwd()
  guard uv is Ok(uv) && cwd is Ok(cwd) else {
    for i = trace.length() - 1; i >= 0; i = i - 1 {
      let loc = trace[i].to_string()
      logger.write_string("  \{loc}\n")
    }
  }
  fn write_file_content(file : Path, start_row : @string.View) raise {
    let start_row = @strconv.parse_int(start_row.to_string())
    let content = StringBuilder::new()
    let decoder = @encoding.decoder(UTF8)
    let buffer = Bytes::make(1024, 0)
    let file = uv.fs_open_sync(
      file.to_string(),
      @uv.OpenFlags::read_only(),
      0o644,
    )
    for count = uv.fs_read_sync(file, [buffer[:]])
        count > 0
        count = uv.fs_read_sync(file, [buffer[:]]) {
      decoder.decode_to(buffer[:count], content, stream=true)
    }
    let content = content.to_string()
    let lines = content.split("\n").collect()
    logger.write_string("  \{lines[start_row - 1]}\n")
  }

  for i = trace.length() - 1; i >= 0; i = i - 1 {
    let loc = trace[i].to_string()
    guard loc.to_string().split(":").collect()
      is [.. file_parts, start_row, start_column_end_row, end_column] else {
      logger.write_string("  \{loc}\n")
      continue
    }
    let file = Path::new(file_parts)
    let file = file.relative_to(cwd)
    let vscode = try (env["TERM_PROGRAM"] is "vscode") catch {
      _ => false
    }
    if vscode &&
      start_column_end_row.split("-").collect() is [start_column, end_row] {
      if start_row == end_row {
        logger.write_string(
          "  \{file.to_string()}:\{start_row}:\{start_column}-\{end_column}\n",
        )
      } else {
        logger.write_string(
          "  \{file.to_string()}:\{start_row}:\{start_column}-\{end_row}.\{end_column}\n",
        )
      }
    } else {
      logger.write_string(
        "  \{file.to_string()}:\{start_row}:\{start_column_end_row}:\{end_column}\n",
      )
    }
    write_file_content(file, start_row) catch {
      e => {
        logger.write_string("  (error processing source location: \{e})")
        continue
      }
    }
  }
}

///|
pub fn backtrace_to_string() -> String {
  let logger = StringBuilder::new()
  context.val.error_trace.output(logger)
  logger.to_string()
}
