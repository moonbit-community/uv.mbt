import subprocess
from pathlib import Path
import json
import platform

uv_libraries = []

if platform.system() == "Windows":
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

if platform.system() == "Linux":
    uv_libraries += ["dl", "rt"]


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
            moon_pkg_json["link"]["native"]["stub-cc-flags"] = f"-I{include_directory}"
            uv_libraries_flags = " ".join([f"-l{library}" for library in uv_libraries])
            moon_pkg_json["link"]["native"]["cc-link-flags"] = f"{static_libary} {uv_libraries_flags}"
        elif platform.system() == "Windows":
            static_libary = Path("src") / "uv-install" / "lib" / "libuv.lib"
            static_libary = static_libary.absolute()
            moon_pkg_json["link"]["native"]["stub-cc-flags"] = f"/I{include_directory}"
            cc_link_flags = " ".join([f"{lib}.lib" for lib in uv_libraries])
            moon_pkg_json["link"]["native"]["cc-link-flags"] = f"{static_libary} {cc_link_flags}"
        else:
            raise NotImplementedError(f"Unsupported platform: {platform.system()}")
    moon_pkg_path.write_text(
        json.dumps(moon_pkg_json, indent=2) + "\n", encoding="utf-8"
    )


def main():
    src_dir = Path("src")
    subprocess.run(["cmake", "-B", src_dir / "uv-build", "-S", src_dir / "uv", "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"])
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
