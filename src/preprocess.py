import sys
import os
import subprocess
from pathlib import Path
import re

include_directories = [
    '.',
    '../lib/uv/include',
]


# already_included: set[Path] = set()


def try_include(file_dir: Path, include_path : str) -> list[str]:
    for include_dir in include_directories:
        include_file = file_dir / include_dir / include_path
        if include_file.exists():
            print(f"Including {include_path}")
            return include_file.read_text().splitlines()
    print(f"Warning: Included file {include_path} not found.")
    return []


def expand_includes(file_path: Path) -> list[str]:
    include_pattern = re.compile(r'#\s*include\s+"([^"]+)"')
    file_dir = Path(file_path).parent

    def read_file(file: Path) -> list[str]:
        return file.read_text().splitlines()

    def process_file(lines: list[str]):
        expanded_lines: list[str] = []
        for line in lines:
            match = include_pattern.match(line)
            if match:
                included_lines = try_include(file_dir, match.group(1))
                expanded_lines.extend(process_file(included_lines))
            else:
                expanded_lines.append(line)
        return expanded_lines

    original_lines = read_file(file_path)
    return process_file(original_lines)

def main():
    preprocess_lines = expand_includes(Path(sys.argv[1]));
    preprocess_text = "\n".join(preprocess_lines)
    Path(sys.argv[2]).write_text(preprocess_text)

    # MOON_HOME = os.environ.get("MOON_HOME")
    # if MOON_HOME is None:
    #     print("MOON_HOME is not set")
    #     sys.exit(1)
    # moon_home = Path(MOON_HOME)
    # subprocess.run(
    #     [
    #         moon_home / "bin/internal/tcc",
    #         "-O3",
    #         "-Wall",
    #         "-Wextra",
    #         "-Wshadow",
    #         "-Wpedantic",
    #         "-Werror=incompatible-pointer-types",
    #         "-std=c11",
    #         "-fPIC",
    #         "-fvisibility=hidden",
    #         "-Isrc/tree-sitter/lib/src",
    #         "-Isrc/tree-sitter/lib/src/wasm",
    #         "-Isrc/tree-sitter/lib/include",
    #         "-Isrc/tinycc/include",
    #         f"-I{moon_home}/include",
    #         "-E",
    #         "-P",
    #         "src/tree-sitter.c",
    #         "-o",
    #         "src/tree-sitter-lib.c",
    #     ],
    #     check=True,
    # )


if __name__ == "__main__":
    main()
