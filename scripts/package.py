#!/usr/bin/env python3

import subprocess
import sys

if __name__ == "__main__":
    subprocess.run(
        [
            "moon",
            "run",
            "-C",
            "scripts",
            "package",
            "--target",
            "native",
            "--",
            *sys.argv[1:],
        ]
    )
