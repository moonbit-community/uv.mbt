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
from datetime import datetime
import fnmatch

MOONBIT_LICENSE_HEADER = """\
// Copyright {year} International Digital Economy Academy
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
"""

C_LICENSE_HEADER = """\
/*
 * Copyright {year} International Digital Economy Academy
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
"""

PYTHON_LICENSE_HEADER = """\
# Copyright {year} International Digital Economy Academy
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
"""


def check_moonbit_license_header(file: Path, header: str) -> bool:
    """
    Check if the file has the correct Moonbit license header.
    """
    return file.read_text().startswith(header)


def check_c_license_header(file: Path, header: str) -> bool:
    """
    Check if the file has the correct C license header.
    """
    return file.read_text().startswith(header)


def check_python_license_header(file: Path, header: str) -> bool:
    """
    Check if the file has the correct Python license header.
    """
    file_lines = file.read_text().splitlines()
    header_lines = header.strip().splitlines()
    i = 0
    while i < len(file_lines):
        # Skip shebang lines and encoding declarations
        if file_lines[i].startswith("#!"):
            i += 1
            continue
        if file_lines[i].strip() == "# -*- coding: utf-8 -*-":
            i += 1
            continue
        # Skip empty lines
        if file_lines[i].strip() == "":
            i += 1
            continue
        break
    if file_lines[i].strip() != header_lines[0].strip():
        return False
    for j in range(1, len(header_lines)):
        if (
            i + j >= len(file_lines)
            or file_lines[i + j].strip() != header_lines[j].strip()
        ):
            return False
    return True


def check_license_header(file: Path, year: int = datetime.now().year) -> bool | None:
    """
    Check if the file has the correct license header.
    """
    moonbit_header = MOONBIT_LICENSE_HEADER.format(year=year)
    c_header = C_LICENSE_HEADER.format(year=year)
    python_header = PYTHON_LICENSE_HEADER.format(year=year)
    if file.suffix in [".mbt", ".mbti"]:
        return check_moonbit_license_header(file, moonbit_header)
    elif file.suffix in [".c", ".h"]:
        return check_c_license_header(file, c_header)
    elif file.suffix in [".py"]:
        return check_python_license_header(file, python_header)
    else:
        return None


def add_ignore(ignored: list[str], file: Path) -> list[str]:
    """
    Add a file to the list of ignored files.
    """
    if not file.exists():
        return ignored
    return ignored + list(
        filter(lambda x: x and not x.startswith("#"), file.read_text().splitlines())
    )


def should_ignore(path: Path, ignored: list[str]) -> bool:
    """
    Check if the path should be ignored based on the ignored patterns.
    """
    for pattern in ignored:
        if pattern.endswith("/") and path.is_dir():
            if fnmatch.fnmatch(path.name, pattern.removesuffix("/")):
                return True
        if fnmatch.fnmatch(path.name, pattern):
            return True
    return False


def check(path: Path, ignored: list[str] = []) -> bool:
    if path == Path("src") / "uv" or path.name.startswith("."):
        return True
    failed = False
    if path.is_dir():
        ignored = add_ignore(ignored, path / ".gitignore")
        ignored = add_ignore(ignored, path / ".git" / "info" / "exclude")
        for entry in path.iterdir():
            if should_ignore(entry, ignored):
                continue
            check(entry, ignored=ignored)
    elif path.is_file():
        if check_license_header(path) == False:
            print(f"File {path} does not have the correct license header.")
            failed = True
    return not failed


def main():
    root = Path(".")
    check(root)


if __name__ == "__main__":
    main()
