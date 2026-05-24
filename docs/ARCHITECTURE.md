# Architecture

## Folder structure & rationale

```
lib/
  core/        ← cross-cutting design system, constants, utilities
  models/      ← immutable data classes (Vendor, Wedding, UserModel, Favorite)
  services/    ← I/O boundary (Firestore, asset loading) — throws exceptions
  providers/   ← Riverpod providers — translate services into UI-friendly state
  features/    ← one folder per user-facing feature; screens + local widgets
  router/      ← GoRouter config + redirect logic
```

**Why feature folders, not type folders.** A feature folder contains the
screen + its tightly-coupled widgets. Cross-cutting widgets (used by 2+
features) graduate to `core/widgets/`. This keeps related code physically
together while preventing premature abstraction.

**Why a `core/` layer.** Design tokens, reusable widgets, shared constants —
everything that has no business knowledge. Feature code imports from `core/`;
`core/` never imports from features.

## State management — Riverpod

Provider taxonomy and when to use each:

| Type | When |
|---|---|
| `Provider` | Pure values / repositories with no async setup. |
| `FutureProvider` | One-shot async load (e.g., the vendor JSON catalog). |
| `StreamProvider` | Firestore stream subscriptions (auth state, wedding doc, favorites subcollection). |
| `StateProvider` | Trivial ephemeral UI state (selected category, filter values). |
| `NotifierProvider` / `AsyncNotifierProvider` | Stateful logic with methods — sign in, create wedding, like a vendor. |

**Naming.** All providers end with `Provider`. Family providers spell out the
parameter: `weddingByIdProvider(weddingId)`.

**Composition over inheritance.** Build derived state with `ref.watch(...)`
inside another provider rather than packing logic into one giant notifier.

## Data flow

### Vendor catalog (static)
```
assets/data/vendors.json
   ↓  (read once at app start)
VendorRepository  ← in services/, throws on parse error
   ↓
vendorsProvider (FutureProvider<List<Vendor>>)
   ↓
filteredVendorsProvider (Provider — watches vendors + filters)
   ↓
SwipeScreen
```

### Live wedding data (Firestore)
```
weddings/{weddingId}                         users/{uid}
        ↓ snapshots()                              ↓ snapshots()
WeddingService                              AuthService
        ↓                                          ↓
weddingProvider (StreamProvider<Wedding>)   authProvider (StreamProvider<User?>)
        ↓                                          ↓
                  HomeScreen / FavoritesScreen
```

### Favorites mutation
```
SwipeScreen (swipe right)
   ↓ ref.read(favoritesNotifierProvider.notifier).like(vendor)
FavoritesNotifier
   ↓ try { await weddingService.addFavorite(...) }
WeddingService.addFavorite          ← throws on Firestore failure
   ↓ writes to weddings/{wid}/favorites/{vendorId}
Firestore stream re-emits → favoritesProvider updates → FavoritesScreen rebuilds
```

The UI never calls Firestore directly. The UI never catches Firestore
exceptions directly. Services throw, providers wrap in `AsyncValue`, screens
render `.when(loading:, error:, data:)`.

## Error handling

1. **Services** throw typed exceptions (`AuthException`, `WeddingException`,
   `VendorLoadException`). They never return `null` for an error case.
2. **Providers** expose `AsyncValue<T>` so the UI gets `loading` / `error`
   / `data` for free. Mutating providers (notifiers) catch and:
   - Set `state = AsyncError(...)` so the screen can react, AND
   - Re-throw a user-facing message that the caller surfaces via SnackBar.
3. **UI** uses `AppErrorState` for full-screen errors and a themed SnackBar
   for transient ones. All user-facing messages are in Romanian and live
   either in `AppStrings` (if reused) or local to the feature.

## Naming conventions

- **Files** — `snake_case.dart`
- **Classes** — `PascalCase`; private classes use leading underscore.
- **Providers** — `camelCaseProvider` suffix. Family params explicit:
  `vendorByIdProvider(id)`.
- **Notifier classes** — `XxxNotifier` paired with `xxxProvider`.
- **Models** — noun, singular: `Vendor`, `Wedding`, `Favorite`.
- **Services** — `XxxService` for stateful APIs, `XxxRepository` for
  read-only data sources.

## The editorial design direction

Read this section before building any UI. The point is to NOT look like
every Lovable / v0 / AI-generated prototype.

**Avoid:**
- Gradient buttons (purple→pink, etc.)
- Glassmorphism / blurred surfaces everywhere
- 16px corner radius on absolutely everything
- Centered hero + emoji + CTA layouts
- Default Material 3 untouched
- Pastel-only, low-contrast palettes
- Material's filled icons used raw
- "Hello, {name}!" greeting headers
- Card-shaped cards with elevation 2 and rounded corners

**Embrace:**
- **Type as the star.** Cormorant Garamond at display sizes, *mix italic +
  regular in the same line.* Big jumps between display and body sizes —
  skip the middle.
- **Asymmetry.** Left-aligned, generous left padding, whitespace as a
  composition element. Photos can bleed to the right edge.
- **Restrained color.** One bold color (wine `#7C2D3A`), warm neutrals
  (`#FAF6F1`, `#F2EBE3`), brass (`#C9A961`) as a non-shiny accent.
- **Full-bleed imagery on the swipe card.** 3:4 portrait, photo to the
  edges, dark gradient at the bottom for legibility, vendor name in mixed
  italic + regular Cormorant.
- **Buttons:** solid, 14px radius (not 16, not full-pill), 52px tall, no
  shadows, no gradients, no Material ripple.
- **Icons:** Phosphor *thin* weight (1.5px stroke). Never the focal element.
- **Animations:** 280ms page fade + slight slide; 100ms scale 0.97 on tap;
  no ripples; staggered fade-in on lists capped at 6 items.
- **Section headers** have a 24×1 horizontal rule next to them in brass.

The visual reference is closer to a wedding-stationery brand or a boutique
hotel mobile site than a SaaS dashboard.

## Firestore schema (preview — built in Phase 2+)

```
users/{userId}
  email          string
  weddingId      string | null
  displayName    string | null
  createdAt      timestamp

weddings/{weddingId}
  inviteCode         string (indexed, unique, format WED-XXXX)
  partnerIds         array<string>  (max 2 user IDs)
  weddingDateStart   timestamp
  weddingDateEnd     timestamp
  guestCount         number
  budgetMin          number
  budgetMax          number
  createdAt          timestamp

  favorites/{vendorId}
    vendorId   string
    category   string
    addedBy    string (userId)
    addedAt    timestamp
```

Security rules: users read/write only their own `users/{uid}`; weddings are
readable/writable only by users whose UID is in `partnerIds`; favorites
inherit wedding permissions. Full rules file lives in `firestore.rules`
once Phase 2 lands.
