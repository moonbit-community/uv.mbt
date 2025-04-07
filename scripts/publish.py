#!/usr/bin/env python3

import shutil
from pathlib import Path
import json
import subprocess
import argparse


def remove_pre_build(path: Path):
    moon_pkg_json = json.loads(path.read_text())
    if "pre-build" in moon_pkg_json:
        moon_pkg_json.pop("pre-build")
        path.write_text(json.dumps(moon_pkg_json, indent=2))


def publish_to(directory: Path, test: bool = True, publish: bool = False):
    if directory.exists():
        shutil.rmtree(directory)
    directory.mkdir()
    shutil.copytree("src", directory / "src")
    remove_pre_build(directory / "src" / "moon.pkg.json")
    shutil.rmtree(directory / "src" / "async")
    shutil.rmtree(directory / "src" / "uv")

    (directory / "src" / ".gitignore").unlink()

    if not test:
        for test_file in directory.rglob("*_test.mbt"):
            test_file.unlink()

    for file in ["README.md", "LICENSE", "moon.mod.json"]:
        shutil.copy(file, directory / file)

    if test:
        subprocess.run(
            ["moon", "test", "--target", "native"], check=True, cwd=directory
        )
        subprocess.run(["moon", "clean"], check=True, cwd=directory)
        shutil.rmtree(directory / ".mooncakes")

    if publish:
        subprocess.run(
            ["moon", "publish"], check=True, cwd=directory
        )


def main():
    parser = argparse.ArgumentParser(description="Package Moon for distribution.")
    parser.add_argument(
        "--test",
        action="store_true",
        help="Run tests before packaging.",
    )
    parser.add_argument(
        "--publish",
        action="store_true",
        help="Publish the package to the specified directory.",
    )
    args = parser.parse_args()
    test = args.test
    publish = args.publish
    publish_to(Path("publish"), test, publish)


if __name__ == "__main__":
    main()
