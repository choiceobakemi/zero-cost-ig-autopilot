"""Blur phone numbers, account numbers, links and QR codes in images before posting them publicly.

Requires the detector:  swiftc -O tools/detect.swift -o tools/detect   (macOS, uses Apple Vision)
Usage:  python3 tools/redact.py in1.png in2.png --out redacted/ [--box x0,y0,x1,y1 ...]
"""
import argparse, json, os, re, subprocess
from PIL import Image, ImageFilter

# Edit for your region: anything matching is blurred.
SENSITIVE = re.compile(
    r'(\+\s?\d[\d \-]{7,}'            # international phone numbers
    r'|\d{7,}'                        # long digit runs (accounts, phones)
    r'|https?:|www\.|forms\.gle|docs\.google|maps|yandex'   # links
    r'|Сбер|Sber|Tinkoff|Alpha|VTB|Airtel|Opay|Access|GTB|Guaranty|Euro|Pounds|Usd)',  # banking words
    re.I)
DETECT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'detect')


def blur(im, box):
    x0, y0, x1, y1 = [int(v) for v in box]
    x0, y0, x1, y1 = max(0, x0), max(0, y0), min(im.width, x1), min(im.height, y1)
    if x1 <= x0 or y1 <= y0: return
    reg = im.crop((x0, y0, x1, y1))
    small = reg.resize((max(1, (x1 - x0) // 28), max(1, (y1 - y0) // 28)), Image.BILINEAR).resize(reg.size, Image.BILINEAR)
    im.paste(small.filter(ImageFilter.GaussianBlur(max(6, (y1 - y0) // 10))), (x0, y0))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('images', nargs='+'); ap.add_argument('--out', default='redacted')
    ap.add_argument('--box', action='append', default=[], help='extra rectangle x0,y0,x1,y1 (applies to every image given)')
    a = ap.parse_args(); os.makedirs(a.out, exist_ok=True)
    for path in a.images:
        found = subprocess.run([DETECT, path], capture_output=True, text=True, check=True).stdout.splitlines()
        im = Image.open(path).convert('RGB'); n = 0
        for line in found:
            o = json.loads(line)
            if o['kind'] == 'qr' or SENSITIVE.search(o['text']):
                pad = 40 if o['kind'] == 'qr' else max(12, o['h'] // 3)
                blur(im, (o['x'] - pad, o['y'] - pad, o['x'] + o['w'] + pad, o['y'] + o['h'] + pad)); n += 1
        for b in a.box: blur(im, b.split(',')); n += 1
        out = os.path.join(a.out, os.path.basename(path)); im.save(out)
        print(f'{path}: blurred {n} region(s) -> {out}')


if __name__ == '__main__':
    main()
