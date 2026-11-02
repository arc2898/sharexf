#!/usr/bin/env python3
"""Generate ShareXF's cross-platform application icons (requires Pillow)."""
from pathlib import Path
import struct
import sys
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else Path(__file__).resolve().parent
OUT.mkdir(parents=True, exist_ok=True)
S = 1024


def rounded_mask(box, radius):
    mask = Image.new('L', (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius=radius, fill=255)
    return mask


def make_icon(dark=False):
    # Warm biscuit-to-ivory field with restrained gold accents.
    top = (24, 22, 19) if dark else (229, 222, 207)
    bottom = (43, 39, 33) if dark else (248, 245, 237)
    base = Image.new('RGBA', (S, S))
    px = base.load()
    for y in range(S):
        t = y / (S - 1)
        c = tuple(round(top[i] * (1 - t) + bottom[i] * t) for i in range(3)) + (255,)
        for x in range(S): px[x, y] = c

    # Soft accent bloom behind the connecting devices.
    glow = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((260, 180, 850, 870), fill=(194, 158, 93, 72 if dark else 96))
    glow = glow.filter(ImageFilter.GaussianBlur(125))
    base = Image.alpha_composite(base, glow)

    # Two offset devices, both rendered as original geometric forms.
    shadow = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((174, 212, 575, 718), radius=66, fill=(0, 0, 0, 130))
    sd.rounded_rectangle((453, 315, 854, 821), radius=66, fill=(0, 0, 0, 145))
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    base = Image.alpha_composite(base, shadow)

    d = ImageDraw.Draw(base)
    pane_fill = (54, 49, 41, 238) if dark else (251, 249, 243, 244)
    pane_back = (37, 34, 29, 245) if dark else (236, 228, 213, 244)
    line1 = (205, 176, 119, 255)
    line2 = (244, 239, 228, 255) if dark else (67, 59, 47, 255)
    d.rounded_rectangle((174, 190, 575, 696), radius=66, fill=pane_back, outline=line1, width=12)
    d.rounded_rectangle((453, 288, 854, 794), radius=66, fill=pane_fill, outline=line2, width=12)

    # Device header bars.
    d.line((225, 278, 523, 278), fill=(231, 219, 194, 105) if dark else (198, 166, 107, 150), width=10)
    d.line((504, 377, 802, 377), fill=(231, 219, 194, 120) if dark else (198, 166, 107, 165), width=10)
    for x in (231, 266, 301):
        d.ellipse((x - 8, 232 - 8, x + 8, 232 + 8), fill=(199, 169, 112, 235))

    # Bidirectional link: a double-ended connector at the overlap.
    link = (49, 44, 36, 255) if dark else (83, 69, 47, 255)
    accent = (202, 170, 111, 255)
    d.rounded_rectangle((350, 477, 678, 553), radius=38, fill=accent)
    d.polygon([(350, 515), (418, 450), (418, 482), (482, 482), (482, 548), (418, 548), (418, 580)], fill=accent)
    d.polygon([(678, 515), (610, 450), (610, 482), (546, 482), (546, 548), (610, 548), (610, 580)], fill=accent)
    d.rounded_rectangle((412, 496, 616, 535), radius=18, fill=link)

    return base


def rounded_app(im):
    mask = rounded_mask((0, 0, S - 1, S - 1), 220)
    result = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    result.paste(im, (0, 0), mask)
    return result


def write_icns(image, path):
    # ICNS PNG chunks: 128, 256, 512 and 1024 pixel representations.
    tags = [(128, b'ic07'), (256, b'ic08'), (512, b'ic09'), (1024, b'ic10')]
    chunks = []
    for size, tag in tags:
        from io import BytesIO
        buf = BytesIO()
        image.resize((size, size), Image.Resampling.LANCZOS).save(buf, format='PNG')
        payload = buf.getvalue()
        chunks.append(tag + struct.pack('>I', len(payload) + 8) + payload)
    data = b''.join(chunks)
    path.write_bytes(b'icns' + struct.pack('>I', len(data) + 8) + data)


for suffix, dark in [('', False), ('-dark', True)]:
    art = rounded_app(make_icon(dark))
    art.save(OUT / f'sharexf{suffix}.png')
    art.save(OUT / f'sharexf{suffix}-mac.png')
    art.save(OUT / f'sharexf{suffix}.ico', format='ICO', sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    write_icns(art, OUT / f'sharexf{suffix}.icns')
    for n in (16, 32, 48, 64, 128, 256, 512):
        art.resize((n, n), Image.Resampling.LANCZOS).save(OUT / f'sharexf{suffix}-{n}.png')

print(f'Generated ShareXF icons in {OUT}')
