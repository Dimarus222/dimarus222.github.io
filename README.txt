HAPPY-pedia — SEO + lightweight terminal-start screen package

Files
- index.html — current optimized interactive site, SEO metadata, structured data and small terminal-style startup overlay.
- assets/ — source site artwork and icons. No existing image was re-encoded or reduced.
- assets/happy-pedia-social-preview.png — Open Graph/Twitter share preview.
- guide/ — crawlable, human-readable landing pages for farm, PTS calculator, pets, weapons, jewelry, each sphere type and updates.
- robots.txt — allows normal crawling and points crawlers to sitemap.xml.
- sitemap.xml — lists the homepage and guide pages.
- yandex_3d9245927726bdb6.html — exact HTML verification file from Yandex Webmaster; keep it unchanged at the published root.
- .nojekyll — asks GitHub Pages to publish this as a static site without Jekyll processing.

Publish
1. Unzip the archive.
2. Upload/commit index.html, yandex_3d9245927726bdb6.html, .nojekyll, robots.txt, sitemap.xml, the entire assets/ directory and entire guide/ directory to the repository's published root. Keep directory names intact.
3. The canonical URL and sitemap currently target the URL in the supplied PageSpeed report:
   https://dimarus222.github.io/ZlKonstantin/
   If the actual public site is a GitVerse Pages domain instead, update this base URL in canonical/og:url/json-ld metadata, guide-page metadata, robots.txt and sitemap.xml before publishing. Do not leave two active hosts declaring each other as canonical by accident.
4. GitHub Pages project-site caveat: the standard robots.txt URL is at the host root (https://dimarus222.github.io/robots.txt), not under /ZlKonstantin/. The robots.txt in this package is useful as a project-root reference but may not be the host-level robots file crawlers use. Submit the project sitemap directly in Google Search Console and Yandex Webmaster. To publish a host-level robots.txt, the account-level Pages repository would need to be updated separately.
5. In Google Search Console, add the exact URL-prefix property, verify ownership, submit https://dimarus222.github.io/ZlKonstantin/sitemap.xml, then inspect the homepage and request indexing. Add the same site in Yandex Webmaster and submit its sitemap.
6. After publication, check that /sitemap.xml, /guide/ and one category page return HTTP 200. Re-run PageSpeed on the published URL.

About the terminal start screen
- It fades out after the inline interface has initialized (DOMContentLoaded) or after a 6.5-second safety timeout.
- It does not wait for Google Sheets. The sheet synchronization remains asynchronous so a slow third-party request cannot hold the entire page behind the loader.
- The overlay is a presentation effect, not a performance fix by itself. Keeping it short avoids deliberately waiting for every non-critical resource.

SEO notes
- The landing pages are intended as useful content, not hidden keyword pages. They link into the interactive site and have unique titles/descriptions, canonical URLs, Open Graph metadata and structured WebPage/BreadcrumbList data.
- Search engines decide when/if to crawl and index pages. No metadata or sitemap can guarantee immediate ranking.

Yandex verification
- After publishing, open https://dimarus222.github.io/ZlKonstantin/yandex_3d9245927726bdb6.html and confirm it returns the exact text “Verification: 3d9245927726bdb6”.
- Then return to Yandex Webmaster and click Verify. The confirmation file intentionally contains only the exact markup requested by Yandex; do not add scripts, styles or other metadata to that file.

SEO integrity
- No SEO-only navigation hidden from ordinary visitors is embedded in the main page. Category landing pages remain listed in sitemap.xml and cross-link through normal, human-visible links on those pages. The visible copyright notice remains unchanged.
