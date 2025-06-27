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
test "relative_to" {
  @async.start(fn() {
    let async_pipe_mbt = @async.Path::new("src/pipe.mbt")
    let fs_mbt = @async.Path::new("src/fs.mbt")
    let relative_path = async_pipe_mbt.relative_to(fs_mbt)
    assert_eq(relative_path, @async.Path::new(["..", "pipe.mbt"]))
    assert_eq(
      fs_mbt.join(relative_path).resolve().relative_to(@async.Path::cwd()),
      @async.Path::new(["src", "pipe.mbt"]),
    )
  })
}

///|
test "windows/String" {
  if @async.system() != "Windows_NT" {
    return
  }
  let string : String = "C:\\Windows\\System32\\file.txt"
  let path = @async.Path::parse(string)
  @json.inspect(path.parts().collect(), content=[
    "C:\\", "Windows", "System32", "file.txt",
  ])
  @json.inspect(path.drive(), content="C:")
  @json.inspect(path.root(), content="\\")
  @json.inspect(path.anchor(), content="C:\\")
}

///|
test "windows/@string.View" {
  if @async.system() != "Windows_NT" {
    return
  }
  let string : @string.View = "C:/Windows/System32/file.txt"
  let path = @async.Path::parse(string)
  @json.inspect(path, content="C:\\Windows\\System32\\file.txt")
  @json.inspect(path.parts().collect(), content=[
    "C:\\", "Windows", "System32", "file.txt",
  ])
  @json.inspect(path.drive(), content="C:")
  @json.inspect(path.root(), content="\\")
  @json.inspect(path.anchor(), content="C:\\")
}

///|
test "windows/drive" {
  if @async.system() != "Windows_NT" {
    return
  }
  let path = @async.Path::parse("C:\\Windows\\System32")
  @json.inspect(path.parts().collect(), content=["C:\\", "Windows", "System32"])
  @json.inspect(path.drive(), content="C:")
  @json.inspect(path.root(), content="\\")
  @json.inspect(path.anchor(), content="C:\\")
  inspect(path, content="C:\\Windows\\System32")
}

///|
test "windows/unc" {
  if @async.system() != "Windows_NT" {
    return
  }
  let path = @async.Path::parse("\\\\server\\share\\file.txt")
  @json.inspect(path.parts().collect(), content=[
    "\\\\server\\share\\", "file.txt",
  ])
  @json.inspect(path.drive(), content="\\\\server\\share")
  @json.inspect(path.root(), content="\\")
  inspect(path, content="\\\\server\\share\\file.txt")
}

///|
test "windows/relative" {
  if @async.system() != "Windows_NT" {
    return
  }
  let path = @async.Path::parse("directory/file.txt")
  @json.inspect(path.parts().collect(), content=["directory", "file.txt"])
  @json.inspect(path.drive(), content="")
  @json.inspect(path.root(), content="")
  inspect(path, content="directory\\file.txt")
}

///|
test "windows/parent" {
  if @async.system() != "Windows_NT" {
    return
  }
  let path = @async.Path::parse("C:\\Windows\\System32\\file.txt")
  let parent = path.parent()
  @json.inspect(parent, content=["C:\\Windows\\System32"])
  let grandparent = parent.bind(fn(parent) { parent.parent() })
  @json.inspect(grandparent, content=["C:\\Windows"])
  let great_grandparent = grandparent.bind(fn(grandparent) {
    grandparent.parent()
  })
  @json.inspect(great_grandparent, content=["C:\\"])
  let great_great_grandparent = great_grandparent.bind(fn(great_grandparent) {
    great_grandparent.parent()
  })
  @json.inspect(great_great_grandparent is None, content=true)
}

///|
test "windows/to_posix_path" {
  if @async.system() != "Windows_NT" {
    return
  }
  let path = @async.Path::parse("C:\\Windows\\System32\\file.txt")
  let posix_path = path.to_posix_path()
  inspect(posix_path, content="C:/Windows/System32/file.txt")
  let path = @async.Path::parse("\\\\server\\share\\file.txt")
  let posix_path = path.to_posix_path()
  inspect(posix_path, content="//server/share/file.txt")
  let path = @async.Path::parse("directory/file.txt")
  let posix_path = path.to_posix_path()
  inspect(posix_path, content="directory/file.txt")
}

///|
test "windows/relative_to" {
  if @async.system() != "Windows_NT" {
    return
  }
  let path = @async.Path::parse("C:\\Windows\\System32\\file.txt")
  let base = @async.Path::parse("C:\\Windows\\System32")
  let relative_path = path.relative_to(base)
  @json.inspect(relative_path, content="file.txt")
}

///|
test "posix/String" {
  if @async.system() == "Windows_NT" {
    return
  }
  let string : String = "/usr/bin/file.txt"
  let path = @async.Path::parse(string)
  inspect(path, content="/usr/bin/file.txt")
}

///|
test "posix/@string.View" {
  if @async.system() == "Windows_NT" {
    return
  }
  let string : @string.View = "/usr/bin/file.txt"
  let path = @async.Path::parse(string)
  inspect(path, content="/usr/bin/file.txt")
}

///|
test "posix/parts" {
  if @async.system() == "Windows_NT" {
    return
  }
  let path = @async.Path::parse("/usr/bin/file.txt")
  @json.inspect(path.parts().collect(), content=["/", "usr", "bin", "file.txt"])
  @json.inspect(path.root(), content="/")
  @json.inspect(path.anchor(), content="/")
  inspect(path, content="/usr/bin/file.txt")
}

///|
test "posix/impl" {
  if @async.system() == "Windows_NT" {
    return
  }
  let path = @async.Path::parse("//usr//bin//file.txt")
  @json.inspect(path.parts().to_array(), content=[
    "//", "usr", "bin", "file.txt",
  ])
  @json.inspect(path.root(), content="//")
  inspect(path, content="//usr/bin/file.txt")
}

///|
test "posix/parent" {
  if @async.system() == "Windows_NT" {
    return
  }
  let path = @async.Path::parse("/usr/bin/file.txt")
  let parent = path.parent()
  @json.inspect(parent, content=["/usr/bin"])
  let grandparent = parent.bind(fn(parent) { parent.parent() })
  @json.inspect(grandparent, content=["/usr"])
  let great_grandparent = grandparent.bind(fn(grandparent) {
    grandparent.parent()
  })
  @json.inspect(great_grandparent, content=["/"])
  let great_great_grandparent = great_grandparent.bind(fn(great_grandparent) {
    great_grandparent.parent()
  })
  @json.inspect(great_great_grandparent is None, content=true)
}

///|
test "posix/to_windows_path" {
  if @async.system() == "Windows_NT" {
    return
  }
  let path = @async.Path::parse("/usr/bin/file.txt")
  let windows_path = path.to_windows_path()
  inspect(windows_path, content="\\usr\\bin\\file.txt")
  let path = @async.Path::parse("//usr//bin//file.txt")
  let windows_path = path.to_windows_path()
  inspect(windows_path, content="\\\\usr\\bin\\file.txt")
  @json.inspect(windows_path.parts().collect(), content=[
    "\\\\usr\\bin\\", "file.txt",
  ])
}

///|
test "posix/relative_to" {
  if @async.system() == "Windows_NT" {
    return
  }
  let path = @async.Path::parse("/usr/bin/file.txt")
  let base = @async.Path::parse("/usr/bin")
  let relative_path = path.relative_to(base)
  @json.inspect(relative_path, content="file.txt")
}

///|
test "Path::new(String)" {
  let path = @async.Path::new("a/b/c")
  if @async.system() == "Windows_NT" {
    @json.inspect(path, content="a\\b\\c")
  } else {
    @json.inspect(path, content="a/b/c")
  }
  @json.inspect(path.parts().collect(), content=["a", "b", "c"])
  @json.inspect(path.drive(), content="")
  @json.inspect(path.root(), content="")
  @json.inspect(path.anchor(), content="")
}

///|
test "Path::parent" {
  let path = @async.Path::new("a/b/c/d/e")
  let parent = path.parent()
  if @async.system() == "Windows_NT" {
    @json.inspect(parent, content=["a\\b\\c\\d"])
  } else {
    @json.inspect(parent, content=["a/b/c/d"])
  }
  let grandparent = parent.bind(fn(parent) { parent.parent() })
  if @async.system() == "Windows_NT" {
    @json.inspect(grandparent, content=["a\\b\\c"])
  } else {
    @json.inspect(grandparent, content=["a/b/c"])
  }
  let great_grandparent = grandparent.bind(fn(grandparent) {
    grandparent.parent()
  })
  if @async.system() == "Windows_NT" {
    @json.inspect(great_grandparent, content=["a\\b"])
  } else {
    @json.inspect(great_grandparent, content=["a/b"])
  }
  let great_great_grandparent = great_grandparent.bind(fn(great_grandparent) {
    great_grandparent.parent()
  })
  @json.inspect(great_great_grandparent, content=["a"])
}

///|
test "Path::to_posix_path" {
  let path = @async.Path::new("a/b/c")
  let posix_path = path.to_posix_path()
  inspect(posix_path, content="a/b/c")
  @json.inspect(posix_path.parts().collect(), content=["a", "b", "c"])
  @json.inspect(posix_path.drive(), content="")
  @json.inspect(posix_path.root(), content="")
  @json.inspect(posix_path.anchor(), content="")
}

///|
test "Path::to_windows_path" {
  let path = @async.Path::new("a/b/c")
  let windows_path = path.to_windows_path()
  inspect(windows_path, content="a\\b\\c")
  @json.inspect(windows_path.parts().collect(), content=["a", "b", "c"])
  @json.inspect(windows_path.drive(), content="")
  @json.inspect(windows_path.root(), content="")
  @json.inspect(windows_path.anchor(), content="")
}

///|
test "Path::op_equal" {
  let path1 = @async.Path::new("a/b/c")
  let path2 = @async.Path::new("a/b/c")
  let path3 = @async.Path::new("a/b/d")
  @json.inspect(path1 == path2, content=true)
  @json.inspect(path1 == path3, content=false)
  @json.inspect(path1 != path2, content=false)
  @json.inspect(path1 != path3, content=true)
}
