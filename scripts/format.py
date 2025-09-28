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

from pathlib import Path
import subprocess
import logging
import json


def clang_format():
    files = []
    for path in Path("src").glob("*.[ch]"):
        if path.is_file() and not path.match("uv#*"):
            files.append(str(path))
            logging.info(f"file {path} will be formatted")
    subprocess.run(["clang-format", "--dry-run", "--Werror", *files], check=True)


def json_format():
    files: list[Path] = []
    for path in Path(".").rglob("moon.pkg.json"):
        if path.is_file():
            files.append(path)
            logging.info(f"file {path} will be formatted")
    for path in Path(".").rglob("moon.mod.json"):
        if path.is_file():
            files.append(path)
            logging.info(f"file {path} will be formatted")
    for path in files:
        path.write_text(
            json.dumps(json.loads(path.read_text(encoding="utf-8")), indent=2) + "\n",
            encoding="utf-8",
        )


def moon_fmt():
    subprocess.run(["moon", "fmt", "--check"], check=True)


def main():
    clang_format()
    json_format()
    moon_fmt()


if __name__ == "__main__":
    main()
