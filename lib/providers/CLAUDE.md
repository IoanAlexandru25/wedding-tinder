# providers/

Riverpod providers — the bridge between services and UI.

## Provider taxonomy

| Type | When to use it |
|---|---|
| `Provider` | Pure values; the service instance itself (`authServiceProvider`). |
| `FutureProvider` | One-shot async load. The vendor catalog. |
| `StreamProvider` | Firestore streams: auth state, wedding doc, favorites. |
| `StateProvider` | Trivial UI state — selected category, filter values. |
| `NotifierProvider` / `AsyncNotifierProvider` | Stateful logic with methods — sign in/up, create wedding, like/unlike vendor. |

## Conventions

- All names end with `Provider`. Notifier classes are `XxxNotifier`.
- Family params are spelled out: `weddingByIdProvider(weddingId)`.
- Providers compose — derive state with `ref.watch(...)` inside another
  provider rather than packing logic into one giant notifier.
- Providers translate service exceptions into `AsyncError`. UI renders
  `.when(loading:, error:, data:)`.

## Per-provider responsibilities (target — built progressively)

- `authProvider` — `StreamProvider<User?>` from `FirebaseAuth.authStateChanges()`.
- `authControllerProvider` — `AsyncNotifierProvider<void>` with `signIn`,
  `signUp`, `signOut` methods.
- `currentUserDocProvider` — `StreamProvider<UserModel?>` for the
  `users/{uid}` doc.
- `weddingProvider` — `StreamProvider<Wedding?>` for the current user's
  wedding. Returns `null` if no wedding linked yet.
- `vendorsProvider` — `FutureProvider<List<Vendor>>` loading from JSON.
- `filtersProvider` — `StateProvider<VendorFilters>` (category, județ,
  price range, search query).
- `filteredVendorsProvider` — `Provider<List<Vendor>>` derived from vendors
  + filters + already-seen-in-session set.
- `favoritesProvider` — `StreamProvider<List<Favorite>>` from
  `weddings/{wid}/favorites`.
- `favoritesControllerProvider` — `AsyncNotifierProvider` with `like`,
  `unlike` methods.

## Don't

- Don't put Firestore code inside providers — call a service.
- Don't `ref.read(...)` reactive providers inside `build` — `ref.watch`.
- Don't create a provider for trivial widget-local state — use
  `StatefulWidget` or `useState` patterns instead.
