# BloomeeTunes Github Page

A small, fast Svelte site used to host BloomeeTunes on GitHub Pages. This file shows just what you need to run, build, and deploy.

---

## Quick start

```bash
# from repo root
cd ghpage
npm install      # or pnpm/yarn
npm run dev      # dev server (localhost)
npm run build    # produces ghpage/build
```

## Deploy (2 easy ways)

1. **Recommended — `deploy_page.py`** (robust, Windows-safe)

   ```bash
   python ../deploy_page.py
   ```

   * Auto-builds (if missing), clones a temp repo, replaces files, force-pushes `ghpage` branch, and cleans temp data with retries.

2. **Quick — `git subtree`**

   ```bash
   git add ghpage/build && git commit -m "build"
   git subtree push --prefix ghpage/build origin ghpage
   ```

   * Ensure `ghpage/build` is committed first.


## Tips

* Add `ghpage/build/.nojekyll` before pushing if you have files starting with `_`.
* Prefer `deploy_page.py` on Windows, `subtree` on Linux/macOS for simplicity.

---

