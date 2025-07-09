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
test "read" {
  @async.start(fn() {
    let moon_mod_json = @async.Path::new("moon.mod.json").read().text()
      |> @json.parse()
    assert_true(moon_mod_json is Object({ "name": "tonyfettes/uv", .. }))
  })
}

///|
test "open" {
  @async.start(fn() {
    let file = @async.Path::new("moon.mod.json").open()
    let content = file.read_text(encoding=UTF8) |> @json.parse()
    assert_true(content is Object({ "name": "tonyfettes/uv", .. }))
    file.close()
  })
}

///|
test "write" {
  @async.start(fn() {
    let path = @async.Path::new(["test", "fixtures", "example_write.txt"])
    assert_false(path.exists())
    let content = "Hello, world!"
    path.write_text(content, encoding=UTF8)
    assert_true(path.exists())
    assert_eq(path.read_text(encoding=UTF8), content)
    path.unlink()
    assert_false(path.exists())
  })
}

///|
test "write/stdio" {
  @async.start(fn() {
    @async.stderr.write_text("Hello, world!\n", encoding=UTF8)
  })
}

///|
test "write/truncate" {
  @async.start(fn() {
    let readme = @async.Path::new("README.md")
    let backup = readme.read_text(encoding=UTF8)
    readme.write_bytes("")
    @json.inspect(readme.read_text(encoding=UTF8), content="")
    readme.write_text(backup, encoding=UTF8)
  })
}

///|
test "scandir" {
  @async.start(fn() {
    assert_eq(@async.Path::new(["test", "fixtures"]).iter().collect(), [
      @async.Path::new(["test", "fixtures", ".gitattributes"]),
      @async.Path::new(["test", "fixtures", "example.txt"]),
    ])
  })
}

///|
test "copy_to/file" {
  @async.start(fn() {
    let src = @async.Path::new(["test", "fixtures", "example.txt"])
    assert_true(src.exists())
    let dst = @async.Path::new(["test", "fixtures", "example_copy.txt"])
    assert_false(dst.exists())
    try {
      src.copy_to(dst)
      assert_true(dst.is_file())
      dst.unlink()
    } catch {
      error => {
        dst.unlink()
        raise error
      }
    }
  })
}

///|
test "copy_to/directory" {
  @async.start(fn() {
    let src = @async.Path::new("src")
    let dst = @async.Path::new("src_copy")
    src.copy_to(dst, recursive=true)
    assert_true(dst.is_dir())
    assert_true(dst.iter().collect().length() > 0)
    dst.remove(recursive=true)
  })
}

///|
test "exists" {
  @async.start(fn() {
    let path = @async.Path::new(["test", "fixtures", "example.txt"])
    @json.inspect(path.exists(), content=true)
  })
}

///|
test "move_to" {
  @async.start(fn() {
    let src = @async.Path::new(["test", "fixtures", "example.txt"])
    let dst = @async.Path::new(["test", "fixtures", "example_move.txt"])
    @json.inspect(src.exists(), content=true)
    @json.inspect(dst.exists(), content=false)
    src.move_to(dst)
    @json.inspect(src.exists(), content=false)
    @json.inspect(dst.exists(), content=true)
    dst.move_to(src)
    @json.inspect(src.exists(), content=true)
    @json.inspect(dst.exists(), content=false)
  })
}

///|
test "walk" {
  @async.start(fn() {
    let fixtures = @async.Path::new(["test", "fixtures"])
    async fn cleanup() {
      let _ = try? fixtures.join("example").remove(recursive=true)
      let _ = try? fixtures.join("example_0.txt").unlink()
      let _ = try? fixtures.join(["example", "1.txt"]).unlink()
      let _ = try? fixtures.join(["example", "2.txt"]).unlink()

    }

    try {
      fixtures.join("example").mkdir()
      let src = fixtures.join("example.txt")
      src.copy_to(fixtures.join("example_0.txt"))
      src.copy_to(fixtures.join("example").join("1.txt"))
      src.copy_to(fixtures.join("example").join("2.txt"))
      let files = @async.Path::new(["test", "fixtures"]).walk().collect()
      files.sort()
      assert_eq(files, [
        @async.Path::new(["test", "fixtures", "example"]),
        @async.Path::new(["test", "fixtures", "example.txt"]),
        @async.Path::new(["test", "fixtures", "example_0.txt"]),
        @async.Path::new(["test", "fixtures", ".gitattributes"]),
        @async.Path::new(["test", "fixtures", "example", "1.txt"]),
        @async.Path::new(["test", "fixtures", "example", "2.txt"]),
      ])
      cleanup()
    } catch {
      error => {
        cleanup()
        raise error
      }
    }
  })
}

///|
test "trace" {
  @async.start(fn() {
    try {
      @async.Path::new(["test", "fixtures"]).mkdir()
      fail("Should not be able to create a directory that already exists")
    } catch {
      error => {
        println(backtrace_to_string())
        println(error)
      }
    }
  })
}

///|
test "with_temporary_directory" {
  @async.start(fn() {
    let mut saved_tmpdir = None
    @async.with_temporary_directory(fn(tmpdir) {
      saved_tmpdir = Some(tmpdir)
      assert_true(tmpdir.is_dir())
      let file = tmpdir.join("temp_file.txt")
      file.write_text("Temporary content", encoding=UTF8)
      assert_eq(file.read_text(encoding=UTF8), "Temporary content")
      assert_true(file.exists())
    })
    guard saved_tmpdir is Some(saved_tmpdir)
    assert_false(saved_tmpdir.exists())
  })
}
