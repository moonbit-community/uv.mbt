#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2025 International Digital Economy Academy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json
from pathlib import Path
import platform
import subprocess
import os
import argparse
import shutil


def macos_flags():
    brew = shutil.which("brew")
    if not brew:
        if Path("/opt/homebrew/bin/brew").exists():
            brew = "/opt/homebrew/bin/brew"
        else:
            raise Exception("Homebrew is not installed or not in PATH")
    llvm_opts = ["llvm", "llvm@18", "llvm@19", "llvm@15", "llvm@13"]
    for llvm in llvm_opts:
        llvm_prefix = subprocess.run(
            [brew, "--prefix", llvm], check=True, text=True, capture_output=True
        ).stdout
        llvm_prefix = llvm_prefix.strip()
        clang_path = Path(llvm_prefix) / "bin" / "clang"
        if clang_path.exists():
            return {"cc": str(clang_path), "stub-cc": str(clang_path)}
    print("Warning: No LLVM installation found, using GCC-14")
    return {
        "stub-cc": "gcc-14",
        "cc": "gcc-14",
    }


def linux_flags():
    return {
        "stub-cc": "gcc",
        "cc": "gcc",
    }


def windows_flags():
    return {
        "stub-cc": "cl",
        "stub-cc-flags": "/DEBUG /fsanitize=address",
        "cc": "cl",
        "cc-flags": "/DEBUG /fsanitize=address",
    }


def modify_moon_pkg_json(moon_pkg_path: Path, flags: dict[str, str]) -> str:
    moon_pkg_text = moon_pkg_path.read_text()
    moon_pkg_json = json.loads(moon_pkg_text)
    if "link" not in moon_pkg_json:
        moon_pkg_json["link"] = {}
    moon_pkg_json["link"]["native"] = flags
    moon_pkg_path.write_text(json.dumps(moon_pkg_json, indent=2))
    return moon_pkg_text


def main():
    parser = argparse.ArgumentParser(
        description="Run MoonBit tests with specified target"
    )
    parser.add_argument(
        "--target",
        default=None,
        type=str,
        help="Target platform (e.g., native, llvm, js, wasm)",
    )
    parser.add_argument(
        "-p",
        "--package",
        default=None,
        type=str,
        nargs=argparse.OPTIONAL,
        help="Package name to test",
    )
    parser.add_argument(
        "-f",
        "--file",
        default=None,
        type=str,
        nargs=argparse.OPTIONAL,
        help="File to test, relative to the package directory",
    )
    parser.add_argument(
        "-i",
        "--index",
        default=None,
        type=int,
        nargs=argparse.OPTIONAL,
        help="Index of the test to run, if applicable",
    )

    args = parser.parse_args()

    subprocess.run(["moon", "check", "--target", args.target], check=True)
    test_path = Path("src")
    flags = None
    if platform.system() == "Linux":
        flags = linux_flags()
    elif platform.system() == "Darwin":
        flags = macos_flags()
    elif platform.system() == "Windows":
        flags = windows_flags()
    if flags is None:
        raise Exception("Unsupported platform")
    uv_pkg_path = test_path / "moon.pkg.json"
    uv_pkg_text = modify_moon_pkg_json(uv_pkg_path, flags)
    print("==============================================")
    print("Running test with the following configuration:")
    print("----------------------------------------------")
    print(json.dumps(flags, indent=2))
    print("----------------------------------------------")
    env = os.environ.copy()
    if platform.system() != "Windows":
        cc = flags["cc"] + " -g -fsanitize=address"
        cc_sh = Path("scripts/cc.sh")
        cc_sh.write_text(f'{cc} "$@"', encoding="utf-8")
        cc_sh.chmod(0o755)
        env["MOON_CC"] = str(cc_sh.resolve())
        env["MOON_AR"] = "/usr/bin/ar"
    if platform.system() != "Windows":
        env["ASAN_OPTIONS"] = "detect_leaks=1"
        lsan_suppressions = Path(".lsan-suppressions").resolve()
        env["LSAN_OPTIONS"] = f"suppressions={lsan_suppressions}"
    try:
        cmd = ["moon", "test", "-v"]
        if args.target is not None:
            cmd.append("--target")
            cmd.append(args.target)
        if args.package is not None:
            cmd.append("-p")
            cmd.append(args.package)
        if args.file is not None:
            cmd.append("-f")
            cmd.append(args.file)
        if args.index is not None:
            cmd.append("-i")
            cmd.append(str(args.index))
        subprocess.run(
            cmd,
            check=True,
            env=env,
        )
    finally:
        uv_pkg_path.write_text(uv_pkg_text)
        Path("scripts/cc.sh").unlink(missing_ok=True)


if __name__ == "__main__":
    main()
