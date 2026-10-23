HAPPY-pedia — ROOT HOST SUPPORT ZIP (dimarus222.github.io repository)

PURPOSE
This package provides the host-level favicon and public bilingual project/team descriptors for https://dimarus222.github.io/. Google treats the favicon at host level, so the favicon must exist in this root repository, not only inside /ZlKonstantin/.

INSTALL
1. Extract into the local root of the dimarus222.github.io repository. Replace these supplied support files when prompted.
2. Do NOT replace/delete the existing root index.html or yandex_3d9245927726bdb6.html verification file.
3. Open PowerShell in this repository root and run:
   powershell -ExecutionPolicy Bypass -File .\install-root-favicon.ps1
   The fixed script is compatible with Windows PowerShell 5.1. It changes only favicon-related link elements inside the current root index.html. It preserves the redirect to /ZlKonstantin/ and other markup. It now locates index.html relative to the script file, so it can be run from the repository root as shown.
4. Check GitHub Desktop and commit/push. Then deploy the MAIN PROJECT ZIP to repository ZlKonstantin.

CONTENTS
- favicon.svg, favicon.ico, favicon.png, favicon-192.png, favicon-512.png, apple-touch-icon.png, site.webmanifest: formats based on the existing HAPPY-pedia HP mark.
- robots.txt: crawling remains permitted and sitemap points to the canonical project sitemap. This is the real host-level robots file.
- about-project.txt, llms.txt, team.json: bilingual, public description and structured info for the project and named team members.
- install-root-favicon.ps1: inserts the appropriate icon links without rewriting the root redirect page.
- .nojekyll.

DO NOT PUT THE FULL INTERACTIVE index.html INTO THIS HOST ROOT REPOSITORY. The interactive site belongs in /ZlKonstantin/. The root homepage should continue redirecting there.
