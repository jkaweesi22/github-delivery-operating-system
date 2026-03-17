# GitHub Pages Setup

To publish the landing page at `https://jkaweesi22.github.io/github-delivery-operating-system/`:

1. Go to your repo: **Settings → Pages**
2. Under **Build and deployment**:
   - **Source:** GitHub Actions
3. Click **Save**

The `.github/workflows/pages.yml` workflow will deploy the `docs/` folder on every push to `main`. The site is usually live within 1–2 minutes.

**URL:** `https://jkaweesi22.github.io/github-delivery-operating-system/`

---

**Alternative (legacy):** Deploy from a branch → Branch: `main`, Folder: `/docs`. This uses GitHub's built-in deployment (may show Node.js deprecation warnings).
