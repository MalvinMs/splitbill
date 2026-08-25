# SplitBill Supabase

The initial schema is in `migrations/20260825000000_initial_schema.sql`.

It creates the MVP tables, indexes, profile trigger, private membership helpers, RLS policies, the private `expense-receipts` Storage bucket, and the Realtime publication entries required by the PRD.

The repository does not currently include the Supabase CLI or a linked Supabase project. Apply this migration through the Supabase CLI or SQL editor after linking the project, then generate typed client definitions for the app.

## Auth redirect configuration

In Supabase Dashboard → Authentication → URL Configuration, configure the mobile callback:

- Site URL: `splitbill://auth/callback`
- Additional Redirect URLs: `splitbill://**`
- For the current Expo Go development server: `exp://127.0.0.1:8081/--/auth/callback`
- For changing Expo Go hosts, optionally add: `exp://**/--/auth/callback`

If the confirmation or reset email templates were customized, use `{{ .ConfirmationURL }}` for the link, or `{{ .RedirectTo }}` when the template constructs its own redirect. Do not use `{{ .SiteURL }}` for these mobile links.

The app deliberately avoids using a local web origin for auth emails. If a public web build is added later, set `EXPO_PUBLIC_AUTH_WEB_REDIRECT_URL` to its HTTPS callback and add that exact URL to the Supabase allow list.

Mobile callback links must be opened from the Android device/emulator email client. A desktop browser cannot open the installed Android app's `splitbill://` scheme.
