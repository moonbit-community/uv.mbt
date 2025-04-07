from typing import Literal, Optional
from pathlib import Path, PurePosixPath
import re
import json

System = Literal["macos", "linux", "win32"]


systems: list[System] = ["macos", "linux", "win32"]


defines = """#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define _WIN32_WINNT 0x0A00
#define _CRT_DECLARE_NONSTDC_NAMES 0
#else
#define _FILE_OFFSET_BITS 64
#define _LARGEFILE_SOURCE
#endif

#ifdef __APPLE__
#define _DARWIN_UNLIMITED_SELECT 1
#define _DARWIN_USE_64_BIT_INODE 1
#endif

#ifdef __linux__
#define _GNU_SOURCE
#define _POSIX_C_SOURCE 200112
#endif
"""


class Config:
    sources: list[str] = []
    libraries: list[str] = []


class Project:
    include: list[Path]
    source: Path
    target: Path
    prefix: str
    copied: set[Path]

    def __init__(
        self, source: Path, target: Path, include: list[Path] = [], prefix: str = ""
    ):
        self.source = source
        self.target = target
        self.include = include
        self.prefix = prefix
        self.copied = set()

    def mangle(self, source: Path) -> Path:
        return Path("#".join([self.prefix, *source.parts]))

    def relocate(self, source: Path, content: str) -> str:
        include_directories = [(self.source / source).parent, *self.include]
        headers = []

        def relocate(header: Path) -> Path:
            for directory in include_directories:
                resolved = ((directory / header).resolve()).relative_to(
                    self.source.resolve()
                )
                if not (self.source / resolved).exists():
                    continue
                relocated = self.mangle(resolved)
                if not (self.target / relocated).exists():
                    self.copy(resolved, relocate=False)
                    headers.append(resolved)
                return relocated
            return header

        def replace(match: re.Match) -> str:
            indent = match.group("indent")
            header: str = match.group("header")
            relocated = relocate(PurePosixPath(header))
            return f'#{indent}include "{relocated.as_posix()}"'

        content = re.sub(r'#(?P<indent>\s*)include "(?P<header>.*?)"', replace, content)

        for source in headers:
            self.copy(source)

        return content

    def condition(self, condition: str, content: str) -> str:
        return f"""#if {condition}
{content}
#endif
"""

    def copy(self, source: Path, relocate: bool = True, condition: Optional[str] = None):
        target = self.mangle(source)
        content = (self.source / source).read_text()
        content = defines + content
        if relocate:
            content = self.relocate(source, content)
        if condition is not None:
            content = self.condition(condition, content)
        print(f"COPY {self.source / source} -> {self.target / target}")
        (self.target / target).write_text(content)
        self.copied.add(target)


def configure(project: Project):
    for source in [
        "src/fs-poll.c",
        "src/idna.c",
        "src/inet.c",
        "src/random.c",
        "src/strscpy.c",
        "src/strtok.c",
        "src/thread-common.c",
        "src/threadpool.c",
        "src/timer.c",
        "src/uv-common.c",
        "src/uv-data-getter-setters.c",
        "src/version.c",
    ]:
        project.copy(PurePosixPath(source))

    for source in [
        "src/win/async.c",
        "src/win/core.c",
        "src/win/detect-wakeup.c",
        "src/win/dl.c",
        "src/win/error.c",
        "src/win/fs.c",
        "src/win/fs-event.c",
        "src/win/getaddrinfo.c",
        "src/win/getnameinfo.c",
        "src/win/handle.c",
        "src/win/loop-watcher.c",
        "src/win/pipe.c",
        "src/win/thread.c",
        "src/win/poll.c",
        "src/win/process.c",
        "src/win/process-stdio.c",
        "src/win/signal.c",
        "src/win/snprintf.c",
        "src/win/stream.c",
        "src/win/tcp.c",
        "src/win/tty.c",
        "src/win/udp.c",
        "src/win/util.c",
        "src/win/winapi.c",
        "src/win/winsock.c",
    ]:
        project.copy(
            source=PurePosixPath(source),
            condition="defined(_WIN32)",
        )

    for source in [
        "src/unix/async.c",
        "src/unix/core.c",
        "src/unix/dl.c",
        "src/unix/fs.c",
        "src/unix/getaddrinfo.c",
        "src/unix/getnameinfo.c",
        "src/unix/loop-watcher.c",
        "src/unix/loop.c",
        "src/unix/pipe.c",
        "src/unix/poll.c",
        "src/unix/process.c",
        "src/unix/random-devurandom.c",
        "src/unix/signal.c",
        "src/unix/stream.c",
        "src/unix/tcp.c",
        "src/unix/thread.c",
        "src/unix/tty.c",
        "src/unix/udp.c",
    ]:
        project.copy(
            source=PurePosixPath(source),
            condition="!defined(_WIN32)",
        )

    for source in ["src/unix/proctitle.c"]:
        project.copy(
            source=PurePosixPath(source),
            condition="defined(__APPLE__) || defined(__linux__)",
        )

    for source in [
        "src/unix/kqueue.c",
        "src/unix/random-getentropy.c",
        "src/unix/darwin-proctitle.c",
        "src/unix/darwin.c",
        "src/unix/fsevents.c",
    ]:
        project.copy(
            source=PurePosixPath(source),
            condition="defined(__APPLE__)",
        )

    for source in [
        "src/unix/linux.c",
        "src/unix/procfs-exepath.c",
        "src/unix/random-getrandom.c",
        "src/unix/random-sysctl-linux.c",
    ]:
        project.copy(
            source=PurePosixPath(source),
            condition="defined(__linux__)",
        )


def update_moon_pkg_json(project: Project, path: Path):
    moon_pkg_json = json.loads(path.read_text())
    native_stubs = []
    for copied in project.copied:
        native_stubs.append(copied.as_posix())
    native_stubs.sort()
    moon_pkg_json["native-stub"] = [*native_stubs, "uv.c"]
    has_pre_build = False
    for task in moon_pkg_json["pre-build"]:
        if "command" in task and task["command"] == "python scripts/prepare.py":
            task["output"] = native_stubs
            has_pre_build = True
    if not has_pre_build:
        moon_pkg_json["pre-build"].append(
            {
                "input": [],
                "output": native_stubs,
                "command": "python scripts/prepare.py",
            }
        )
    path.write_text(json.dumps(moon_pkg_json, indent=2) + "\n")


def main():
    source = Path("src") / "uv"
    target = Path("src")
    target.mkdir(parents=True, exist_ok=True)
    include = [source / "include", source / "src"]
    project = Project(source, target, include=include, prefix="uv")
    configure(project)
    update_moon_pkg_json(project, Path("src") / "moon.pkg.json")


if __name__ == "__main__":
    main()
