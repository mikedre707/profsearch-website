# Professional Search Website — Design Spec

Date: 2026-08-07
Owner: Michael Lazaro
Status: Approved pending Michael's review of this document

## Goal

Replace the placeholder page at profsearch.net with a real website for Professional Search, Michael's insurance staffing and recruiting agency. The site has two jobs:

1. Get employers with open insurance roles to call 415-246-7302 or email mike@profsearch.net.
2. Get candidates with relevant experience to email their resume to mike@profsearch.net.

## Decisions Made (with Michael, 2026-08-07)

| Question | Decision |
|----------|----------|
| Positioning | Insurance-first. Lead with insurance staffing; Legal, Healthcare, Finance, IT appear as a secondary "we also staff" section. |
| Audience balance | Both audiences, split paths. Two doors on the homepage: employers and job seekers. |
| Domain | profsearch.net. Email on the domain must keep working; MX records stay untouched. |
| Fees on site | Publish all terms: 15% of base salary, 90-day guarantee, free temp-to-perm conversion after 6 months. |
| Job listings | None. Evergreen content only. |
| Personal presence | Name Mike Lazaro as the recruiter, link his LinkedIn. No photo for now. |
| Years claim | "Over 30 years" / "30+ years". |
| Build approach | Hand-coded static HTML/CSS, hosted free on GitHub Pages under the mikedre707 account, custom domain profsearch.net. |
| Design direction | Approved mockup: option A's clean white layout combined with option C's heritage elements from the printed handout. |
| Contact mechanics | mailto links with prefilled subjects, email address always visible with a copy button, no forms, no third-party services. |
| Analytics | None. No cookies, no consent banner. |

## Verified Business Facts (source: Michael's handouts and About-us PDF)

Use these exactly. Do not invent claims beyond them.

- Family-owned staffing and recruiting agency, national reach, over 30 years in business.
- Specialty: insurance industry placements.
- Service types: Direct Hire, Temp-to-Hire, Contract/Temporary Assignment.
- Terms: 15% of base salary fee. 90-day guarantee on placements. Contract candidates convert to permanent at no cost after 6 months of employment.
- Insurance roles placed: all positions within claims departments; commercial lines and employee benefits account managers and account executives; producers/brokers; loss control; risk management.
- Legal roles: legal assistants, paralegals, attorneys.
- Healthcare roles: all lines of nursing, workers' compensation, nurse case managers, coding, auditing, pharmacy/PBM.
- Finance roles: all accounting and finance professionals, accounting managers, finance managers, staff accountants, junior accountants, chief financial officers.
- IT roles: software engineers.
- Contact: Mike Lazaro, mike@profsearch.net, 415-246-7302, linkedin.com/in/michael-lazaro-b891a011a.
- Owner-added placements (Michael, 2026-08-27): nurses, administrative professionals, sales executives, account managers, plus "and more" phrasing, approved for the homepage hero.

## Site Structure

Five pages, one shared stylesheet, shared header and footer.

1. **index.html — Home.** Hero with insurance-first headline, the two doors, terms highlights, industries strip, Let's Connect band.
2. **employers.html — For Employers.** Services (Direct Hire, Temp-to-Hire, Contract), published terms as a three-item feature row, insurance roles list, why a 30-year specialist beats a generalist agency, call/email CTAs.
3. **job-seekers.html — For Job Seekers.** Role types placed (insurance first, then the four other verticals), how working with Mike works (send resume, he matches you against employer relationships built over 30 years), resume CTA: email your resume as PDF or Word to mike@profsearch.net.
4. **about.html — About.** Family-owned story, over 30 years, national reach, insurance specialty, Mike Lazaro named as the recruiter clients and candidates work with, LinkedIn link.
5. **contact.html — Contact.** Email, phone, LinkedIn, both CTAs repeated, the Let's Connect circle as the visual anchor.

Header on every page: logo, nav links (Home, For Employers, For Job Seekers, About, Contact), phone number in orange. Footer on every page: contact details and copyright (owner accepted the shipped no-logo footer, 2026-08-07).

## Design System

Approved via browser mockup (A + C combined). The mockup file is preserved at `.superpowers/brainstorm/42014-1786120206/content/homepage-combined.html`.

- **Colors:** Navy `#1F2A44` (primary, headers, bands, footer), Orange `#F4924E` (accents, CTAs, rules, kickers), light section background `#F7F8FA`, white, body text gray `#5a6070`.
- **Typography:** Geometric sans matching the handout's feel. Self-hosted Poppins woff2 for headings (700/800 weights only, two small files), system sans stack for body text. No third-party font requests.
- **Logo:** Recreate the three-people outline mark as inline SVG (navy strokes), with "PROFESSIONAL SEARCH" in navy caps and "STAFFING & RECRUITING" in orange letterspaced caps beneath. Also derive a favicon and a square social-share image from it.
- **Signature elements from the handout:** full-width navy title band with white text and a 4px orange rule beneath it; the navy "Let's Connect!" circle with 4px orange ring used as the closing contact motif.
- **Imagery:** Photos extracted from Michael's handout PDFs, stored in `assets-src/`: magnifying-glass-over-paper-people banner (hero), insurance policy folders, legal gavel, healthcare team hands, finance desk, IT engineer. Compress to optimized JPEG (universal support, no fallback complexity), hero ≤ 150 KB. The "silver necklace" image from the Canva template is template residue; never use it. The cheering-group photo requires background cleanup before use; optional, not required for launch.
- **Layout:** Clean white base, generous spacing, outlined door cards (navy border for employers, orange for job seekers), responsive single-column collapse on mobile with the phone number tappable (`tel:` link).

## Homepage Content Flow (approved mockup)

1. Nav bar (white, slim).
2. Hero on `#F7F8FA`: orange kicker "INSURANCE STAFFING & RECRUITING", navy headline "The insurance talent partner with 30+ years of placements." (orange highlight on "30+ years"), subline naming family-owned, national, claims/broker/risk, and the three service types. Two buttons: "I'm hiring" (navy) and "I'm looking for work" (orange). Right side: hero photo.
3. Navy title band: "Staffing & Recruiting Expertise" + orange rule.
4. Two doors: FOR EMPLOYERS (roles + terms line + "Start a search" to employers.html), FOR JOB SEEKERS (pitch + "Email your resume" mailto CTA + link to job-seekers.html).
5. Industries strip: INSURANCE — OUR SPECIALTY (photo tile, wider) + LEGAL, HEALTHCARE, FINANCE, IT tiles.
6. Let's Connect band (navy): circle badge + email, phone, LinkedIn.
7. Footer.

## Contact Mechanics

- Resume CTA: `mailto:mike@profsearch.net` with URL-encoded subject `Resume Submission - Insurance Professional` (plain hyphen; em dashes break in some mail clients) and a short prefilled body prompting the sender to attach a resume (PDF or Word) and state the role type and location they want. Exact body wording is an implementation detail; keep it under 40 words. Job-seekers page repeats the address in plain text beside a copy-to-clipboard button (the one JavaScript behavior on the site).
- Employer CTA: `mailto:mike@profsearch.net?subject=Hiring%20Inquiry` plus prominent `tel:+14152467302` links.
- The email address and phone number appear as visible text in header/footer and on both door cards. No contact forms. No form services.

## Tech

- Static HTML5 + one CSS file. No framework, no build step. One small JS snippet for copy-to-clipboard (progressive enhancement; page works without it).
- Responsive breakpoints: single column under 720px; nav links wrap to a second row on small screens. No hamburger menu, no JS navigation.
- SEO: unique `<title>` and meta description per page targeting "insurance staffing agency", "insurance claims recruiter", "insurance recruiting" and related queries; Open Graph tags; JSON-LD `EmploymentAgency` block with name, phone, email, URL; `sitemap.xml`; `robots.txt`; canonical URLs on `https://profsearch.net`.
- Accessibility: semantic landmarks, alt text on photos, AA contrast (check orange-on-white button text; darken orange or use navy text if it fails), focus states.
- Performance: system-font fallbacks, compressed images, no external requests except optional self-hosted fonts. Target: loads fast on a phone.

## Hosting and Launch

1. Git repo in `/Users/michaellazaro/Desktop/Apps /ProfSearch-Website` (this repo), pushed to a new public GitHub repository under mikedre707 (public marketing content; public repos get GitHub Pages free).
2. GitHub Pages serves from the repo; site reviewable immediately at the github.io URL. Michael reviews on his phone before any DNS change.
3. Domain cutover, guided with Michael at the registrar for profsearch.net (registrar to be identified at launch; likely the same place hosting his email):
   - Add `CNAME` file (`profsearch.net`) to the repo.
   - At the registrar: A records for apex `profsearch.net` → GitHub Pages IPs (185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153), `www` CNAME → `mikedre707.github.io`.
   - Do not touch MX or mail-related records. mike@profsearch.net must keep working throughout. Record existing DNS values before changing anything.
   - Enable "Enforce HTTPS" in GitHub Pages once the certificate issues.
4. After launch, optional: repoint tinyurl.com/23r9w44e from the Canva site to profsearch.net (Michael's tinyurl account), and retire the Canva site.

## Out of Scope (v1)

- Job listings or any content requiring maintenance.
- Contact forms, applicant tracking, file upload.
- Analytics, cookies, consent banners.
- Blog, testimonials, client logos, Mike's photo (all possible later).
- The other four verticals getting their own pages (they live as sections on existing pages).

## Success Criteria

- Site live at https://profsearch.net with valid HTTPS; www redirects or resolves to the same site.
- mike@profsearch.net sends and receives normally after DNS changes.
- Every page renders correctly on a phone; Lighthouse mobile performance and accessibility both 90+.
- A candidate can go from landing on the homepage to a pre-addressed resume email in two taps.
- An employer can find the phone number without scrolling on any page.
- Google Search Console verified and sitemap submitted, so the site starts getting indexed.

## Open Items (not blockers)

- Identify the registrar and current DNS host for profsearch.net at launch time (Michael logs in; Claude guides).
- Whether to keep or cancel the old hosting that serves the placeholder page once DNS points at GitHub Pages.
- tinyurl repoint decision after launch.
