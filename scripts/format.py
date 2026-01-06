#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2026 International Digital Economy Academy
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


import argparse
from pathlib import Path
import subprocess
import logging
import json


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


def clang_format(write: bool = False):
    logger.info(f"formatting C files: write = {write}")
    files = []
    for path in Path("src").glob("*.[ch]"):
        if path.is_file() and not path.match("uv#*"):
            files.append(str(path))
            logger.info(f"file {path} will be checked")
    if write:
        subprocess.run(["clang-format", "-i", *files], check=True)
    else:
        subprocess.run(["clang-format", "--dry-run", "--Werror", *files], check=True)


def json_format(write: bool = False):
    logger.info(f"formatting JSON files: write = {write}")
    files: list[Path] = [Path("src/moon.pkg.json"), Path("moon.mod.json")]
    for path in files:
        logger.info(f"file {path} will be checked")
        text = path.read_text(encoding="utf-8")
        parsed = json.loads(text)
        formatted = json.dumps(parsed, indent=2) + "\n"
        if text != formatted:
            if write:
                path.write_text(formatted, encoding="utf-8")
            else:
                raise ValueError(f"File {path} is not properly formatted")


def moon_fmt(write: bool = False):
    logger.info(f"formatting MoonBit files: write = {write}")
    if write:
        subprocess.run(["moon", "fmt"], check=True)
    else:
        subprocess.run(["moon", "fmt", "--check"], check=True)


def main():
    parser = argparse.ArgumentParser(description="Check code format")
    parser.add_argument(
        "--write",
        action="store_true",
        default=False,
        help="Write changes to files",
    )
    args = parser.parse_args()
    print(args)
    if args.write:
        logger.info("Writing code format changes")
    else:
        logger.info("Checking code format")
    clang_format(write=args.write)
    json_format(write=args.write)
    moon_fmt(write=args.write)


if __name__ == "__main__":
    main()
