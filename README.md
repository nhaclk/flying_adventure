# Flying Adventure

A Flutter + Flame flying game with three playable characters.

## Run locally

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then run:

```bash
flutter pub get
flutter run -d chrome
```

## Publish on GitHub Pages

The workflow in `.github/workflows/deploy.yml` builds and publishes the game
when code is pushed to `main` or `master`. It also supports manual deployments
from the Actions tab and automatically sets the correct base path for project
sites and `username.github.io` user sites.

1. Commit and push the workflow to this repository:

   ```bash
   git add .github/workflows/deploy.yml README.md
   git commit -m "Deploy game to GitHub Pages"
   git push origin main
   ```

2. Open [Settings → Pages](https://github.com/nhaclk/flying_adventure/settings/pages).
   Under **Build and deployment → Source**, select **GitHub Actions**.
3. Open the **Actions** tab and wait for **Deploy to GitHub Pages** to complete
   successfully.
4. Visit **https://nhaclk.github.io/flying_adventure/**. The first deployment
   can take a few minutes to become available.

Future pushes to `main` (or `master`) publish updates automatically. To deploy
without a new push, open **Actions → Deploy to GitHub Pages → Run workflow**.

## Build for web locally

To build locally with the same project-site path:

```bash
flutter build web --release --base-href /flying_adventure/
```
