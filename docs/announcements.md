# Announcements (in-app news)

The bell on Home shows an inbox. Besides an available app update, it lists
entries from **`ghpage/feed.json`**, which is published with the site like
`CHANGELOG.md` and `repositories.json`:

```
https://hemantkarya.github.io/BloomeeTunes/feed.json
```

Use it for news, your other apps, sign-up or pre-registration links, and
important notices. Nothing is tracked; links open in the browser or store.

## Publish in three steps

1. Add an entry at the **top** of `items` in `ghpage/feed.json` with
   `"draft": true`.
2. Preview it in the app (below), then remove `"draft": true`.
3. Deploy the site as usual: `python deploy_page.py`. The script refuses to
   deploy a feed that is not valid JSON, lacks an id or title, or repeats an
   id.

Installed apps check at most every 6 hours, only asking whether the file
changed, and keep the last good copy for offline use.

## Preview before publishing

```
flutter run --dart-define=BLOOMEE_FEED=ghpage/feed.json
```

The app then reads your local file. Drafts show, scheduling and dismissals
are ignored, and pulling down in the inbox reloads the file after each edit.
In any debug build the eye button in the inbox toggles the same preview for
the published feed.

## Entry format

Only `id` and `title` are required.

```json
{
  "id": "melodex-launch",
  "kind": "app",
  "title": { "en": "Meet Melodex", "hi": "मिलिए Melodex से" },
  "body": "Our new lyrics app. Free and open source.",
  "image": "https://hemantkarya.github.io/BloomeeTunes/assets/melodex.webp",
  "action": {
    "label": "Get it",
    "url": {
      "android": "https://play.google.com/store/apps/details?id=...",
      "store": "ms-windows-store://pdp/?productid=...",
      "default": "https://github.com/..."
    }
  },
  "home": true,
  "start": "2026-12-01",
  "end": "2027-01-15"
}
```

| Field | Meaning |
|---|---|
| `id` | Unique and never reused. Seen and dismissed state is kept per id. |
| `kind` | `announcement` (default), `app`, `form` (sign-up / survey), `notice` (important). Sets the icon and label. |
| `title`, `body` | Text, or text per language (`en`, `hi`, `pt-br`…). Falls back to the language, then English. |
| `image` | Optional `https` banner, shown at 2:1. |
| `action.label` | Button text; defaults to "Open". |
| `action.url` | One link, or links per `android` / `windows` / `linux` / `macos` / `ios`, `store` (Microsoft Store installs) and `default`. Only `https`, `ms-windows-store:`, `market:` and `mailto:` links are used. |
| `home` | Also show a small card on Home. |
| `urgent` | Listed first, highlighted, and kept on Home until closed, even if the user turned Home cards off. Use rarely. |
| `start`, `end` | Show from `start` until the end of `end` (UTC dates, or full ISO times). |
| `platforms` | Only these platforms, e.g. `["android"]`. |
| `store` | `true`: Store installs only. `false`: everyone except Store installs. |
| `minVersion`, `maxVersion` | App version range, e.g. `"3.1.0"`. |
| `draft` | Hidden from users; visible only in preview. |

## What users see

- **Inbox**: every live entry until the user dismisses it or it expires.
  New entries are counted on the bell and tagged "New" once.
- **Home card**: one at a time, only for `home` or `urgent` entries, taken
  in feed order. Closing it (or tapping its button) brings up the next
  unseen entry straight away, so each one is shown once. Entries already
  read in the inbox are skipped. A fresh install sees no card on its first
  day. Users can turn Home cards off in Settings → Updates & news.
- **Update dialog**: shown once per new version; afterwards the update
  stays in the inbox.
