#!/usr/bin/env python3
"""
Deploy ghpage/build -> ghpage (force) using git worktree + local build.

Improvements:
 - Creates orphan temp branch from current HEAD and pushes it to origin/ghpage.
 - Robust cleanup: handles 'branch used by worktree' and 'worktree remove prompts'
   by doing non-interactive git commands, filesystem removal with backoff,
   git worktree prune, and fallback branch deletion via update-ref.
 - Cross-platform; streams build output; uses only stdlib.
"""

from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import sys
import os
import signal
import platform
from datetime import datetime

# ---------- CONFIG ----------
BUILD_SOURCE = Path("ghpage")
BUILD_DIR = BUILD_SOURCE / "build"
BRANCH = "ghpage"
REMOTE = "origin"
RETRY_DELAYS = [1, 2, 2, 4, 4, 6, 8, 10]  # backoff sequence
# ----------------------------

_temp_worktree = None
_temp_branch = None

def log(msg=""):
    print(msg, flush=True)

def find_pkg_manager():
    for name in ("npm", "pnpm", "yarn"):
        path = shutil.which(name)
        if path:
            return name, path
    if platform.system() == "Windows":
        appdata = os.environ.get("APPDATA")
        if appdata:
            candidate = Path(appdata) / "npm" / "npm.cmd"
            if candidate.exists():
                return "npm", str(candidate)
        pf = os.environ.get("ProgramFiles", r"C:\Program Files")
        candidate = Path(pf) / "nodejs" / "npm.cmd"
        if candidate.exists():
            return "npm", str(candidate)
    return None, None

def run_stream(cmd, cwd=None, check=True):
    log(f"> {' '.join(map(str, cmd))}  (cwd={cwd})")
    return subprocess.run(list(map(str, cmd)), cwd=str(cwd) if cwd else None, check=check)

def run_capture(cmd, cwd=None, stdin_devnull=False):
    """Run command, capture stdout/stderr, return CompletedProcess. Non-interactive."""
    kwargs = {"cwd": str(cwd) if cwd else None, "text": True, "capture_output": True}
    if stdin_devnull:
        kwargs["stdin"] = subprocess.DEVNULL
    return subprocess.run(list(map(str, cmd)), **kwargs)

def ensure_git():
    if not shutil.which("git"):
        sys.exit("❌ git not found on PATH. Install Git and try again.")

def get_repo_root():
    out = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip()
    return Path(out)

def optional_build(repo_root, pm_name, pm_exe):
    src = (repo_root / BUILD_SOURCE).resolve()
    build_abs = (repo_root / BUILD_DIR).resolve()
    if build_abs.exists():
        log(f"✅ Build exists: {build_abs}")
        return True
    if not (src / "package.json").exists():
        log("ℹ️ No package.json in ghpage — skipping auto build.")
        return False

    log(f"📦 Using package manager: {pm_name} ({pm_exe})")
    if pm_name == "npm":
        install_cmd = [pm_exe, "ci"] if (src / "package-lock.json").exists() else [pm_exe, "install"]
        build_cmd = [pm_exe, "run", "build"]
    elif pm_name == "pnpm":
        install_cmd = [pm_exe, "install"]
        build_cmd = [pm_exe, "run", "build"]
    else:
        install_cmd = [pm_exe, "install"]
        build_cmd = [pm_exe, "run", "build"]

    try:
        log("🔁 Installing dependencies (streaming output)...")
        run_stream(install_cmd, cwd=src)
        log("🔨 Building (streaming output)...")
        run_stream(build_cmd, cwd=src)
    except FileNotFoundError as e:
        raise RuntimeError(f"Package manager not found when executing command: {e}")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Install/build failed (rc={e.returncode}). See above output.")

    if build_abs.exists():
        log("✅ Build created.")
        return True
    raise RuntimeError("Build finished but build folder not found. Check your build script.")

### Clean/removal helpers ###

def safe_rmtree_onexc(func, path, exc_info):
    try:
        os.chmod(path, 0o666)
    except Exception:
        pass
    try:
        func(path)
    except Exception:
        pass

def fs_remove_with_backoff(path: Path, delays=RETRY_DELAYS):
    """Attempts to remove directory from filesystem with backoff; returns True on success."""
    if not path.exists():
        log(f"✅ Path already removed: {path}")
        return True
    last_exc = None
    for i, d in enumerate(delays, start=1):
        try:
            log(f"🗑️ FS removal attempt {i}: deleting {path} ...")
            shutil.rmtree(path, onexc=safe_rmtree_onexc)
            if not path.exists():
                log("✅ FS remove succeeded.")
                return True
        except Exception as e:
            last_exc = e
            log(f"⚠️ FS removal attempt {i} failed: {e}")
        log(f"⏳ Waiting {d}s before next attempt...")
        time.sleep(d)
    # final try
    try:
        log("🔁 Final FS removal attempt...")
        shutil.rmtree(path, onexc=safe_rmtree_onexc)
        if not path.exists():
            log("✅ Removed on final attempt")
            return True
    except Exception as e:
        last_exc = e
    log("❌ All FS removal attempts failed.")
    if last_exc:
        log(f"Last error: {last_exc}")
    return False

def try_git_worktree_remove(path: Path, repo_root: Path):
    """Call git worktree remove --force non-interactively (stdin closed). Return CompletedProcess."""
    cmd = ["git", "worktree", "remove", "--force", str(path)]
    return run_capture(cmd, cwd=repo_root, stdin_devnull=True)

def prune_worktrees(repo_root: Path):
    run_stream(["git", "worktree", "prune"], cwd=repo_root, check=False)

def delete_branch(repo_root: Path, branch: str):
    """Try to delete branch; fallback to update-ref if branch deletion fails."""
    # First try branch -D
    cp = run_capture(["git", "branch", "-D", branch], cwd=repo_root)
    if cp.returncode == 0:
        log(f"✅ Deleted branch {branch} with git branch -D")
        return True
    log(f"⚠️ git branch -D failed: {cp.stderr.strip() if cp.stderr else cp.stdout.strip()}")
    # Fallback: remove ref directly
    cp2 = run_capture(["git", "update-ref", "-d", f"refs/heads/{branch}"], cwd=repo_root)
    if cp2.returncode == 0:
        log(f"✅ Deleted branch ref refs/heads/{branch} with update-ref")
        return True
    log(f"❌ Could not delete branch {branch}. Last error: {cp2.stderr.strip() if cp2.stderr else cp2.stdout.strip()}")
    return False

def cleanup_worktree_and_branch(wt: Path, repo_root: Path, temp_branch: str):
    """
    Robust cleanup:
     1. Try `git worktree remove --force` (non-interactive)
     2. If it fails, attempt filesystem deletion with backoff
     3. Run `git worktree prune`
     4. Delete branch (branch -D or update-ref)
    """
    log("🧹 Starting robust cleanup of worktree & temp branch...")
    # 1) try git worktree remove --force non-interactive
    cp = try_git_worktree_remove(wt, repo_root)
    if cp.returncode == 0:
        log("✅ git worktree remove succeeded.")
    else:
        log("⚠️ git worktree remove returned non-zero. Proceeding with FS removal attempts.")
        if cp.stdout:
            log("stdout:\n" + cp.stdout)
        if cp.stderr:
            log("stderr:\n" + cp.stderr)
        # 2) try to remove directory directly with backoff
        removed = fs_remove_with_backoff(wt)
        if not removed:
            log("❌ Filesystem removal failed. Will still attempt to prune and branch cleanup, but manual deletion may be required.")
        else:
            log("ℹ️ Directory removed from filesystem; continuing cleanup.")

        # After FS removal we should prune to remove worktree metadata
        prune_worktrees(repo_root)

        # Try git worktree remove again (may succeed now or be a no-op)
        cp2 = try_git_worktree_remove(wt, repo_root)
        if cp2.returncode == 0:
            log("✅ git worktree remove succeeded on retry.")
        else:
            log("ℹ️ git worktree remove retry returned non-zero (probably already pruned).")

    # 3) prune to ensure metadata cleaned
    prune_worktrees(repo_root)

    # 4) delete the temporary branch (attempt several times with small delays)
    last_success = False
    for i, d in enumerate(RETRY_DELAYS, start=1):
        log(f"🔧 Attempt {i} to delete temp branch {temp_branch} ...")
        ok = delete_branch(repo_root, temp_branch)
        if ok:
            last_success = True
            break
        log(f"⏳ Waiting {d}s before next branch-deletion attempt...")
        time.sleep(d)

    if not last_success:
        log(f"❌ Could not delete temp branch {temp_branch}. You can remove it manually: git branch -D {temp_branch}")
    else:
        log(f"✅ Temp branch {temp_branch} removed.")

### Deployment flow (local build + worktree) ###

def setup_worktree_from_head(repo_root: Path):
    global _temp_worktree, _temp_branch
    tmpdir = tempfile.mkdtemp(prefix="_ghpage_wt_", dir=str(repo_root))
    _temp_worktree = Path(tmpdir)
    _temp_branch = f"{BRANCH}-tmp-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}"
    log(f"ℹ️ Created worktree dir: {_temp_worktree}")
    # add worktree from HEAD (no fetch)
    run_stream(["git", "worktree", "add", str(_temp_worktree), "HEAD"], cwd=repo_root)
    # create unique orphan branch inside the worktree
    run_stream(["git", "checkout", "--orphan", _temp_branch], cwd=_temp_worktree)
    run_stream(["git", "rm", "-rf", "."], cwd=_temp_worktree, check=False)
    log(f"✅ Orphan branch {_temp_branch} created in worktree")
    return _temp_worktree, _temp_branch

def clear_worktree_root(wt: Path):
    for item in wt.iterdir():
        if item.name == ".git":
            continue
        try:
            if item.is_dir():
                shutil.rmtree(item, onexc=safe_rmtree_onexc)
            else:
                item.unlink()
        except Exception as e:
            log(f"⚠️ Could not remove {item}: {e}")

def copy_build(src: Path, dst: Path):
    log(f"📁 Copying build {src} -> {dst}")
    for item in src.iterdir():
        dest = dst / item.name
        if item.is_dir():
            if dest.exists():
                shutil.rmtree(dest, onexc=safe_rmtree_onexc)
            shutil.copytree(item, dest)
        else:
            if dest.exists():
                dest.unlink()
            shutil.copy2(item, dest)


def copy_changelogs_into_build(repo_root: Path):
    """Copy top-level changelog files (CHANGELOG*, e.g. CHANGELOG.md) into the build dir.

    This ensures changelog(s) are included in the deployed site. Returns True if any
    files were copied, False otherwise.
    """
    build_dir = (repo_root / BUILD_DIR).resolve()
    if not build_dir.exists():
        log(f"⚠️ Build directory not found: {build_dir} — skipping changelog copy.")
        return False

    copied_any = False
    for p in repo_root.glob("CHANGELOG*"):
        if p.is_file():
            dest = build_dir / p.name
            try:
                shutil.copy2(p, dest)
                log(f"📄 Copied changelog {p.name} -> {dest}")
                copied_any = True
            except Exception as e:
                log(f"⚠️ Failed to copy changelog {p} -> {dest}: {e}")

    if not copied_any:
        log("ℹ️ No changelog files found at repo root to copy.")
    return copied_any

def commit_and_push(wt: Path):
    # run_stream(["git", "config", "user.name", "ghpage-deployer"], cwd=wt, check=False)
    # run_stream(["git", "config", "user.email", "ghpage-deployer@example.com"], cwd=wt, check=False)
    run_stream(["git", "add", "-A"], cwd=wt)
    status = subprocess.run(["git", "status", "--porcelain"], cwd=str(wt), capture_output=True, text=True)
    if status.stdout.strip() == "":
        cp = subprocess.run(["git", "rev-parse", "--verify", "HEAD"], cwd=str(wt), capture_output=True, text=True, check=False)
        if cp.returncode != 0:
            run_stream(["git", "add", "-A"], cwd=wt)
            run_stream(["git", "commit", "-m", f"Deploy {datetime.utcnow().isoformat()}"], cwd=wt)
    else:
        run_stream(["git", "commit", "-m", f"Deploy {datetime.utcnow().isoformat()}"], cwd=wt)
    run_stream(["git", "push", "--force", REMOTE, f"HEAD:refs/heads/{BRANCH}"], cwd=wt)

def _signal_handler(sig, frame):
    log(f"\n⚠️ Caught signal {sig}. Attempting cleanup...")
    global _temp_worktree, _temp_branch
    if _temp_worktree and _temp_branch:
        try:
            repo_root = get_repo_root()
            cleanup_worktree_and_branch(_temp_worktree, repo_root, _temp_branch)
        except Exception:
            pass
    sys.exit(2)

def find_or_build(repo_root: Path):
    pm_name, pm_exe = find_pkg_manager()
    if not pm_name:
        log("❌ No package manager found on PATH (npm/pnpm/yarn). Install Node or pnpm/yarn.")
        sys.exit(1)
    if not (repo_root / BUILD_DIR).exists():
        optional_build(repo_root, pm_name, pm_exe)
    else:
        log("ℹ️ Using existing build directory.")


def main():
    global _temp_worktree, _temp_branch
    signal.signal(signal.SIGINT, _signal_handler)
    try:
        signal.signal(signal.SIGTERM, _signal_handler)
    except Exception:
        pass

    ensure_git()
    repo_root = get_repo_root()
    log(f"Repository root: {repo_root}")

    # Build from local code (guaranteed)
    try:
        find_or_build(repo_root)
    except Exception as e:
        log(f"❌ Build step failed: {e}")
        return 1

    # Copy changelogs into the build folder (if any) so they get deployed too
    try:
        copy_changelogs_into_build(repo_root)
    except Exception as e:
        log(f"⚠️ Failed while copying changelogs: {e}")

    # Prepare temp worktree (from HEAD) and unique orphan branch
    try:
        wt, tmpb = setup_worktree_from_head(repo_root)
    except Exception as e:
        log(f"❌ Failed to prepare worktree: {e}")
        return 1

    # Copy build, commit, push
    try:
        clear_worktree_root(wt)
        copy_build(repo_root / BUILD_DIR, wt)
        commit_and_push(wt)
    except Exception as e:
        log(f"❌ Error during copy/commit/push: {e}")
        log("Attempting cleanup...")
        cleanup_worktree_and_branch(wt, repo_root, tmpb)
        return 1

    # Robust cleanup
    cleanup_worktree_and_branch(wt, repo_root, tmpb)
    log("✅ Deployment finished.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
