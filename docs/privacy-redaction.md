# Blurring private details automatically

Client designs (invitations, flyers) often contain phone numbers, bank or mobile-money accounts, RSVP form links, map links and QR codes. Before they go public, blur them.

`tools/detect.swift` uses Apple's built-in Vision framework (macOS only, free, offline) to find **every line of text and every QR code** in an image, including very tall "scrolling" invites, which it processes in overlapping tiles. `tools/redact.py` then blurs anything matching a "sensitive" pattern.

```bash
swiftc -O tools/detect.swift -o tools/detect     # once
python3 tools/redact.py page1.png page2.png --out redacted/
# optional: blur extra rectangles the detector missed (x0,y0,x1,y1 in pixels)
python3 tools/redact.py page3.png --out redacted/ --box 740,5210,1740,6190
```

What gets blurred by default: phone numbers (`+7…`, `+234…`, 7+ digit runs), URLs (`https://`, `forms.gle`, `maps`), banking keywords (bank names, "Euro", "Usd", "Airtel", "Opay"…) and every detected QR code. Edit `SENSITIVE` in `redact.py` for your region.

> ⚠️ OCR isn't perfect: stylised QR codes and decorative scripts can be missed. **Always look at the output** before posting, and use `--box` for anything that slipped through.
