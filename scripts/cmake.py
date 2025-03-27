import subprocess
from pathlib import Path
import json
import platform


def generate_native_flags_to(moon_pkg_path: Path):
    moon_pkg_json = json.loads(moon_pkg_path.read_text(encoding="utf-8"))
    moon_pkg_json["link"] = {}
    moon_pkg_json["link"]["native"] = {}
    if "stub-cc-flags" not in moon_pkg_json["link"]:
        if platform.system() == "Darwin" or platform.system() == "Linux":
            moon_pkg_json["link"]["native"]["stub-cc-flags"] = "-Isrc/uv-install/include"
            moon_pkg_json["link"]["native"]["cc-link-flags"] = "src/uv-install/lib/libuv.a"
        elif platform.system() == "Windows":
            moon_pkg_json["link"]["native"]["stub-cc-flags"] = "/Isrc\\uv-install\\include"
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
            ]
            cc_link_flags = " ".join([f"/link {lib}.lib" for lib in external_libraries])
            moon_pkg_json["link"]["native"]["cc-link-flags"] = f"src\\uv-install\\lib\\libuv.lib {cc_link_flags}"
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
