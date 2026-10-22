HAPPY-pedia — root repository setup

This small package is for a NEW GitHub Pages user-site repository named exactly:
  dimarus222.github.io

Do not put these files into the existing ZlKonstantin project repository.

Files included:
- yandex_3d9245927726bdb6.html — Yandex Webmaster ownership-verification file, unchanged token/content.
- index.html — redirects visitors from https://dimarus222.github.io/ to the existing project at /ZlKonstantin/.
- robots.txt — provides a host-level robots file and points crawlers to the existing project's sitemap.

Setup:
1. On GitHub create a PUBLIC repository owned by dimarus222 with the exact name dimarus222.github.io.
2. Clone that new repository using GitHub Desktop.
3. Extract the contents of this ZIP into the root of the cloned repository (not into a new nested folder).
4. Commit and Push.
5. In the new repository, open Settings -> Pages and publish from branch main, folder /(root), if Pages is not enabled automatically.
6. Wait until these URLs work:
   https://dimarus222.github.io/yandex_3d9245927726bdb6.html
   https://dimarus222.github.io/robots.txt
7. In Yandex Webmaster, confirm https://dimarus222.github.io using the HTML file method.

The main HAPPY-pedia project remains in the existing ZlKonstantin repository; do not replace its contents with this package.
