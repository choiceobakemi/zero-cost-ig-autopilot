# Zero-Cost Instagram Autopilot

Schedule Instagram (and LinkedIn) posts **for $0** using a self-hosted [Postiz](https://github.com/gitroomhq/postiz-app) on your own Mac, with Claude Code as the assistant that prepares the images, writes the captions and schedules the posts for you.

> Point Claude at a folder → describe what you want → it builds the carousel, writes the caption, uploads the media and schedules it. You approve every post before it goes out.

Everything here is free: no VPS, no paid scheduler, no paid storage. The trade-off is that your Mac has to be **on and awake** when a post is due (the scheduler runs on it).

---

## How it fits together

```
 Your files ──► Claude Code ──► slides (JPEG) ──► free public image host (catbox.moe)
                     │                                        │
                     │ (MCP)                                  │ image URLs
                     ▼                                        ▼
              Postiz on your Mac (Docker) ──── at post time ──► Instagram Graph API
              (Postgres · Redis · Temporal)                    (Meta downloads the images)
```

Why the public image host? Instagram doesn't accept uploaded bytes: Meta's servers **download each image from a URL**. Postiz stores uploads at `http://localhost/...`, which Meta can't reach. So the slides go to a public URL first. See [docs/media-hosting.md](docs/media-hosting.md).

## What you need

| | Cost | Notes |
|---|---|---|
| A Mac (Apple Silicon or Intel) | — | ~3 GB of RAM while running |
| [Homebrew](https://brew.sh) | free | |
| Colima + Docker CLI | free | replaces Docker Desktop, no admin password |
| Postiz (open source) | free | AGPL-3.0, runs in Docker |
| Instagram **Professional** account (Creator or Business) | free | personal accounts can't use the API |
| Meta developer app | free | stays in Development mode for your own account |
| LinkedIn developer app (optional) | free | needs a LinkedIn Page to create |
| Claude Code (optional, for the assistant part) | your subscription | everything else works without it |

**Not free (skip or pay):** X/Twitter API is pay-per-use since Feb 2026. Pinterest and Reddit need manual approval that can take weeks.

---

## Setup (about an hour, most of it in Meta's dashboard)

### 1. Docker without Docker Desktop
```bash
brew install colima docker docker-compose
colima start --cpu 4 --memory 6 --disk 40
```
> **Confusing bit:** Homebrew's Compose is a *plugin*, so `docker compose` (with a space) may say "unknown command". Use **`docker-compose`** (with a hyphen) everywhere below.

### 2. Postiz
```bash
git clone --depth 1 https://github.com/gitroomhq/postiz-app.git
cd postiz-app
# give it a real secret instead of the placeholder
sed -i '' "s|JWT_SECRET: '.*'|JWT_SECRET: '$(openssl rand -hex 32)'|" docker-compose.yaml
cp /path/to/zero-cost-ig-autopilot/templates/docker-compose.override.yaml .   # restart policies + leaner stack (see below)
docker-compose up -d
```
Open **http://localhost:4007** and create your account. The first start takes 1–3 minutes.

> **Why the override file?** Upstream gives the Temporal containers (the part that actually *fires scheduled posts*) no restart policy. After a reboot, Postiz comes back but Temporal doesn't, so scheduled posts silently never go out. The override adds `restart: always` and moves debug-only containers behind a `debug` profile to save RAM.

### 3. Start everything automatically at login
```bash
./scripts/install-autostart.sh
```
This installs a small login item that starts Colima, waits for Temporal, and restarts Postiz once if its API isn't answering (Postiz sometimes boots before Temporal is ready and doesn't recover on its own). Logs: `~/Library/Logs/postiz-start.log`.

> **Confusing bit:** macOS blocks background jobs from reading `~/Documents`, `~/Desktop` and iCloud folders. That's why the script is installed to `~/Library/Application Support/` and doesn't need your compose file at boot.

### 4. Connect your channels
- **Instagram:** [docs/instagram-meta-app.md](docs/instagram-meta-app.md). This is the longest step, with screenshots-in-words for every page of Meta's dashboard.
- **LinkedIn:** [docs/linkedin.md](docs/linkedin.md). It includes a fix for the `unauthorized_scope_error` everyone hits.

### 5. (Optional) Let Claude Code drive Postiz
In Postiz, go to **Settings → Developers** and copy your API key. Then, in your own terminal:
```bash
claude mcp add --scope user --transport http postiz http://localhost:4007/api/mcp \
  --header "Authorization: Bearer YOUR_API_KEY"
claude mcp list        # postiz should show ✔ Connected
```
> **Use `--scope user`, never `--scope project`.** Project scope writes the key into a `.mcp.json` in your folder, and it ends up in git.
>
> **Ignore the "Claude" connector inside Postiz's own UI.** It relays through Postiz Cloud and needs your instance on public HTTPS. The direct localhost connection above is free and private.

Workflow and example prompts: [docs/claude-workflow.md](docs/claude-workflow.md).

---

## Posting checklist (what actually trips people up)

1. **Images must be JPEG.** Instagram's API rejects PNG, and Postiz doesn't convert. `scripts/prepare-and-upload.sh` converts and uploads in one go.
2. **Carousels: 2–10 images**, all the same aspect ratio. Instagram crops every slide to the first one's shape. 1080×1350 (4:5) is the sweet spot.
3. **Max 5 hashtags** per post (Instagram's current limit).
4. **Music can't be added through the API to image carousels.** After it posts, open it → **⋯ → Edit → add audio**. Or, if a song matters, schedule that one in Instagram's own app instead (*Advanced settings → Schedule*).
5. **"Hide like count" isn't in the API either.** Open the post → **⋯ → Hide like count**.
6. **Your Mac must be awake** at post time. Set a reminder 2 minutes after each post to check it went live.

## Protecting people's privacy
Client work often contains phone numbers, bank/mobile-money details, RSVP links and QR codes. `tools/` has a macOS OCR + QR detector and a redaction script that blurs those automatically. See [docs/privacy-redaction.md](docs/privacy-redaction.md). **Always eyeball the result before posting.**

## Troubleshooting
[docs/troubleshooting.md](docs/troubleshooting.md) covers scope errors, 502s, posts not firing, Meta tester invites that "never arrive", Tailscale being blocked, and more.

## License
Scripts and docs in this repo: MIT (see `LICENSE`). Postiz itself is AGPL-3.0. The LinkedIn patch script modifies your *local* Postiz install and redistributes none of its code.
