///|
struct Project {
  include : Array[@async.Path]
  source : @async.Path
  target : @async.Path
  prefix : @string.View
  copied : Set[@async.Path]
}

///|
fn Project::new(
  source : @async.Path,
  target : @async.Path,
  include~ : Array[@async.Path] = [],
  prefix~ : @string.View = ""
) -> Project {
  Project::{ include, source, target, prefix, copied: Set::new() }
}

///|
fn Project::mangle(self : Project, path : @async.Path) -> @async.Path {
  @async.Path::new([self.prefix, ..path.parts()].map(_.to_string()).join("#"))
}

///|
let defines =
  #|#ifdef _WIN32
  #|#define WIN32_LEAN_AND_MEAN
  #|#define _WIN32_WINNT 0x0A00
  #|#define _CRT_DECLARE_NONSTDC_NAMES 0
  #|#else
  #|#define _FILE_OFFSET_BITS 64
  #|#define _LARGEFILE_SOURCE
  #|#endif
  #|
  #|#ifdef __APPLE__
  #|#define _DARWIN_UNLIMITED_SELECT 1
  #|#define _DARWIN_USE_64_BIT_INODE 1
  #|#endif
  #|
  #|#ifdef __linux__
  #|#define _GNU_SOURCE
  #|#define _POSIX_C_SOURCE 200112
  #|#endif

///|
fn Project::condition(content : String, condition : String) -> String {
  $|#if \{condition}
  $|\{content}
  $|#endif
}

///|
async fn Project::copy(
  self : Project,
  source : @async.Path,
  prepare_defines~ : Bool = true,
  relocate~ : Bool = true,
  condition? : String
) -> Unit! {
  let target = self.mangle(source)
  let mut content = self.source.join(source).read_text(encoding=UTF8)
  if prepare_defines {
    content = defines + content
  }
  if relocate {
    content = self.relocate(source, content)
  }
  if condition is Some(condition) {
    content = Project::condition(content, condition)
  }
  println("COPY \{self.source.join(source)} -> \{self.target.join(target)}")
  self.target.join(target).write_text(content, encoding=UTF8)
  self.copied.add(source)
}

///|
async fn Project::relocate(
  self : Project,
  source : @async.Path,
  content : String
) -> String! {
  let include_directories = []
  if self.source.join(source).parent() is Some(source_directory) {
    include_directories.push(source_directory)
  }
  include_directories.append(self.include)
  let headers = []
  async fn relocate(header : @async.Path) -> Result[@async.Path, Error] {
    try {
      for directory in include_directories {
        if not(directory.join(header).exists()) {
          continue
        }
        let resolved = directory
          .join(header)
          .resolve()
          .relative_to(self.source.resolve())
        if not(self.source.join(resolved).exists()) {
          continue
        }
        let relocated = self.mangle(resolved)
        if not(self.target.join(relocated).exists()) {
          println("HERE")
          self.copy(resolved, prepare_defines=false, relocate=false)
          headers.push(resolved)
        }
        return Ok(relocated)
      }
      return Ok(header)
    } catch {
      e => return Err(e)
    }
  }

  async fn replace(source : String) -> Result[String, Error] {
    let target = StringBuilder::new()
    let lines : Array[@string.View] = source.split("\n").collect()
    for i = 0; i < lines.length(); i = i + 1 {
      let line = lines[i]
      let line = loop line {
        [' ', .. line] => {
          target.write_char(' ')
          continue line
        }
        [.. line] => break line
      }
      guard line is ['#', .. line] else {
        for char in line {
          target.write_char(char)
        }
        target.write_char('\n')
        continue
      }
      target.write_char('#')
      let line = loop line {
        [' ', .. line] => {
          target.write_char(' ')
          continue line
        }
        [.. line] => break line
      }
      guard line is [.. "include", .. line] else {
        for char in line {
          target.write_char(char)
        }
        target.write_char('\n')
        continue
      }
      target.write_string("include")
      let line = loop line {
        [' ', .. line] => {
          target.write_char(' ')
          continue line
        }
        [.. line] => break line
      }
      guard line is ['"', .. line] else {
        for char in line {
          target.write_char(char)
        }
        target.write_char('\n')
        continue
      }
      target.write_char('"')
      let filename = StringBuilder::new()
      let line = loop line {
        ['"', ..] | [] as line => break line
        [char, .. line] => {
          filename.write_char(char)
          continue line
        }
      }
      let filename = @async.Path::new(filename.to_string())
      match relocate(filename) {
        Ok(relocated) => {
          let relocated = relocated.to_posix_path().to_string()
          target.write_string(relocated)
          for char in line {
            target.write_char(char)
          }
        }
        Err(error) => return Err(error)
      }
    }
    return Ok(target.to_string())
  }

  let content = replace(content).unwrap_or_error()
  for source in headers {
    self.copy(source, prepare_defines=false)
  }
  content
}

///|
async fn configure(project : Project) -> Unit! {
  for
    source in [
      "src/fs-poll.c", "src/idna.c", "src/inet.c", "src/random.c", "src/strscpy.c",
      "src/strtok.c", "src/thread-common.c", "src/threadpool.c", "src/timer.c", "src/uv-common.c",
      "src/uv-data-getter-setters.c", "src/version.c",
    ] {
    project.copy(@async.Path::posix(source).to_path())
  }
  for
    source in [
      "src/win/async.c", "src/win/core.c", "src/win/detect-wakeup.c", "src/win/dl.c",
      "src/win/error.c", "src/win/fs.c", "src/win/fs-event.c", "src/win/getaddrinfo.c",
      "src/win/getnameinfo.c", "src/win/handle.c", "src/win/loop-watcher.c", "src/win/pipe.c",
      "src/win/thread.c", "src/win/poll.c", "src/win/process.c", "src/win/process-stdio.c",
      "src/win/signal.c", "src/win/snprintf.c", "src/win/stream.c", "src/win/tcp.c",
      "src/win/tty.c", "src/win/udp.c", "src/win/util.c", "src/win/winapi.c", "src/win/winsock.c",
    ] {
    project.copy(
      @async.Path::posix(source).to_path(),
      condition="defined(_WIN32)",
    )
  }
  for
    source in [
      "src/unix/async.c", "src/unix/core.c", "src/unix/dl.c", "src/unix/fs.c", "src/unix/getaddrinfo.c",
      "src/unix/getnameinfo.c", "src/unix/loop-watcher.c", "src/unix/loop.c", "src/unix/pipe.c",
      "src/unix/poll.c", "src/unix/process.c", "src/unix/random-devurandom.c", "src/unix/signal.c",
      "src/unix/stream.c", "src/unix/tcp.c", "src/unix/thread.c", "src/unix/tty.c",
      "src/unix/udp.c",
    ] {
    project.copy(
      @async.Path::posix(source).to_path(),
      condition="!defined(_WIN32)",
    )
  }
  for source in ["src/unix/proctitle.c"] {
    project.copy(
      @async.Path::posix(source).to_path(),
      condition="defined(__APPLE__) || defined(__linux__)",
    )
  }
  for
    source in [
      "src/unix/kqueue.c", "src/unix/random-getentropy.c", "src/unix/darwin-proctitle.c",
      "src/unix/darwin.c", "src/unix/fsevents.c",
    ] {
    project.copy(
      @async.Path::posix(source).to_path(),
      condition="defined(__APPLE__)",
    )
  }
  for
    source in [
      "src/unix/linux.c", "src/unix/procfs-exepath.c", "src/unix/random-getrandom.c",
      "src/unix/random-sysctl-linux.c",
    ] {
    project.copy(
      @async.Path::posix(source).to_path(),
      condition="defined(__linux__)",
    )
  }
}

///|
async fn update_moon_pkg_json(project : Project, path : @async.Path) -> Unit! {
  @async.backtrace(fn() {
    let moon_pkg_json = @json.parse(path.read_text(encoding=UTF8))
      .as_object()
      .unwrap()
    let native_stubs : Array[String] = []
    for copied in project.copied {
      if copied.suffix() is Some(".c") {
        native_stubs.push(copied.to_posix_path().to_string())
      }
    }
    native_stubs.sort()
    native_stubs.push("uv.c")
    moon_pkg_json["native-stub"] = native_stubs.to_json()
    path.write_text(moon_pkg_json.to_json().stringify(indent=2), encoding=UTF8)
  })
}

///|
fn main {
  try
    @async.start(fn() {
      let source = @async.Path::new(["src", "uv"])
      let target = @async.Path::new("src")
      let include : Array[@async.Path] = [
        source.join("include"),
        source.join("src"),
      ]
      let project = Project::new(source, target, include~, prefix="uv")
      configure(project)
      update_moon_pkg_json(project, @async.Path::new(["src", "moon.pkg.json"]))
    }) catch {
    e => println("Error: \{e}")
  }
}
