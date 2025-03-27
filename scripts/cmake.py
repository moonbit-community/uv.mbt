import subprocess
from pathlib import Path
import json
import platform

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


def generate_native_flags_to(moon_pkg_path: Path):
    moon_pkg_json = json.loads(moon_pkg_path.read_text(encoding="utf-8"))
    moon_pkg_json["link"] = {}
    moon_pkg_json["link"]["native"] = {}
    include_directory = Path("src") / "uv-install" / "include"
    include_directory = include_directory.absolute()
    if "stub-cc-flags" not in moon_pkg_json["link"]:
        if platform.system() == "Darwin" or platform.system() == "Linux":
            static_libary = Path("src") / "uv-install" / "lib" / "libuv.a"
            static_libary = static_libary.absolute()
            define_flags = " ".join([f"-D{define}" for define in uv_defines])
            moon_pkg_json["link"]["native"]["stub-cc-flags"] = f"-I{include_directory} {define_flags}"
            uv_libraries_flags = " ".join([f"-l{library}" for library in uv_libraries])
            moon_pkg_json["link"]["native"]["cc-link-flags"] = f"{static_libary} {uv_libraries_flags} -static"
        elif platform.system() == "Windows":
            static_libary = Path("src") / "uv-install" / "lib" / "libuv.lib"
            static_libary = static_libary.absolute()
            moon_pkg_json["link"]["native"]["stub-cc-flags"] = f"/I{include_directory}"
            external_libraries = [
                "psapi",
                "user32",
                "advapi32",
                "iphlpapi",
                "userenv",
                "ws2_32",
                "dbghelp",
                "ole32",
                "shell32",
                "msvcrt",
            ]
            cc_link_flags = " ".join([f"{lib}.lib" for lib in external_libraries])
            moon_pkg_json["link"]["native"]["cc-link-flags"] = f"{static_libary} {cc_link_flags}"
        else:
            raise NotImplementedError(f"Unsupported platform: {platform.system()}")
    moon_pkg_path.write_text(
        json.dumps(moon_pkg_json, indent=2) + "\n", encoding="utf-8"
    )


def main():
    src_dir = Path("src")
    subprocess.run(["cmake", "-B", src_dir / "uv-build", "-S", src_dir / "uv"])
    subprocess.run(
        [
            "cmake",
            "--build",
            src_dir / "uv-build",
            "--config",
            "Release",
        ]
    )
    subprocess.run(
        ["cmake", "--install", src_dir / "uv-build", "--prefix", src_dir / "uv-install"]
    )
    generate_native_flags_to(src_dir / "moon.pkg.json")


if __name__ == "__main__":
    main()
