# Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `docker: unknown command: docker compose` | Homebrew installs Compose as a separate binary | Use `docker-compose` |
| Postiz loads but scheduled posts never go out after a reboot | Temporal containers have no restart policy upstream | Use `templates/docker-compose.override.yaml` and `scripts/install-autostart.sh` |
| `curl localhost:4007/api/...` gives 502 | Backend crashed because it started before Temporal | `docker restart postiz` (the autostart script does this for you) |
| Claude says the Postiz MCP failed with 502 | Same as above, or the container is restarting | Wait a minute and restart the Claude session |
| LinkedIn: `unauthorized_scope_error` | Postiz requests company-page scopes | `scripts/patch-linkedin-scopes.sh`, see [linkedin.md](linkedin.md) |
| Instagram connect fails right after Meta's consent screen | Redirect URI mismatch | Must be the exact `redirectmeto.com/http://localhost...` URL, see [instagram-meta-app.md](instagram-meta-app.md) §3 |
| Instagram tester invite "never arrives" | Instagram doesn't notify | Accept at instagram.com/accounts/manage_access → Tester Invites |
| Post fails at publish time with a media error | localhost image URL, or a PNG | Public URL plus JPEG, see [media-hosting.md](media-hosting.md) |
| Carousel slides look cropped | Slides have different aspect ratios | Make every slide the same size (1080×1350) |
| Tailscale Funnel URL never loads from outside | Network blocks Tailscale relays | Run `tailscale netcheck`; use catbox instead |
| `npx: command not found` | Node.js not installed | `brew install node` |
| A login item can't read your files | macOS privacy protection for Documents, Desktop and iCloud | Keep background scripts outside those folders |
| X/Twitter channel | API is pay-per-use since Feb 2026 | Skip it, or budget for it |
