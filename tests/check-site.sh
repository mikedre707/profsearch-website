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
  ck "$p no em dash" bash -c "! grep -q '—' '$p'"
  ck "$p never claims 35 years" bash -c "! grep -qi '35 year' '$p'"
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
