#!/usr/bin/env python3

import json
from pathlib import Path
import platform
import subprocess
import os


def macos_flags():
    llvm_opts = ["llvm", "llvm@18", "llvm@19", "llvm@15", "llvm@13"]
    for llvm in llvm_opts:
        llvm_prefix = subprocess.run(
            ["brew", "--prefix", llvm], check=True, text=True, capture_output=True
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


def main():
    subprocess.run(["moon", "check", "--target", "native"], check=True)
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
    moon_pkg_path = test_path / "moon.pkg.json"
    moon_pkg_text = moon_pkg_path.read_text()
    moon_pkg_json = json.loads(moon_pkg_text)
    if "link" not in moon_pkg_json:
        moon_pkg_json["link"] = {}
    moon_pkg_json["link"]["native"] = flags
    moon_pkg_path.write_text(json.dumps(moon_pkg_json, indent=2))
    print("==============================================")
    print("Running test with the following configuration:")
    print("----------------------------------------------")
    print(moon_pkg_path.read_text())
    print("----------------------------------------------")
    env = os.environ.copy()
    if platform.system() != "Windows":
        env["MOON_CC"] = flags["cc"] + " -g -fsanitize=address"
        env["MOON_AR"] = "/usr/bin/ar"
    if platform.system() != "Windows":
        env["ASAN_OPTIONS"] = "detect_leaks=1"
        lsan_suppressions = Path(".lsan-suppressions").resolve()
        env["LSAN_OPTIONS"] = f"suppressions={lsan_suppressions}"
    try:
        subprocess.run(
            ["moon", "test", "--target", "native", "-v"],
            check=True,
            env=env,
        )
    finally:
        moon_pkg_path.write_text(moon_pkg_text)


if __name__ == "__main__":
    main()
