# Connecting Instagram (Meta developer app)

Postiz has two Instagram connectors. Use **Instagram (Standalone)**: it uses "Instagram API with Instagram Login" and does **not** need a Facebook Page.

## 0. Make your Instagram account Professional
Instagram app → Settings → **Account type and tools → Switch to professional account** → choose **Creator** (or Business).
> ⚠️ Professional accounts can't be private. Switching makes the account public. Creator accounts get the full music library; Business accounts only get a royalty-free subset.

## 1. Create the app
1. Go to **developers.facebook.com** → **Get Started** (top right) and register as a developer. You need a Facebook account for this.
2. Open **https://developers.facebook.com/apps** ("My Apps") → **Create App**.
3. Use case: **Manage messaging & content on Instagram**. App type: **Business**.

> **Confusing bit:** if your left menu under *Instagram* only shows **"API setup with Facebook login"**, you picked a use case without Instagram Login. Make a new app with the use case above. In the new dashboard it's under **Use cases → Customize → (dropdown) Instagram API**.

## 2. Add the permissions Postiz asks for
**Use cases → Customize → Permissions and features**, then **+ Add** on all four:
- `instagram_business_basic`
- `instagram_business_content_publish` ← not in Meta's "required" list, but publishing fails without it
- `instagram_business_manage_comments`
- `instagram_business_manage_insights`

In Development mode, adding permissions needs **no app review**.

## 3. Redirect URI (this is where most setups break)
Left menu → **API setup with Instagram login** → step **"Set up Instagram business login"** → click the chevron to expand it → **OAuth redirect URIs**.

If your Postiz runs on plain `http://localhost` (the default), enter **exactly**:
```
https://redirectmeto.com/http://localhost:4007/integrations/social/instagram-standalone
```
Why: Meta only accepts HTTPS redirects. When `FRONTEND_URL` isn't HTTPS, Postiz automatically wraps it in `redirectmeto.com`, a free public redirector that bounces you back to localhost. (Change the port if yours isn't 4007.)

> The authorisation code passes through redirectmeto.com. It's useless without your app secret, but be aware a third party sits in that hop.

You can **skip** these sections on that page: *Generate access tokens*, *Configure webhooks* (they need a published app) and *App review*.

## 4. Add yourself as a tester
**App roles → Roles → Add People → Instagram Tester** → type your Instagram username (no `@`).

> **Confusing bit:** the invite shows as **Pending** and **no notification arrives**. Accept it manually on the **web**: log in to instagram.com as that account and open **https://www.instagram.com/accounts/manage_access/** → **Tester Invites** tab → **Accept**. The in-app menu often doesn't show it.
>
> You can't add yourself as "Developer" if you're the app's Administrator; that role already includes developer access. That error is harmless.

## 5. Give Postiz the credentials
At the top of the *API setup with Instagram login* page you'll see an **Instagram app ID** and **Instagram app secret** (click *Show*).
> ⚠️ These are **not** the main "App ID" at the top of the dashboard. Use the Instagram ones.

Add them to `postiz-app/docker-compose.yaml` under `postiz → environment` (the variables aren't in the upstream file):
```yaml
      INSTAGRAM_APP_ID: 'your-instagram-app-id'
      INSTAGRAM_APP_SECRET: 'your-instagram-app-secret'
```
```bash
docker-compose up -d postiz
```

## 6. Connect
Postiz → **Add Channel → Instagram (Standalone)** → approve. Done.

If it fails, the reason is in the URL Meta sends you back to (`error_description=...`). See [troubleshooting.md](troubleshooting.md).
