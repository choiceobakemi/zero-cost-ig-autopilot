# Getting images to Instagram (free)

**The problem:** Instagram's publishing API takes an `image_url`, and Meta's servers download the file from it. Postiz's local storage hands out `http://localhost:4007/uploads/...` links that only your Mac can open, so every Instagram post fails at publish time.

**The good news:** Postiz accepts *any* HTTPS URL as an attachment (unless you set `RESTRICT_UPLOAD_DOMAINS`), so you only need somewhere public to put the files.

## Option A: catbox.moe (what this repo uses)
Free, no account, permanent links, 200 MB per file.
```bash
./scripts/prepare-and-upload.sh slides/*.png
# → converts each to JPEG and prints one public URL per file (also saved to uploaded-urls.txt)
```
> ⚠️ Anything uploaded is **public to anyone with the link**, permanently. Only upload final, redacted, portfolio-ready images, the same ones that will be public on Instagram anyway.

## Option B: Tailscale Funnel (your own Mac as the host)
Free and gives you a stable `https://<machine>.<tailnet>.ts.net` URL that serves one folder. Great when it works, **but** it relays traffic through Tailscale's servers worldwide, and some networks or countries block them. Check before relying on it:
```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale netcheck
```
If most "DERP latency" lines are empty, Funnel won't be reachable from outside. Use Option A.

## Option C: Cloudflare R2 / S3
Postiz supports R2 natively (`STORAGE_PROVIDER: cloudflare`) and the free tier is generous, but Cloudflare asks for a payment method on file.

## Gotchas
- **JPEG only.** PNGs get rejected by Instagram's API, and Postiz doesn't convert them.
- **Test the link in a private browser window** before scheduling. If it doesn't load there, Meta can't load it either.
- **Videos (Reels):** MP4 (H.264 + AAC) works the same way. Keep files under the host's size limit; `ffmpeg` can compress them.
