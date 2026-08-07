# Professional Search Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and launch the five-page static marketing site for Professional Search at profsearch.net, hosted free on GitHub Pages.

**Architecture:** Hand-written static HTML5 with one shared stylesheet and one tiny JS helper (copy email address). Deployed via GitHub Actions to GitHub Pages from the `site/` folder so repo docs never publish. Custom domain attached afterward with Michael at his registrar; MX records untouched.

**Tech Stack:** HTML5, CSS3, vanilla JS (one snippet), Python 3 + Pillow (image prep, already installed), GitHub Pages + Actions, `gh` CLI.

## Global Constraints

- Repo root: `/Users/michaellazaro/Desktop/Apps /ProfSearch-Website` (note the space in `Apps `; always quote paths).
- Deployable site lives entirely in `site/`. Nothing outside `site/` gets published.
- Colors, exact: navy `#1F2A44`, orange `#F4924E`, light bg `#F7F8FA`, body/paragraph copy `#5a6070`. White `#ffffff`. (`styles.css` additionally defines `--text: #333a4a` as the darker strong-text base; paragraph copy uses `#5a6070`.)
- Contact facts, exact: `mike@profsearch.net`, phone display `415-246-7302`, tel link `+14152467302`, LinkedIn `https://www.linkedin.com/in/michael-lazaro-b891a011a`.
- Years claim: "over 30 years" / "30+ years". Never "35".
- Terms, exact: 15% of base salary fee; 90-day guarantee; contract candidates convert to permanent at no cost after 6 months.
- mailto subjects use plain hyphens, never em dashes. Site prose: no em dashes anywhere (house copy style).
- No analytics, no cookies, no forms, no third-party requests at runtime (self-hosted fonts only, with graceful system-font fallback if the font download step fails).
- Copy claims only what the spec's "Verified Business Facts" section states. Do not invent testimonials, client names, placement counts, or office locations.
- The "silver necklace" image in `assets-src/h2_img2_667x1000.png` is Canva template residue. Never use it.
- Canonical URLs use `https://profsearch.net`. Site page filenames: `index.html`, `employers.html`, `job-seekers.html`, `about.html`, `contact.html`.
- Git: commit after each task with the message given in the task. All commits end with the trailer `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` (add as a second `-m` flag; not repeated in each task's command for brevity — THIS is the one allowed deviation from verbatim commands).
- DNS cutover: only A/CNAME website records change. MX and TXT records are recorded before and verified unchanged after. mike@profsearch.net must keep working.

---

### Task 1: Scaffold, check script, fonts, favicon, JS helper

**Files:**
- Create: `site/js/copy-email.js`
- Create: `site/robots.txt`
- Create: `site/404.html`
- Create: `tests/check-site.sh`
- Create: `site/fonts/poppins-700.woff2`, `site/fonts/poppins-800.woff2` (downloaded)
- Create: `site/img/favicon.svg`

**Interfaces:**
- Produces: `tests/check-site.sh` (bash, run from repo root; exits 0 when the finished site passes all assertions). CSS hook consumed by later tasks: any button with class `copy-email` copies the email address when clicked; JS swaps its text to `Copied!` for 2 seconds.

- [ ] **Step 1: Create the check script (the failing test for the whole build)**

Create `tests/check-site.sh`:

```bash
#!/bin/bash
# Static assertions for the Professional Search site. Run from repo root.
cd "$(dirname "$0")/.." || exit 1
FAIL=0
ck() { # ck <description> <command...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "PASS: $desc"; else echo "FAIL: $desc"; FAIL=1; fi
}
PAGES="site/index.html site/employers.html site/job-seekers.html site/about.html site/contact.html"

for p in $PAGES; do
  ck "$p exists" test -f "$p"
  ck "$p has <title>" grep -q "<title>" "$p"
  ck "$p has meta description" grep -q 'name="description"' "$p"
  ck "$p links stylesheet" grep -q 'css/styles.css' "$p"
  ck "$p has tel link" grep -q 'tel:+14152467302' "$p"
  ck "$p has email text" grep -q 'mike@profsearch.net' "$p"
  ck "$p has viewport meta" grep -q 'name="viewport"' "$p"
  ck "$p no em dash" bash -c "test -f '$p' && ! grep -q '—' '$p'"
  ck "$p never claims 35 years" bash -c "test -f '$p' && ! grep -qi '35 year' '$p'"
done

ck "styles.css exists" test -f site/css/styles.css
ck "navy color present" grep -q '1F2A44' site/css/styles.css
ck "orange color present" grep -q 'F4924E' site/css/styles.css
ck "copy-email.js exists" test -f site/js/copy-email.js
ck "resume mailto with hyphen subject" grep -q 'Resume%20Submission%20-%20Insurance%20Professional' site/job-seekers.html
ck "resume mailto on homepage" grep -q 'Resume%20Submission%20-%20Insurance%20Professional' site/index.html
ck "hiring mailto on employers page" grep -q 'Hiring%20Inquiry' site/employers.html
ck "JSON-LD EmploymentAgency" grep -q 'EmploymentAgency' site/index.html
ck "sitemap exists" test -f site/sitemap.xml
ck "sitemap lists 5 pages" bash -c "[ \"\$(grep -c '<loc>' site/sitemap.xml)\" = 5 ]"
ck "robots.txt points at sitemap" grep -q 'Sitemap: https://profsearch.net/sitemap.xml' site/robots.txt
ck "404 page exists" test -f site/404.html
ck "hero image exists" test -f site/img/hero.jpg
ck "no necklace image shipped" bash -c "! ls site/img | grep -qi necklace"
ck "hero under 150KB" bash -c "[ \"\$(stat -f%z site/img/hero.jpg)\" -lt 153600 ]"
ck "LinkedIn linked on about" grep -q 'linkedin.com/in/michael-lazaro-b891a011a' site/about.html
ck "LinkedIn linked on contact" grep -q 'linkedin.com/in/michael-lazaro-b891a011a' site/contact.html
ck "favicon exists" test -f site/img/favicon.svg
ck "og image exists" test -f site/img/og.png

exit $FAIL
```

- [ ] **Step 2: Run it; expect many FAILs (nothing built yet)**

Run: `chmod +x tests/check-site.sh && ./tests/check-site.sh; echo "exit=$?"`
Expected: FAIL lines for every page assertion, `exit=1`. (PASS count will grow task by task; the script goes fully green in Task 9.)

- [ ] **Step 3: Create `site/js/copy-email.js`**

```javascript
// Copies the business email to the clipboard from any .copy-email button.
document.addEventListener('click', function (e) {
  var btn = e.target.closest('.copy-email');
  if (!btn) return;
  var email = 'mike@profsearch.net';
  function done() {
    var old = btn.textContent;
    btn.textContent = 'Copied!';
    btn.disabled = true;
    setTimeout(function () { btn.textContent = old; btn.disabled = false; }, 2000);
  }
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(email).then(done, function () { window.prompt('Copy the address:', email); });
  } else {
    window.prompt('Copy the address:', email);
  }
});
```

- [ ] **Step 4: Create `site/robots.txt`**

```
User-agent: *
Allow: /

Sitemap: https://profsearch.net/sitemap.xml
```

- [ ] **Step 5: Create `site/404.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Page Not Found | Professional Search</title>
<meta name="robots" content="noindex">
<style>
/* Self-contained on purpose: the 404 renders for any bad path, so it must not
   rely on relative asset paths. */
body { font-family: 'Avenir Next', 'Segoe UI', Helvetica, Arial, sans-serif; color: #5a6070; line-height: 1.6; margin: 0; }
main { max-width: 640px; margin: 80px auto; padding: 0 20px; }
h1 { color: #1F2A44; line-height: 1.2; margin: 0 0 12px; }
a { color: #1F2A44; }
.rule { height: 4px; background: #F4924E; width: 64px; margin-bottom: 18px; }
</style>
</head>
<body>
<main>
  <div class="rule"></div>
  <h1>Page not found</h1>
  <p>That page moved or never existed. Head back to the <a href="/">homepage</a>, or reach Mike directly at <a href="mailto:mike@profsearch.net">mike@profsearch.net</a> or <a href="tel:+14152467302">415-246-7302</a>.</p>
</main>
</body>
</html>
```

- [ ] **Step 6: Download Poppins woff2 (headings font)**

Run:

```bash
cd "/Users/michaellazaro/Desktop/Apps /ProfSearch-Website" && mkdir -p site/fonts && python3 - <<'EOF'
import re, urllib.request
ua = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120 Safari/537.36'}
css_url = 'https://fonts.googleapis.com/css2?family=Poppins:wght@700;800&display=swap'
css = urllib.request.urlopen(urllib.request.Request(css_url, headers=ua), timeout=20).read().decode()
blocks = re.findall(r'font-weight: (\d+);[^}]*?src: url\((https://fonts.gstatic.com/[^)]+\.woff2)\)[^}]*?U\+0000-00FF', css, re.S)
seen = {}
for weight, url in blocks:
    if weight in ('700', '800') and weight not in seen:
        seen[weight] = url
        urllib.request.urlretrieve(url, f'site/fonts/poppins-{weight}.woff2')
        print('saved', weight, url)
assert set(seen) == {'700', '800'}, f'got {seen}'
EOF
ls -la site/fonts/
```

Expected: two files `poppins-700.woff2` and `poppins-800.woff2`, each roughly 7-10 KB (latin subset). If the download fails (network), skip: the CSS in Task 2 falls back to system fonts and every later step still works. Note the skip in the commit message.

- [ ] **Step 7: Create `site/img/favicon.svg` (three-people mark, navy on white)**

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="#ffffff"/>
  <g fill="none" stroke="#1F2A44" stroke-width="3.2" stroke-linecap="round">
    <circle cx="20" cy="20" r="6"/>
    <circle cx="32" cy="16" r="6"/>
    <circle cx="44" cy="20" r="6"/>
    <path d="M10 48 v-8 a9 9 0 0 1 9-9 h2 a9 9 0 0 1 9 9 v8"/>
    <path d="M24 44 v-11 a8 8 0 0 1 8-8 h0 a8 8 0 0 1 8 8 v11"/>
    <path d="M34 48 v-8 a9 9 0 0 1 9-9 h2 a9 9 0 0 1 9 9 v8"/>
  </g>
  <rect x="14" y="52" width="36" height="4" rx="2" fill="#F4924E"/>
</svg>
```

- [ ] **Step 8: Create `.claude/launch.json` (local preview server config)**

```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "site",
      "runtimeExecutable": "python3",
      "runtimeArgs": ["-m", "http.server", "8901", "--directory", "site"],
      "port": 8901
    }
  ]
}
```

- [ ] **Step 9: Run targeted checks**

Run: `./tests/check-site.sh 2>/dev/null | grep -E "copy-email|robots|404|favicon"`
Expected: those four lines PASS.

- [ ] **Step 10: Commit**

```bash
git add tests site .claude
git commit -m "feat: scaffold site with check script, fonts, favicon, copy-email helper"
```

---

### Task 2: Design system stylesheet

**Files:**
- Create: `site/css/styles.css`

**Interfaces:**
- Produces (consumed by every page): CSS classes `site-header`, `logo`, `logo-mark`, `logo-text`, `main-nav`, `nav-phone`, `hero`, `hero-inner`, `hero-copy`, `kicker`, `hero-photo`, `btn`, `btn-navy`, `btn-orange`, `btn-outline`, `band`, `band-rule`, `doors`, `door`, `door-employers`, `door-seekers`, `terms-row`, `term`, `industries`, `industry-tile`, `tile-photo`, `tile-label`, `tile-featured`, `connect-band`, `connect-circle`, `connect-details`, `section`, `section-title`, `role-columns`, `role-group`, `steps`, `step`, `site-footer`, `copy-email`, `email-line`, `notfound`, `page-hero`.

- [ ] **Step 1: Create `site/css/styles.css` (complete file)**

```css
/* Professional Search design system. Navy #1F2A44, orange #F4924E. */
@font-face {
  font-family: 'Poppins';
  src: url('../fonts/poppins-700.woff2') format('woff2');
  font-weight: 700;
  font-display: swap;
}
@font-face {
  font-family: 'Poppins';
  src: url('../fonts/poppins-800.woff2') format('woff2');
  font-weight: 800;
  font-display: swap;
}
:root {
  --navy: #1F2A44;
  --navy-soft: #28365a;
  --orange: #F4924E;
  --orange-deep: #b45309;
  --bg-light: #F7F8FA;
  --text: #333a4a;
  --text-soft: #5a6070;
  --heading: 'Poppins', 'Avenir Next', 'Segoe UI', Arial, sans-serif;
  --body: 'Avenir Next', 'Segoe UI', Helvetica, Arial, sans-serif;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body { font-family: var(--body); color: var(--text); line-height: 1.6; background: #fff; }
img { max-width: 100%; display: block; }
a { color: var(--navy); }
h1, h2, h3 { font-family: var(--heading); color: var(--navy); line-height: 1.18; }

.wrap { max-width: 1080px; margin: 0 auto; padding: 0 20px; }

/* Header */
.site-header { border-bottom: 1px solid #ececf1; background: #fff; }
.site-header .wrap { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding-top: 14px; padding-bottom: 14px; flex-wrap: wrap; }
.logo { display: flex; align-items: center; gap: 10px; text-decoration: none; }
.logo-mark { width: 40px; height: 36px; flex-shrink: 0; }
.logo-text { line-height: 1.12; }
.logo-text .l1 { font-family: var(--heading); font-weight: 800; font-size: 15px; letter-spacing: 1.4px; color: var(--navy); display: block; }
.logo-text .l2 { font-weight: 700; font-size: 9.5px; letter-spacing: 2.6px; color: var(--orange-deep); display: block; }
.main-nav { display: flex; align-items: center; gap: 20px; flex-wrap: wrap; }
.main-nav a { text-decoration: none; font-size: 14.5px; font-weight: 600; color: var(--text); }
.main-nav a:hover, .main-nav a[aria-current="page"] { color: var(--orange-deep); }
.nav-phone { font-family: var(--heading); font-weight: 700; color: var(--orange-deep) !important; }

/* Buttons */
.btn { display: inline-block; border-radius: 7px; padding: 13px 22px; font-family: var(--heading); font-weight: 700; font-size: 15px; text-decoration: none; border: 0; cursor: pointer; }
.btn-navy { background: var(--navy); color: #fff; }
.btn-navy:hover { background: var(--navy-soft); }
.btn-orange { background: var(--orange-deep); color: #fff; }
.btn-orange:hover { background: #9a4508; }
.btn-outline { border: 2px solid var(--navy); color: var(--navy); background: #fff; }

/* Hero (home) */
.hero { background: var(--bg-light); }
.hero-inner { display: flex; align-items: stretch; gap: 0; max-width: 1080px; margin: 0 auto; }
.hero-copy { flex: 1.08; padding: 64px 20px 64px 20px; }
.kicker { font-family: var(--heading); font-weight: 700; font-size: 13px; letter-spacing: 2.4px; color: var(--orange-deep); }
.hero-copy h1 { font-size: clamp(30px, 4.6vw, 44px); font-weight: 800; margin: 12px 0 14px; }
.hero-copy h1 em { color: var(--orange-deep); font-style: normal; }
.hero-copy p { color: var(--text-soft); font-size: 17px; max-width: 34em; }
.hero-ctas { margin-top: 26px; display: flex; gap: 12px; flex-wrap: wrap; }
.hero-photo { flex: 1; min-height: 320px; background-size: cover; background-position: center; }

/* Page hero (inner pages) */
.page-hero { background: var(--bg-light); padding: 52px 0; }
.page-hero h1 { font-size: clamp(28px, 4vw, 38px); font-weight: 800; margin: 10px 0 12px; }
.page-hero p { color: var(--text-soft); font-size: 17px; max-width: 42em; }

/* Navy title band with orange rule */
.band { background: var(--navy); color: #fff; text-align: center; padding: 18px 20px; }
.band h2 { color: #fff; font-size: clamp(20px, 3vw, 26px); font-weight: 700; }
.band-rule { height: 4px; background: var(--orange); }

/* Doors */
.doors { display: flex; gap: 22px; padding: 40px 0; }
.door { flex: 1; border-radius: 12px; padding: 26px; }
.door h3 { font-size: 19px; font-weight: 800; letter-spacing: 0.6px; margin-bottom: 10px; }
.door p { color: var(--text-soft); font-size: 15px; margin-bottom: 10px; }
.door .facts { color: var(--navy); font-weight: 700; font-size: 14.5px; margin-bottom: 16px; }
.door-employers { border: 2px solid var(--navy); }
.door-seekers { border: 2px solid var(--orange); }
.door .aux { display: block; margin-top: 12px; font-size: 14px; }

/* Terms row */
.terms-row { display: flex; gap: 22px; padding: 8px 0 44px; }
.term { flex: 1; background: var(--bg-light); border-radius: 10px; padding: 20px; }
.term strong { font-family: var(--heading); color: var(--navy); font-size: 17px; display: block; margin-bottom: 6px; }
.term span { color: var(--text-soft); font-size: 14.5px; }

/* Industries */
.industries { display: flex; gap: 12px; padding-bottom: 48px; }
.industry-tile { flex: 1; border: 1px solid #ececf1; border-radius: 10px; overflow: hidden; }
.tile-featured { flex: 1.55; }
.tile-photo { height: 92px; background-size: cover; background-position: center; }
.tile-label { font-family: var(--heading); font-weight: 700; font-size: 11.5px; letter-spacing: 1.4px; text-align: center; padding: 8px 6px; color: var(--navy); }
.tile-featured .tile-label { background: var(--navy); color: #fff; }

/* Sections */
.section { padding: 44px 0; }
.section-title { font-size: clamp(22px, 3vw, 28px); font-weight: 800; margin-bottom: 18px; }
.section p + p { margin-top: 12px; }
.cards-3 { display: flex; gap: 20px; margin-top: 22px; }
.card { flex: 1; border: 1px solid #ececf1; border-radius: 10px; padding: 22px; }
.card h3 { font-size: 17px; margin-bottom: 8px; }
.card p { color: var(--text-soft); font-size: 14.5px; }

/* Role lists */
.role-columns { display: flex; gap: 26px; flex-wrap: wrap; margin-top: 18px; }
.role-group { flex: 1 1 200px; }
.role-group h3 { font-size: 15px; letter-spacing: 1px; margin-bottom: 8px; color: var(--orange-deep); }
.role-group ul { list-style: none; }
.role-group li { padding: 3px 0 3px 18px; position: relative; color: var(--text-soft); font-size: 14.5px; }
.role-group li::before { content: ''; position: absolute; left: 0; top: 11px; width: 7px; height: 7px; border-radius: 50%; background: var(--orange); }

/* Steps (job seekers) */
.steps { counter-reset: step; margin-top: 20px; }
.step { display: flex; gap: 16px; align-items: flex-start; padding: 14px 0; }
.step::before { counter-increment: step; content: counter(step); flex-shrink: 0; width: 38px; height: 38px; border-radius: 50%; background: var(--navy); color: #fff; font-family: var(--heading); font-weight: 700; display: flex; align-items: center; justify-content: center; }
.step h3 { font-size: 16px; margin-bottom: 4px; }
.step p { color: var(--text-soft); font-size: 14.5px; }

/* Email line with copy button */
.email-line { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-top: 14px; }
.email-line code { font-size: 16px; font-weight: 700; color: var(--navy); background: var(--bg-light); padding: 8px 12px; border-radius: 6px; }
.copy-email { font-size: 13px; padding: 8px 14px; border-radius: 6px; border: 1.5px solid var(--navy); background: #fff; color: var(--navy); font-weight: 700; cursor: pointer; }

/* Connect band */
.connect-band { background: var(--navy); color: #fff; }
.connect-band .wrap { display: flex; align-items: center; justify-content: center; gap: 40px; padding: 40px 20px; flex-wrap: wrap; }
.connect-circle { width: 165px; height: 165px; border-radius: 50%; border: 4px solid var(--orange); display: flex; align-items: center; justify-content: center; text-align: center; font-family: var(--heading); font-weight: 800; font-size: 21px; line-height: 1.25; flex-shrink: 0; }
.connect-details { font-size: 16px; line-height: 2.15; }
.connect-details a { color: #fff; text-decoration: none; font-weight: 700; }
.connect-details a:hover { color: var(--orange); }
.connect-details .ico { display: inline-block; width: 26px; color: var(--orange); font-weight: 700; }

/* Footer */
.site-footer { background: var(--navy); color: #b9c2d4; border-top: 4px solid var(--orange); }
.site-footer .wrap { padding: 22px 20px; display: flex; justify-content: space-between; gap: 14px; flex-wrap: wrap; font-size: 13px; }
.site-footer a { color: #fff; text-decoration: none; }

/* 404 */
.notfound { max-width: 640px; margin: 80px auto; padding: 0 20px; }
.notfound h1 { margin-bottom: 12px; }

/* Responsive */
@media (max-width: 860px) {
  .hero-inner { flex-direction: column; }
  .hero-photo { min-height: 220px; }
  .industries { flex-wrap: wrap; }
  .industry-tile { flex: 1 1 44%; }
  .tile-featured { flex: 1 1 100%; }
}
@media (max-width: 720px) {
  .doors, .terms-row, .cards-3 { flex-direction: column; }
  .site-header .wrap { justify-content: center; text-align: center; }
  .main-nav { justify-content: center; }
}
```

- [ ] **Step 2: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep -E "styles|color"`
Expected: `PASS: styles.css exists`, `PASS: navy color present`, `PASS: orange color present`.

- [ ] **Step 3: Commit**

```bash
git add site/css/styles.css
git commit -m "feat: add design system stylesheet"
```

---

### Task 3: Optimize images

**Files:**
- Create: `site/img/hero.jpg`, `site/img/insurance.jpg`, `site/img/legal.jpg`, `site/img/healthcare.jpg`, `site/img/finance.jpg`, `site/img/it.jpg`, `site/img/og.png`
- Create: `scripts/prep-images.py`

**Interfaces:**
- Consumes: `assets-src/*.png` (extracted from Michael's handout PDFs in the brainstorming session).
- Produces: the seven web images above at the exact paths pages reference.

- [ ] **Step 1: Create `scripts/prep-images.py`**

```python
#!/usr/bin/env python3
"""Prepare web images from handout source art. Run from repo root."""
from PIL import Image, ImageDraw, ImageFont
import os

SRC = 'assets-src'
OUT = 'site/img'
os.makedirs(OUT, exist_ok=True)

def jpeg(src, dest, width, quality=80):
    im = Image.open(os.path.join(SRC, src)).convert('RGB')
    if im.width > width:
        im = im.resize((width, round(im.height * width / im.width)), Image.LANCZOS)
    im.save(os.path.join(OUT, dest), 'JPEG', quality=quality, optimize=True, progressive=True)
    kb = os.path.getsize(os.path.join(OUT, dest)) // 1024
    print(f'{dest}: {im.width}x{im.height} {kb}KB')
    return kb

hero_kb = jpeg('h1_img1_1827x602.png', 'hero.jpg', 1400, 78)
assert hero_kb < 150, f'hero.jpg too big: {hero_kb}KB, lower quality and rerun'
jpeg('h2_img4_1124x749.png', 'insurance.jpg', 600)
jpeg('h2_img7_1204x602.png', 'legal.jpg', 600)
jpeg('h2_img6_807x807.png', 'healthcare.jpg', 600)
jpeg('h2_img3_980x653.png', 'finance.jpg', 600)
jpeg('h2_img5_1095x714.png', 'it.jpg', 600)

# Social share card 1200x630: navy field, brand lockup, orange ring motif.
og = Image.new('RGB', (1200, 630), '#1F2A44')
d = ImageDraw.Draw(og)
d.ellipse([880, 140, 1120, 380], outline='#F4924E', width=10)
try:
    f_big = ImageFont.truetype('/System/Library/Fonts/HelveticaNeue.ttc', 74, index=1)
    f_small = ImageFont.truetype('/System/Library/Fonts/HelveticaNeue.ttc', 34, index=1)
    f_tag = ImageFont.truetype('/System/Library/Fonts/HelveticaNeue.ttc', 30, index=0)
except OSError:
    f_big = f_small = f_tag = ImageFont.load_default()
d.text((90, 200), 'PROFESSIONAL', font=f_big, fill='#ffffff')
d.text((90, 290), 'SEARCH', font=f_big, fill='#ffffff')
d.text((92, 392), 'S T A F F I N G   &   R E C R U I T I N G', font=f_small, fill='#F4924E')
d.text((92, 470), 'Insurance talent, placed right. 30+ years.', font=f_tag, fill='#b9c2d4')
og.save(os.path.join(OUT, 'og.png'), 'PNG', optimize=True)
print('og.png:', os.path.getsize(os.path.join(OUT, 'og.png')) // 1024, 'KB')
```

- [ ] **Step 2: Run it**

Run: `cd "/Users/michaellazaro/Desktop/Apps /ProfSearch-Website" && python3 scripts/prep-images.py`
Expected: seven lines printed, `hero.jpg` under 150 KB, no assertion error.

- [ ] **Step 3: Look at the output images**

Read `site/img/hero.jpg` and `site/img/og.png` with the file viewer. Expected: hero shows the magnifying-glass-over-paper-people photo cleanly; og.png shows the brand lockup, no clipped text. If og.png text clips or the font failed to load, adjust coordinates or font path and rerun.

- [ ] **Step 4: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep -E "hero|necklace|og "`
Expected: `PASS: hero image exists`, `PASS: no necklace image shipped`, `PASS: hero under 150KB`, `PASS: og image exists`.

- [ ] **Step 5: Commit**

```bash
git add scripts/prep-images.py site/img
git commit -m "feat: add optimized web images and social share card"
```

---

### Task 4: Homepage (index.html)

**Files:**
- Create: `site/index.html`

**Interfaces:**
- Consumes: `css/styles.css` classes from Task 2, images from Task 3, `js/copy-email.js` from Task 1.
- Produces: the shared header/footer markup pattern that Tasks 5-8 copy verbatim (only `aria-current` moves and `<title>`/meta change).

- [ ] **Step 1: Create `site/index.html` (complete file)**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Professional Search | Insurance Staffing and Recruiting Agency</title>
<meta name="description" content="Family-owned national insurance staffing agency with 30+ years of placements. Direct hire, temp-to-hire, and contract recruiting for claims, broker, and risk professionals. 15% fee, 90-day guarantee.">
<link rel="canonical" href="https://profsearch.net/">
<link rel="icon" href="img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="css/styles.css">
<meta property="og:title" content="Professional Search | Insurance Staffing and Recruiting">
<meta property="og:description" content="Family-owned national insurance staffing agency with 30+ years of placements. 15% fee, 90-day guarantee.">
<meta property="og:image" content="https://profsearch.net/img/og.png">
<meta property="og:url" content="https://profsearch.net/">
<meta property="og:type" content="website">
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "EmploymentAgency",
  "name": "Professional Search",
  "description": "Family-owned insurance staffing and recruiting agency with over 30 years of placements nationwide.",
  "url": "https://profsearch.net/",
  "email": "mike@profsearch.net",
  "telephone": "+1-415-246-7302",
  "founder": { "@type": "Person", "name": "Mike Lazaro" },
  "areaServed": "US",
  "sameAs": ["https://www.linkedin.com/in/michael-lazaro-b891a011a"]
}
</script>
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="logo" href="index.html">
      <svg class="logo-mark" viewBox="0 0 34 30" fill="none" stroke="#1F2A44" stroke-width="1.6" aria-hidden="true">
        <circle cx="9" cy="7" r="3.2"/><circle cx="17" cy="5" r="3.2"/><circle cx="25" cy="7" r="3.2"/>
        <path d="M4 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/><path d="M12 20 v-8 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v8"/><path d="M20 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/>
      </svg>
      <span class="logo-text"><span class="l1">PROFESSIONAL SEARCH</span><span class="l2">STAFFING &amp; RECRUITING</span></span>
    </a>
    <nav class="main-nav" aria-label="Main">
      <a href="index.html" aria-current="page">Home</a>
      <a href="employers.html">For Employers</a>
      <a href="job-seekers.html">For Job Seekers</a>
      <a href="about.html">About</a>
      <a href="contact.html">Contact</a>
      <a class="nav-phone" href="tel:+14152467302">415-246-7302</a>
    </nav>
  </div>
</header>

<section class="hero">
  <div class="hero-inner">
    <div class="hero-copy">
      <span class="kicker">INSURANCE STAFFING &amp; RECRUITING</span>
      <h1>The insurance talent partner with <em>30+ years</em> of placements.</h1>
      <p>Professional Search is a family-owned staffing and recruiting agency serving employers nationwide. We place claims, broker, and risk professionals through direct hire, temp-to-hire, and contract assignments.</p>
      <div class="hero-ctas">
        <a class="btn btn-navy" href="employers.html">I'm hiring</a>
        <a class="btn btn-orange" href="job-seekers.html">I'm looking for work</a>
      </div>
    </div>
    <div class="hero-photo" style="background-image:url('img/hero.jpg')" role="img" aria-label="Magnifying glass examining a row of paper people, one highlighted"></div>
  </div>
</section>

<div class="band"><h2>Staffing &amp; Recruiting Expertise</h2></div>
<div class="band-rule"></div>

<main>
<div class="wrap">
  <div class="doors">
    <div class="door door-employers">
      <h3>FOR EMPLOYERS</h3>
      <p>Open roles to fill? We source vetted insurance professionals at every level, from claims staff to department leaders, plus talent in legal, healthcare, finance, and IT.</p>
      <p class="facts">15% of base salary. 90-day guarantee. Free temp-to-perm conversion after 6 months.</p>
      <a class="btn btn-navy" href="employers.html">Start a search</a>
      <a class="aux" href="tel:+14152467302">Or call Mike: 415-246-7302</a>
    </div>
    <div class="door door-seekers">
      <h3>FOR JOB SEEKERS</h3>
      <p>Put 30+ years of employer relationships to work on your next move. If you have insurance industry experience, send your resume today. Candidates never pay a fee.</p>
      <a class="btn btn-orange" href="mailto:mike@profsearch.net?subject=Resume%20Submission%20-%20Insurance%20Professional&amp;body=Hi%20Mike%2C%0A%0AMy%20resume%20is%20attached.%20I%27m%20looking%20for%20%5Brole%20type%5D%20roles%20in%20%5Bcity%2Fstate%20or%20remote%5D.%0A%0AThanks%2C">Email your resume</a>
      <a class="aux" href="job-seekers.html">See the roles we place</a>
    </div>
  </div>

  <div class="terms-row">
    <div class="term"><strong>15% flat fee</strong><span>Of first-year base salary. Below what most agencies charge.</span></div>
    <div class="term"><strong>90-day guarantee</strong><span>Every placement is backed for a full 90 days.</span></div>
    <div class="term"><strong>Free conversion</strong><span>Contract hires become your permanent employees at no cost after 6 months.</span></div>
  </div>
</div>

<div class="band"><h2>Insurance is our specialty. We staff beyond it.</h2></div>
<div class="band-rule"></div>

<div class="wrap">
  <div class="industries" style="padding-top:34px;">
    <div class="industry-tile tile-featured">
      <div class="tile-photo" style="background-image:url('img/insurance.jpg')" role="img" aria-label="Insurance policy folders for auto, home, life, and medical lines"></div>
      <div class="tile-label">INSURANCE: OUR SPECIALTY</div>
    </div>
    <div class="industry-tile">
      <div class="tile-photo" style="background-image:url('img/legal.jpg')" role="img" aria-label="Gavel and scales of justice"></div>
      <div class="tile-label">LEGAL</div>
    </div>
    <div class="industry-tile">
      <div class="tile-photo" style="background-image:url('img/healthcare.jpg')" role="img" aria-label="Healthcare team joining hands"></div>
      <div class="tile-label">HEALTHCARE</div>
    </div>
    <div class="industry-tile">
      <div class="tile-photo" style="background-image:url('img/finance.jpg')" role="img" aria-label="Calculator, currency, and financial charts"></div>
      <div class="tile-label">FINANCE</div>
    </div>
    <div class="industry-tile">
      <div class="tile-photo" style="background-image:url('img/it.jpg')" role="img" aria-label="Software engineer working at a computer"></div>
      <div class="tile-label">IT</div>
    </div>
  </div>
</div>
</main>

<section class="connect-band">
  <div class="wrap">
    <div class="connect-circle">Let's<br>Connect!</div>
    <div class="connect-details">
      <div><span class="ico">&#9993;</span> <a href="mailto:mike@profsearch.net">mike@profsearch.net</a></div>
      <div><span class="ico">&#9990;</span> <a href="tel:+14152467302">415-246-7302</a></div>
      <div><span class="ico">in</span> <a href="https://www.linkedin.com/in/michael-lazaro-b891a011a" rel="noopener" target="_blank">Mike Lazaro on LinkedIn</a></div>
    </div>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <span>&copy; 2026 Professional Search. Insurance Staffing &amp; Recruiting.</span>
    <span><a href="mailto:mike@profsearch.net">mike@profsearch.net</a> &nbsp;|&nbsp; <a href="tel:+14152467302">415-246-7302</a></span>
  </div>
</footer>

<script src="js/copy-email.js" defer></script>
</body>
</html>
```

- [ ] **Step 2: Serve locally and eyeball**

Start the dev server via the project preview tool (`.claude/launch.json` entry `site`, `python3 -m http.server 8901 --directory site`, port 8901). Open `http://localhost:8901/`. Expected: homepage renders with hero photo right, both doors, industries strip, connect band. No 404s in the network panel except the four pages not yet built.

- [ ] **Step 3: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep "index"`
Expected: every `site/index.html` line PASS, plus `PASS: resume mailto on homepage`, `PASS: JSON-LD EmploymentAgency`.

- [ ] **Step 4: Commit**

```bash
git add site/index.html
git commit -m "feat: add homepage"
```

---

### Task 5: For Employers page

**Files:**
- Create: `site/employers.html`

**Interfaces:**
- Consumes: header/footer pattern from Task 4 (aria-current moved to For Employers), CSS classes from Task 2.

- [ ] **Step 1: Create `site/employers.html` (complete file)**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Hire Insurance Talent | Professional Search Staffing</title>
<meta name="description" content="Fill claims, broker, loss control, and risk roles with vetted insurance professionals. 15% of base salary, 90-day guarantee, free temp-to-perm conversion. Call 415-246-7302.">
<link rel="canonical" href="https://profsearch.net/employers.html">
<link rel="icon" href="img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="css/styles.css">
<meta property="og:title" content="Hire Insurance Talent | Professional Search">
<meta property="og:description" content="Vetted insurance professionals. 15% fee, 90-day guarantee.">
<meta property="og:image" content="https://profsearch.net/img/og.png">
<meta property="og:url" content="https://profsearch.net/employers.html">
<meta property="og:type" content="website">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="logo" href="index.html">
      <svg class="logo-mark" viewBox="0 0 34 30" fill="none" stroke="#1F2A44" stroke-width="1.6" aria-hidden="true">
        <circle cx="9" cy="7" r="3.2"/><circle cx="17" cy="5" r="3.2"/><circle cx="25" cy="7" r="3.2"/>
        <path d="M4 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/><path d="M12 20 v-8 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v8"/><path d="M20 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/>
      </svg>
      <span class="logo-text"><span class="l1">PROFESSIONAL SEARCH</span><span class="l2">STAFFING &amp; RECRUITING</span></span>
    </a>
    <nav class="main-nav" aria-label="Main">
      <a href="index.html">Home</a>
      <a href="employers.html" aria-current="page">For Employers</a>
      <a href="job-seekers.html">For Job Seekers</a>
      <a href="about.html">About</a>
      <a href="contact.html">Contact</a>
      <a class="nav-phone" href="tel:+14152467302">415-246-7302</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="wrap">
    <span class="kicker">FOR EMPLOYERS</span>
    <h1>Hire vetted insurance professionals.</h1>
    <p>You work with one recruiter, Mike Lazaro, backed by Professional Search's 30+ years of insurance placements. Describe the role. Get a short list of candidates worth interviewing, not a stack of resumes.</p>
    <div class="hero-ctas">
      <a class="btn btn-navy" href="mailto:mike@profsearch.net?subject=Hiring%20Inquiry&amp;body=Hi%20Mike%2C%0A%0AWe%27re%20looking%20to%20fill%20%5Brole%5D%20in%20%5Blocation%5D.%20Please%20get%20in%20touch.%0A%0AThanks%2C">Email Mike about a role</a>
      <a class="btn btn-outline" href="tel:+14152467302">Call 415-246-7302</a>
    </div>
  </div>
</section>

<main>
<div class="wrap section">
  <h2 class="section-title">Three ways to hire</h2>
  <div class="cards-3">
    <div class="card"><h3>Direct Hire</h3><p>We recruit, screen, and deliver finalists for your permanent role. You hire; the 90-day guarantee backs the placement.</p></div>
    <div class="card"><h3>Temp-to-Hire</h3><p>Evaluate on the job before committing. After 6 months of employment, conversion to your payroll is free.</p></div>
    <div class="card"><h3>Contract / Temporary</h3><p>Cover surges, leaves, and projects with experienced insurance professionals who contribute from day one.</p></div>
  </div>
</div>

<div class="band"><h2>Straightforward terms</h2></div>
<div class="band-rule"></div>

<div class="wrap">
  <div class="terms-row" style="padding-top:34px;">
    <div class="term"><strong>15% of base salary</strong><span>One flat fee, below what most agencies charge.</span></div>
    <div class="term"><strong>90-day guarantee</strong><span>If a placement does not work out in the first 90 days, we make it right.</span></div>
    <div class="term"><strong>Free conversion</strong><span>Contract candidates join your payroll at no charge after 6 months of employment.</span></div>
  </div>
</div>

<div class="wrap section" style="padding-top:0;">
  <h2 class="section-title">Roles we fill</h2>
  <div class="role-columns">
    <div class="role-group">
      <h3>INSURANCE, OUR SPECIALTY</h3>
      <ul>
        <li>All positions within claims departments</li>
        <li>Commercial lines and employee benefits account managers and account executives</li>
        <li>Producers and brokers</li>
        <li>Loss control</li>
        <li>Risk management</li>
      </ul>
    </div>
    <div class="role-group">
      <h3>LEGAL</h3>
      <ul><li>Legal assistants</li><li>Paralegals</li><li>Attorneys</li></ul>
      <h3 style="margin-top:16px;">IT</h3>
      <ul><li>Software engineers</li></ul>
    </div>
    <div class="role-group">
      <h3>HEALTHCARE</h3>
      <ul><li>All lines of nursing</li><li>Workers' compensation</li><li>Nurse case managers</li><li>Coding</li><li>Auditing</li><li>Pharmacy / PBM</li></ul>
    </div>
    <div class="role-group">
      <h3>FINANCE</h3>
      <ul><li>Accounting and finance professionals</li><li>Accounting managers</li><li>Finance managers</li><li>Staff accountants</li><li>Junior accountants</li><li>Chief financial officers</li></ul>
    </div>
  </div>
</div>

<div class="wrap section" style="padding-top:0;">
  <h2 class="section-title">Why Professional Search</h2>
  <div class="cards-3">
    <div class="card"><h3>30+ years of relationships</h3><p>Three decades of placements built a national network of insurance professionals we can reach when your role opens.</p></div>
    <div class="card"><h3>You work with the owner</h3><p>Family-owned. No junior account reps and no handoffs. Mike runs every search himself.</p></div>
    <div class="card"><h3>Specialists, not generalists</h3><p>We speak claims, underwriting, and risk. Candidates arrive screened for insurance experience, not keyword-matched.</p></div>
  </div>
</div>
</main>

<section class="connect-band">
  <div class="wrap">
    <div class="connect-circle">Let's<br>Connect!</div>
    <div class="connect-details">
      <div><span class="ico">&#9993;</span> <a href="mailto:mike@profsearch.net?subject=Hiring%20Inquiry">mike@profsearch.net</a></div>
      <div><span class="ico">&#9990;</span> <a href="tel:+14152467302">415-246-7302</a></div>
      <div><span class="ico">in</span> <a href="https://www.linkedin.com/in/michael-lazaro-b891a011a" rel="noopener" target="_blank">Mike Lazaro on LinkedIn</a></div>
    </div>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <span>&copy; 2026 Professional Search. Insurance Staffing &amp; Recruiting.</span>
    <span><a href="mailto:mike@profsearch.net">mike@profsearch.net</a> &nbsp;|&nbsp; <a href="tel:+14152467302">415-246-7302</a></span>
  </div>
</footer>

<script src="js/copy-email.js" defer></script>
</body>
</html>
```

- [ ] **Step 2: Eyeball in browser**

Reload `http://localhost:8901/employers.html`. Expected: page hero, three service cards, terms row, four role columns, why-us cards, connect band. Nav highlights For Employers.

- [ ] **Step 3: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep "employers"`
Expected: all employers.html assertions PASS including `hiring mailto`.

- [ ] **Step 4: Commit**

```bash
git add site/employers.html
git commit -m "feat: add for-employers page"
```

---

### Task 6: For Job Seekers page

**Files:**
- Create: `site/job-seekers.html`

**Interfaces:**
- Consumes: header/footer pattern from Task 4 (aria-current on For Job Seekers), `.copy-email` behavior from Task 1.

- [ ] **Step 1: Create `site/job-seekers.html` (complete file)**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Insurance Jobs - Email Your Resume | Professional Search</title>
<meta name="description" content="Looking for claims, broker, or risk roles? Email your resume to mike@profsearch.net. 30+ years of employer relationships, nationwide placements, never a fee for candidates.">
<link rel="canonical" href="https://profsearch.net/job-seekers.html">
<link rel="icon" href="img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="css/styles.css">
<meta property="og:title" content="Insurance Jobs - Email Your Resume | Professional Search">
<meta property="og:description" content="30+ years of employer relationships. Email your resume today.">
<meta property="og:image" content="https://profsearch.net/img/og.png">
<meta property="og:url" content="https://profsearch.net/job-seekers.html">
<meta property="og:type" content="website">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="logo" href="index.html">
      <svg class="logo-mark" viewBox="0 0 34 30" fill="none" stroke="#1F2A44" stroke-width="1.6" aria-hidden="true">
        <circle cx="9" cy="7" r="3.2"/><circle cx="17" cy="5" r="3.2"/><circle cx="25" cy="7" r="3.2"/>
        <path d="M4 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/><path d="M12 20 v-8 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v8"/><path d="M20 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/>
      </svg>
      <span class="logo-text"><span class="l1">PROFESSIONAL SEARCH</span><span class="l2">STAFFING &amp; RECRUITING</span></span>
    </a>
    <nav class="main-nav" aria-label="Main">
      <a href="index.html">Home</a>
      <a href="employers.html">For Employers</a>
      <a href="job-seekers.html" aria-current="page">For Job Seekers</a>
      <a href="about.html">About</a>
      <a href="contact.html">Contact</a>
      <a class="nav-phone" href="tel:+14152467302">415-246-7302</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="wrap">
    <span class="kicker">FOR JOB SEEKERS</span>
    <h1>Your next insurance role starts with one email.</h1>
    <p>Employers nationwide ask Professional Search for claims, broker, and risk professionals. Send your resume and Mike matches you against openings that fit your experience and location. No portals and no accounts. Candidates never pay a fee.</p>
    <div class="hero-ctas">
      <a class="btn btn-orange" href="mailto:mike@profsearch.net?subject=Resume%20Submission%20-%20Insurance%20Professional&amp;body=Hi%20Mike%2C%0A%0AMy%20resume%20is%20attached.%20I%27m%20looking%20for%20%5Brole%20type%5D%20roles%20in%20%5Bcity%2Fstate%20or%20remote%5D.%0A%0AThanks%2C">Email your resume</a>
    </div>
    <div class="email-line">
      <span>Attach your resume as a PDF or Word doc to:</span>
      <code>mike@profsearch.net</code>
      <button class="copy-email" type="button">Copy address</button>
    </div>
  </div>
</section>

<main>
<div class="wrap section">
  <h2 class="section-title">How it works</h2>
  <div class="steps">
    <div class="step"><div><h3>Email your resume</h3><p>PDF or Word, attached to a note with the role type and location you want. If you have insurance industry experience, we want to see it.</p></div></div>
    <div class="step"><div><h3>Talk with Mike</h3><p>A direct conversation about your goals, salary expectations, and where you want to work. Confidential, always.</p></div></div>
    <div class="step"><div><h3>Interview with matched employers</h3><p>Mike presents you to employers Professional Search has served for decades, for roles that actually fit. Direct hire, temp-to-hire, or contract.</p></div></div>
  </div>
</div>

<div class="band"><h2>Roles we place</h2></div>
<div class="band-rule"></div>

<div class="wrap section">
  <div class="role-columns">
    <div class="role-group">
      <h3>INSURANCE, OUR SPECIALTY</h3>
      <ul>
        <li>All positions within claims departments</li>
        <li>Commercial lines and employee benefits account managers and account executives</li>
        <li>Producers and brokers</li>
        <li>Loss control</li>
        <li>Risk management</li>
      </ul>
    </div>
    <div class="role-group">
      <h3>LEGAL</h3>
      <ul><li>Legal assistants</li><li>Paralegals</li><li>Attorneys</li></ul>
      <h3 style="margin-top:16px;">IT</h3>
      <ul><li>Software engineers</li></ul>
    </div>
    <div class="role-group">
      <h3>HEALTHCARE</h3>
      <ul><li>All lines of nursing</li><li>Workers' compensation</li><li>Nurse case managers</li><li>Coding</li><li>Auditing</li><li>Pharmacy / PBM</li></ul>
    </div>
    <div class="role-group">
      <h3>FINANCE</h3>
      <ul><li>Accounting and finance professionals</li><li>Accounting managers</li><li>Finance managers</li><li>Staff accountants</li><li>Junior accountants</li><li>Chief financial officers</li></ul>
    </div>
  </div>
  <p style="margin-top:26px;"><a class="btn btn-orange" href="mailto:mike@profsearch.net?subject=Resume%20Submission%20-%20Insurance%20Professional&amp;body=Hi%20Mike%2C%0A%0AMy%20resume%20is%20attached.%20I%27m%20looking%20for%20%5Brole%20type%5D%20roles%20in%20%5Bcity%2Fstate%20or%20remote%5D.%0A%0AThanks%2C">Email your resume to Mike</a></p>
</div>
</main>

<section class="connect-band">
  <div class="wrap">
    <div class="connect-circle">Let's<br>Connect!</div>
    <div class="connect-details">
      <div><span class="ico">&#9993;</span> <a href="mailto:mike@profsearch.net?subject=Resume%20Submission%20-%20Insurance%20Professional">mike@profsearch.net</a></div>
      <div><span class="ico">&#9990;</span> <a href="tel:+14152467302">415-246-7302</a></div>
      <div><span class="ico">in</span> <a href="https://www.linkedin.com/in/michael-lazaro-b891a011a" rel="noopener" target="_blank">Mike Lazaro on LinkedIn</a></div>
    </div>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <span>&copy; 2026 Professional Search. Insurance Staffing &amp; Recruiting.</span>
    <span><a href="mailto:mike@profsearch.net">mike@profsearch.net</a> &nbsp;|&nbsp; <a href="tel:+14152467302">415-246-7302</a></span>
  </div>
</footer>

<script src="js/copy-email.js" defer></script>
</body>
</html>
```

- [ ] **Step 2: Eyeball + test the copy button**

Reload `http://localhost:8901/job-seekers.html`. Click "Copy address". Expected: button text flips to "Copied!" for 2 seconds; clipboard now holds `mike@profsearch.net` (verify by pasting into the browser URL bar). Click "Email your resume". Expected: mail client opens pre-addressed with subject `Resume Submission - Insurance Professional`.

- [ ] **Step 3: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep "job-seekers"`
Expected: all job-seekers.html assertions PASS including `resume mailto with hyphen subject`.

- [ ] **Step 4: Commit**

```bash
git add site/job-seekers.html
git commit -m "feat: add for-job-seekers page with resume email flow"
```

---

### Task 7: About page

**Files:**
- Create: `site/about.html`

**Interfaces:**
- Consumes: header/footer pattern from Task 4 (aria-current on About).

- [ ] **Step 1: Create `site/about.html` (complete file)**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>About Professional Search | 30+ Years of Insurance Recruiting</title>
<meta name="description" content="Professional Search is a family-owned insurance staffing and recruiting agency. For over 30 years, we have connected employers nationwide with top-tier insurance talent.">
<link rel="canonical" href="https://profsearch.net/about.html">
<link rel="icon" href="img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="css/styles.css">
<meta property="og:title" content="About Professional Search">
<meta property="og:description" content="Family-owned insurance staffing and recruiting, over 30 years.">
<meta property="og:image" content="https://profsearch.net/img/og.png">
<meta property="og:url" content="https://profsearch.net/about.html">
<meta property="og:type" content="website">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="logo" href="index.html">
      <svg class="logo-mark" viewBox="0 0 34 30" fill="none" stroke="#1F2A44" stroke-width="1.6" aria-hidden="true">
        <circle cx="9" cy="7" r="3.2"/><circle cx="17" cy="5" r="3.2"/><circle cx="25" cy="7" r="3.2"/>
        <path d="M4 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/><path d="M12 20 v-8 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v8"/><path d="M20 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/>
      </svg>
      <span class="logo-text"><span class="l1">PROFESSIONAL SEARCH</span><span class="l2">STAFFING &amp; RECRUITING</span></span>
    </a>
    <nav class="main-nav" aria-label="Main">
      <a href="index.html">Home</a>
      <a href="employers.html">For Employers</a>
      <a href="job-seekers.html">For Job Seekers</a>
      <a href="about.html" aria-current="page">About</a>
      <a href="contact.html">Contact</a>
      <a class="nav-phone" href="tel:+14152467302">415-246-7302</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="wrap">
    <span class="kicker">ABOUT US</span>
    <h1>Family-owned and insurance-focused for over 30 years.</h1>
    <p>Professional Search has spent three decades forging connections between employers and top-tier talent across the insurance industry.</p>
  </div>
</section>

<main>
<div class="wrap section">
  <h2 class="section-title">The Professional Search story</h2>
  <p>Professional Search is a family-owned staffing and recruiting agency. For over 30 years we have specialized in the insurance industry, sourcing qualified claims professionals at every level and dynamic insurance leaders for employers locally and nationally.</p>
  <p>The model has stayed the same for three decades: know the industry, know the people, and never hand a client a stack of resumes when a short list of the right candidates will do. That approach built lasting relationships with employers who come back every time a seat opens, and with candidates who send us their colleagues when we place them.</p>
  <p>Alongside the insurance specialty, clients rely on us to fill roles in legal, healthcare, finance, and IT.</p>
</div>

<div class="band"><h2>Who you'll work with</h2></div>
<div class="band-rule"></div>

<div class="wrap section">
  <p>Every search at Professional Search runs through <strong>Mike Lazaro</strong>. When you call or email, you reach the person who actually fills the role: no account managers, no handoffs, no call centers. Employers get a recruiting partner who has seen every kind of insurance hire; candidates get a direct line to someone who knows which employers are worth their time.</p>
  <p style="margin-top:14px;"><a class="btn btn-navy" href="https://www.linkedin.com/in/michael-lazaro-b891a011a" rel="noopener" target="_blank">Connect with Mike on LinkedIn</a></p>
</div>
</main>

<section class="connect-band">
  <div class="wrap">
    <div class="connect-circle">Let's<br>Connect!</div>
    <div class="connect-details">
      <div><span class="ico">&#9993;</span> <a href="mailto:mike@profsearch.net">mike@profsearch.net</a></div>
      <div><span class="ico">&#9990;</span> <a href="tel:+14152467302">415-246-7302</a></div>
      <div><span class="ico">in</span> <a href="https://www.linkedin.com/in/michael-lazaro-b891a011a" rel="noopener" target="_blank">Mike Lazaro on LinkedIn</a></div>
    </div>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <span>&copy; 2026 Professional Search. Insurance Staffing &amp; Recruiting.</span>
    <span><a href="mailto:mike@profsearch.net">mike@profsearch.net</a> &nbsp;|&nbsp; <a href="tel:+14152467302">415-246-7302</a></span>
  </div>
</footer>

<script src="js/copy-email.js" defer></script>
</body>
</html>
```

- [ ] **Step 2: Eyeball**

Reload `http://localhost:8901/about.html`. Expected: story section, "Who you'll work with" band, LinkedIn button works.

- [ ] **Step 3: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep "about"`
Expected: all about.html assertions PASS including `LinkedIn linked on about`.

- [ ] **Step 4: Commit**

```bash
git add site/about.html
git commit -m "feat: add about page"
```

---

### Task 8: Contact page

**Files:**
- Create: `site/contact.html`

**Interfaces:**
- Consumes: header/footer pattern from Task 4 (aria-current on Contact), `.copy-email` from Task 1.

- [ ] **Step 1: Create `site/contact.html` (complete file)**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Contact Mike Lazaro | Professional Search</title>
<meta name="description" content="Reach Professional Search: email mike@profsearch.net or call 415-246-7302. Hiring for insurance roles or looking for your next one? Let's connect.">
<link rel="canonical" href="https://profsearch.net/contact.html">
<link rel="icon" href="img/favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="css/styles.css">
<meta property="og:title" content="Contact | Professional Search">
<meta property="og:description" content="Email mike@profsearch.net or call 415-246-7302.">
<meta property="og:image" content="https://profsearch.net/img/og.png">
<meta property="og:url" content="https://profsearch.net/contact.html">
<meta property="og:type" content="website">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="logo" href="index.html">
      <svg class="logo-mark" viewBox="0 0 34 30" fill="none" stroke="#1F2A44" stroke-width="1.6" aria-hidden="true">
        <circle cx="9" cy="7" r="3.2"/><circle cx="17" cy="5" r="3.2"/><circle cx="25" cy="7" r="3.2"/>
        <path d="M4 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/><path d="M12 20 v-8 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v8"/><path d="M20 22 v-6 a5 5 0 0 1 5-5 h0 a5 5 0 0 1 5 5 v6"/>
      </svg>
      <span class="logo-text"><span class="l1">PROFESSIONAL SEARCH</span><span class="l2">STAFFING &amp; RECRUITING</span></span>
    </a>
    <nav class="main-nav" aria-label="Main">
      <a href="index.html">Home</a>
      <a href="employers.html">For Employers</a>
      <a href="job-seekers.html">For Job Seekers</a>
      <a href="about.html">About</a>
      <a href="contact.html" aria-current="page">Contact</a>
      <a class="nav-phone" href="tel:+14152467302">415-246-7302</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="wrap">
    <span class="kicker">CONTACT</span>
    <h1>Let's connect.</h1>
    <p>Hiring for an insurance role, or ready for your next one? Reach Mike directly.</p>
  </div>
</section>

<main>
<div class="wrap section">
  <h2 class="section-title">Two ways to reach Mike</h2>
  <div class="doors">
    <div class="door door-employers">
      <h3>HIRING?</h3>
      <p>Tell Mike about the role: title, location, and what the ideal hire looks like.</p>
      <a class="btn btn-navy" href="mailto:mike@profsearch.net?subject=Hiring%20Inquiry&amp;body=Hi%20Mike%2C%0A%0AWe%27re%20looking%20to%20fill%20%5Brole%5D%20in%20%5Blocation%5D.%20Please%20get%20in%20touch.%0A%0AThanks%2C">Email about hiring</a>
      <a class="aux" href="tel:+14152467302">Or call: 415-246-7302</a>
    </div>
    <div class="door door-seekers">
      <h3>JOB SEEKING?</h3>
      <p>Attach your resume as a PDF or Word doc and tell Mike the role type and location you want.</p>
      <a class="btn btn-orange" href="mailto:mike@profsearch.net?subject=Resume%20Submission%20-%20Insurance%20Professional&amp;body=Hi%20Mike%2C%0A%0AMy%20resume%20is%20attached.%20I%27m%20looking%20for%20%5Brole%20type%5D%20roles%20in%20%5Bcity%2Fstate%20or%20remote%5D.%0A%0AThanks%2C">Email your resume</a>
    </div>
  </div>
  <div class="email-line">
    <span>Email:</span>
    <code>mike@profsearch.net</code>
    <button class="copy-email" type="button">Copy address</button>
  </div>
</div>
</main>

<section class="connect-band">
  <div class="wrap">
    <div class="connect-circle">Let's<br>Connect!</div>
    <div class="connect-details">
      <div><span class="ico">&#9993;</span> <a href="mailto:mike@profsearch.net">mike@profsearch.net</a></div>
      <div><span class="ico">&#9990;</span> <a href="tel:+14152467302">415-246-7302</a></div>
      <div><span class="ico">in</span> <a href="https://www.linkedin.com/in/michael-lazaro-b891a011a" rel="noopener" target="_blank">Mike Lazaro on LinkedIn</a></div>
    </div>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <span>&copy; 2026 Professional Search. Insurance Staffing &amp; Recruiting.</span>
    <span><a href="mailto:mike@profsearch.net">mike@profsearch.net</a> &nbsp;|&nbsp; <a href="tel:+14152467302">415-246-7302</a></span>
  </div>
</footer>

<script src="js/copy-email.js" defer></script>
</body>
</html>
```

- [ ] **Step 2: Eyeball**

Reload `http://localhost:8901/contact.html`. Expected: two doors, email line with working copy button, connect band.

- [ ] **Step 3: Verify checks**

Run: `./tests/check-site.sh 2>/dev/null | grep "contact"`
Expected: all contact.html assertions PASS including `LinkedIn linked on contact`.

- [ ] **Step 4: Commit**

```bash
git add site/contact.html
git commit -m "feat: add contact page"
```

---

### Task 9: Sitemap + full local verification

**Files:**
- Create: `site/sitemap.xml`

**Interfaces:**
- Consumes: everything built so far. Produces the fully green check script.

- [ ] **Step 1: Create `site/sitemap.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://profsearch.net/</loc><lastmod>2026-08-07</lastmod></url>
  <url><loc>https://profsearch.net/employers.html</loc><lastmod>2026-08-07</lastmod></url>
  <url><loc>https://profsearch.net/job-seekers.html</loc><lastmod>2026-08-07</lastmod></url>
  <url><loc>https://profsearch.net/about.html</loc><lastmod>2026-08-07</lastmod></url>
  <url><loc>https://profsearch.net/contact.html</loc><lastmod>2026-08-07</lastmod></url>
</urlset>
```

- [ ] **Step 2: Run the full check script**

Run: `./tests/check-site.sh; echo "exit=$?"`
Expected: every line PASS, `exit=0`. Fix anything red before continuing.

- [ ] **Step 3: Full browser verification (desktop + mobile + dark)**

With the local server running: check all five pages at desktop width for layout breaks and console errors; resize to mobile (375px) and confirm single-column stacking, wrapped nav, readable text, tappable phone link; confirm no horizontal scrolling. Verify every nav link works from every page (no dead links).

- [ ] **Step 4: Internal link sweep**

Run:

```bash
cd "/Users/michaellazaro/Desktop/Apps /ProfSearch-Website" && python3 - <<'EOF'
import re, os
ok = True
for page in os.listdir('site'):
    if not page.endswith('.html'): continue
    html = open(f'site/{page}').read()
    refs = re.findall(r'(?:href|src)="([^"]+)"', html)
    refs += re.findall(r"url\('([^']+)'\)", html)
    for ref in refs:
        if ref.startswith(('http', 'mailto:', 'tel:', '#', 'data:')): continue
        if ref == '/': continue  # 404 page's homepage link, resolves at the domain root
        path = os.path.join('site', ref.split('?')[0].split('#')[0])
        if not os.path.exists(path):
            print(f'BROKEN in {page}: {ref}'); ok = False
print('all internal links resolve' if ok else 'FIX BROKEN LINKS')
EOF
```

Expected: `all internal links resolve`.

- [ ] **Step 5: Commit**

```bash
git add site/sitemap.xml
git commit -m "feat: add sitemap; site passes full local verification"
```

---

### Task 10: GitHub repo, Pages workflow, first deploy

**Files:**
- Create: `.github/workflows/deploy-pages.yml`
- Create: `README.md`

**Interfaces:**
- Consumes: the complete `site/` folder.
- Produces: live site at `https://mikedre707.github.io/profsearch-website/`, the temporary review URL. All internal links and assets are relative paths, so the site renders fully styled at this subpath URL AND later at profsearch.net. Michael reviews here on his phone before any DNS change.

- [ ] **Step 1: Create `.github/workflows/deploy-pages.yml`**

```yaml
name: Deploy site to GitHub Pages
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: true
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: site
      - id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 2: Create `README.md`**

```markdown
# Professional Search Website

Static marketing site for Professional Search (insurance staffing and recruiting), served at https://profsearch.net via GitHub Pages.

- `site/` is the deployable site. Everything else stays private to the repo.
- Deploys automatically from `main` via `.github/workflows/deploy-pages.yml`.
- `tests/check-site.sh` runs the static content assertions; keep it green.
- Design spec and plan live in `docs/superpowers/`.

Contact: mike@profsearch.net
```

- [ ] **Step 3: Run the pre-deploy verification gate**

Per Michael's standing rule, run the full check suite before any deploy:

Run: `./tests/check-site.sh; echo "exit=$?"`
Expected: `exit=0`. Do not push until green.

- [ ] **Step 4: Ensure branch is `main`, then create the GitHub repo and push**

```bash
cd "/Users/michaellazaro/Desktop/Apps /ProfSearch-Website"
git branch -M main
git add .github README.md
git commit -m "ci: add GitHub Pages deploy workflow and README"
gh repo create profsearch-website --public --source . --push
```

Expected: repo `mikedre707/profsearch-website` created, `main` pushed.

- [ ] **Step 5: Enable Pages (Actions build type) and watch the deploy**

```bash
gh api -X POST repos/mikedre707/profsearch-website/pages -f build_type=workflow 2>/dev/null || gh api -X PUT repos/mikedre707/profsearch-website/pages -f build_type=workflow
gh run watch --repo mikedre707/profsearch-website --exit-status
```

Expected: workflow `Deploy site to GitHub Pages` completes successfully. If the first run raced the Pages enablement and failed, re-run it: `gh run rerun --repo mikedre707/profsearch-website --failed`.

- [ ] **Step 6: Smoke-test the temporary URL**

```bash
curl -s -o /dev/null -w 'page: %{http_code}\n' https://mikedre707.github.io/profsearch-website/
curl -s -o /dev/null -w 'css: %{http_code}\n' https://mikedre707.github.io/profsearch-website/css/styles.css
curl -s -o /dev/null -w 'hero: %{http_code}\n' https://mikedre707.github.io/profsearch-website/img/hero.jpg
```

Expected: all `200`. Open the URL in the browser: fully styled homepage. Send the URL to Michael for phone review before Task 11.

- [ ] **Step 7: Commit nothing (already committed); confirm clean tree**

Run: `git status --short`
Expected: empty output.

---

### Task 11: Custom domain and DNS cutover (requires Michael at the registrar)

**Files:**
- None (GitHub settings + registrar DNS only)

**Interfaces:**
- Consumes: live Pages deployment from Task 10.
- Produces: https://profsearch.net serving the site with HTTPS; email untouched.

**STOP: This task needs Michael live. Do not start it without him.**

- [ ] **Step 1: Record current DNS before touching anything**

```bash
dig +short profsearch.net A
dig +short profsearch.net MX
dig +short profsearch.net TXT
dig +short www.profsearch.net CNAME
dig +short profsearch.net NS
```

Save the full output into `docs/dns-before-cutover.txt` and commit it. The NS lines identify the DNS host; that tells Michael where to log in. Cross-check with `whois profsearch.net | grep -i registrar`.

- [ ] **Step 2: Set the custom domain on the Pages site**

```bash
gh api -X PUT repos/mikedre707/profsearch-website/pages -f cname=profsearch.net
```

Expected: HTTP 204. GitHub now expects the domain and will provision a certificate once DNS points at it.

- [ ] **Step 3: Michael logs into the DNS host and changes ONLY these records**

Guide him to, in the DNS management panel:

- Delete or edit the existing apex `A` record(s) for `profsearch.net` (currently pointing at the old placeholder host) and add four `A` records: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`.
- Add or edit `www` as a `CNAME` to `mikedre707.github.io.`
- Touch nothing labeled MX, mail, TXT/SPF/DKIM/DMARC. Read every record's type out loud before saving.

- [ ] **Step 4: Verify DNS propagation**

Run (repeat until it matches; can take minutes to hours):

```bash
dig +short profsearch.net A
dig +short www.profsearch.net CNAME
dig +short profsearch.net MX
```

Expected: the four GitHub IPs; `mikedre707.github.io.`; MX output IDENTICAL to `docs/dns-before-cutover.txt`.

- [ ] **Step 5: Enforce HTTPS once the certificate issues**

```bash
gh api repos/mikedre707/profsearch-website/pages --jq '.https_certificate.state'
```

When it reports `approved` or `issued`, run:

```bash
gh api -X PUT repos/mikedre707/profsearch-website/pages -F https_enforced=true
```

- [ ] **Step 6: Full production smoke test**

```bash
curl -s -o /dev/null -w 'apex: %{http_code}\n' https://profsearch.net/
curl -s -o /dev/null -w 'www: %{http_code} -> %{redirect_url}\n' -I https://www.profsearch.net/
curl -s https://profsearch.net/ | grep -c "30+ years"
curl -s -o /dev/null -w 'css: %{http_code}\n' https://profsearch.net/css/styles.css
curl -s -o /dev/null -w 'sitemap: %{http_code}\n' https://profsearch.net/sitemap.xml
```

Expected: apex 200, www 200 or 301 to apex, grep count >= 1, css 200, sitemap 200. Then open https://profsearch.net in the browser and click through all five pages, desktop and mobile widths.

- [ ] **Step 7: Email safety confirmation**

Have Michael send an email from his phone to mike@profsearch.net and confirm it arrives, and send one out from mike@profsearch.net. Both must work. If either fails, restore the recorded DNS immediately from `docs/dns-before-cutover.txt`.

- [ ] **Step 8: Commit the DNS record file**

```bash
git add docs/dns-before-cutover.txt
git commit -m "docs: record pre-cutover DNS state"
git push
```

---

### Task 12: Post-launch (with Michael, optional, non-blocking)

- [ ] **Step 1: Google Search Console.** Walk Michael through adding the `profsearch.net` domain property (DNS TXT verification at the same registrar panel; a TXT ADD is safe and touches no existing records) and submit `https://profsearch.net/sitemap.xml`.
- [ ] **Step 2: tinyurl repoint.** If Michael wants, he logs into tinyurl and repoints `tinyurl.com/23r9w44e` from the Canva site to `https://profsearch.net` so all printed handouts lead to the real site.
- [ ] **Step 3: Old hosting.** Identify what the placeholder hosting was (from the NS/whois output in Task 11) and let Michael decide whether to cancel any paid plan there. Email hosting must be identified first; cancel nothing that could serve mail.

## Plan Self-Review (completed at write time)

- Spec coverage: five pages (Tasks 4-8), design system and signature elements (Task 2), contact mechanics with exact mailto strings (Tasks 4, 6, 8), images with necklace exclusion and hero size cap (Task 3), SEO meta + JSON-LD + sitemap + robots (Tasks 1, 4-9), accessibility basics via semantic landmarks/alt text/aria-current (Tasks 4-8), GitHub Pages via Actions from `site/` (Task 10), DNS cutover with MX protection (Task 11), Search Console + tinyurl + old hosting (Task 12). Success criteria all covered by Task 9 Step 3 and Task 11 Steps 6-7.
- Placeholders: none; every file's full content is in its create step.
- Consistency: class names in HTML match `styles.css`; `.copy-email` matches `copy-email.js`; image filenames in HTML match `prep-images.py` outputs; all five sitemap URLs match actual filenames.
