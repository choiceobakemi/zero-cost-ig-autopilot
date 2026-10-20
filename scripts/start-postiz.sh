#!/bin/zsh
# Starts Colima (every Postiz container has a restart policy, so Docker brings them back),
# then makes sure Postiz's backend comes up *after* Temporal. Safe to run by hand any time.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
echo "=== $(date) starting"

colima status >/dev/null 2>&1 || colima start || { echo "colima failed to start"; exit 1; }

# Optional: if you use Tailscale Funnel for media, make sure the app is running.
[ -d /Applications/Tailscale.app ] && open -g -a Tailscale

# Wait (up to 3 min) for Temporal on port 7233
for i in {1..36}; do nc -z localhost 7233 2>/dev/null && break; sleep 5; done
sleep 15

# The API answers 401 (not logged in) when the backend is up; otherwise restart Postiz once.
api_up() { [ "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:4007/api/user/self)" = "401" ]; }
for i in {1..12}; do api_up && { echo "postiz up"; exit 0; }; sleep 5; done
echo "backend not answering, restarting postiz"
docker restart postiz
for i in {1..36}; do api_up && { echo "postiz up after restart"; exit 0; }; sleep 5; done
echo "postiz still not answering"; exit 1
