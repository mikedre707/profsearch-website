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
