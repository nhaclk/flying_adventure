# Flying Adventure

A Flutter + Flame flying game with three playable characters.

## Run locally

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then run:

```bash
flutter pub get
flutter run -d chrome
```

## Publish on GitHub Pages

The GitHub Actions workflow in `.github/workflows/deploy.yml` builds the Flutter
web app and publishes it to GitHub Pages whenever code is pushed to `main` or
`master`. It also supports manually starting a deployment from the Actions tab.
The workflow chooses the correct web base path for both project sites and
`username.github.io` user sites.

1. Create a new repository on GitHub. For a project site, use any repository
   name, such as `flying-adventure`. A user site must use the repository name
   `YOUR-USERNAME.github.io`.
2. In this project folder, initialize Git and push the code to your new
   repository. Replace `YOUR-USERNAME` and `YOUR-REPOSITORY` with the values
   from GitHub:

   ```bash
   git init
   git add .
   git commit -m "Prepare Flying Adventure for GitHub Pages"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
   git push -u origin main
   ```

   If this folder is already connected to a different Git repository, update
   its `origin` remote instead of running `git init` or adding a second remote.
3. On GitHub, open the repository's **Settings → Pages**. Under **Build and
   deployment → Source**, select **GitHub Actions**.
4. Open the repository's **Actions** tab and wait for the **Deploy to GitHub
   Pages** workflow to complete successfully.
5. Open the URL shown in **Settings → Pages**. A project site is normally at
   `https://YOUR-USERNAME.github.io/YOUR-REPOSITORY/`; a user site is at
   `https://YOUR-USERNAME.github.io/`.

Future pushes to `main` (or `master`) publish updates automatically. To publish
without a new push, open **Actions → Deploy to GitHub Pages → Run workflow**.

## Build for web locally

For a project site, replace `YOUR-REPOSITORY` with the repository name:

```bash
flutter build web --release --base-href /YOUR-REPOSITORY/
```

For a `username.github.io` user site, use the root path:

```bash
flutter build web --release --base-href /
```
