#!/usr/bin/env python3
"""
Deploy ghpage/build -> ghpage branch using git worktree and using the CURRENT local code for build.

Behavior:
 - Uses your current local working copy (HEAD) to build (no remote fetch before build).
 - Creates a temporary worktree from HEAD (fast, no clone).
 - Creates a unique orphan branch inside the worktree (so it won't clash with any local branch).
 - Replaces worktree contents with ghpage/build, commits, and force-pushes the orphan branch to origin/ghpage.
 - Deletes the temporary orphan branch locally and removes the worktree with retry/backoff.
 - Cross-platform (Windows/macOS/Linux); uses only Python stdlib.
"""

from pathlib import Path
import subprocess, tempfile, shutil, os, time, stat, signal, sys, platform
from datetime import datetime

# ---------- CONFIG ----------
BUILD_SOURCE = Path("ghpage")
BUILD_DIR = BUILD_SOURCE / "build"
BRANCH = "ghpage"               # remote branch to update
REMOTE = "origin"
RETRY_DELAYS = [1, 2, 2, 4, 4, 6, 8, 10]
# ----------------------------

_temp_worktree = None
_temp_branch = None

def log(msg=""):
    print(msg, flush=True)

def run_cmd(cmd, cwd=None, capture_output=False, check=True):
    log(f"🔹 {' '.join(map(str, cmd))}  (cwd={cwd})")
    try:
        return subprocess.run(list(map(str, cmd)),
                              cwd=str(cwd) if cwd else None,
                              text=True,
                              capture_output=capture_output,
                              check=check)
    except subprocess.CalledProcessError as e:
        if capture_output:
            if e.stdout:
                log("stdout:\n" + e.stdout)
            if e.stderr:
                log("stderr:\n" + e.stderr)
        raise

def make_writable(p: Path):
    try:
        if platform.system() == "Windows":
            os.chmod(p, stat.S_IWRITE)
        else:
            if p.is_dir():
                os.chmod(p, 0o700)
            else:
                os.chmod(p, 0o666)
    except Exception:
        pass

def safe_rmtree_onexc(func, path, exc_info):
    try:
        p = Path(path)
        make_writable(p)
        func(path)
    except Exception as e:
        log(f"⚠️ onexc handler couldn't remove {path}: {e}")

def remove_with_backoff(path: Path, delays=RETRY_DELAYS):
    if not path.exists():
        log(f"✅ Path not present: {path}")
        return True
    last = None
    for i, d in enumerate(delays, start=1):
        try:
            log(f"🗑️ Attempt {i}: removing {path} ...")
            shutil.rmtree(path, onexc=safe_rmtree_onexc)
            if not path.exists():
                log(f"✅ Removed {path}")
                return True
        except Exception as e:
            last = e
            log(f"⚠️ Removal attempt {i} failed: {e}")
        log(f"⏳ Waiting {d}s...")
        time.sleep(d)
    # final try
    try:
        log("🔁 Final removal attempt...")
        shutil.rmtree(path, onexc=safe_rmtree_onexc)
        if not path.exists():
            log("✅ Removed on final attempt")
            return True
    except Exception as e:
        last = e
    log("❌ All attempts failed.")
    if last:
        log(f"Last error: {last}")
    return False

def ensure_git():
    try:
        run_cmd(["git", "--version"], capture_output=True)
    except Exception:
        sys.exit("❌ git not found on PATH")

def get_repo_root():
    cp = run_cmd(["git", "rev-parse", "--show-toplevel"], capture_output=True)
    return Path(cp.stdout.strip())

def optional_build():
    """Builds ghpage if missing and package.json exists. Uses local files (current branch)."""
    if BUILD_DIR.exists():
        log(f"✅ Build directory found: {BUILD_DIR}")
        return True
    pkg = BUILD_SOURCE / "package.json"
    if not pkg.exists():
        log(f"ℹ️ No package.json at {pkg}. Skipping auto-build.")
        return False
    install_cmd = ["npm", "ci"] if (BUILD_SOURCE / "package-lock.json").exists() else ["npm", "install"]
    try:
        log("📦 Installing dependencies (npm)...")
        run_cmd(install_cmd, cwd=BUILD_SOURCE)
        log("🛠️ Running build (npm run build)...")
        run_cmd(["npm", "run", "build"], cwd=BUILD_SOURCE)
        if BUILD_DIR.exists():
            log("✅ Build completed (from local code).")
            return True
        else:
            log("❌ Build did not produce the build directory. Check logs.")
            return False
    except Exception:
        log("❌ Build step failed.")
        raise

def setup_worktree_from_head(repo_root: Path):
    """
    Create a temporary worktree based on current HEAD, then create a unique orphan branch inside it.
    Returns (worktree_path, temp_branch_name).
    """
    global _temp_worktree, _temp_branch
    tmpdir = tempfile.mkdtemp(prefix="_ghpage_wt_", dir=str(repo_root))
    _temp_worktree = Path(tmpdir)
    timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    _temp_branch = f"{BRANCH}-tmp-{timestamp}"
    log(f"ℹ️ Created worktree dir: {_temp_worktree}")
    log("ℹ️ Adding worktree from current HEAD (no fetch, uses local code)...")
    # Add worktree checking out current HEAD
    run_cmd(["git", "worktree", "add", str(_temp_worktree), "HEAD"], cwd=repo_root)
    # Inside worktree, create orphan branch with unique name
    run_cmd(["git", "checkout", "--orphan", _temp_branch], cwd=_temp_worktree)
    # remove any files from index (safe)
    run_cmd(["git", "rm", "-rf", "."], cwd=_temp_worktree, check=False)
    log(f"✅ Created orphan branch {_temp_branch} in worktree based on local HEAD")
    return _temp_worktree, _temp_branch

def clear_worktree_root(wt: Path):
    log("🧹 Clearing worktree files (except .git)...")
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

def copy_build_to_worktree(src: Path, dst: Path):
    log(f"📁 Copying build files from {src} -> {dst}")
    for item in src.iterdir():
        dest = dst / item.name
        try:
            if item.is_dir():
                if dest.exists():
                    shutil.rmtree(dest, onexc=safe_rmtree_onexc)
                shutil.copytree(item, dest)
            else:
                if dest.exists():
                    dest.unlink()
                shutil.copy2(item, dest)
        except Exception as e:
            log(f"⚠️ Failed copying {item} -> {dest}: {e}")
            raise

def commit_and_push_from_worktree(wt: Path, temp_branch: str):
    # set identity in the worktree (local)
    # try:
    #     run_cmd(["git", "config", "user.name", "ghpage-deployer"], cwd=wt)
    #     run_cmd(["git", "config", "user.email", "ghpage-deployer@example.com"], cwd=wt)
    # except Exception:
    #     pass

    run_cmd(["git", "add", "-A"], cwd=wt)
    status = run_cmd(["git", "status", "--porcelain"], cwd=wt, capture_output=True)
    if status.stdout.strip() == "":
        log("ℹ️ No changes to commit in worktree.")
        # make initial commit if none exists
        cp = run_cmd(["git", "rev-parse", "--verify", "HEAD"], cwd=wt, capture_output=True, check=False)
        if cp.returncode != 0:
            log("ℹ️ Creating initial commit for orphan branch.")
            run_cmd(["git", "add", "-A"], cwd=wt)
            run_cmd(["git", "commit", "-m", f"Deploy {datetime.utcnow().isoformat()}"], cwd=wt)
    else:
        run_cmd(["git", "commit", "-m", f"Deploy {datetime.utcnow().isoformat()}"], cwd=wt)

    # Force push the temporary orphan branch to the remote ghpage branch
    log(f"🚀 Force-pushing {temp_branch} -> {REMOTE}/{BRANCH}")
    run_cmd(["git", "push", "--force", REMOTE, f"HEAD:refs/heads/{BRANCH}"], cwd=wt)
    log("✅ Push complete.")

def cleanup_worktree_and_branch(wt: Path, repo_root: Path, temp_branch: str):
    # first delete the local temp branch ref if present (it exists locally)
    try:
        run_cmd(["git", "branch", "-D", temp_branch], cwd=repo_root, check=False)
    except Exception as e:
        log(f"⚠️ Could not delete local temp branch {temp_branch}: {e}")
    # remove worktree reference and dir
    try:
        run_cmd(["git", "worktree", "remove", "--force", str(wt)], cwd=repo_root, check=False)
    except Exception as e:
        log(f"⚠️ git worktree remove failed: {e}")
    removed = remove_with_backoff(wt)
    if not removed:
        log(f"⚠️ Please delete the worktree directory manually: {wt.resolve()}")

def _signal_handler(sig, frame):
    log(f"\n⚠️ Caught signal {sig}. Cleaning up...")
    global _temp_worktree, _temp_branch
    if _temp_worktree and _temp_branch:
        try:
            repo_root = get_repo_root()
            cleanup_worktree_and_branch(_temp_worktree, repo_root, _temp_branch)
        except Exception:
            pass
    sys.exit(2)

def main():
    global _temp_worktree, _temp_branch
    log("=== deploy (local-build + worktree) starting ===")
    ensure_git()
    repo_root = get_repo_root()
    log(f"Repository root: {repo_root}")

    # signals
    signal.signal(signal.SIGINT, _signal_handler)
    try:
        signal.signal(signal.SIGTERM, _signal_handler)
    except Exception:
        pass

    # ensure build exists (build from local code)
    try:
        if not BUILD_DIR.exists():
            ok = optional_build()
            if not ok:
                log("❗ Build not available. Exiting.")
                return 1
    except Exception as e:
        log(f"❌ Build failed: {e}")
        return 1

    # prepare worktree from current HEAD and create unique orphan branch
    try:
        wt, tbranch = setup_worktree_from_head(repo_root)
    except Exception as e:
        log(f"❌ Failed to prepare worktree: {e}")
        return 1

    try:
        clear_worktree_root(wt)
        copy_build_to_worktree(BUILD_DIR, wt)
        commit_and_push_from_worktree(wt, tbranch)
    except Exception as e:
        log(f"❌ Error while copying/committing: {e}")
        log("Attempting cleanup...")
        cleanup_worktree_and_branch(wt, repo_root, tbranch)
        return 1

    # cleanup
    cleanup_worktree_and_branch(wt, repo_root, tbranch)
    log("✅ Deployment finished.")
    return 0

if __name__ == "__main__":
    rc = main()
    sys.exit(rc)
