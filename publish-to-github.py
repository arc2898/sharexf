#!/usr/bin/env python3
"""Copy this ShareXF source tree into arc2898/sharexf and push it to main.

Run from an extracted ShareXF directory with Python 3 and Git installed.
GitHub authentication is provided by the user's normal Git credential manager.
"""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPOSITORY = "https://github.com/arc2898/sharexf.git"
EXCLUDED_DIRS = {
    ".git", ".gradle", ".idea", ".pytest_cache", ".swiftpm", ".vscode",
    "__pycache__", ".build", ".cache", ".next", ".turbo", ".venv", "venv",
    "coverage", "dist", "node_modules", "target", "out",
}
EXCLUDED_PATHS = {
    "android/app/build", "android/.gradle", "android/dist",
    "mac/dist", "windows/dist", "linux/dist",
    "mac-helper/.build", "mac-helper/.swiftpm",
    "linux-helper/bin", "windows-helper/bin",
    "mac/vendor/adb", "windows/vendor/adb", "linux/vendor/adb",
}
EXCLUDED_FILES = {
    ".DS_Store", "Thumbs.db", ".env", ".env.local", ".env.production",
    "result", "result-*",
}
SECRET_SUFFIXES = {".p12", ".pfx", ".jks", ".keystore", ".mobileprovision", ".pem", ".key", ".crt", ".cer"}


def run(command: list[str], cwd: Path | None = None) -> None:
    subprocess.run(command, cwd=cwd, check=True)


def ignore(directory: str, names: list[str]) -> set[str]:
    excluded = set()
    relative = Path(directory).resolve().relative_to(SOURCE_ROOT)
    for name in names:
        path = Path(name)
        candidate = (relative / name).as_posix()
        if name in EXCLUDED_DIRS or name in EXCLUDED_FILES or candidate in EXCLUDED_PATHS:
            excluded.add(name)
        elif path.suffix.lower() in SECRET_SUFFIXES or path.suffix.lower() in {".pyc", ".log"}:
            excluded.add(name)
    return excluded


SOURCE_ROOT: Path


def main() -> int:
    source = Path(__file__).resolve().parent
    global SOURCE_ROOT
    SOURCE_ROOT = source
    if not (source / "README.md").is_file() or not (source / "android").is_dir():
        print("Run this script from the extracted ShareXF project directory.", file=sys.stderr)
        return 2

    if shutil.which("git") is None:
        print("Git is required. Install Git and run this script again.", file=sys.stderr)
        return 2

    author = subprocess.run(["git", "config", "--get", "user.name"], capture_output=True, text=True)
    email = subprocess.run(["git", "config", "--get", "user.email"], capture_output=True, text=True)
    if author.returncode != 0 or email.returncode != 0:
        print("Configure your Git commit identity first:", file=sys.stderr)
        print('  git config --global user.name "Your Name"', file=sys.stderr)
        print('  git config --global user.email "your-email@example.com"', file=sys.stderr)
        return 2

    with tempfile.TemporaryDirectory(prefix="sharexf-publish-") as temporary:
        checkout = Path(temporary) / "sharexf"
        print("Cloning the ShareXF repository…")
        run(["git", "clone", REPOSITORY, str(checkout)])

        print("Copying source, platform clients, legal pages and workflows…")
        for item in source.iterdir():
            if item.name in EXCLUDED_DIRS or item.name in EXCLUDED_FILES:
                continue
            if item.is_dir():
                shutil.copytree(item, checkout / item.name, dirs_exist_ok=True, ignore=ignore, symlinks=True)
            elif item.is_file():
                if item.name in EXCLUDED_FILES or item.suffix.lower() in SECRET_SUFFIXES or item.suffix.lower() in {".pyc", ".log"}:
                    continue
                shutil.copy2(item, checkout / item.name)

        run(["git", "add", "--all"], cwd=checkout)
        changed = subprocess.run(["git", "diff", "--cached", "--quiet"], cwd=checkout)
        if changed.returncode == 0:
            print("The repository already matches this source tree; nothing to commit.")
            return 0
        if changed.returncode != 1:
            print("Could not inspect the staged changes.", file=sys.stderr)
            return changed.returncode

        print("Committing ShareXF source…")
        run(["git", "commit", "-m", "Import complete ShareXF multi-platform source"], cwd=checkout)
        print("Pushing to GitHub main…")
        run(["git", "push", "origin", "HEAD:main"], cwd=checkout)

    print("Source pushed: https://github.com/arc2898/sharexf")
    print("Website: https://arc2898.github.io/sharexf/")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        print(f"Command failed with exit code {error.returncode}.", file=sys.stderr)
        print("Check GitHub authentication, repository access and branch protection.", file=sys.stderr)
        raise SystemExit(error.returncode)
