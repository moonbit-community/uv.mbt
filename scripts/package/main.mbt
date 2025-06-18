///|
async fn sanitize_package(path : @nasty.Path) -> Unit raise {
  let moon_pkg_json = path.read_text(encoding=UTF8) |> @json.parse()
  if moon_pkg_json is Object(moon_pkg_json) {
    let mut changed = false
    if moon_pkg_json.get("pre-build") is Some(_) {
      moon_pkg_json.remove("pre-build")
      changed = true
    }
    if moon_pkg_json.get("test-import") is Some(_) {
      moon_pkg_json.remove("test-import")
      changed = true
    }
    if changed {
      path.write_text(
        Json::object(moon_pkg_json).stringify(indent=2),
        encoding=UTF8,
      )
    }
  }
}

///|
async fn publish(
  source : @nasty.Path,
  target : @nasty.Path,
  run_test~ : Bool = true,
  run_publish~ : Bool = false
) -> Unit raise Error {
  if target.exists() {
    println("target \{target} exists, removing...")
    target.remove(recursive=true)
    println("target \{target} removed")
  }
  target.mkdir()
  source.join("src").copy_to(target.join("src"), recursive=true)
  target.join("src").join(".gitignore").remove()
  sanitize_package(target.join("src").join("moon.pkg.json"))
  target.join("src").join("uv").remove(recursive=true)
  for file in ["README.md", "LICENSE", "moon.mod.json"] {
    source.join(file).copy_to(target.join(file))
  }
  if run_test {
    source.join("test").copy_to(target.join("test"), recursive=true)
    let process = @nasty.spawn(
      "moon",
      ["test", "--target", "native"],
      cwd=target,
      stdout=Stdout,
      stderr=Stderr,
    )
    assert_eq(process.status(), 0)
    let process = @nasty.spawn("moon", ["clean"], cwd=target)
    assert_eq(process.status(), 0)
    target.join("target").remove(recursive=true)
    target.join("test").remove(recursive=true)
  }
  target
  .walk()
  .each(fn(path) {
    if path.is_file() &&
      path.name() is Some(name) &&
      name.has_suffix("_test.mbt") {
      path.unlink()
    }
  })
  if run_publish {
    let process = @nasty.spawn(
      "moon",
      ["publish", "--target", "native"],
      cwd=target,
    )
    assert_eq(process.status(), 0)
  }
}

///|
fn main {
  @nasty.start(fn() {
    let args = @nasty.args()
    guard args is [prog, .. args]
    let parser = @clap.Parser::new(prog~, args={
      "test": @clap.Arg::flag(short='t', help="Run tests for packaged code"),
      "publish": @clap.Arg::flag(
        short='p',
        help="Publish the package to a registry",
      ),
      "target": @clap.Arg::named(
        short='o',
        help="Output directory for the package, defaults to [SOURCE]/publish",
      ),
      "source": @clap.Arg::positional(
        nargs=AtMost(1),
        help="Source directory for the package",
      ),
    })
    let value = @clap.SimpleValue::new(prog)
    if parser.parse(value, args) is Some(help_message) {
      println(help_message)
      return
    }
    let run_test = value.flags.get("test").or(true)
    let run_publish = value.flags.get("publish").or(false)
    let source = if value.positional_args.get(0) is Some(source) {
      @nasty.Path::new(source)
    } else {
      @nasty.cwd()
    }
    let target = if value.args.get("target") is Some(target) {
      @nasty.Path::new(target)
    } else {
      source.join("publish")
    }
    publish(source, target, run_test~, run_publish~)
  }) catch {
    error => println(error)
  }
}
