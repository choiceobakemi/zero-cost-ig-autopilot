#!/bin/zsh
# Removes the company-page scopes from Postiz's *personal* LinkedIn provider so it works with
# the two instant LinkedIn products (Share on LinkedIn + Sign In with OpenID Connect).
# Usage: ./scripts/patch-linkedin-scopes.sh /path/to/postiz-app
set -e
APP="${1:?usage: $0 /path/to/postiz-app}"; cd "$APP"
F=libraries/nestjs-libraries/src/integrations/social/linkedin.provider.js
mkdir -p patches
docker cp "postiz:/app/apps/backend/dist/$F" patches/linkedin.provider.js
cp patches/linkedin.provider.js patches/linkedin.provider.js.orig
python3 - <<'PY'
import re
p = 'patches/linkedin.provider.js'; s = open(p).read()
new, n = re.subn(r"\s*'(r_basicprofile|rw_organization_admin|w_organization_social|r_organization_social)',", "", s, count=4)
if n == 0: raise SystemExit("Scopes not found: Postiz may have changed this file. Nothing patched.")
open(p, 'w').write(new); print(f"removed {n} scopes")
PY
[ -f docker-compose.override.yaml ] || echo 'services:' > docker-compose.override.yaml
if ! grep -q linkedin.provider.js docker-compose.override.yaml; then
cat >> docker-compose.override.yaml <<YML

  postiz:
    volumes:
      - ./patches/linkedin.provider.js:/app/apps/backend/dist/$F:ro
      - ./patches/linkedin.provider.js:/app/apps/orchestrator/dist/$F:ro
YML
fi
docker-compose up -d postiz
echo "Done. Reconnect LinkedIn in Postiz. Undo: delete the two linkedin.provider.js lines in docker-compose.override.yaml."
