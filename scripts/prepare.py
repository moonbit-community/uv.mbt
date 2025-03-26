import platform
import json
import re

uv_defines = []
uv_sources = [
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
]
uv_libraries = []

if platform.system() == "Windows":
    uv_defines += [
        "WIN32_LEAN_AND_MEAN",
        "_WIN32_WINNT=0x0A00",
        "_CRT_DECLARE_NONSTDC_NAMES=0",
    ]
    uv_libraries += [
        "psapi",
        "user32",
        "advapi32",
        "iphlpapi",
        "userenv",
        "ws2_32",
        "dbghelp",
        "ole32",
        "shell32",
    ]
    uv_sources += [
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
    ]
else:
    uv_defines += ["_FILE_OFFSET_BITS=64", "_LARGEFILE_SOURCE"]
    uv_sources += [
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
    ]

if platform.system() in ["Darwin", "Linux"]:
    uv_sources += ["src/unix/proctitle.c"]

if platform.system() == "Darwin":
    uv_sources += ["src/unix/kqueue.c"]

if platform.system() == "Darwin":
    uv_sources += ["src/unix/random-getentropy.c"]

if platform.system() == "Darwin":
    uv_defines += ["_DARWIN_UNLIMITED_SELECT=1", "_DARWIN_USE_64_BIT_INODE=1"]
    uv_sources += [
        "src/unix/darwin-proctitle.c",
        "src/unix/darwin.c",
        "src/unix/fsevents.c",
    ]

if platform.system() == "Linux":
    uv_defines += ["_GNU_SOURCE", "_POSIX_C_SOURCE=200112"]
    uv_libraries += ["dl", "rt"]
    uv_sources += [
        "src/unix/linux.c",
        "src/unix/procfs-exepath.c",
        "src/unix/random-getrandom.c",
        "src/unix/random-sysctl-linux.c",
    ]

from pathlib import Path
import shutil

uv_directory = Path("src") / "uv"
uv_lib_directory = Path("src") / "uv-lib"
if uv_lib_directory.exists():
    shutil.rmtree(uv_lib_directory)

uv_lib_directory.mkdir(parents=True, exist_ok=True)
(uv_lib_directory / ".gitignore").write_text("\n".join(["*.c", "*.h"]) + "\n")
(uv_lib_directory / "moon.pkg.json").write_text("{}\n")


def create_directory(directory: Path):
    print(f"create directory {directory}")
    directory.mkdir(parents=True, exist_ok=True)


def moon_pkg_json_add_native_stub(moon_pkg_path: Path, native_stub: str):
    moon_pkg_json = json.loads(moon_pkg_path.read_text())
    if "native-stub" not in moon_pkg_json:
        moon_pkg_json["native-stub"] = []
    moon_pkg_json["native-stub"].append(native_stub)
    moon_pkg_path.write_text(json.dumps(moon_pkg_json, indent=2) + "\n")


def copy_header_with_relocated_headers(source: Path, destination: Path):
    print(f"copy {source} -> {destination}")
    content = source.read_text()

    def relocate(match: re.Match) -> str:
        header = match.group(1)
        if (uv_directory / "src" / header).exists():
            header = (uv_directory / "src").relative_to(source.parent, walk_up=True) / header
            return f'#include "{header.as_posix()}"'
        if (uv_directory / "include" / header).exists():
            header = (uv_directory / "src").relative_to(source.parent, walk_up=True) / header
            return f'#include "{header.as_posix()}"'
        return f'#include "{header}"'

    content = re.sub(r'#include "(.*?)"', relocate, content)
    if not destination.parent.exists():
        create_directory(destination.parent)
    destination.write_text(content)


# Copy headers
for header in (uv_directory / "src").rglob("*.h"):
    relative_path = header.relative_to(uv_directory / "src")
    destination = uv_lib_directory / relative_path
    copy_header_with_relocated_headers(header, destination)


def copy_source_with_relocated_headers(source: Path, destination: Path):
    print(f"copy {source} -> {destination}")
    content = source.read_text()

    def relocate(match: re.Match) -> str:
        header = match.group(1)
        if (uv_directory / "src" / header).exists():
            return f'#include "{header}"'
        if (uv_directory / "include" / header).exists():
            return f'#include "{header}"'
        hypothesis = (source.parent.relative_to(uv_directory / "src")) / header
        header = hypothesis.as_posix()
        return f'#include "{header}"'

    content = re.sub(r'#include "(.*?)"', relocate, content)
    if not destination.parent.exists():
        create_directory(destination.parent)
    destination.write_text(content)


# Copy files
native_stubs = []
for source in uv_sources:
    source_path = uv_directory / source
    destination = uv_lib_directory / source_path.name
    copy_source_with_relocated_headers(source_path, destination)
    native_stubs.append(destination.name)


# Copy API header
shutil.copy(uv_directory / "include" / "uv.h", uv_lib_directory / "uv.h")
shutil.copytree(uv_directory / "include" / "uv", uv_lib_directory / "uv")
(uv_lib_directory / "uv" / "uv").symlink_to(".")


src_directory = Path("src")
shutil.copy(src_directory / "uv.c", uv_lib_directory / "uv-lib.c")
native_stubs.append("uv-lib.c")
moon_pkg_json = {
    "native-stub": native_stubs,
}
(uv_lib_directory / "moon.pkg.json").write_text(
    json.dumps(moon_pkg_json, indent=2) + "\n"
)

moon_pkg_path = src_directory / "moon.pkg.json"
moon_pkg_json = json.loads(moon_pkg_path.read_text())
if "import" not in moon_pkg_json:
    moon_pkg_json["import"] = []
moon_pkg_json["import"].append("tonyfettes/uv/uv-lib")
