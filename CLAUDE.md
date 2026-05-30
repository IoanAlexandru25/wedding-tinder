# Wedding Tinder

Flutter app for engaged couples to swipe through wedding vendors and build a
shared shortlist. University project — code quality is graded alongside
functionality.

## Stack

- **Flutter** (Dart 3.x), Material 3
- **Riverpod** (`flutter_riverpod`) — state management
- **go_router** — routing with auth-aware redirects
- **Firebase** — Auth (email/password), Firestore (users, weddings, favorites)
- **appinio_swiper** — swipe deck
- **google_fonts** — Cormorant Garamond (display) + Inter (UI)
- **phosphor_flutter** — thin-stroke editorial icons

Vendors are NOT in Firestore — they live in `assets/data/vendors.json` because
the catalog is static and we want to skip per-swipe reads.

## Setup

```bash
flutter pub get
flutter run
```

Firebase is not wired up in Phase 0. From Phase 2 onward you'll need to run
`flutterfire configure` and drop `firebase_options.dart` next to `main.dart`.

## Dev routes

- `/_dev/design` — design system showcase. Renders every color, typography
  style, widget, and the editorial composition rules. Open this first on a
  fresh install to verify the build.

## Where things live

```
lib/
  main.dart                — entry point, status-bar config, ProviderScope
  app.dart                 — MaterialApp.router with theme + router
  core/
    constants/             — categories, județe, shared Romanian strings
    theme/                 — colors, typography, spacing, radii, ThemeData
    widgets/               — reusable UI primitives (AppButton, AppCard, etc.)
    utils/                 — formatters, helpers (Phase 1+)
  models/                  — Vendor, Wedding, UserModel, Favorite (Phase 1)
  services/                — Firestore + asset access (Phase 1+)
  providers/               — Riverpod providers (Phase 1+)
  features/
    auth/                  — sign-in, sign-up, wedding setup (Phase 2)
    home/                  — category + filter UI (Phase 3)
    swipe/                 — swipe deck + vendor detail (Phase 4)
    favorites/             — shared shortlist (Phase 5)
    profile/               — wedding info, invite code (Phase 6)
    dev/                   — design showcase
  router/
    app_router.dart        — GoRouter configuration
```

## Conventions

- **Files** `snake_case.dart` · **Classes** `PascalCase` · **Providers** `camelCaseProvider`
- **Imports order** — dart → flutter → packages → relative
- **No magic values** — colors from `AppColors`, spacing from `AppSpacing`,
  radii from `AppRadii`, repeated strings from `AppStrings`
- **Widgets stay dumb** — they consume providers and render. No Firestore
  calls or business logic inside widgets.
- **Services don't touch UI** — they return data or throw exceptions.
  Providers translate exceptions into `AsyncValue` for the UI.
- **Romanian UI strings only** — with correct diacritics (ă, â, î, ș, ț).
  Code, comments, and docs stay in English.
- **`const` everywhere possible** — every constructor that can be const, is.
- **No raw hex codes** in `lib/` outside `app_colors.dart`.

## Editorial direction (read before building UI)

This app is intentionally NOT in the default "AI-generated app" aesthetic.
See `docs/ARCHITECTURE.md` for the full creative direction. TL;DR:

- Cormorant Garamond for display, mixed italic + regular in the same line
- Inter for UI text; uppercase tracked overlines for metadata
- Left-aligned, asymmetric, generous whitespace
- One bold color (wine `#7C2D3A`), lots of warm neutrals
- Full-bleed imagery on vendor cards, no rounded-everything
- Phosphor thin icons, never Material's filled defaults
- No gradients on buttons, no glassmorphism, no ripples
```
