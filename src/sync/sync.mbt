///|
pub fn[T] backtrace(
  loc~ : SourceLoc = _,
  f : () -> T raise Error
) -> T raise Error {
  f() catch {
    SystemError(_, trace) as system_error => {
      trace.push(loc)
      raise system_error
    }
    error => raise error
  }
}

///|
priv enum ErrorInfo {
  Exists(&ToPath)
  IsDirectory(&ToPath)
  NotEmpty(&ToPath)
  NotFound(&ToPath)
  NotSupported(&ToPath)
} derive(ToJson(repr(ext_tagged)))

///|
impl Show for ErrorInfo with output(self : ErrorInfo, logger : &Logger) -> Unit {
  match self {
    Exists(path) => logger.write_string("Exists: \{path.to_string()}")
    IsDirectory(path) => logger.write_string("IsDirectory: \{path.to_string()}")
    NotEmpty(path) => logger.write_string("NotEmpty: \{path.to_string()}")
    NotFound(path) => logger.write_string("NotFound: \{path.to_string()}")
    NotSupported(path) =>
      logger.write_string("NotSupported: \{path.to_string()} is not supported")
  }
}

///|
impl Show for SystemError with output(self : SystemError, logger : &Logger) -> Unit {
  let SystemError(value, trace) = self
  logger.write_string("Trace:\n")
  let uv = try? uv()
  let cwd = try? @uv.cwd()
  guard uv is Ok(uv) && cwd is Ok(cwd) else {
    for i = trace.length() - 1; i >= 0; i = i - 1 {
      let loc = trace[i].to_string()
      logger.write_string("  \{loc}\n")
    }
    logger.write_string(value.to_string())
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
    for nread = uv.fs_read_sync(file, [buffer[:]])
        nread > 0
        nread = uv.fs_read_sync(file, [buffer[:]]) {
      decoder.decode_to(buffer[:nread], content, stream=true)
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
    logger.write_string(
      "  \{file.to_string()}:\{start_row}:\{start_column_end_row}:\{end_column}\n",
    )
    write_file_content(file, start_row) catch {
      e => {
        logger.write_string("  (error processing source location: \{e})")
        continue
      }
    }
  }
  logger.write_string(value.to_string())
}

///|
priv suberror SystemError {
  SystemError(ErrorInfo, Array[SourceLoc])
}

///|
fn SystemError::new(
  value : ErrorInfo,
  trace~ : Array[SourceLoc] = [],
  loc~ : SourceLoc = _
) -> SystemError {
  SystemError(value, [loc, ..trace])
}

///|
fn SystemError::exists(
  path : &ToPath,
  loc~ : SourceLoc = _,
  caller? : SourceLoc
) -> SystemError {
  let locs = [loc]
  if caller is Some(caller) {
    locs.push(caller)
  }
  SystemError(Exists(path), locs)
}

///|
fn SystemError::is_directory(
  path : &ToPath,
  loc~ : SourceLoc = _
) -> SystemError {
  SystemError(IsDirectory(path), [loc])
}

///|
fn SystemError::not_empty(path : &ToPath, loc~ : SourceLoc = _) -> SystemError {
  SystemError(NotEmpty(path), [loc])
}

///|
fn SystemError::not_found(path : &ToPath, loc~ : SourceLoc = _) -> SystemError {
  SystemError(NotFound(path), [loc])
}

///|
fn SystemError::not_supported(
  self : &ToPath,
  loc~ : SourceLoc = _
) -> SystemError {
  SystemError(NotSupported(self), [loc])
}

///|
let uv_ref : Ref[@uv.Loop?] = Ref::new(None)

///|
fn uv() -> @uv.Loop raise @uv.Errno {
  if uv_ref.val is Some(uv) {
    return uv
  }
  let uv = @uv.Loop::new()
  uv_ref.val = Some(uv)
  return uv
}
