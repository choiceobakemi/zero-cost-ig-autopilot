# Connecting LinkedIn (personal profile)

## 1. Create the app
1. **https://www.linkedin.com/developers/apps** → **Create app**. It must be linked to a **LinkedIn Page**, so create a free Company Page first if you have none.
2. **Products** tab → request **Share on LinkedIn** and **Sign In with LinkedIn using OpenID Connect** (both are granted instantly).
3. **Auth** tab → **Authorized redirect URLs** → add:
   ```
   http://localhost:4007/integrations/social/linkedin
   http://localhost:4007/integrations/social/linkedin-page
   ```
4. Copy the **Client ID** and **Primary Client Secret** into `docker-compose.yaml` (`LINKEDIN_CLIENT_ID`, `LINKEDIN_CLIENT_SECRET`), then run `docker-compose up -d postiz`.

## 2. The `unauthorized_scope_error` you will hit
Postiz requests company-page scopes (`w_organization_social`, `r_organization_social`, `rw_organization_admin`) and `r_basicprofile` **even for your personal profile**. LinkedIn only grants those through the *Community Management API*, which needs an approval application. So the connect fails with:
```
error=unauthorized_scope_error&error_description=Scope "w_organization_social" is not authorized for your application
```

**Fix:** trim the personal provider down to the scopes the instant products give you (`openid profile w_member_social`):
```bash
./scripts/patch-linkedin-scopes.sh /path/to/postiz-app
```
The script copies the compiled provider out of the running container, removes the four restricted scopes, and mounts the patched file back in via `docker-compose.override.yaml`, in both the backend and the orchestrator (which runs the scheduled posts). Your Postiz checkout and the image stay untouched.

- Only the plain **LinkedIn** channel works afterwards. **LinkedIn Page** still needs Community Management API approval.
- **Undo:** remove the two `linkedin.provider.js` volume lines from the override and run `docker-compose up -d postiz`.
- **After upgrading the Postiz image**, re-run the script, since the mounted file would be the old version's code.
